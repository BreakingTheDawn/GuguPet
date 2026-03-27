import 'package:flutter/material.dart';
import '../../../core/theme/theme.dart';
import '../../../core/services/ai_config_loader_service.dart';
import '../../../shared/widgets/widgets.dart';

/// AI对话设置页面
/// 仅显示AI配置信息，不再允许用户手动配置
class AISettingsPage extends StatefulWidget {
  const AISettingsPage({super.key});

  @override
  State<AISettingsPage> createState() => _AISettingsPageState();
}

class _AISettingsPageState extends State<AISettingsPage> {
  bool _isLoading = true;
  Map<String, dynamic> _configInfo = {};

  @override
  void initState() {
    super.initState();
    _loadConfig();
  }

  Future<void> _loadConfig() async {
    try {
      final config = await AIConfigLoaderService.getConfig();
      final enabledProviders = config.providers.where((p) => p.enabled).toList();
      
      setState(() {
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
                  '已自动配置，无需手动设置',
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
                decoration: const BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '服务状态：正常运行',
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'AI对话功能已自动配置并启用，咕咕会使用智能AI与您进行对话。',
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.mutedForeground,
            ),
          ),
        ],
      ),
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
                    Icons.check_circle,
                    color: AppColors.indigo500,
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
}
