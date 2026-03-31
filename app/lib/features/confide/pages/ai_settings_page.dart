import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../core/theme/theme.dart';
import '../../../core/services/ai_config_loader_service.dart';
import '../../../core/services/ai_auto_config_service.dart';
import '../../../core/services/security_service.dart';
import '../../../shared/widgets/widgets.dart';

/// AI对话设置页面
/// 用户可以在此配置自己的API密钥
class AISettingsPage extends StatefulWidget {
  const AISettingsPage({super.key});

  @override
  State<AISettingsPage> createState() => _AISettingsPageState();
}

class _AISettingsPageState extends State<AISettingsPage> {
  bool _isLoading = true;
  bool _isConfigured = false;
  bool _obscureApiKey = true;
  
  final _apiKeyController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  
  Map<String, dynamic> _configInfo = {};

  @override
  void initState() {
    super.initState();
    _loadConfig();
  }

  @override
  void dispose() {
    _apiKeyController.dispose();
    super.dispose();
  }

  Future<void> _loadConfig() async {
    try {
      final config = await AIConfigLoaderService.getConfig();
      final enabledProviders = config.providers.where((p) => p.enabled).toList();
      
      // 检查API Key是否已配置
      final hasKey = await _checkApiKeyConfigured();
      
      setState(() {
        _isConfigured = hasKey;
        _configInfo = {
          'version': config.version,
          'providers': enabledProviders.map((p) => {
            'name': p.name,
            'model': p.defaultModel,
            'enabled': p.enabled,
          }).toList(),
          'streaming': config.conversation.enableStreaming,
          'fallback': config.fallback.order,
        };
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  Future<bool> _checkApiKeyConfigured() async {
    try {
      // 使用AIAutoConfigService检查API密钥是否已配置
      final secureStorage = const FlutterSecureStorage();
      final securityService = SecurityService();
      
      final encryptedKey = await secureStorage.read(key: 'ai_api_key_glm');
      
      if (encryptedKey == null || encryptedKey.isEmpty) {
        return false;
      }
      
      // 尝试解密密钥
      final decryptedKey = securityService.decryptData(encryptedKey);
      return decryptedKey.isNotEmpty;
    } catch (e) {
      debugPrint('检查API密钥配置失败: $e');
      return false;
    }
  }

  Future<void> _saveApiKey() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    
    final apiKey = _apiKeyController.text.trim();
    
    try {
      setState(() => _isLoading = true);
      
      await AIAutoConfigService.configureGLM(apiKey);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('API密钥配置成功'),
            backgroundColor: AppColors.indigo500,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
        
        _apiKeyController.clear();
        await _loadConfig();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('配置失败: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
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
            _buildStatusCard(),
            const SizedBox(height: AppSpacing.lg),
            _buildApiKeyConfigCard(),
            const SizedBox(height: AppSpacing.lg),
            _buildGuideCard(),
            const SizedBox(height: AppSpacing.lg),
            _buildProvidersCard(),
            const SizedBox(height: AppSpacing.lg),
            _buildFeaturesCard(),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text('AI对话设置'),
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
                  'AI智能对话',
                  style: AppTypography.headingMedium.copyWith(
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '配置您的API密钥以启用AI对话功能',
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

  Widget _buildStatusCard() {
    return GlassContainer(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: _isConfigured ? Colors.green : Colors.orange,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                _isConfigured ? '服务状态：已配置' : '服务状态：未配置',
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            _isConfigured 
                ? 'AI对话功能已启用，咕咕会使用智能AI与您进行对话。'
                : '请配置您的API密钥以启用AI对话功能。',
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.mutedForeground,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildApiKeyConfigCard() {
    return GlassContainer(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.indigo500.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.key,
                  color: AppColors.indigo500,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'API密钥配置',
                style: AppTypography.headingSmall.copyWith(
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: _apiKeyController,
                  obscureText: _obscureApiKey,
                  decoration: InputDecoration(
                    labelText: '智谱GLM API密钥',
                    hintText: '请输入您的API密钥',
                    prefixIcon: const Icon(Icons.vpn_key, size: 20),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureApiKey ? Icons.visibility : Icons.visibility_off,
                        size: 20,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureApiKey = !_obscureApiKey;
                        });
                      },
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return '请输入API密钥';
                    }
                    if (value.trim().length < 10) {
                      return 'API密钥格式不正确';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _saveApiKey,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.indigo500,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text(
                            '保存配置',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGuideCard() {
    return GlassContainer(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.indigo500.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.help_outline,
                  color: AppColors.indigo500,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '如何获取API密钥？',
                style: AppTypography.headingSmall.copyWith(
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildGuideStep(
            '1',
            '访问智谱AI开放平台',
            'https://open.bigmodel.cn/',
            onTap: () => _copyToClipboard('https://open.bigmodel.cn/'),
          ),
          const SizedBox(height: 12),
          _buildGuideStep(
            '2',
            '注册/登录账号',
            '支持手机号、微信等多种登录方式',
          ),
          const SizedBox(height: 12),
          _buildGuideStep(
            '3',
            '创建应用',
            '在控制台创建新应用，选择GLM-4模型',
          ),
          const SizedBox(height: 12),
          _buildGuideStep(
            '4',
            '获取API密钥',
            '在应用详情页复制API密钥，粘贴到上方输入框',
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: Colors.blue[700], size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '智谱AI提供免费额度，GLM-4-Flash模型免费使用',
                    style: AppTypography.bodySmall.copyWith(
                      color: Colors.blue[700],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGuideStep(String number, String title, String description, {VoidCallback? onTap}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: AppColors.indigo500,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              number,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              GestureDetector(
                onTap: onTap,
                child: Text(
                  description,
                  style: AppTypography.bodySmall.copyWith(
                    color: onTap != null ? AppColors.indigo500 : AppColors.mutedForeground,
                    decoration: onTap != null ? TextDecoration.underline : null,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProvidersCard() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final providers = _configInfo['providers'] as List? ?? [];

    return GlassContainer(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'AI模型配置',
            style: AppTypography.headingSmall.copyWith(
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 16),
          ...providers.asMap().entries.map((entry) {
            final index = entry.key;
            final provider = entry.value as Map<String, dynamic>;
            final isPrimary = index == 0;
            
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: isPrimary 
                          ? AppColors.indigo500.withValues(alpha: 0.1)
                          : AppColors.mutedForeground.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      isPrimary ? '主用' : '备用',
                      style: AppTypography.labelSmall.copyWith(
                        color: isPrimary ? AppColors.indigo500 : AppColors.mutedForeground,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          provider['name'] ?? '',
                          style: AppTypography.bodyMedium.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          '模型: ${provider['model'] ?? ''}',
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.mutedForeground,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    _isConfigured ? Icons.check_circle : Icons.radio_button_unchecked,
                    color: _isConfigured ? AppColors.indigo500 : AppColors.mutedForeground,
                    size: 20,
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildFeaturesCard() {
    return GlassContainer(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '功能特性',
            style: AppTypography.headingSmall.copyWith(
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 16),
          _buildFeatureItem(
            Icons.stream,
            '流式响应',
            '实时显示AI回复内容，无需等待完整响应',
          ),
          const SizedBox(height: 12),
          _buildFeatureItem(
            Icons.swap_horiz,
            '自动故障转移',
            '主模型不可用时自动切换到备用模型',
          ),
          const SizedBox(height: 12),
          _buildFeatureItem(
            Icons.memory,
            '上下文记忆',
            '记住对话历史，保持对话连贯性',
          ),
          const SizedBox(height: 12),
          _buildFeatureItem(
            Icons.pets,
            '宠物性格',
            '咕咕会根据配置的性格特点进行回复',
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(IconData icon, String title, String description) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.indigo500.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: AppColors.indigo500,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                description,
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.mutedForeground,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
  
  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('已复制: $text'),
        backgroundColor: AppColors.indigo500,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
