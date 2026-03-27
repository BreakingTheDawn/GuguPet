import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import '../../data/datasources/local/database_helper.dart';

/// 测试用户初始化服务
/// 负责创建预定义的测试账号（需手动登录）
class TestUserInitializer {
  /// 测试账号配置
  static const String testAccount = 'testVIP';
  
  /// 测试密码（明文，实际存储时会加密）
  static const String testPassword = '123456';
  
  /// 测试用户名
  static const String testUserName = 'VIP测试账号';
  
  /// 测试用户是否为VIP
  static const bool testUserIsVip = true;
  
  /// VIP有效期天数（从创建日期开始计算）
  static const int testUserVipDays = 365;
  
  /// 所有专栏ID列表（1-8）
  static const List<int> allColumnIds = [1, 2, 3, 4, 5, 6, 7, 8];
  
  /// 密码加密（SHA256）
  /// 与 AuthLocalDatasource 保持一致
  static String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    final hash = sha256.convert(bytes);
    return hash.toString();
  }
  
  /// 初始化测试用户
  /// 创建预定义的测试账号，但不会自动登录
  /// 用户需要使用 testAccount/testPassword 手动登录
  static Future<void> initialize() async {
    try {
      final db = await DatabaseHelper().database;
      
      // 检查测试账号是否已存在
      final existing = await db.query(
        DatabaseHelper.tableUsers,
        where: 'account = ?',
        whereArgs: [testAccount],
        limit: 1,
      );
      
      if (existing.isEmpty) {
        print('[TestUserInitializer] 创建测试VIP账号: $testAccount');
        
        // 生成用户ID
        final userId = 'test_vip_${DateTime.now().millisecondsSinceEpoch}';
        final now = DateTime.now().toIso8601String();
        
        // 计算VIP过期时间
        final vipExpireTime = testUserIsVip 
            ? DateTime.now().add(Duration(days: testUserVipDays)).toIso8601String()
            : null;
        
        // 插入测试用户
        // 注意：is_logged_in = 0，需要手动登录
        await db.insert(
          DatabaseHelper.tableUsers,
          {
            // 认证字段
            'user_id': userId,
            'account': testAccount,
            'password': _hashPassword(testPassword),
            'user_name': testUserName,
            'is_logged_in': 0,  // 不自动登录，需要手动登录
            
            // 用户档案字段
            'job_intention': '产品经理',
            'city': '北京',
            'salary_expect': '15k-25k',
            'pet_memory': '[]',
            'vip_status': testUserIsVip ? 1 : 0,
            'vip_expire_time': vipExpireTime,
            'is_onboarded': 1,
            'industry_tag': '互联网',
            'onboarding_report': null,
            'created_at': now,
            'updated_at': now,
          },
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
        
        // 为VIP测试账号初始化所有专栏购买记录
        await _initializeVipColumnPurchases(db, userId);
        
        print('[TestUserInitializer] 测试VIP账号创建成功');
        print('[TestUserInitializer] 账号: $testAccount');
        print('[TestUserInitializer] 密码: $testPassword');
        print('[TestUserInitializer] VIP状态: $testUserIsVip');
        print('[TestUserInitializer] 已解锁所有专栏: ${allColumnIds.length} 个');
      } else {
        print('[TestUserInitializer] 测试账号已存在，跳过创建');
        
        // 检查是否已有专栏购买记录，如果没有则补充
        final userId = existing.first['user_id'] as String;
        await _ensureVipColumnPurchases(db, userId);
      }
    } catch (e, stackTrace) {
      print('[TestUserInitializer] 初始化测试用户失败: $e');
      print('[TestUserInitializer] 堆栈跟踪: $stackTrace');
      // 初始化失败不影响应用启动
    }
  }
  
  /// 为VIP测试账号初始化所有专栏购买记录
  /// VIP用户免费领取所有专栏，purchaseType为'vip'
  static Future<void> _initializeVipColumnPurchases(Database db, String userId) async {
    try {
      final now = DateTime.now();
      
      for (final columnId in allColumnIds) {
        final recordId = '${userId}_${columnId}_vip_${now.millisecondsSinceEpoch}';
        
        await db.insert(
          DatabaseHelper.tablePurchasedColumns,
          {
            'id': recordId,
            'user_id': userId,
            'column_id': columnId.toString(),
            'purchase_type': 'vip',  // VIP免费领取类型
            'purchase_price': null,  // VIP免费，价格为null
            'purchased_at': now.toIso8601String(),
          },
          conflictAlgorithm: ConflictAlgorithm.ignore,
        );
      }
      
      print('[TestUserInitializer] 已为VIP账号初始化 ${allColumnIds.length} 个专栏购买记录');
    } catch (e) {
      print('[TestUserInitializer] 初始化专栏购买记录失败: $e');
    }
  }
  
  /// 确保已存在的VIP账号有专栏购买记录
  static Future<void> _ensureVipColumnPurchases(Database db, String userId) async {
    try {
      // 检查是否已有购买记录
      final existingPurchases = await db.query(
        DatabaseHelper.tablePurchasedColumns,
        where: 'user_id = ?',
        whereArgs: [userId],
      );
      
      // 如果购买记录数量少于专栏总数，补充缺失的记录
      if (existingPurchases.length < allColumnIds.length) {
        print('[TestUserInitializer] 补充VIP账号的专栏购买记录');
        
        final purchasedColumnIds = existingPurchases
            .map((p) => int.tryParse(p['column_id'] as String))
            .whereType<int>()
            .toSet();
        
        final now = DateTime.now();
        
        for (final columnId in allColumnIds) {
          if (!purchasedColumnIds.contains(columnId)) {
            final recordId = '${userId}_${columnId}_vip_${now.millisecondsSinceEpoch}';
            
            await db.insert(
              DatabaseHelper.tablePurchasedColumns,
              {
                'id': recordId,
                'user_id': userId,
                'column_id': columnId.toString(),
                'purchase_type': 'vip',
                'purchase_price': null,
                'purchased_at': now.toIso8601String(),
              },
              conflictAlgorithm: ConflictAlgorithm.ignore,
            );
          }
        }
        
        print('[TestUserInitializer] 已补充缺失的专栏购买记录');
      }
    } catch (e) {
      print('[TestUserInitializer] 检查专栏购买记录失败: $e');
    }
  }
  
  /// 获取测试账号
  static String getTestAccount() => testAccount;
  
  /// 获取测试密码
  static String getTestPassword() => testPassword;
  
  /// 获取测试用户名
  static String getTestUserName() => testUserName;
  
  /// 获取测试用户VIP状态
  static bool getTestUserVipStatus() => testUserIsVip;
  
  /// 打印测试账号信息（用于调试）
  static void printTestAccountInfo() {
    print('========================================');
    print('测试账号信息:');
    print('账号: $testAccount');
    print('密码: $testPassword');
    print('用户名: $testUserName');
    print('VIP状态: $testUserIsVip');
    print('VIP有效期: $testUserVipDays 天');
    print('已解锁专栏: ${allColumnIds.length} 个');
    print('========================================');
  }
}
