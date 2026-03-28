import 'package:flutter/material.dart';
import '../data/models/models.dart';
import '../services/wish_envelope_service.dart';
import '../../../data/datasources/local/database_helper.dart';

// ═══════════════════════════════════════════════════════════════════════════════
/// 创建信封页面
/// 上岸用户创建鼓励信封
// ═══════════════════════════════════════════════════════════════════════════════
class CreateEnvelopePage extends StatefulWidget {
  /// 创建者ID
  final String creatorId;
  
  /// 创建者昵称
  final String creatorName;
  
  /// 创建者职位（已上岸的公司/职位）
  final String? creatorTitle;
  
  /// 创建完成回调
  final VoidCallback? onCreated;

  const CreateEnvelopePage({
    super.key,
    required this.creatorId,
    required this.creatorName,
    this.creatorTitle,
    this.onCreated,
  });

  @override
  State<CreateEnvelopePage> createState() => _CreateEnvelopePageState();
}

class _CreateEnvelopePageState extends State<CreateEnvelopePage> {
  // ────────────────────────────────────────────────────────────────────────────
  // 私有属性
  // ────────────────────────────────────────────────────────────────────────────

  /// 标题控制器
  final _titleController = TextEditingController();
  
  /// 内容控制器
  final _contentController = TextEditingController();
  
  /// 选中的信封类型
  EnvelopeType _selectedType = EnvelopeType.encouragement;
  
  /// 是否公开
  bool _isPublic = true;
  
  /// 是否正在提交
  bool _isSubmitting = false;
  
  /// 信封服务
  late final WishEnvelopeService _envelopeService;

  // ────────────────────────────────────────────────────────────────────────────
  // 生命周期方法
  // ────────────────────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _initService();
  }

  Future<void> _initService() async {
    final db = await DatabaseHelper().database;
    _envelopeService = WishEnvelopeService(database: db);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  // ────────────────────────────────────────────────────────────────────────────
  // 构建方法
  // ────────────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('创建鼓励信封'),
        actions: [
          TextButton(
            onPressed: _isSubmitting ? null : _submitEnvelope,
            child: _isSubmitting
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('发布'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 类型选择
            _buildTypeSelector(),
            
            const SizedBox(height: 24),
            
            // 标题输入
            _buildTitleInput(),
            
            const SizedBox(height: 16),
            
            // 内容输入
            _buildContentInput(),
            
            const SizedBox(height: 24),
            
            // 公开设置
            _buildPublicSwitch(),
            
            const SizedBox(height: 24),
            
            // 提示信息
            _buildTips(),
          ],
        ),
      ),
    );
  }

  /// 构建类型选择器
  Widget _buildTypeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '信封类型',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: EnvelopeType.values.map((type) {
            final isSelected = _selectedType == type;
            return Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _selectedType = type),
                child: Container(
                  margin: EdgeInsets.only(
                    right: type != EnvelopeType.values.last ? 8 : 0,
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? _getTypeColor(type).withValues(alpha: 0.1)
                        : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected ? _getTypeColor(type) : Colors.transparent,
                      width: 2,
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        _getTypeIcon(type),
                        style: const TextStyle(fontSize: 24),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _getTypeName(type),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          color: isSelected ? _getTypeColor(type) : Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  /// 构建标题输入
  Widget _buildTitleInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '信封标题',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _titleController,
          maxLength: 50,
          decoration: InputDecoration(
            hintText: '给信封起个温暖的名字',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
        ),
      ],
    );
  }

  /// 构建内容输入
  Widget _buildContentInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '信封内容',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _contentController,
          maxLines: 8,
          maxLength: 500,
          decoration: InputDecoration(
            hintText: '写下你想对求职者说的话...',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            contentPadding: const EdgeInsets.all(16),
          ),
        ),
      ],
    );
  }

  /// 构建公开开关
  Widget _buildPublicSwitch() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.public, size: 20),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '公开信封',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  '公开后其他用户可以在许愿树看到',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: _isPublic,
            onChanged: (value) => setState(() => _isPublic = value),
          ),
        ],
      ),
    );
  }

  /// 构建提示信息
  Widget _buildTips() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline, size: 20, color: Colors.blue.shade400),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '温馨提示',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Colors.blue.shade700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '你创建的鼓励信封将随机分配给正在求职的用户，给他们带去温暖和鼓励。感谢你传递正能量！',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.blue.shade600,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ────────────────────────────────────────────────────────────────────────────
  // 私有方法
  // ────────────────────────────────────────────────────────────────────────────

  /// 提交信封
  Future<void> _submitEnvelope() async {
    // 验证输入
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请输入信封标题')),
      );
      return;
    }
    
    if (_contentController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请输入信封内容')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      // 创建信封
      final envelope = WishEnvelope(
        id: '${DateTime.now().millisecondsSinceEpoch}_${widget.creatorId.hashCode}',
        creatorId: widget.creatorId,
        creatorName: widget.creatorName,
        creatorTitle: widget.creatorTitle,
        title: _titleController.text.trim(),
        content: _contentController.text.trim(),
        type: _selectedType,
        isPublic: _isPublic,
        createdAt: DateTime.now(),
      );

      await _envelopeService.createEnvelope(envelope);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('信封创建成功，感谢你的温暖！')),
        );
        widget.onCreated?.call();
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('创建失败，请重试')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  /// 获取类型颜色
  Color _getTypeColor(EnvelopeType type) {
    switch (type) {
      case EnvelopeType.encouragement:
        return Colors.pink;
      case EnvelopeType.experience:
        return Colors.blue;
      case EnvelopeType.blessing:
        return Colors.amber;
    }
  }

  /// 获取类型图标
  String _getTypeIcon(EnvelopeType type) {
    switch (type) {
      case EnvelopeType.encouragement:
        return '💌';
      case EnvelopeType.experience:
        return '📝';
      case EnvelopeType.blessing:
        return '🌟';
    }
  }

  /// 获取类型名称
  String _getTypeName(EnvelopeType type) {
    switch (type) {
      case EnvelopeType.encouragement:
        return '鼓励信';
      case EnvelopeType.experience:
        return '经验分享';
      case EnvelopeType.blessing:
        return '祝福信';
    }
  }
}
