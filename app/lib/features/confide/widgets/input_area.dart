import 'package:flutter/material.dart';
import '../../../core/theme/theme.dart';
import '../../../shared/widgets/widgets.dart';

class InputArea extends StatefulWidget {
  final Function(String) onSubmit;

  const InputArea({super.key, required this.onSubmit});

  @override
  State<InputArea> createState() => _InputAreaState();
}

class _InputAreaState extends State<InputArea> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    if (_controller.text.trim().isNotEmpty) {
      widget.onSubmit(_controller.text.trim());
      _controller.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          '此刻想对咕咕说点什么？',
          style: AppTypography.labelSmall.copyWith(
            color: const Color(0xFFB8B0D0),
            letterSpacing: 0.05,
          ),
        ),
        const SizedBox(height: 8),
        GlassContainer(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          borderRadius: BorderRadius.circular(AppSpacing.radius3xl),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  style: AppTypography.bodyMedium.copyWith(
                    color: const Color(0xFF5A5A7A),
                  ),
                  decoration: InputDecoration(
                    hintText: '今天又投了5份简历，有点累了...',
                    hintStyle: AppTypography.bodyMedium.copyWith(
                      color: AppColors.mutedForeground,
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                  ),
                  onSubmitted: (_) => _handleSubmit(),
                ),
              ),
              ValueListenableBuilder<TextEditingValue>(
                valueListenable: _controller,
                builder: (context, value, child) {
                  if (value.text.trim().isEmpty) return const SizedBox.shrink();
                  return GestureDetector(
                    onTap: _handleSubmit,
                    child: const Text('🕊️', style: TextStyle(fontSize: 20)),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}
