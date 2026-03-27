import '../models/auth_user.dart';

/// 认证数据源接口
/// 定义认证相关的数据操作抽象方法
/// 支持依赖注入和测试Mock
abstract class AuthDatasource {
  /// 注册新用户
  /// [account] 账号
  /// [password] 密码
  /// [userName] 用户名
  /// 返回注册结果：成功返回AuthUser，失败返回null
  Future<AuthUser?> register({
    required String account,
    required String password,
    required String userName,
  });

  /// 用户登录
  /// [account] 账号
  /// [password] 密码
  /// 返回登录结果：成功返回AuthUser，失败返回null
  Future<AuthUser?> login({
    required String account,
    required String password,
  });

  /// 用户登出
  /// [userId] 用户ID
  Future<void> logout(String userId);

  /// 获取当前登录用户
  /// 返回当前登录的用户，未登录返回null
  Future<AuthUser?> getCurrentUser();

  /// 检查账号是否存在
  /// [account] 账号
  /// 返回账号是否存在
  Future<bool> isAccountExists(String account);
}
