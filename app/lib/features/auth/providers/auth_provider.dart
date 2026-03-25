import 'package:flutter/foundation.dart';
import '../data/models/auth_user.dart';
import '../data/models/auth_state.dart';
import '../data/repositories/auth_repository.dart';
import '../data/repositories/auth_repository_impl.dart';

/// 认证状态管理Provider
/// 全局管理用户登录状态
class AuthProvider extends ChangeNotifier {
  final AuthRepository _repository;
  
  /// 当前认证状态
  AuthState _state = AuthState.loading;
  
  /// 当前登录用户
  AuthUser? _currentUser;
  
  /// 错误信息
  String? _errorMessage;
  
  AuthProvider({AuthRepository? repository})
      : _repository = repository ?? AuthRepositoryImpl();
  
  // ==================== Getters ====================
  
  /// 当前认证状态
  AuthState get state => _state;
  
  /// 当前登录用户
  AuthUser? get currentUser => _currentUser;
  
  /// 是否已登录
  bool get isAuthenticated => _state == AuthState.authenticated;
  
  /// 是否未登录
  bool get isUnauthenticated => _state == AuthState.unauthenticated;
  
  /// 错误信息
  String? get errorMessage => _errorMessage;
  
  // ==================== 公共方法 ====================
  
  /// 初始化认证状态
  /// 应用启动时调用，检查是否有已登录用户
  Future<void> initialize() async {
    _state = AuthState.loading;
    notifyListeners();
    
    try {
      _currentUser = await _repository.getCurrentUser();
      _state = _currentUser?.isLoggedIn == true
          ? AuthState.authenticated
          : AuthState.unauthenticated;
      _errorMessage = null;
    } catch (e) {
      _state = AuthState.unauthenticated;
      _currentUser = null;
      _errorMessage = '初始化认证状态失败: $e';
    }
    
    notifyListeners();
  }
  
  /// 用户注册
  /// [account] 账号（至少3个字符）
  /// [password] 密码（至少6个字符）
  /// [userName] 用户昵称（至少2个字符）
  Future<bool> register({
    required String account,
    required String password,
    required String userName,
  }) async {
    _errorMessage = null;
    
    try {
      final user = await _repository.register(
        account: account,
        password: password,
        userName: userName,
      );
      
      if (user != null) {
        _currentUser = user;
        _state = AuthState.authenticated;
        notifyListeners();
        return true;
      } else {
        _errorMessage = '注册失败，账号可能已存在或输入格式不正确';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = '注册失败: $e';
      notifyListeners();
      return false;
    }
  }
  
  /// 用户登录
  Future<bool> login({
    required String account,
    required String password,
  }) async {
    _errorMessage = null;
    
    try {
      final user = await _repository.login(
        account: account,
        password: password,
      );
      
      if (user != null) {
        _currentUser = user;
        _state = AuthState.authenticated;
        notifyListeners();
        return true;
      } else {
        _errorMessage = '账号或密码错误';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = '登录失败: $e';
      notifyListeners();
      return false;
    }
  }
  
  /// 用户登出
  Future<void> logout() async {
    try {
      await _repository.logout();
      _currentUser = null;
      _state = AuthState.unauthenticated;
      _errorMessage = null;
      notifyListeners();
    } catch (e) {
      _errorMessage = '登出失败: $e';
      notifyListeners();
    }
  }
  
  /// 检查账号是否存在
  Future<bool> isAccountExists(String account) async {
    return await _repository.isAccountExists(account);
  }
  
  /// 清除错误信息
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
