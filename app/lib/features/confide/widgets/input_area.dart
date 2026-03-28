import 'package:flutter/material.dart';
import '../../../core/theme/theme.dart';
import '../../../core/services/app_strings.dart';
import '../../../shared/widgets/widgets.dart';

class InputArea extends StatefulWidget {
  final Function(String) onSubmit;

  const InputArea({super.key, required this.onSubmit});

  @override
  State<InputArea> createState() => _InputAreaState();
}

class _InputAreaState extends State<InputArea> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    if (_controller.text.trim().isNotEmpty) {
      widget.onSubmit(_controller.text.trim());
      _controller.clear();
      // 提交后重新获取焦点，方便用户继续输入
      _focusNode.requestFocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          AppStrings().confide.inputPlaceholder,
          style: AppTypography.labelSmall.copyWith(
            color: AppColors.confideInputBorder,
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
                  focusNode: _focusNode,
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.confideInputText,
                  ),
                  decoration: InputDecoration(
                    hintText: AppStrings().confide.inputHint,
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
