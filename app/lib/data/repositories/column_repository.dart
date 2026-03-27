import '../../features/columns/data/models/column_content.dart';
import '../../features/columns/data/models/purchased_column.dart';
import '../../features/columns/data/models/favorite_column.dart';

// ═══════════════════════════════════════════════════════════════════════════════
/// 专栏仓库接口
/// 定义专栏相关的业务操作接口
// ═══════════════════════════════════════════════════════════════════════════════
abstract class ColumnRepository {
  // ────────────────────────────────────────────────────────────────────────────
  // 专栏内容相关操作
  // ────────────────────────────────────────────────────────────────────────────

  /// 获取专栏完整内容
  /// [columnId] 专栏ID
  /// 返回专栏完整内容，不存在则返回null
  Future<ColumnContent?> getColumnContent(String columnId);

  // ────────────────────────────────────────────────────────────────────────────
  // 购买相关操作
  // ────────────────────────────────────────────────────────────────────────────

  /// 获取用户所有已购专栏列表
  /// [userId] 用户ID
  /// 返回已购专栏记录列表
  Future<List<PurchasedColumn>> getPurchasedColumns(String userId);

  /// 购买专栏
  /// [record] 购买记录数据
  Future<void> purchaseColumn(PurchasedColumn record);

  /// 检查用户是否已购买指定专栏
  /// [userId] 用户ID
  /// [columnId] 专栏ID
  /// 返回是否已购买
  Future<bool> isPurchased(String userId, String columnId);

  /// 获取用户对指定专栏的购买记录
  /// [userId] 用户ID
  /// [columnId] 专栏ID
  /// 返回购买记录，未购买则返回null
  Future<PurchasedColumn?> getPurchaseRecord(String userId, String columnId);

  // ────────────────────────────────────────────────────────────────────────────
  // 收藏相关操作
  // ────────────────────────────────────────────────────────────────────────────

  /// 获取用户所有收藏专栏列表
  /// [userId] 用户ID
  /// 返回收藏专栏记录列表
  Future<List<FavoriteColumn>> getFavoriteColumns(String userId);

  /// 添加专栏到收藏
  /// [record] 收藏记录数据
  Future<void> addToFavorites(FavoriteColumn record);

  /// 从收藏中移除专栏
  /// [userId] 用户ID
  /// [columnId] 专栏ID
  Future<void> removeFromFavorites(String userId, String columnId);

  /// 检查用户是否已收藏指定专栏
  /// [userId] 用户ID
  /// [columnId] 专栏ID
  /// 返回是否已收藏
  Future<bool> isFavorited(String userId, String columnId);
}
