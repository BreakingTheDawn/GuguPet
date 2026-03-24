import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/theme.dart';
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

  @override
  void initState() {
    super.initState();
    _responseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
  }

  @override
  void dispose() {
    _responseController.dispose();
    super.dispose();
  }

  /// 处理用户倾诉提交
  /// 同时更新宠物情感状态和羁绊值
  void _handleSubmit(String input) {
    setState(() {
      _response = _responseService.getResponse(input);
      _showResponse = true;
      _petState = PetState.happy;
      _messageCount++;
    });
    _responseController.forward(from: 0);

    // 调用 PetProvider 记录倾诉互动
    final petProvider = context.read<PetProvider>();
    petProvider.onConfide(
      content: input,
      actionType: 'confide',
      emotionType: 'positive',
    );

    // 生成宠物个性化回复
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
                // 宠物状态指示器（上移，透明背景）
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
          // 侧边互动栏
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
        // 宠物话语气泡（统一位置显示）
        if (_showResponse)
          Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: ResponseBubble(
              text: _response,
              animation: _responseController,
            ),
          ),
        // 宠物可点击区域
        PetAvatar(
          state: _petState,
          onTap: _onPetTap,
        ),
        const SizedBox(height: 16),
        if (!_showResponse && _petState != PetState.teasing)
          Text(
            _messageCount == 0
                ? '咕咕在等你倾诉...'
                : '已倾诉 $_messageCount 次，咕咕一直在 ♡',
            style: AppTypography.caption.copyWith(
              color: const Color(0xFFBBB0D0),
            ),
          ),
      ],
    );
  }

  /// 点击宠物触发搞怪动作
  void _onPetTap() {
    // 如果正在显示回复，不处理点击
    if (_showResponse) return;
    
    // 触发搞怪动画
    setState(() {
      _petState = PetState.teasing;
      _response = '嘻嘻~好痒！';
      _showResponse = true;
    });
    _responseController.forward(from: 0);

    // 调用状态机记录互动
    final petProvider = context.read<PetProvider>();
    petProvider.onConfide(
      content: '点击宠物互动',
      actionType: 'touchPet',
      emotionType: 'positive',
    );

    // 2秒后恢复idle状态
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _petState = PetState.idle;
          _showResponse = false;
        });
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
