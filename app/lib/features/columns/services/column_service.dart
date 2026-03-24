import 'package:flutter/foundation.dart';
import '../../../data/repositories/column_repository.dart';
import '../data/models/column_content.dart';
import '../data/models/purchased_column.dart';
import '../data/models/favorite_column.dart';
import '../data/column_data.dart';

// ═══════════════════════════════════════════════════════════════════════════════
/// 专栏业务服务
/// 负责处理专栏相关的业务逻辑，包括获取内容、购买、收藏等操作
// ═══════════════════════════════════════════════════════════════════════════════
class ColumnService {
  // ────────────────────────────────────────────────────────────────────────────
  // 依赖注入
  // ────────────────────────────────────────────────────────────────────────────

  /// 专栏仓库接口
  final ColumnRepository _repository;

  ColumnService({
    required ColumnRepository repository,
  }) : _repository = repository;

  // ────────────────────────────────────────────────────────────────────────────
  // 专栏内容相关操作
  // ────────────────────────────────────────────────────────────────────────────

  /// 获取专栏完整内容
  /// [columnId] 专栏ID
  /// [userId] 用户ID，用于检查购买和收藏状态
  /// 返回专栏完整内容，包含购买和收藏状态
  Future<ColumnContent?> getColumnContent(
    String columnId, {
    String userId = 'default_user',
  }) async {
    try {
      // 1. 从仓库获取专栏内容
      final content = await _repository.getColumnContent(columnId);
      if (content == null) {
        debugPrint('专栏不存在: $columnId');
        return null;
      }

      // 2. 检查购买状态
      final isPurchased = await _repository.isPurchased(userId, columnId);

      // 3. 检查收藏状态
      final isFavorited = await _repository.isFavorited(userId, columnId);

      // 4. 返回包含状态的内容
      return content.copyWith(
        isPurchased: isPurchased,
        isFavorite: isFavorited,
      );
    } catch (e) {
      debugPrint('获取专栏内容失败: $e');
      rethrow;
    }
  }

  /// 获取专栏预览内容
  /// [columnId] 专栏ID
  /// 返回专栏的预览内容（无需购买即可查看）
  Future<List<String>> getPreviewContent(String columnId) async {
    try {
      // 从静态数据中获取预览内容
      final columnIdInt = int.tryParse(columnId);
      if (columnIdInt == null) {
        debugPrint('专栏ID格式错误: $columnId');
        return [];
      }

      // 查找对应的专栏
      final column = ColumnData.columns.firstWhere(
        (item) => item.id == columnIdInt,
        orElse: () => throw Exception('专栏不存在'),
      );

      return column.previewContent;
    } catch (e) {
      debugPrint('获取预览内容失败: $e');
      return [];
    }
  }

  // ────────────────────────────────────────────────────────────────────────────
  // 购买相关操作
  // ────────────────────────────────────────────────────────────────────────────

  /// 购买专栏
  /// [userId] 用户ID
  /// [columnId] 专栏ID
  /// [price] 购买价格
  /// 返回是否购买成功
  Future<bool> purchaseColumn(
    String userId,
    String columnId,
    double price,
  ) async {
    try {
      // 1. 检查是否已购买
      final isPurchased = await _repository.isPurchased(userId, columnId);
      if (isPurchased) {
        debugPrint('专栏已购买，无需重复购买');
        return true;
      }

      // 2. 创建购买记录
      final record = PurchasedColumn(
        id: '${userId}_${columnId}_${DateTime.now().millisecondsSinceEpoch}',
        userId: userId,
        columnId: columnId,
        purchaseType: 'single', // 单独购买类型
        purchasePrice: price,
        purchasedAt: DateTime.now(),
      );

      // 3. 保存购买记录
      await _repository.purchaseColumn(record);

      debugPrint('专栏购买成功: $columnId');
      return true;
    } catch (e) {
      debugPrint('购买专栏失败: $e');
      rethrow;
    }
  }

  /// 检查购买状态
  /// [userId] 用户ID
  /// [columnId] 专栏ID
  /// 返回是否已购买
  Future<bool> checkPurchaseStatus(String userId, String columnId) async {
    try {
      return await _repository.isPurchased(userId, columnId);
    } catch (e) {
      debugPrint('检查购买状态失败: $e');
      return false;
    }
  }

  /// 获取用户已购专栏列表
  /// [userId] 用户ID
  /// 返回已购专栏ID列表
  Future<List<String>> getPurchasedColumnIds(String userId) async {
    try {
      final purchasedColumns = await _repository.getPurchasedColumns(userId);
      return purchasedColumns.map((item) => item.columnId).toList();
    } catch (e) {
      debugPrint('获取已购专栏列表失败: $e');
      return [];
    }
  }

