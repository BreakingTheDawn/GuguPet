import 'package:flutter/material.dart';
import '../../../core/theme/theme.dart';
import '../../../shared/widgets/widgets.dart';
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

  void _handleSubmit(String input) {
    setState(() {
      _response = _responseService.getResponse(input);
      _showResponse = true;
      _petState = PetState.happy;
      _messageCount++;
    });
    _responseController.forward(from: 0);

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
                _buildHeader(),
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
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 40, 24, 8),
      child: Center(
        child: Text(
          '职宠小窝',
          style: AppTypography.labelSmall.copyWith(
            color: AppColors.mutedForeground,
            letterSpacing: 0.2,
          ),
        ),
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
        Stack(
          clipBehavior: Clip.none,
          children: [
            PetAvatar(state: _petState),
            Positioned(
              right: -18,
              top: 28,
              child: _buildSideBubble(),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (!_showResponse)
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

  Widget _buildSideBubble() {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.75),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.95), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6450C8).withOpacity(0.15),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Center(
        child: Text(
          _petState == PetState.happy ? '🥰' : '🫂',
          style: const TextStyle(fontSize: 20),
        ),
      ),
    );
  }

  List<Widget> _buildStars() {
    return const [
      AnimatedStar(left: 0.12, top: 0.08, delay: Duration.zero),
      AnimatedStar(left: 0.82, top: 0.06, delay: Duration(milliseconds: 500)),
      AnimatedStar(left: 0.88, top: 0.18, delay: Duration(seconds: 1)),
      AnimatedStar(left: 0.08, top: 0.22, delay: Duration(milliseconds: 1500)),
      AnimatedStar(left: 0.92, top: 0.30, delay: Duration(milliseconds: 800)),
      AnimatedStar(left: 0.05, top: 0.35, delay: Duration(milliseconds: 1200)),
    ].map((star) {
      return Positioned(
        left: star.left * MediaQuery.of(context).size.width,
        top: star.top * MediaQuery.of(context).size.height,
        child: AnimatedStar(
          left: 0,
          top: 0,
          delay: star.delay,
        ),
      );
    }).toList();
  }
}
