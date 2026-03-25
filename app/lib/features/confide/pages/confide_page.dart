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
import '../services/response_service.dart';

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

  /// 随机移动动画控制器
  Timer? _randomMoveTimer;
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _responseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _scheduleNextMove();
  }

  @override
  void dispose() {
    _responseController.dispose();
    _randomMoveTimer?.cancel();
    super.dispose();
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
  void _handleSubmit(String input) {
    _randomMoveTimer?.cancel();
    
    // 获取响应结果（包含文本和情感类型）
    final responseResult = _responseService.getResponseWithEmotion(input);
    
    setState(() {
      _response = responseResult.text;
      _showResponse = true;
      _petState = _getPetStateFromEmotion(responseResult.emotion);
      _messageCount++;
    });
    _responseController.forward(from: 0);

    final petProvider = context.read<PetProvider>();
    petProvider.onConfide(
      content: input,
      actionType: 'confide',
      emotionType: responseResult.emotion.name,
    );

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
                  child: _buildContent(),
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
  }

  Widget _buildContent() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (_showResponse)
          Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: ResponseBubble(
              text: _response,
              animation: _responseController,
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