  // ────────────────────────────────────────────────────────────────────────────
  // 收藏相关操作
  // ────────────────────────────────────────────────────────────────────────────

  /// 收藏专栏
  /// [userId] 用户ID
  /// [columnId] 专栏ID
  /// [columnTitle] 专栏标题（用于收藏列表显示）
  /// 返回是否收藏成功
  Future<bool> addToFavorites(
    String userId,
    String columnId, {
    String? columnTitle,
  }) async {
    try {
      // 1. 检查是否已收藏
      final isFavorited = await _repository.isFavorited(userId, columnId);
      if (isFavorited) {
        debugPrint('专栏已收藏，无需重复收藏');
        return true;
      }

      // 2. 创建收藏记录
      final record = FavoriteColumn(
        id: '${userId}_${columnId}_${DateTime.now().millisecondsSinceEpoch}',
        userId: userId,
        columnId: columnId,
        columnTitle: columnTitle,
        createdAt: DateTime.now(),
      );

      // 3. 保存收藏记录
      await _repository.addToFavorites(record);

      debugPrint('专栏收藏成功: $columnId');
      return true;
    } catch (e) {
      debugPrint('收藏专栏失败: $e');
      rethrow;
    }
  }

  /// 取消收藏专栏
  /// [userId] 用户ID
  /// [columnId] 专栏ID
  /// 返回是否取消成功
  Future<bool> removeFromFavorites(String userId, String columnId) async {
    try {
      await _repository.removeFromFavorites(userId, columnId);
      debugPrint('取消收藏成功: $columnId');
      return true;
    } catch (e) {
      debugPrint('取消收藏失败: $e');
      rethrow;
    }
  }

  /// 切换收藏状态
  /// [userId] 用户ID
  /// [columnId] 专栏ID
  /// [columnTitle] 专栏标题（用于收藏列表显示）
  /// 返回最新的收藏状态
  Future<bool> toggleFavorite(
    String userId,
    String columnId, {
    String? columnTitle,
  }) async {
    try {
      final isFavorited = await _repository.isFavorited(userId, columnId);

      if (isFavorited) {
        await removeFromFavorites(userId, columnId);
        return false;
      } else {
        await addToFavorites(userId, columnId, columnTitle: columnTitle);
        return true;
      }
    } catch (e) {
      debugPrint('切换收藏状态失败: $e');
      rethrow;
    }
  }

  /// 检查收藏状态
  /// [userId] 用户ID
  /// [columnId] 专栏ID
  /// 返回是否已收藏
  Future<bool> checkFavoriteStatus(String userId, String columnId) async {
    try {
      return await _repository.isFavorited(userId, columnId);
    } catch (e) {
      debugPrint('检查收藏状态失败: $e');
      return false;
    }
  }

  /// 获取用户收藏专栏列表（仅ID）
  /// [userId] 用户ID
  /// 返回收藏专栏ID列表
  Future<List<String>> getFavoriteColumnIds(String userId) async {
    try {
      final favoriteColumns = await _repository.getFavoriteColumns(userId);
      return favoriteColumns.map((item) => item.columnId).toList();
    } catch (e) {
      debugPrint('获取收藏专栏列表失败: $e');
      return [];
    }
  }

  /// 获取用户收藏专栏列表（完整记录）
  /// [userId] 用户ID
  /// 返回收藏专栏记录列表
  Future<List<FavoriteColumn>> getFavoriteColumns(String userId) async {
    try {
      return await _repository.getFavoriteColumns(userId);
    } catch (e) {
      debugPrint('获取收藏专栏列表失败: $e');
      return [];
    }
  }

  // ────────────────────────────────────────────────────────────────────────────
  // 辅助方法
  // ────────────────────────────────────────────────────────────────────────────

  /// 格式化价格显示
  /// [price] 价格数值
  /// 返回格式化后的价格字符串
  String formatPrice(double price) {
    if (price == 0) {
      return '免费';
    }
    return '¥${price.toStringAsFixed(1)}';
  }

  /// 检查专栏是否为VIP免费
  /// [columnId] 专栏ID
  /// 返回是否VIP免费
  bool isVipFree(String columnId) {
    // TODO: 根据实际业务逻辑判断VIP免费专栏
    // 目前暂无VIP免费专栏
    return false;
  }

  /// 计算购买优惠
  /// [originalPrice] 原价
  /// [discount] 折扣（0-1之间）
  /// 返回优惠后的价格
  double calculateDiscountedPrice(double originalPrice, double discount) {
    if (discount <= 0 || discount > 1) {
      return originalPrice;
    }
    return originalPrice * discount;
  }
}
