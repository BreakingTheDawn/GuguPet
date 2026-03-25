import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

// ═══════════════════════════════════════════════════════════════════════════════
/// 购买确认弹窗组件
/// 用于确认专栏购买，支持VIP用户免费阅读和普通用户付费购买
// ═══════════════════════════════════════════════════════════════════════════════
class PurchaseDialog extends StatefulWidget {
  // ────────────────────────────────────────────────────────────────────────────
  // 组件属性
  // ────────────────────────────────────────────────────────────────────────────

  /// 专栏ID
  final String columnId;

  /// 专栏标题
  final String columnTitle;

  /// 专栏价格
  final double price;

  /// 是否是VIP用户
  final bool isVipUser;

  /// 购买成功回调
  final VoidCallback? onPurchaseSuccess;

  /// 开通VIP回调
  final VoidCallback? onOpenVip;

  // ────────────────────────────────────────────────────────────────────────────
  // 构造函数
  // ────────────────────────────────────────────────────────────────────────────

  const PurchaseDialog({
    super.key,
    required this.columnId,
    required this.columnTitle,
    required this.price,
    this.isVipUser = false,
    this.onPurchaseSuccess,
    this.onOpenVip,
  });

  // ────────────────────────────────────────────────────────────────────────────
  // 静态方法：显示购买弹窗
  // ────────────────────────────────────────────────────────────────────────────

  /// 显示购买弹窗
  /// [context] 上下文
  /// [columnId] 专栏ID
  /// [columnTitle] 专栏标题
  /// [price] 专栏价格
  /// [isVipUser] 是否是VIP用户
  /// [onPurchaseSuccess] 购买成功回调
  /// [onOpenVip] 开通VIP回调
  /// 返回购买结果（true: 成功, false: 失败, null: 取消）
  static Future<bool?> show({
    required BuildContext context,
    required String columnId,
    required String columnTitle,
    required double price,
    bool isVipUser = false,
    VoidCallback? onPurchaseSuccess,
    VoidCallback? onOpenVip,
  }) {
    return showDialog<bool>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.45),
      barrierDismissible: true,
      builder: (context) => PurchaseDialog(
        columnId: columnId,
        columnTitle: columnTitle,
        price: price,
        isVipUser: isVipUser,
        onPurchaseSuccess: onPurchaseSuccess,
        onOpenVip: onOpenVip,
      ),
    );
  }

  @override
  State<PurchaseDialog> createState() => _PurchaseDialogState();
}

