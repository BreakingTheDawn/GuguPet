import 'package:sqflite/sqflite.dart';
import '../../../features/columns/data/models/purchased_column.dart';
import '../../../features/columns/data/models/favorite_column.dart';
import 'database_helper.dart';

// ═══════════════════════════════════════════════════════════════════════════════
/// 专栏本地数据源接口
/// 定义专栏购买和收藏数据的本地存储操作
// ═══════════════════════════════════════════════════════════════════════════════
abstract class ColumnLocalDatasource {
  // ────────────────────────────────────────────────────────────────────────────
  // 购买记录相关操作
  // ────────────────────────────────────────────────────────────────────────────

  /// 获取指定用户的专栏购买记录
  /// [userId] 用户ID
  /// [columnId] 专栏ID
  /// 返回购买记录，不存在则返回null
  Future<PurchasedColumn?> getPurchaseRecord(String userId, String columnId);

  /// 获取用户所有已购专栏列表
  /// [userId] 用户ID
  /// 返回已购专栏记录列表
  Future<List<PurchasedColumn>> getPurchasedColumns(String userId);

  /// 保存专栏购买记录
  /// [record] 购买记录数据
  Future<void> savePurchaseRecord(PurchasedColumn record);

  /// 检查用户是否已购买指定专栏
  /// [userId] 用户ID
  /// [columnId] 专栏ID
  /// 返回是否已购买
  Future<bool> isColumnPurchased(String userId, String columnId);

  // ────────────────────────────────────────────────────────────────────────────
  // 收藏记录相关操作
  // ────────────────────────────────────────────────────────────────────────────

  /// 获取指定用户的专栏收藏记录
  /// [userId] 用户ID
  /// [columnId] 专栏ID
  /// 返回收藏记录，不存在则返回null
  Future<FavoriteColumn?> getFavoriteRecord(String userId, String columnId);

  /// 获取用户所有收藏专栏列表
  /// [userId] 用户ID
  /// 返回收藏专栏记录列表
  Future<List<FavoriteColumn>> getFavoriteColumns(String userId);

  /// 保存专栏收藏记录
  /// [record] 收藏记录数据
  Future<void> saveFavoriteRecord(FavoriteColumn record);

  /// 移除专栏收藏记录
  /// [userId] 用户ID
  /// [columnId] 专栏ID
  Future<void> removeFavoriteRecord(String userId, String columnId);

  /// 检查用户是否已收藏指定专栏
  /// [userId] 用户ID
  /// [columnId] 专栏ID
  /// 返回是否已收藏
  Future<bool> isColumnFavorited(String userId, String columnId);
}

// ═══════════════════════════════════════════════════════════════════════════════
/// SQLite数据源实现
/// 使用SQLite数据库存储专栏购买和收藏数据
// ═══════════════════════════════════════════════════════════════════════════════
class SqliteColumnLocalDatasource implements ColumnLocalDatasource {
  /// 数据库帮助类实例
  final DatabaseHelper _databaseHelper;

  /// 构造函数
  /// [databaseHelper] 可选的数据库帮助类，默认使用单例
  SqliteColumnLocalDatasource({DatabaseHelper? databaseHelper})
      : _databaseHelper = databaseHelper ?? DatabaseHelper();

  /// 获取数据库实例
  Future<Database> get _database async => _databaseHelper.database;

  // ═══════════════════════════════════════════════════════════════════════════════
  // 购买记录相关操作实现
  // ═══════════════════════════════════════════════════════════════════════════════

  @override
  Future<PurchasedColumn?> getPurchaseRecord(
    String userId,
    String columnId,
  ) async {
    try {
      final db = await _database;

      // 查询购买记录表
      final results = await db.query(
        DatabaseHelper.tablePurchasedColumns,
        where:
            '${DatabaseHelper.columnUserId} = ? AND ${DatabaseHelper.columnColumnId} = ?',
        whereArgs: [userId, columnId],
        limit: 1,
      );

      // 如果没有找到记录，返回null
      if (results.isEmpty) return null;

      // 将数据库Map转换为PurchasedColumn模型
      return _mapToPurchasedColumn(results.first);
    } catch (e, stackTrace) {
      print('[SqliteColumnLocalDatasource] 获取购买记录失败: $e');
      print('[SqliteColumnLocalDatasource] 堆栈跟踪: $stackTrace');
      rethrow;
    }
  }

