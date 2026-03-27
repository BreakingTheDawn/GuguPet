import '../datasources/auth_datasource.dart';
import '../datasources/auth_local_datasource.dart';
import '../models/auth_user.dart';
import 'auth_repository.dart';

/// 认证仓库实现
/// 封装认证相关的业务逻辑
/// 支持 AuthDatasource 接口注入，便于测试和依赖注入
class AuthRepositoryImpl implements AuthRepository {
  final AuthDatasource _localDatasource;
  
  AuthRepositoryImpl({AuthDatasource? localDatasource})
      : _localDatasource = localDatasource ?? AuthLocalDatasource();
  
  @override
  Future<AuthUser?> register({
    required String account,
    required String password,
    required String userName,
  }) async {
    // 验证账号格式（至少3个字符）
    if (account.length < 3) {
      return null;
    }
    
    // 验证密码格式（至少6个字符）
    if (password.length < 6) {
      return null;
    }
    
    // 验证用户名（至少2个字符）
    if (userName.length < 2) {
      return null;
    }
    
    return await _localDatasource.register(
      account: account,
      password: password,
      userName: userName,
    );
  }
  
  @override
  Future<AuthUser?> login({
    required String account,
    required String password,
  }) async {
    return await _localDatasource.login(
      account: account,
      password: password,
    );
  }
  
  @override
  Future<void> logout() async {
    final user = await getCurrentUser();
    if (user != null) {
      await _localDatasource.logout(user.userId);
    }
  }
  
  @override
  Future<AuthUser?> getCurrentUser() async {
    return await _localDatasource.getCurrentUser();
  }
  
  @override
  Future<bool> isAccountExists(String account) async {
    return await _localDatasource.isAccountExists(account);
  }
  
  @override
  Future<bool> isAuthenticated() async {
    final user = await getCurrentUser();
    return user != null && user.isLoggedIn;
  }
}
