import '../models/user_profile.dart';

/// 用户仓库接口
/// 定义用户数据的业务操作
abstract class UserRepository {
  /// 获取指定用户
  Future<UserProfile?> getUser(String userId);
  
  /// 保存用户
  Future<void> saveUser(UserProfile user);
  
  /// 更新用户
  Future<void> updateUser(UserProfile user);
  
  /// 删除用户
  Future<void> deleteUser(String userId);
  
  /// 获取所有用户
  Future<List<UserProfile>> getAllUsers();
  
  /// 检查用户是否已完成入职
  Future<bool> isOnboarded(String userId);
  
  /// 设置用户入职状态
  Future<void> setOnboarded(String userId, bool value);
}
