import '../models/auth_user.dart';

/// 认证仓库接口
/// 定义认证相关的业务操作
abstract class AuthRepository {
  /// 用户注册
  Future<AuthUser?> register({
    required String account,
    required String password,
    required String userName,
  });
  
  /// 用户登录
  Future<AuthUser?> login({
    required String account,
    required String password,
  });
  
  /// 用户登出
  Future<void> logout();
  
  /// 获取当前登录用户
  Future<AuthUser?> getCurrentUser();
  
  /// 检查账号是否存在
  Future<bool> isAccountExists(String account);
  
  /// 检查是否已登录
  Future<bool> isAuthenticated();
}
