import 'package:flutter/material.dart';
import '../data/models/error_record.dart';
import 'feedback_form_page.dart';

/// 错误对话框
/// 当应用捕获到错误时显示，允许用户查看错误详情并提交反馈
class ErrorDialog extends StatelessWidget {
  /// 错误记录
  final ErrorRecord errorRecord;

  const ErrorDialog({
    super.key,
    required this.errorRecord,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.error_outline, color: Colors.red[400]),
          const SizedBox(width: 8),
          const Text('发生错误'),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '很抱歉，应用遇到了一个错误。您可以选择提交反馈帮助我们改进。',
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 16),
            _buildErrorInfo(),
            if (errorRecord.hasStackTrace) ...[
              const SizedBox(height: 12),
              _buildStackTraceSection(),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('关闭'),
        ),
        ElevatedButton.icon(
          onPressed: () {
            Navigator.of(context).pop();
            _openFeedbackForm(context);
          },
          icon: const Icon(Icons.feedback, size: 18),
          label: const Text('提交反馈'),
        ),
      ],
    );
  }

  /// 构建错误信息
  Widget _buildErrorInfo() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                _getTypeIcon(errorRecord.type),
                size: 16,
                color: Colors.grey[600],
              ),
              const SizedBox(width: 4),
              Text(
                errorRecord.typeDisplayName,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[700],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            errorRecord.truncatedMessage,
            style: const TextStyle(fontSize: 14),
          ),
          const SizedBox(height: 4),
          Text(
            '时间: ${_formatTime(errorRecord.timestamp)}',
            style: TextStyle(fontSize: 12, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  /// 构建堆栈跟踪区域
  Widget _buildStackTraceSection() {
    return ExpansionTile(
      title: const Text('堆栈跟踪'),
      tilePadding: EdgeInsets.zero,
      children: [
        Container(
          height: 150,
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(8),
          ),
          child: SingleChildScrollView(
            child: Text(
              errorRecord.stackTrace ?? '',
              style: const TextStyle(
                fontFamily: 'monospace',
                fontSize: 11,
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// 打开反馈表单
  void _openFeedbackForm(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => FeedbackFormPage(
          errorData: {
            'type': errorRecord.type.name,
            'message': errorRecord.message,
            'stackTrace': errorRecord.stackTrace,
            'timestamp': errorRecord.timestamp.toIso8601String(),
          },
        ),
      ),
    );
  }

  /// 获取类型图标
  IconData _getTypeIcon(ErrorType type) {
    switch (type) {
      case ErrorType.flutter:
        return Icons.flutter_dash;
      case ErrorType.dart:
        return Icons.code;
      case ErrorType.network:
        return Icons.wifi_off;
      case ErrorType.custom:
        return Icons.error;
    }
  }

  /// 格式化时间
  String _formatTime(DateTime time) {
    return '${time.year}-${time.month.toString().padLeft(2, '0')}-${time.day.toString().padLeft(2, '0')} '
        '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  /// 显示错误对话框的静态方法
  static Future<void> show(BuildContext context, ErrorRecord error) {
    return showDialog(
      context: context,
      builder: (context) => ErrorDialog(errorRecord: error),
    );
  }
}
