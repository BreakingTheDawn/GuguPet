import 'package:flutter/material.dart';
import '../../../core/theme/theme.dart';
import '../../../core/di/service_provider.dart';
import '../../../core/services/llm_provider.dart';
import '../../../shared/widgets/widgets.dart';
import '../services/ai_config_service.dart';

/// AI对话设置页面
/// 配置Gemini API密钥、端点、模型等参数
class AISettingsPage extends StatefulWidget {
  const AISettingsPage({super.key});

  @override
  State<AISettingsPage> createState() => _AISettingsPageState();
}

class _AISettingsPageState extends State<AISettingsPage> {
  final _formKey = GlobalKey<FormState>();
  final _apiKeyController = TextEditingController();
  final _endpointController = TextEditingController();
  final _modelController = TextEditingController();
  
  bool _isEnabled = false;
  bool _obscureApiKey = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadConfig();
  }

  @override
  void dispose() {
    _apiKeyController.dispose();
    _endpointController.dispose();
    _modelController.dispose();
    super.dispose();
  }

  Future<void> _loadConfig() async {
    // 使用全局服务提供者获取配置
    final config = serviceProvider.aiConfigService.config;
    
    setState(() {
      // 只有当用户之前保存过配置时才填充输入框
      if (config.apiKey.isNotEmpty) {
        _apiKeyController.text = config.apiKey;
      }
      if (config.endpoint.isNotEmpty) {
        _endpointController.text = config.endpoint;
      }
      if (config.model.isNotEmpty) {
        _modelController.text = config.model;
      }
      _isEnabled = config.isEnabled;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F7FC),
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildIntroCard(),
            const SizedBox(height: AppSpacing.lg),
            _buildForm(),
            const SizedBox(height: AppSpacing.lg),
            _buildSaveButton(),
            const SizedBox(height: AppSpacing.lg),
            _buildHelpSection(),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text('Gemini AI 设置'),
      backgroundColor: Colors.transparent,
      elevation: 0,
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFF8F7FC), Color(0xFFEEE8F5)],
          ),
        ),
      ),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: AppColors.primary),
        onPressed: () => Navigator.pop(context),
      ),
    );
  }

  Widget _buildIntroCard() {
    return GlassContainer(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.indigo500.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.psychology,
              color: AppColors.indigo500,
              size: 32,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Google Gemini AI',
                      style: AppTypography.headingMedium.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '使用Gemini 1.5 Flash模型进行智能对话',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.mutedForeground,
                      ),
                    ),
                  ],
                ),
              ),
        ],
      ),
    );
  }

  Widget _buildSwitchTile() {
    return GlassContainer(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '启用 AI 对话',
                style: AppTypography.headingSmall.copyWith(
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '关闭后使用本地对话模式',
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.mutedForeground,
                ),
              ),
            ],
          ),
          Switch(
            value: _isEnabled,
            onChanged: (value) {
              setState(() {
                _isEnabled = value;
              });
            },
            activeTrackColor: AppColors.indigo500,
          ),
        ],
      ),
    );
  }

  Widget _buildForm() {
    return GlassContainer(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 启用开关
            _buildSwitchTile(),
            const Divider(height: 32),
            
            // API密钥
            Text(
              'API密钥 *',
              style: AppTypography.labelMedium.copyWith(
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _apiKeyController,
              obscureText: _obscureApiKey,
              decoration: InputDecoration(
                hintText: '输入您的Google Gemini API密钥',
                hintStyle: TextStyle(color: AppColors.mutedForeground),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureApiKey ? Icons.visibility_off : Icons.visibility,
                    color: AppColors.mutedForeground,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscureApiKey = !_obscureApiKey;
                    });
                  },
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.divider),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.divider),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.indigo500),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.destructive),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.destructive),
                ),
              ),
              validator: (value) {
                if (_isEnabled && (value == null || value.trim().isEmpty)) {
                  return '请输入API密钥';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            
            // API端点
            Text(
              'API端点',
              style: AppTypography.labelMedium.copyWith(
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Gemini API的请求地址',
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.mutedForeground,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _endpointController,
              decoration: InputDecoration(
                hintText: 'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent',
                hintStyle: TextStyle(
                  color: AppColors.mutedForeground,
                  fontSize: 12,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.divider),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.divider),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.indigo500),
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // 模型名称
            Text(
              '模型名称',
              style: AppTypography.labelMedium.copyWith(
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '推荐使用 gemini-1.5-flash',
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.mutedForeground,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _modelController,
              decoration: InputDecoration(
                hintText: 'gemini-1.5-flash',
                hintStyle: TextStyle(color: AppColors.mutedForeground),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.divider),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.divider),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.indigo500),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _handleSave,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.indigo500,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: _isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Text(
                '保存配置',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }

  Widget _buildHelpSection() {
    return GlassContainer(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.help_outline,
                color: AppColors.indigo500,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                '配置帮助',
                style: AppTypography.headingSmall.copyWith(
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildHelpItem(
            '1. 获取API密钥',
            '访问 Google AI Studio (aistudio.google.com) 创建API密钥',
          ),
          const SizedBox(height: 8),
          _buildHelpItem(
            '2. 配置说明',
            'API密钥：必填，输入您获取的密钥\n端点：选填，使用默认配置即可\n模型：选填，默认使用 gemini-1.5-flash',
          ),
          const SizedBox(height: 8),
          _buildHelpItem(
            '3. 注意事项',
            '• Gemini免费额度有限，用完会切换到本地模式\n• 请妥善保管您的API密钥\n• 如遇429错误，表示配额已用完',
          ),
        ],
      ),
    );
  }

  Widget _buildHelpItem(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTypography.bodyMedium.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          content,
          style: AppTypography.bodySmall.copyWith(
            color: AppColors.mutedForeground,
          ),
        ),
      ],
    );
  }

  Future<void> _handleSave() async {
    // 如果启用了AI，验证API密钥
    if (_isEnabled) {
      final apiKey = _apiKeyController.text.trim();
      
      if (apiKey.isEmpty) {
        if (!_formKey.currentState!.validate()) {
          return;
        }
      }
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final config = AIConfig(
        provider: LLMProvider.gemini,
        apiKey: _apiKeyController.text.trim(),
        endpoint: _endpointController.text.trim().isEmpty
            ? 'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent'
            : _endpointController.text.trim(),
        model: _modelController.text.trim().isEmpty
            ? 'gemini-1.5-flash'
            : _modelController.text.trim(),
        isEnabled: _isEnabled,
      );

      // 使用全局服务提供者保存配置
      await serviceProvider.saveAIConfig(config);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('配置已保存'),
            backgroundColor: AppColors.indigo500,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('保存失败: $e'),
            backgroundColor: AppColors.destructive,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
