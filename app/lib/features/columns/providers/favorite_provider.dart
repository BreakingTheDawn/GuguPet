import 'package:flutter/foundation.dart';
import '../services/column_service.dart';
import '../data/models/favorite_column.dart';

// ═══════════════════════════════════════════════════════════════════════════════
/// 收藏状态管理Provider
/// 负责管理用户的收藏列表、加载状态和收藏操作
// ═══════════════════════════════════════════════════════════════════════════════
class FavoriteProvider extends ChangeNotifier {
  // ────────────────────────────────────────────────────────────────────────────
  // 依赖注入
  // ────────────────────────────────────────────────────────────────────────────

  /// 专栏业务服务
  final ColumnService _columnService;

  FavoriteProvider({
    required ColumnService columnService,
  }) : _columnService = columnService;

  // ────────────────────────────────────────────────────────────────────────────
  // 状态变量
  // ────────────────────────────────────────────────────────────────────────────

  /// 用户收藏列表
  List<FavoriteColumn> _favorites = [];

  /// 是否正在加载
  bool _isLoading = false;

  /// 是否正在执行操作（收藏、取消收藏等）
  bool _isOperating = false;

  /// 错误信息
  String? _errorMessage;

  /// 当前用户ID
  String _userId = 'default_user';

  // ────────────────────────────────────────────────────────────────────────────
  // Getter方法
  // ────────────────────────────────────────────────────────────────────────────

  /// 获取收藏列表
  List<FavoriteColumn> get favorites => List.unmodifiable(_favorites);

  /// 获取收藏数量
  int get favoriteCount => _favorites.length;

  /// 获取加载状态
  bool get isLoading => _isLoading;

  /// 获取操作状态
  bool get isOperating => _isOperating;

  /// 获取错误信息
  String? get errorMessage => _errorMessage;

  /// 获取用户ID
  String get userId => _userId;

  /// 获取收藏专栏ID列表
  List<String> get favoriteColumnIds =>
      _favorites.map((item) => item.columnId).toList();

  // ────────────────────────────────────────────────────────────────────────────
  // 公共方法
  // ────────────────────────────────────────────────────────────────────────────

  /// 加载用户收藏列表
  /// [userId] 用户ID，可选，默认为当前用户
  Future<void> loadFavorites({String? userId}) async {
    // 设置加载状态
    _isLoading = true;
    _errorMessage = null;
    if (userId != null) {
      _userId = userId;
    }
    notifyListeners();

    try {
      // 获取收藏列表
      final favorites = await _columnService.getFavoriteColumns(_userId);

      _favorites = favorites;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = '加载收藏列表失败: $e';
      debugPrint('FavoriteProvider Error: $e');
      notifyListeners();
    }
  }

  /// 检查专栏是否已收藏
  /// [columnId] 专栏ID
  /// 返回是否已收藏
  bool isFavorited(String columnId) {
    return _favorites.any((item) => item.columnId == columnId);
  }

