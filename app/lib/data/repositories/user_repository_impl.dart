import 'dart:async';

import '../models/user_profile.dart';
import '../datasources/local/user_local_datasource.dart';
import 'user_repository.dart';

/// 用户仓库实现
/// 默认使用SQLite数据源,支持依赖注入其他数据源
class UserRepositoryImpl implements UserRepository {
  final UserLocalDatasource _localDatasource;
  
  /// 是否已初始化完成（用于SQLite数据源的迁移）
  bool _initialized = false;
  
  /// 初始化完成器,用于并发初始化同步
  /// 使用 Completer 模式确保初始化只执行一次,避免竞态条件
  Completer<void>? _initCompleter;

  /// 构造函数
  /// [localDatasource] 可选的数据源,默认使用SqliteUserLocalDatasource
  /// [useMock] 是否使用Mock数据源（用于测试）
  UserRepositoryImpl({
    UserLocalDatasource? localDatasource,
    bool useMock = false,
  }) : _localDatasource = localDatasource ??
           (useMock ? MockUserLocalDatasource() : SqliteUserLocalDatasource());

  /// 确保数据源已初始化
  /// 对于SqliteUserLocalDatasource,会执行数据迁移
  /// 使用 Completer 模式确保并发调用时只初始化一次
  Future<void> _ensureInitialized() async {
    // 快速检查: 已初始化完成直接返回
    if (_initialized) return;
    
    // 检查是否有正在进行的初始化
    // 如果 _initCompleter 不为 null,说明有其他调用正在初始化
    if (_initCompleter != null) {
      await _initCompleter!.future;
      return;
    }
    
    // 创建新的初始化 Completer
    _initCompleter = Completer<void>();
    
    try {
      final datasource = _localDatasource;
      if (datasource is SqliteUserLocalDatasource) {
        await datasource.initialize();
      }
      _initialized = true;
      _initCompleter!.complete();
    } catch (e) {
      // 初始化失败时重置 Completer,允许重试
      _initCompleter = null;
      rethrow;
    }
  }

  @override
  Future<UserProfile?> getUser(String userId) async {
    await _ensureInitialized();
    return await _localDatasource.getUser(userId);
  }

  @override
  Future<void> saveUser(UserProfile user) async {
    await _ensureInitialized();
    await _localDatasource.saveUser(user);
  }

  @override
  Future<void> updateUser(UserProfile user) async {
    await _ensureInitialized();
    await _localDatasource.updateUser(user);
  }

  @override
  Future<void> deleteUser(String userId) async {
    await _ensureInitialized();
    await _localDatasource.deleteUser(userId);
  }

  @override
  Future<List<UserProfile>> getAllUsers() async {
    await _ensureInitialized();
    return await _localDatasource.getAllUsers();
  }

  @override
  Future<bool> isOnboarded(String userId) async {
    final user = await getUser(userId);
    return user?.isOnboarded ?? false;
  }

  @override
  Future<void> setOnboarded(String userId, bool value) async {
    final user = await getUser(userId);
    if (user != null) {
      final updated = UserProfile(
        userId: user.userId,
        userName: user.userName,
        jobIntention: user.jobIntention,
        city: user.city,
        salaryExpect: user.salaryExpect,
        petMemory: user.petMemory,
        vipStatus: user.vipStatus,
        vipExpireTime: user.vipExpireTime,
        isOnboarded: value,
        industryTag: user.industryTag,
        onboardingReport: user.onboardingReport,
        isParkUnlocked: user.isParkUnlocked,
        parkUnlockedAt: user.parkUnlockedAt,
        parkUnlockSource: user.parkUnlockSource,
      );
      await updateUser(updated);
    }
  }

  @override
  Future<bool> isParkUnlocked(String userId) async {
    final user = await getUser(userId);
    return user?.isParkUnlocked ?? false;
  }

  @override
  Future<void> unlockPark(String userId, {String source = 'offer'}) async {
    final user = await getUser(userId);
    if (user != null && !user.isParkUnlocked) {
      final updated = user.copyWith(
        isParkUnlocked: true,
        parkUnlockedAt: Optional(DateTime.now()),
        parkUnlockSource: source,
      );
      await updateUser(updated);
    }
  }
}
