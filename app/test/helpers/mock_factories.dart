import 'package:jobpet/data/models/user_profile.dart';
import 'package:jobpet/features/auth/data/models/auth_user.dart';
import 'package:jobpet/features/pet/data/models/pet_model.dart';
import 'package:jobpet/features/pet/data/models/pet_emotion.dart';

/// Mock工厂
/// 提供创建测试用Mock对象的方法
class MockFactories {
  /// 创建测试用的UserProfile
  static UserProfile createTestUserProfile({
    String userId = 'test_user_001',
    String userName = '测试用户',
    String? jobIntention = '产品经理',
    String? city = '北京',
    String? salaryExpect = '15k-25k',
    bool vipStatus = false,
    DateTime? vipExpireTime,
    bool isOnboarded = true,
    String? industryTag = '互联网',
  }) {
    return UserProfile(
      userId: userId,
      userName: userName,
      jobIntention: jobIntention,
      city: city,
      salaryExpect: salaryExpect,
      vipStatus: vipStatus,
      vipExpireTime: vipExpireTime,
      isOnboarded: isOnboarded,
      industryTag: industryTag,
    );
  }

  /// 创建VIP用户的UserProfile
  static UserProfile createVipUserProfile({
    String userId = 'vip_user_001',
    String userName = 'VIP用户',
    int vipDays = 365,
  }) {
    return UserProfile(
      userId: userId,
      userName: userName,
      vipStatus: true,
      vipExpireTime: DateTime.now().add(Duration(days: vipDays)),
      isOnboarded: true,
    );
  }

  /// 创建测试用的AuthUser
  static AuthUser createTestAuthUser({
    String userId = 'auth_user_001',
    String account = 'testuser',
    String userName = '测试用户',
    bool isLoggedIn = true,
    DateTime? createdAt,
  }) {
    return AuthUser(
      userId: userId,
      account: account,
      userName: userName,
      isLoggedIn: isLoggedIn,
      createdAt: createdAt ?? DateTime.now(),
    );
  }

  /// 创建测试用的PetModel
  static PetModel createTestPetModel({
    String petId = 'pet_001',
    String userId = 'pet_user_001',
    String name = '咕咕',
    PetEmotionType currentEmotion = PetEmotionType.normal,
    int emotionValue = 50,
    int bondLevel = 1,
    double bondExp = 0,
    Map<String, dynamic> stats = const {},
  }) {
    final now = DateTime.now();
    return PetModel(
      petId: petId,
      userId: userId,
      name: name,
      currentEmotion: currentEmotion,
      emotionValue: emotionValue,
      bondLevel: bondLevel,
      bondExp: bondExp,
      lastInteractionTime: now,
      stats: stats,
      createdAt: now,
      updatedAt: now,
    );
  }

  /// 创建测试用的JSON数据（UserProfile）
  static Map<String, dynamic> createTestUserProfileJson({
    String userId = 'test_user_001',
    String userName = '测试用户',
    bool vipStatus = false,
  }) {
    return {
      'userId': userId,
      'userName': userName,
      'jobIntention': '产品经理',
      'city': '北京',
      'salaryExpect': '15k-25k',
      'petMemory': <Map<String, dynamic>>[],
      'vipStatus': vipStatus,
      'vipExpireTime': null,
      'isOnboarded': true,
      'industryTag': '互联网',
      'onboardingReport': null,
    };
  }

  /// 创建测试用的数据库记录（AuthUser）
  static Map<String, dynamic> createTestAuthUserDatabaseMap({
    String userId = 'auth_user_001',
    String account = 'testuser',
    String userName = '测试用户',
    int isLoggedIn = 1,
  }) {
    return {
      'user_id': userId,
      'account': account,
      'user_name': userName,
      'is_logged_in': isLoggedIn,
      'created_at': DateTime.now().toIso8601String(),
    };
  }

  /// 创建测试用的JSON数据（PetModel）
  static Map<String, dynamic> createTestPetModelJson({
    String petId = 'pet_001',
    String userId = 'pet_user_001',
    String name = '咕咕',
    String currentEmotion = 'normal',
    int emotionValue = 50,
    int bondLevel = 1,
    double bondExp = 0,
  }) {
    final now = DateTime.now().toIso8601String();
    return {
      'petId': petId,
      'userId': userId,
      'name': name,
      'currentEmotion': currentEmotion,
      'emotionValue': emotionValue,
      'bondLevel': bondLevel,
      'bondExp': bondExp,
      'lastInteractionTime': now,
      'stats': <String, dynamic>{},
      'createdAt': now,
      'updatedAt': now,
    };
  }
}
