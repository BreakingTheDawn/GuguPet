/// 认证状态枚举
/// 用于表示当前用户的登录状态
enum AuthState {
  /// 未登录（初始状态或已登出）
  unauthenticated,
  
  /// 已登录
  authenticated,
  
  /// 加载中（正在验证登录状态）
  loading,
}

/// 认证状态扩展方法
extension AuthStateExtension on AuthState {
  /// 是否已登录
  bool get isAuthenticated => this == AuthState.authenticated;
  
  /// 是否未登录
  bool get isUnauthenticated => this == AuthState.unauthenticated;
  
  /// 是否正在加载
  bool get isLoading => this == AuthState.loading;
}
