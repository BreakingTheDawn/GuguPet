import 'package:flutter/foundation.dart';
import '../data/models/column_content.dart';
import '../services/column_service.dart';

// ═══════════════════════════════════════════════════════════════════════════════
/// 专栏状态管理Provider
/// 负责管理专栏详情页面的状态，包括内容、购买状态、收藏状态等
// ═══════════════════════════════════════════════════════════════════════════════
class ColumnProvider extends ChangeNotifier {
  // ────────────────────────────────────────────────────────────────────────────
  // 依赖注入
  // ────────────────────────────────────────────────────────────────────────────

  /// 专栏业务服务
  final ColumnService _columnService;

  ColumnProvider({
    required ColumnService columnService,
  }) : _columnService = columnService;

  // ────────────────────────────────────────────────────────────────────────────
  // 状态变量
  // ────────────────────────────────────────────────────────────────────────────

  /// 当前专栏内容
  ColumnContent? _columnContent;

  /// 是否已购买
  bool _isPurchased = false;

  /// 是否已收藏
  bool _isFavorited = false;

  /// 是否正在加载
  bool _isLoading = false;

  /// 是否正在执行操作（购买、收藏等）
  bool _isOperating = false;

  /// 错误信息
  String? _errorMessage;

  /// 当前用户ID
  String _userId = 'default_user';

  // ────────────────────────────────────────────────────────────────────────────
  // Getter方法
  // ────────────────────────────────────────────────────────────────────────────

  /// 获取专栏内容
  ColumnContent? get columnContent => _columnContent;

  /// 获取购买状态
  bool get isPurchased => _isPurchased;

  /// 获取收藏状态
  bool get isFavorited => _isFavorited;

  /// 获取加载状态
  bool get isLoading => _isLoading;

  /// 获取操作状态
  bool get isOperating => _isOperating;

  /// 获取错误信息
  String? get errorMessage => _errorMessage;

  /// 获取用户ID
  String get userId => _userId;

  /// 获取专栏标题
  String get columnTitle => _columnContent?.title ?? '';

  /// 获取专栏价格
  double get columnPrice => _columnContent?.price ?? 0;

  /// 获取格式化价格
  String get formattedPrice => _columnService.formatPrice(columnPrice);

  /// 判断是否可以阅读完整内容
  bool get canReadFullContent => _isPurchased || columnPrice == 0;

  // ────────────────────────────────────────────────────────────────────────────
  // 公共方法
  // ────────────────────────────────────────────────────────────────────────────

  /// 加载专栏详情
  /// [columnId] 专栏ID
  /// [userId] 用户ID，可选，默认为 'default_user'
  Future<void> loadColumnDetail(
    String columnId, {
    String? userId,
  }) async {
    // 设置加载状态
    _isLoading = true;
    _errorMessage = null;
    if (userId != null) {
      _userId = userId;
    }
    notifyListeners();

    try {
      // 获取专栏内容
      final content = await _columnService.getColumnContent(
        columnId,
        userId: _userId,
      );

      if (content == null) {
        _isLoading = false;
        _errorMessage = '专栏不存在';
        notifyListeners();
        return;
      }

      // 更新状态
      _columnContent = content;
      _isPurchased = content.isPurchased;
      _isFavorited = content.isFavorite;
      _isLoading = false;

      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = '加载专栏详情失败: $e';
      debugPrint('ColumnProvider Error: $e');
      notifyListeners();
    }
  }

  /// 购买专栏
  /// 返回是否购买成功
  Future<bool> purchaseColumn() async {
    if (_columnContent == null) {
      debugPrint('专栏内容为空，无法购买');
      return false;
    }

    // 检查是否已购买
    if (_isPurchased) {
      debugPrint('专栏已购买，无需重复购买');
      return true;
    }

    // 设置操作状态
    _isOperating = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // 执行购买
      final success = await _columnService.purchaseColumn(
        _userId,
        _columnContent!.id,
        _columnContent!.price,
      );

      if (success) {
        _isPurchased = true;
        _isOperating = false;
        notifyListeners();
        return true;
      } else {
        _isOperating = false;
        _errorMessage = '购买失败，请稍后重试';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _isOperating = false;
      _errorMessage = '购买失败: $e';
      debugPrint('购买专栏失败: $e');
      notifyListeners();
      rethrow;
    }
  }

  /// 切换收藏状态
  /// 返回最新的收藏状态
  Future<bool> toggleFavorite() async {
    if (_columnContent == null) {
      debugPrint('专栏内容为空，无法切换收藏状态');
      return false;
    }

    // 设置操作状态
    _isOperating = true;
    notifyListeners();

    try {
      // 切换收藏状态
      final isFavorited = await _columnService.toggleFavorite(
        _userId,
        _columnContent!.id,
        columnTitle: _columnContent!.title,
      );

      _isFavorited = isFavorited;
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

  /// 添加收藏
  /// 返回是否收藏成功
  Future<bool> addToFavorites() async {
    if (_columnContent == null) {
      debugPrint('专栏内容为空，无法收藏');
      return false;
    }

    // 设置操作状态
    _isOperating = true;
    notifyListeners();

    try {
      final success = await _columnService.addToFavorites(
        _userId,
        _columnContent!.id,
        columnTitle: _columnContent!.title,
      );

      if (success) {
        _isFavorited = true;
      }

      _isOperating = false;
      notifyListeners();
      return success;
    } catch (e) {
      _isOperating = false;
      debugPrint('收藏专栏失败: $e');
      notifyListeners();
      rethrow;
    }
  }

  /// 取消收藏
  /// 返回是否取消成功
  Future<bool> removeFromFavorites() async {
    if (_columnContent == null) {
      debugPrint('专栏内容为空，无法取消收藏');
      return false;
    }

    // 设置操作状态
    _isOperating = true;
    notifyListeners();

    try {
      final success = await _columnService.removeFromFavorites(
        _userId,
        _columnContent!.id,
      );

      if (success) {
        _isFavorited = false;
      }

      _isOperating = false;
      notifyListeners();
      return success;
    } catch (e) {
      _isOperating = false;
      debugPrint('取消收藏失败: $e');
      notifyListeners();
      rethrow;
    }
  }

  /// 刷新购买状态
  Future<void> refreshPurchaseStatus() async {
    if (_columnContent == null) return;

    try {
      _isPurchased = await _columnService.checkPurchaseStatus(
        _userId,
        _columnContent!.id,
      );
      notifyListeners();
    } catch (e) {
      debugPrint('刷新购买状态失败: $e');
    }
  }

  /// 刷新收藏状态
  Future<void> refreshFavoriteStatus() async {
    if (_columnContent == null) return;

    try {
      _isFavorited = await _columnService.checkFavoriteStatus(
        _userId,
        _columnContent!.id,
      );
      notifyListeners();
    } catch (e) {
      debugPrint('刷新收藏状态失败: $e');
    }
  }

  /// 清除数据
  void clear() {
    _columnContent = null;
    _isPurchased = false;
    _isFavorited = false;
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
}
