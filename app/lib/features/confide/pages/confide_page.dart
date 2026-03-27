import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/theme.dart';
import '../../../core/services/app_strings.dart';
import '../../../shared/widgets/widgets.dart';
import '../../pet/providers/pet_provider.dart';
import '../../pet/widgets/pet_interaction_bar.dart';
import '../../pet/widgets/pet_status_indicator.dart';
import '../widgets/pet_avatar.dart';
import '../widgets/response_bubble.dart';
import '../widgets/input_area.dart';
import '../widgets/ai_unlock_dialog.dart';
import '../services/response_service.dart';
import '../providers/confide_provider.dart';

class ConfidePage extends StatefulWidget {
  const ConfidePage({super.key});

  @override
  State<ConfidePage> createState() => _ConfidePageState();
}

class _ConfidePageState extends State<ConfidePage>
    with TickerProviderStateMixin {
  final _responseService = ResponseService();
  String _response = '';
  bool _showResponse = false;
  PetState _petState = PetState.idle;
  int _messageCount = 0;
  late AnimationController _responseController;
  
  /// 流式响应气泡的Key（用于访问State更新文本）
  final GlobalKey<ResponseBubbleState> _responseBubbleKey = GlobalKey<ResponseBubbleState>();

  /// 随机移动动画控制器
  Timer? _randomMoveTimer;
  final Random _random = Random();
  
  /// 倾诉Provider（从全局获取）
  ConfideProvider? _confideProvider;
  
  /// 是否已初始化
  bool _initialized = false;
  
  /// 是否已显示解锁弹窗
  bool _unlockDialogShown = false;

  @override
  void initState() {
    super.initState();
    
    _responseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _scheduleNextMove();
    
    // 延迟初始化，等待Provider准备就绪
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeConfide();
    });
  }

  @override
  void dispose() {
    _responseController.dispose();
    _randomMoveTimer?.cancel();
    // 不需要dispose _confideProvider，因为它是全局的
    super.dispose();
  }

  /// 初始化倾诉功能
  Future<void> _initializeConfide() async {
    if (_initialized) return;
    
    // 从全局获取ConfideProvider
    _confideProvider = context.read<ConfideProvider>();
    
    final petProvider = context.read<PetProvider>();
    
    // 获取用户ID（从petProvider或authProvider获取）
    final userId = petProvider.pet?.userId ?? 'default_user';
    
    // 初始化倾诉Provider（如果尚未初始化）
    await _confideProvider!.initialize(userId);
    
    // 检查是否需要显示解锁弹窗
    final bondLevel = petProvider.bondLevel;
    debugPrint('=== 解锁弹窗检查 ===');
    debugPrint('bondLevel: $bondLevel');
    debugPrint('shouldShowUnlockDialog: ${_confideProvider!.shouldShowUnlockDialog(bondLevel)}');
    debugPrint('_unlockDialogShown: $_unlockDialogShown');
    
    if (_confideProvider!.shouldShowUnlockDialog(bondLevel) && !_unlockDialogShown) {
      debugPrint('>>> 显示解锁弹窗');
      _unlockDialogShown = true;
      _showUnlockDialog();
    } else {
      debugPrint('>>> 不显示解锁弹窗');
    }
    
    _initialized = true;
  }

  /// 显示AI功能解锁弹窗
  Future<void> _showUnlockDialog() async {
    if (!mounted) return;
    
    final result = await AIUnlockDialog.show(context);
    
    // 标记已显示
    if (_confideProvider != null) {
      await _confideProvider!.markUnlockDialogShown();
    }
    
    // 如果用户选择去配置，导航已在弹窗中处理
    if (result == true && mounted) {
      // 用户已去配置，可以做一些后续处理
    }
  }

  /// 调度下一次随机移动动画（5-15秒间隔）
  void _scheduleNextMove() {
    final nextDelay = 5 + _random.nextInt(11);
    _randomMoveTimer?.cancel();
    _randomMoveTimer = Timer(Duration(seconds: nextDelay), () {
      if (mounted && _petState == PetState.idle && !_showResponse) {
        setState(() {
          _petState = PetState.move;
        });
      } else {
        _scheduleNextMove();
      }
    });
  }

  /// 移动动画完成回调
  void _onMoveAnimationComplete() {
    if (mounted && _petState == PetState.move) {
      setState(() {
        _petState = PetState.idle;
      });
      _scheduleNextMove();
    }
  }

  /// 根据情感类型获取宠物状态
  PetState _getPetStateFromEmotion(EmotionType emotion) {
    switch (emotion) {
      case EmotionType.positive:
        return PetState.happy;
      case EmotionType.negative:
        return PetState.angry;
      default:
        return PetState.idle;
    }
  }

  /// 处理用户倾诉提交
  Future<void> _handleSubmit(String input) async {
    _randomMoveTimer?.cancel();
    
    final petProvider = context.read<PetProvider>();
    
    // 记录倾诉行为
    petProvider.onConfide(
      content: input,
      actionType: 'confide',
      emotionType: 'neutral',
    );

    // 判断是否使用AI对话服务
    if (_confideProvider != null && _confideProvider!.isAIEnabled) {
      // 使用AI生成回复
      setState(() {
        _showResponse = true;
        _petState = PetState.idle;
        _messageCount++;
        _response = ''; // 清空之前的响应
      });
      
      // 重置响应气泡
      _responseBubbleKey.currentState?.reset();
      _responseController.forward(from: 0);
      
      try {
        // 设置流式响应回调
        final chatService = _confideProvider!.chatService;
        chatService?.onStreamResponse = (chunk, isDone) {
          if (mounted) {
            setState(() {
              _response += chunk;
            });
            // 直接更新气泡内容
            _responseBubbleKey.currentState?.updateText(_response, isDone: isDone);
          }
        };
        
        final result = await _confideProvider!.sendMessage(
          userId: petProvider.pet?.userId ?? 'default_user',
          message: input,
          bondTitle: petProvider.bondTitle,
          emotionDescription: '平静、温和',
        );
        
        if (mounted) {
          setState(() {
            _response = result.content;
            // 如果Token不足，可以显示特殊提示
            if (result.isTokenExhausted) {
              _petState = PetState.angry;
            }
          });
          // 最终更新气泡内容
          _responseBubbleKey.currentState?.updateText(_response, isDone: true);
        }
      } catch (e) {
        // AI调用失败，显示错误提示
        debugPrint('AI对话失败: $e');
        if (mounted) {
          setState(() {
            _response = '咕...网络好像有点问题，稍后再试试吧~';
          });
          _responseBubbleKey.currentState?.updateText(_response, isDone: true);
        }
      }
    } else {
      // 使用本地模板生成回复（简单倾诉模式）
      final responseResult = _responseService.getResponseWithEmotion(input);
      
      setState(() {
        _response = responseResult.text;
        _showResponse = true;
        _petState = _getPetStateFromEmotion(responseResult.emotion);
        _messageCount++;
      });
      _responseController.forward(from: 0);
      
      // 使用原有的PetProvider生成回复
      petProvider.generateResponse(
        scene: 'confide',
        userMessage: input,
      ).then((petResponse) {
        if (mounted && petResponse.isNotEmpty) {
          setState(() {
            _response = petResponse;
          });
        }
      });
    }

    Future.delayed(const Duration(milliseconds: 5500), () {
      if (mounted) {
        setState(() {
          _showResponse = false;
          _petState = PetState.idle;
        });
        _scheduleNextMove();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // 使用Consumer监听ConfideProvider变化
    return Consumer<ConfideProvider>(
      builder: (context, confideProvider, child) {
        _confideProvider = confideProvider;
        
        return Container(
          decoration: const BoxDecoration(gradient: AppColors.confideBackground),
          child: Stack(
            children: [
              ..._buildStars(),
              SafeArea(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                      child: PetStatusIndicator(),
                    ),
                    Expanded(
                      child: _buildContent(confideProvider),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                      child: InputArea(onSubmit: _handleSubmit),
                    ),
                  ],
                ),
              ),
              Positioned(
                right: 12,
                top: MediaQuery.of(context).size.height * 0.30,
                child: const PetInteractionBar(),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildContent(ConfideProvider confideProvider) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (_showResponse)
          Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: ResponseBubble(
              key: _responseBubbleKey,
              text: _response,
              animation: _responseController,
              enableStreaming: confideProvider.isAIEnabled,
            ),
          ),
        PetAvatar(
          state: _petState,
          onTap: _onPetTap,
          onAnimationComplete: _petState == PetState.move 
              ? _onMoveAnimationComplete 
              : null,
        ),
        const SizedBox(height: 16),
        if (!_showResponse && _petState != PetState.teasing && _petState != PetState.move)
          Column(
            children: [
              Text(
                _messageCount == 0
                    ? AppStrings().confide.waitingHint
                    : AppStrings().getStringWithParams(
                        AppStrings().confide.messageCountHint,
                        {'count': _messageCount.toString()}
                      ),
                style: AppTypography.caption.copyWith(
                  color: const Color(0xFFBBB0D0),
                ),
              ),
              // 显示AI状态指示
              if (confideProvider.isAIEnabled)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.auto_awesome,
                        size: 14,
                        color: AppColors.indigo500.withValues(alpha: 0.7),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'AI智能对话中',
                        style: AppTypography.caption.copyWith(
                          color: AppColors.indigo500.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
      ],
    );
  }

  /// 点击宠物触发搞怪动作
  void _onPetTap() {
    if (_showResponse || _petState == PetState.move) return;
    
    _randomMoveTimer?.cancel();
    
    setState(() {
      _petState = PetState.teasing;
      _response = AppStrings().confide.petTickle;
      _showResponse = true;
    });
    _responseController.forward(from: 0);

    final petProvider = context.read<PetProvider>();
    petProvider.onConfide(
      content: AppStrings().confide.petInteraction,
      actionType: 'touchPet',
      emotionType: 'positive',
    );

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _petState = PetState.idle;
          _showResponse = false;
        });
        _scheduleNextMove();
      }
    });
  }

  List<Widget> _buildStars() {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    return [
      AnimatedStar(left: 0.12 * width, top: 0.08 * height, delay: Duration.zero),
      AnimatedStar(left: 0.82 * width, top: 0.06 * height, delay: const Duration(milliseconds: 500)),
      AnimatedStar(left: 0.88 * width, top: 0.18 * height, delay: const Duration(seconds: 1)),
      AnimatedStar(left: 0.08 * width, top: 0.22 * height, delay: const Duration(milliseconds: 1500)),
      AnimatedStar(left: 0.92 * width, top: 0.30 * height, delay: const Duration(milliseconds: 800)),
      AnimatedStar(left: 0.05 * width, top: 0.35 * height, delay: const Duration(milliseconds: 1200)),
    ];
  }
}
