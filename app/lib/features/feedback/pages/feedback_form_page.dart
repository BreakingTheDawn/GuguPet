import 'package:flutter/material.dart';
import '../data/models/user_feedback.dart';

/// 反馈表单页面
class FeedbackFormPage extends StatefulWidget {
  /// 预设的错误数据（从错误捕获服务传入）
  final Map<String, dynamic>? errorData;

  const FeedbackFormPage({super.key, this.errorData});

  @override
  State<FeedbackFormPage> createState() => _FeedbackFormPageState();
}

class _FeedbackFormPageState extends State<FeedbackFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();

  FeedbackType _selectedType = FeedbackType.bug;
  int _rating = 0;
  bool _includeDeviceInfo = true;
  bool _includeErrorLog = true;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    // 如果有错误数据，自动填充
    if (widget.errorData != null) {
      _titleController.text = '错误报告: ${widget.errorData!['message'] ?? '未知错误'}';
      _contentController.text = '错误详情:\n${widget.errorData!['stackTrace'] ?? ''}';
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  /// 提交反馈
  Future<void> _submitFeedback() async {
    if (!_formKey.currentState!.validate()) return;
    if (_rating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请选择评分')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      // TODO: 通过Provider调用FeedbackService
      await Future.delayed(const Duration(seconds: 1)); // 模拟网络请求

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('反馈提交成功，感谢您的反馈！')),
        );
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('提交失败: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('意见反馈'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 反馈类型选择
              _buildTypeSelector(),
              const SizedBox(height: 16),

              // 标题输入
              _buildTitleField(),
              const SizedBox(height: 16),

              // 内容输入
              _buildContentField(),
              const SizedBox(height: 16),

              // 评分选择
              _buildRatingSelector(),
              const SizedBox(height: 16),

              // 附加选项
              _buildAdditionalOptions(),
              const SizedBox(height: 24),

              // 提交按钮
              _buildSubmitButton(),
            ],
          ),
        ),
      ),
    );
  }

  /// 构建反馈类型选择器
  Widget _buildTypeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '反馈类型',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: FeedbackType.values.map((type) {
            final isSelected = _selectedType == type;
            return ChoiceChip(
              label: Text(_getTypeLabel(type)),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) {
                  setState(() => _selectedType = type);
                }
              },
              selectedColor: Theme.of(context).primaryColor.withValues(alpha: 0.2),
            );
          }).toList(),
        ),
      ],
    );
  }

  /// 构建标题输入框
  Widget _buildTitleField() {
    return TextFormField(
      controller: _titleController,
      decoration: const InputDecoration(
        labelText: '标题',
        hintText: '请输入反馈标题',
        border: OutlineInputBorder(),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return '请输入标题';
        }
        if (value.length > 50) {
          return '标题不能超过50个字符';
        }
        return null;
      },
    );
  }

  /// 构建内容输入框
  Widget _buildContentField() {
    return TextFormField(
      controller: _contentController,
      decoration: const InputDecoration(
        labelText: '详细描述',
        hintText: '请详细描述您的问题或建议',
        border: OutlineInputBorder(),
        alignLabelWithHint: true,
      ),
      maxLines: 6,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return '请输入详细描述';
        }
        if (value.length > 1000) {
          return '描述不能超过1000个字符';
        }
        return null;
      },
    );
  }

  /// 构建评分选择器
  Widget _buildRatingSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '评分',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Row(
          children: List.generate(5, (index) {
            return IconButton(
              icon: Icon(
                index < _rating ? Icons.star : Icons.star_border,
                color: Colors.amber,
                size: 32,
              ),
              onPressed: () {
                setState(() => _rating = index + 1);
              },
            );
          }),
        ),
        if (_rating > 0)
          Text(
            _getRatingText(_rating),
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
      ],
    );
  }

  /// 构建附加选项
  Widget _buildAdditionalOptions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '附加信息',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        CheckboxListTile(
          title: const Text('包含设备信息'),
          subtitle: const Text('帮助我们更好地定位问题'),
          value: _includeDeviceInfo,
          onChanged: (value) {
            setState(() => _includeDeviceInfo = value ?? true);
          },
          contentPadding: EdgeInsets.zero,
        ),
        CheckboxListTile(
          title: const Text('包含错误日志'),
          subtitle: const Text('上传最近的错误日志'),
          value: _includeErrorLog,
          onChanged: (value) {
            setState(() => _includeErrorLog = value ?? true);
          },
          contentPadding: EdgeInsets.zero,
        ),
      ],
    );
  }

  /// 构建提交按钮
  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: _isSubmitting ? null : _submitFeedback,
        child: _isSubmitting
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Text('提交反馈'),
      ),
    );
  }

  /// 获取类型标签
  String _getTypeLabel(FeedbackType type) {
    switch (type) {
      case FeedbackType.bug:
        return 'Bug报告';
      case FeedbackType.suggestion:
        return '功能建议';
      case FeedbackType.complaint:
        return '投诉';
      case FeedbackType.praise:
        return '表扬';
      case FeedbackType.other:
        return '其他';
    }
  }

  /// 获取评分文本
  String _getRatingText(int rating) {
    switch (rating) {
      case 1:
        return '非常不满意';
      case 2:
        return '不满意';
      case 3:
        return '一般';
      case 4:
        return '满意';
      case 5:
        return '非常满意';
      default:
        return '';
    }
  }
}
