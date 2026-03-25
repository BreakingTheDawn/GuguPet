import '../../data/models/user_profile.dart';
import '../../data/repositories/user_repository.dart';
import '../di/repository_provider.dart';

/// 测试用户初始化服务
/// 负责在应用启动时创建默认测试用户
class TestUserInitializer {
  static const String testUserId = 'default_user';
  static const String testUserName = '测试用户';
  
  /// 初始化测试用户
  /// 如果用户不存在则创建，存在则跳过
  static Future<void> initialize() async {
    try {
      final userRepository = repositoryProvider.userRepository;
      
      // 检查测试用户是否已存在
      final existingUser = await userRepository.getUser(testUserId);
      
      if (existingUser == null) {
        print('[TestUserInitializer] 创建测试用户: $testUserId');
        
        // 创建测试用户
        final testUser = UserProfile(
          userId: testUserId,
          userName: testUserName,
          jobIntention: '产品经理',
          city: '北京',
          salaryExpect: '15k-25k',
          vipStatus: false,
          isOnboarded: true,
          industryTag: '互联网',
        );
        
        await userRepository.saveUser(testUser);
        print('[TestUserInitializer] 测试用户创建成功');
      } else {
        print('[TestUserInitializer] 测试用户已存在，跳过创建');
      }
    } catch (e, stackTrace) {
      print('[TestUserInitializer] 初始化测试用户失败: $e');
      print('[TestUserInitializer] 堆栈跟踪: $stackTrace');
      // 初始化失败不影响应用启动
    }
  }
  
  /// 获取测试用户ID
  static String getTestUserId() => testUserId;
  
  /// 获取测试用户名
  static String getTestUserName() => testUserName;
}