  @override
  Future<List<PurchasedColumn>> getPurchasedColumns(String userId) async {
    try {
      final db = await _database;

      // 查询用户所有购买记录，按购买时间降序排列
      final results = await db.query(
        DatabaseHelper.tablePurchasedColumns,
        where: '${DatabaseHelper.columnUserId} = ?',
        whereArgs: [userId],
        orderBy: '${DatabaseHelper.columnPurchasedAt} DESC',
      );

      // 将结果列表转换为PurchasedColumn模型列表
      return results.map(_mapToPurchasedColumn).toList();
    } catch (e, stackTrace) {
      print('[SqliteColumnLocalDatasource] 获取已购专栏列表失败: $e');
      print('[SqliteColumnLocalDatasource] 堆栈跟踪: $stackTrace');
      rethrow;
    }
  }

  @override
  Future<void> savePurchaseRecord(PurchasedColumn record) async {
    try {
      final db = await _database;

      // 将PurchasedColumn模型转换为数据库Map
      final data = _purchasedColumnToMap(record);

      // 使用INSERT OR REPLACE确保数据唯一性
      await db.insert(
        DatabaseHelper.tablePurchasedColumns,
        data,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e, stackTrace) {
      print('[SqliteColumnLocalDatasource] 保存购买记录失败: $e');
      print('[SqliteColumnLocalDatasource] 堆栈跟踪: $stackTrace');
      rethrow;
    }
  }

  @override
  Future<bool> isColumnPurchased(String userId, String columnId) async {
    try {
      final db = await _database;

      // 查询是否存在购买记录
      final results = await db.query(
        DatabaseHelper.tablePurchasedColumns,
        where:
            '${DatabaseHelper.columnUserId} = ? AND ${DatabaseHelper.columnColumnId} = ?',
        whereArgs: [userId, columnId],
        limit: 1,
      );

      return results.isNotEmpty;
    } catch (e, stackTrace) {
      print('[SqliteColumnLocalDatasource] 检查购买状态失败: $e');
      print('[SqliteColumnLocalDatasource] 堆栈跟踪: $stackTrace');
      rethrow;
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════════
  // 收藏记录相关操作实现
  // ═══════════════════════════════════════════════════════════════════════════════

  @override
  Future<FavoriteColumn?> getFavoriteRecord(
    String userId,
    String columnId,
  ) async {
    try {
      final db = await _database;

      // 查询收藏记录表
      final results = await db.query(
        DatabaseHelper.tableFavoriteColumns,
        where:
            '${DatabaseHelper.columnUserId} = ? AND ${DatabaseHelper.columnColumnId} = ?',
        whereArgs: [userId, columnId],
        limit: 1,
      );

      // 如果没有找到记录，返回null
      if (results.isEmpty) return null;

      // 将数据库Map转换为FavoriteColumn模型
      return _mapToFavoriteColumn(results.first);
    } catch (e, stackTrace) {
      print('[SqliteColumnLocalDatasource] 获取收藏记录失败: $e');
      print('[SqliteColumnLocalDatasource] 堆栈跟踪: $stackTrace');
      rethrow;
    }
  }

  @override
  Future<List<FavoriteColumn>> getFavoriteColumns(String userId) async {
    try {
      final db = await _database;

      // 查询用户所有收藏记录，按收藏时间降序排列
      final results = await db.query(
        DatabaseHelper.tableFavoriteColumns,
        where: '${DatabaseHelper.columnUserId} = ?',
        whereArgs: [userId],
        orderBy: '${DatabaseHelper.columnCreatedAt} DESC',
      );

      // 将结果列表转换为FavoriteColumn模型列表
      return results.map(_mapToFavoriteColumn).toList();
    } catch (e, stackTrace) {
      print('[SqliteColumnLocalDatasource] 获取收藏专栏列表失败: $e');
      print('[SqliteColumnLocalDatasource] 堆栈跟踪: $stackTrace');
      rethrow;
    }
  }

  @override
  Future<void> saveFavoriteRecord(FavoriteColumn record) async {
    try {
      final db = await _database;

      // 将FavoriteColumn模型转换为数据库Map
      final data = _favoriteColumnToMap(record);

      // 使用INSERT OR REPLACE确保数据唯一性
      await db.insert(
        DatabaseHelper.tableFavoriteColumns,
        data,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e, stackTrace) {
      print('[SqliteColumnLocalDatasource] 保存收藏记录失败: $e');
      print('[SqliteColumnLocalDatasource] 堆栈跟踪: $stackTrace');
      rethrow;
    }
  }

  @override
  Future<void> removeFavoriteRecord(String userId, String columnId) async {
    try {
      final db = await _database;

      // 删除指定的收藏记录
      await db.delete(
        DatabaseHelper.tableFavoriteColumns,
        where:
            '${DatabaseHelper.columnUserId} = ? AND ${DatabaseHelper.columnColumnId} = ?',
        whereArgs: [userId, columnId],
      );
    } catch (e, stackTrace) {
      print('[SqliteColumnLocalDatasource] 移除收藏记录失败: $e');
      print('[SqliteColumnLocalDatasource] 堆栈跟踪: $stackTrace');
      rethrow;
    }
  }

  @override
  Future<bool> isColumnFavorited(String userId, String columnId) async {
    try {
      final db = await _database;

      // 查询是否存在收藏记录
      final results = await db.query(
        DatabaseHelper.tableFavoriteColumns,
        where:
            '${DatabaseHelper.columnUserId} = ? AND ${DatabaseHelper.columnColumnId} = ?',
        whereArgs: [userId, columnId],
        limit: 1,
      );

      return results.isNotEmpty;
    } catch (e, stackTrace) {
      print('[SqliteColumnLocalDatasource] 检查收藏状态失败: $e');
      print('[SqliteColumnLocalDatasource] 堆栈跟踪: $stackTrace');
      rethrow;
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════════
  // 数据转换辅助方法
  // ═══════════════════════════════════════════════════════════════════════════════

  /// 将PurchasedColumn模型转换为数据库Map
  /// 用于插入或更新数据库记录
  Map<String, dynamic> _purchasedColumnToMap(PurchasedColumn record) {
    return {
      DatabaseHelper.columnId: record.id,
      DatabaseHelper.columnUserId: record.userId,
      DatabaseHelper.columnColumnId: record.columnId,
      DatabaseHelper.columnPurchaseType: record.purchaseType,
      DatabaseHelper.columnPurchasePrice: record.purchasePrice,
      DatabaseHelper.columnPurchasedAt: record.purchasedAt.toIso8601String(),
    };
  }

  /// 将数据库Map转换为PurchasedColumn模型
  /// 用于从数据库读取数据后转换为模型对象
  PurchasedColumn _mapToPurchasedColumn(Map<String, dynamic> map) {
    return PurchasedColumn(
      id: map[DatabaseHelper.columnId] as String,
      userId: map[DatabaseHelper.columnUserId] as String,
      columnId: map[DatabaseHelper.columnColumnId] as String,
      purchaseType: map[DatabaseHelper.columnPurchaseType] as String,
      purchasePrice: map[DatabaseHelper.columnPurchasePrice] != null
          ? (map[DatabaseHelper.columnPurchasePrice] as num).toDouble()
          : null,
      purchasedAt:
          DateTime.parse(map[DatabaseHelper.columnPurchasedAt] as String),
    );
  }

  /// 将FavoriteColumn模型转换为数据库Map
  /// 用于插入或更新数据库记录
  Map<String, dynamic> _favoriteColumnToMap(FavoriteColumn record) {
    return {
      DatabaseHelper.columnId: record.id,
      DatabaseHelper.columnUserId: record.userId,
      DatabaseHelper.columnColumnId: record.columnId,
      DatabaseHelper.columnCreatedAt: record.createdAt.toIso8601String(),
    };
  }

  /// 将数据库Map转换为FavoriteColumn模型
  /// 用于从数据库读取数据后转换为模型对象
  FavoriteColumn _mapToFavoriteColumn(Map<String, dynamic> map) {
    return FavoriteColumn(
      id: map[DatabaseHelper.columnId] as String,
      userId: map[DatabaseHelper.columnUserId] as String,
      columnId: map[DatabaseHelper.columnColumnId] as String,
      createdAt: DateTime.parse(map[DatabaseHelper.columnCreatedAt] as String),
    );
  }
}