class _PurchaseDialogState extends State<PurchaseDialog> {
  // ────────────────────────────────────────────────────────────────────────────
  // 构建UI
  // ────────────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Center(
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.0, end: 1.0),
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        builder: (context, value, child) {
          return Transform.scale(
            scale: 0.9 + (0.1 * value),
            child: Opacity(
              opacity: value,
              child: child,
            ),
          );
        },
        child: Material(
          color: Colors.transparent,
          child: Container(
            width: 320,
            margin: const EdgeInsets.symmetric(horizontal: 28),
            decoration: BoxDecoration(
              color: AppColors.archiveModalBackground,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildHeader(),
                _buildContent(context),
                _buildButtons(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ────────────────────────────────────────────────────────────────────────────
  // 构建弹窗头部
  // ────────────────────────────────────────────────────────────────────────────

  /// 构建弹窗头部
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: AppColors.archiveAccent.withValues(alpha: 0.15),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // 购物车图标
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: AppColors.archiveBannerGradient,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.shopping_cart_outlined,
              color: Colors.white,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          // 标题
          const Expanded(
            child: Text(
              '购买确认',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.archiveText,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ────────────────────────────────────────────────────────────────────────────
  // 构建内容区域
  // ────────────────────────────────────────────────────────────────────────────

  /// 构建内容区域
  Widget _buildContent(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 专栏标题
          _buildColumnTitle(),
          const SizedBox(height: 20),

          // 价格信息卡片
          _buildPriceCard(),

          // VIP提示（非VIP用户显示）
          if (!widget.isVipUser) ...[
            const SizedBox(height: 16),
            _buildVipCard(context),
          ],

          // VIP免费提示（VIP用户显示）
          if (widget.isVipUser) ...[
            const SizedBox(height: 16),
            _buildVipFreeHint(),
          ],
        ],
      ),
    );
  }

  /// 构建专栏标题
  Widget _buildColumnTitle() {
    return Row(
      children: [
        // 书籍图标
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: AppColors.archiveCardStart.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(
            Icons.menu_book_outlined,
            color: AppColors.archiveAccent,
            size: 18,
          ),
        ),
        const SizedBox(width: 12),
        // 标题文本
        Expanded(
          child: Text(
            widget.columnTitle,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.archiveText,
              height: 1.4,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  /// 构建价格卡片
  Widget _buildPriceCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.archiveCardStart.withValues(alpha: 0.4),
            AppColors.archiveCardEnd.withValues(alpha: 0.3),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.archiveAccent.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // 价格图标
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.6),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.attach_money,
              color: AppColors.archiveAccent,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          // 价格标签
          const Expanded(
            child: Text(
              '专栏价格',
              style: TextStyle(
                fontSize: 13,
                color: AppColors.archiveTextMuted,
              ),
            ),
          ),
          // 价格数值
          Text(
            _formatPrice(widget.price),
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.archiveAccent,
            ),
          ),
        ],
      ),
    );
  }

  /// 构建VIP卡片（非VIP用户显示）
  Widget _buildVipCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFFFFF8E1).withValues(alpha: 0.8),
            const Color(0xFFFFECB3).withValues(alpha: 0.6),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFFFB300).withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // VIP标题
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFFFFB300), Color(0xFFFF8F00)],
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.star,
                  color: Colors.white,
                  size: 16,
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                'VIP会员特权',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFFE65100),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // VIP说明
          const Text(
            'VIP会员可免费阅读所有专栏',
            style: TextStyle(
              fontSize: 12,
              color: Color(0xFFBF360C),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 12),
          // 开通VIP按钮
          GestureDetector(
            onTap: () {
              Navigator.of(context).pop(false);
              widget.onOpenVip?.call();
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFFFFB300), Color(0xFFFF8F00)],
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Center(
                child: Text(
                  '立即开通VIP',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 构建VIP免费提示（VIP用户显示）
  Widget _buildVipFreeHint() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F5E9).withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF4CAF50).withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: const Color(0xFF4CAF50).withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_circle,
              color: Color(0xFF4CAF50),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'VIP会员免费阅读',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2E7D32),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ────────────────────────────────────────────────────────────────────────────
  // 构建按钮区域
  // ────────────────────────────────────────────────────────────────────────────

  /// 构建按钮区域
  Widget _buildButtons(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      child: Row(
        children: [
          // 取消按钮
          Expanded(
            child: _buildCancelButton(context),
          ),
          const SizedBox(width: 12),
          // 确认按钮
          Expanded(
            flex: 2,
            child: _buildConfirmButton(context),
          ),
        ],
      ),
    );
  }

  /// 构建取消按钮
  Widget _buildCancelButton(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context).pop(null),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.muted.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(
          child: Text(
            '取消',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.archiveTextMuted,
            ),
          ),
        ),
      ),
    );
  }

  /// 构建确认按钮
  Widget _buildConfirmButton(BuildContext context) {
    return _ShimmerPurchaseButton(
      text: widget.isVipUser ? '立即阅读' : '确认购买',
      onTap: () => _handlePurchase(context),
    );
  }

  // ────────────────────────────────────────────────────────────────────────────
  // 业务逻辑处理
  // ────────────────────────────────────────────────────────────────────────────

  /// 处理购买操作
  Future<void> _handlePurchase(BuildContext context) async {
    try {
      // 显示加载提示
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.archiveAccent),
          ),
        ),
      );

      // 模拟网络延迟
      await Future.delayed(const Duration(milliseconds: 800));

      // 检查组件是否仍然挂载
      if (!mounted) return;

      // 关闭加载提示
      Navigator.of(context).pop();

      // VIP用户直接成功
      if (widget.isVipUser) {
        Navigator.of(context).pop(true);
        widget.onPurchaseSuccess?.call();
        return;
      }

      // 普通用户模拟购买流程
      // TODO: 这里应该调用真实的支付接口
      // 目前模拟购买成功
      final success = await _simulatePurchase();

      // 检查组件是否仍然挂载
      if (!mounted) return;

      if (success) {
        // 关闭弹窗并返回成功
        Navigator.of(context).pop(true);
        // 触发成功回调
        widget.onPurchaseSuccess?.call();
        // 显示成功提示
        _showSuccessToast(context);
      } else {
        // 关闭弹窗并返回失败
        Navigator.of(context).pop(false);
        // 显示失败提示
        _showErrorToast(context);
      }
    } catch (e) {
      // 检查组件是否仍然挂载
      if (!mounted) return;
      
      // 关闭可能存在的加载提示
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
      // 显示错误提示
      _showErrorToast(context);
      debugPrint('购买失败: $e');
    }
  }

  /// 模拟购买流程
  /// TODO: 替换为真实的支付接口调用
  Future<bool> _simulatePurchase() async {
    // 模拟支付处理
    await Future.delayed(const Duration(milliseconds: 500));
    // 模拟90%的成功率
    return true;
  }

  /// 显示成功提示
  void _showSuccessToast(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white, size: 20),
            SizedBox(width: 12),
            Text('购买成功！'),
          ],
        ),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  /// 显示错误提示
  void _showErrorToast(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.error, color: Colors.white, size: 20),
            SizedBox(width: 12),
            Text('购买失败，请重试'),
          ],
        ),
        backgroundColor: AppColors.destructive,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // ────────────────────────────────────────────────────────────────────────────
  // 辅助方法
  // ────────────────────────────────────────────────────────────────────────────

  /// 格式化价格显示
  String _formatPrice(double price) {
    if (price == 0) {
      return '免费';
    }
    return '¥${price.toStringAsFixed(1)}';
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
/// 带闪光效果的购买按钮组件
/// 提供视觉吸引力，增强购买转化率
// ═══════════════════════════════════════════════════════════════════════════════
class _ShimmerPurchaseButton extends StatefulWidget {
  /// 按钮文本
  final String text;

  /// 点击回调
  final VoidCallback onTap;

  const _ShimmerPurchaseButton({
    required this.text,
    required this.onTap,
  });

  @override
  State<_ShimmerPurchaseButton> createState() => _ShimmerPurchaseButtonState();
}

class _ShimmerPurchaseButtonState extends State<_ShimmerPurchaseButton>
    with SingleTickerProviderStateMixin {
  // ────────────────────────────────────────────────────────────────────────────
  // 动画控制器
  // ────────────────────────────────────────────────────────────────────────────

  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    // 初始化闪光动画控制器
    _controller = AnimationController(
      duration: const Duration(milliseconds: 2500),
      vsync: this,
    )..repeat();
    // 创建位移动画
    _animation = Tween<double>(begin: -1.0, end: 2.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.linear),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // ────────────────────────────────────────────────────────────────────────────
  // 构建UI
  // ────────────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment(-1, -1),
            end: Alignment(1, 1),
            colors: [Color(0xFF8B6040), Color(0xFF6A4020)],
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF8B6040).withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // 闪光效果层
            AnimatedBuilder(
              animation: _animation,
              builder: (context, child) {
                return ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: SizedBox(
                    width: double.infinity,
                    height: 46,
                    child: Stack(
                      children: [
                        Positioned(
                          left: _animation.value * 200,
                          top: 0,
                          bottom: 0,
                          child: Container(
                            width: 64,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.transparent,
                                  Colors.white.withValues(alpha: 0.22),
                                  Colors.transparent,
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            // 按钮文字
            Text(
              widget.text,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