  /// 添加收藏
  /// [columnId] 专栏ID
  /// [columnTitle] 专栏标题（可选，用于收藏列表显示）
  /// 返回是否收藏成功
  Future<bool> addToFavorites(
    String columnId, {
    String? columnTitle,
  }) async {
    // 检查是否已收藏
    if (isFavorited(columnId)) {
      debugPrint('专栏已收藏，无需重复收藏');
      return true;
    }

    // 设置操作状态
    _isOperating = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // 执行收藏操作
      final success = await _columnService.addToFavorites(
        _userId,
        columnId,
        columnTitle: columnTitle,
      );

      if (success) {
        // 重新加载收藏列表
        await loadFavorites();
      }

      _isOperating = false;
      notifyListeners();
      return success;
    } catch (e) {
      _isOperating = false;
      _errorMessage = '收藏失败: $e';
      debugPrint('收藏专栏失败: $e');
      notifyListeners();
      rethrow;
    }
  }

  /// 取消收藏
  /// [columnId] 专栏ID
  /// 返回是否取消成功
  Future<bool> removeFromFavorites(String columnId) async {
    // 检查是否已收藏
    if (!isFavorited(columnId)) {
      debugPrint('专栏未收藏，无需取消');
      return true;
    }

    // 设置操作状态
    _isOperating = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // 执行取消收藏操作
      final success = await _columnService.removeFromFavorites(
        _userId,
        columnId,
      );

      if (success) {
        // 从本地列表中移除
        _favorites.removeWhere((item) => item.columnId == columnId);
      }

      _isOperating = false;
      notifyListeners();
      return success;
    } catch (e) {
      _isOperating = false;
      _errorMessage = '取消收藏失败: $e';
      debugPrint('取消收藏失败: $e');
      notifyListeners();
      rethrow;
    }
  }

  /// 切换收藏状态
  /// [columnId] 专栏ID
  /// [columnTitle] 专栏标题（可选，用于收藏列表显示）
  /// 返回最新的收藏状态
  Future<bool> toggleFavorite(
    String columnId, {
    String? columnTitle,
  }) async {
    // 设置操作状态
    _isOperating = true;
    notifyListeners();

    try {
      // 切换收藏状态
      final isFavorited = await _columnService.toggleFavorite(
        _userId,
        columnId,
        columnTitle: columnTitle,
      );

      // 更新本地状态
      if (isFavorited) {
        // 添加到收藏列表
        await loadFavorites();
      } else {
        // 从收藏列表中移除
        _favorites.removeWhere((item) => item.columnId == columnId);
      }

      _isOperating = false;
      notifyListeners();
      return isFavorited;
    } catch (e) {
      _isOperating = false;
      debugPrint('切换收藏状态失败: $e');
      notifyListeners();
      rethrow;
    }
  }

  /// 刷新收藏状态
  /// [columnId] 专栏ID
  Future<void> refreshFavoriteStatus(String columnId) async {
    try {
      final isFavorited = await _columnService.checkFavoriteStatus(
        _userId,
        columnId,
      );

      // 更新本地状态
      if (isFavorited && !this.isFavorited(columnId)) {
        // 添加到收藏列表
        await loadFavorites();
      } else if (!isFavorited && this.isFavorited(columnId)) {
        // 从收藏列表中移除
        _favorites.removeWhere((item) => item.columnId == columnId);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('刷新收藏状态失败: $e');
    }
  }

  /// 清除数据
  void clear() {
    _favorites = [];
    _isLoading = false;
    _isOperating = false;
    _errorMessage = null;
    notifyListeners();
  }

  /// 清除错误信息
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// 设置用户ID
  void setUserId(String userId) {
    _userId = userId;
    notifyListeners();
  }

  /// 根据ID获取收藏记录
  /// [columnId] 专栏ID
  /// 返回收藏记录，如果不存在则返回null
  FavoriteColumn? getFavoriteByColumnId(String columnId) {
    try {
      return _favorites.firstWhere((item) => item.columnId == columnId);
    } catch (e) {
      return null;
    }
  }

  /// 获取收藏时间
  /// [columnId] 专栏ID
  /// 返回收藏时间，如果未收藏则返回null
  DateTime? getFavoriteTime(String columnId) {
    final favorite = getFavoriteByColumnId(columnId);
    return favorite?.createdAt;
  }

  /// 按收藏时间排序（最新的在前）
  void sortByTime({bool descending = true}) {
    if (descending) {
      _favorites.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    } else {
      _favorites.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    }
    notifyListeners();
  }

  /// 按标题排序
  void sortByTitle({bool ascending = true}) {
    if (ascending) {
      _favorites.sort((a, b) =>
          (a.columnTitle ?? '').compareTo(b.columnTitle ?? ''));
    } else {
      _favorites.sort((a, b) =>
          (b.columnTitle ?? '').compareTo(a.columnTitle ?? ''));
    }
    notifyListeners();
  }
}
