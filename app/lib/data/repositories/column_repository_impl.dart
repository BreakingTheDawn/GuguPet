import 'package:flutter/material.dart';
import '../datasources/local/column_local_datasource.dart';
import '../../features/columns/data/models/column_content.dart';
import '../../features/columns/data/models/purchased_column.dart';
import '../../features/columns/data/models/favorite_column.dart';
import '../../features/columns/data/column_data.dart';
import 'column_repository.dart';

// ═══════════════════════════════════════════════════════════════════════════════
/// 专栏仓库实现
/// 封装数据源操作，提供统一的业务逻辑接口
// ═══════════════════════════════════════════════════════════════════════════════
class ColumnRepositoryImpl implements ColumnRepository {
  // ═══════════════════════════════════════════════════════════════════════════════
  // 依赖注入
  // ═══════════════════════════════════════════════════════════════════════════════

  /// 本地数据源实例
  final ColumnLocalDatasource _localDatasource;

  /// 构造函数
  /// [localDatasource] 本地数据源，默认使用SQLite实现
  ColumnRepositoryImpl({ColumnLocalDatasource? localDatasource})
      : _localDatasource = localDatasource ?? SqliteColumnLocalDatasource();

  // ═══════════════════════════════════════════════════════════════════════════════
  // 专栏内容相关操作实现
  // ═══════════════════════════════════════════════════════════════════════════════

  @override
  Future<ColumnContent?> getColumnContent(String columnId) async {
    try {
      // 从ColumnData中查找对应的专栏基本信息
      final columnItem = ColumnData.columns.firstWhere(
        (item) => item.id.toString() == columnId,
        orElse: () => throw Exception('专栏不存在: $columnId'),
      );

      // 获取专栏扩展数据（完整内容和章节）
      final extendedData = ColumnData.getExtendedData(columnItem.id);

      // 获取当前用户ID并查询购买和收藏状态
      final userId = await _getCurrentUserId();
      final isPurchased = await _localDatasource.isColumnPurchased(userId, columnId);
      final isFavorite = await _localDatasource.isColumnFavorited(userId, columnId);

      // 将ColumnItem转换为ColumnContent
      return ColumnContent(
        id: columnItem.id.toString(),
        title: columnItem.title,
        category: columnItem.category,
        catBg: _colorToHex(columnItem.catBg),
        catColor: _colorToHex(columnItem.catColor),
        price: _parsePrice(columnItem.price),
        emoji: columnItem.emoji,
        previewContent: columnItem.previewContent,
        fullContent: extendedData?.fullContent ?? '', // 从扩展数据获取完整内容
        sections: extendedData?.sections ?? [], // 从扩展数据获取章节列表
        isPurchased: isPurchased, // 从数据源查询的购买状态
        isFavorite: isFavorite, // 从数据源查询的收藏状态
      );
    } catch (e) {
      print('[ColumnRepositoryImpl] 获取专栏内容失败: $e');
      rethrow;
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════════
  // 购买相关操作实现
  // ═══════════════════════════════════════════════════════════════════════════════

  @override
  Future<List<PurchasedColumn>> getPurchasedColumns(String userId) async {
    try {
      return await _localDatasource.getPurchasedColumns(userId);
    } catch (e) {
      print('[ColumnRepositoryImpl] 获取已购专栏列表失败: $e');
      rethrow;
    }
  }

  @override
  Future<void> purchaseColumn(PurchasedColumn record) async {
    try {
      await _localDatasource.savePurchaseRecord(record);
    } catch (e) {
      print('[ColumnRepositoryImpl] 购买专栏失败: $e');
      rethrow;
    }
  }

  @override
  Future<bool> isPurchased(String userId, String columnId) async {
    try {
      return await _localDatasource.isColumnPurchased(userId, columnId);
    } catch (e) {
      print('[ColumnRepositoryImpl] 检查购买状态失败: $e');
      rethrow;
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════════
  // 收藏相关操作实现
  // ═══════════════════════════════════════════════════════════════════════════════

  @override
  Future<List<FavoriteColumn>> getFavoriteColumns(String userId) async {
    try {
      return await _localDatasource.getFavoriteColumns(userId);
    } catch (e) {
      print('[ColumnRepositoryImpl] 获取收藏专栏列表失败: $e');
      rethrow;
    }
  }

  @override
  Future<void> addToFavorites(FavoriteColumn record) async {
    try {
      await _localDatasource.saveFavoriteRecord(record);
    } catch (e) {
      print('[ColumnRepositoryImpl] 添加收藏失败: $e');
      rethrow;
    }
  }

  @override
  Future<void> removeFromFavorites(String userId, String columnId) async {
    try {
      await _localDatasource.removeFavoriteRecord(userId, columnId);
    } catch (e) {
      print('[ColumnRepositoryImpl] 移除收藏失败: $e');
      rethrow;
    }
  }

  @override
  Future<bool> isFavorited(String userId, String columnId) async {
    try {
      return await _localDatasource.isColumnFavorited(userId, columnId);
    } catch (e) {
      print('[ColumnRepositoryImpl] 检查收藏状态失败: $e');
      rethrow;
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════════
  // 辅助方法
  // ═══════════════════════════════════════════════════════════════════════════════

  /// 获取当前用户ID
  /// 当前使用默认用户ID，后续可从认证服务获取
  Future<String> _getCurrentUserId() async {
    // TODO: 后续可从认证服务或UserRepository获取当前登录用户ID
    return 'default_user';
  }

  /// 将Color转换为十六进制字符串
  /// 用于存储颜色值
  String _colorToHex(Color color) {
    // 使用 ARGB 格式转换，忽略 alpha 通道
    final hex = color.value.toRadixString(16).padLeft(8, '0');
    // 取后6位（RGB），忽略前2位（Alpha）
    return '#${hex.substring(2).toUpperCase()}';
  }

  /// 解析价格字符串
  /// 将"¥19.9"格式转换为double数值
  double _parsePrice(String priceStr) {
    try {
      // 移除货币符号和空格
      final cleanStr = priceStr.replaceAll(RegExp(r'[¥￥\s]'), '');
      return double.parse(cleanStr);
    } catch (e) {
      print('[ColumnRepositoryImpl] 解析价格失败: $priceStr, 错误: $e');
      return 0.0;
    }
  }
}
