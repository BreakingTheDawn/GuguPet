import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import '../../data/datasources/local/database_helper.dart';
import 'test_user_initializer.dart';

/// Admin测试用户初始化服务
/// 负责创建预定义的Admin测试账号（需手动登录）
/// 拥有与testVIP完全相同的权益
class TestAdminInitializer {
  /// Admin测试账号配置
  static const String adminAccount = 'testAdmin';
  
  /// Admin测试密码（明文，实际存储时会加密）
  static const String adminPassword = '12345600';
  
  /// Admin测试用户名
  static const String adminUserName = 'Admin测试账号';
  
  /// Admin测试用户是否为VIP（与testVIP一致）
  static const bool adminIsVip = true;
  
  /// VIP有效期天数（与testVIP一致）
  static const int adminVipDays = 365;
  
  /// 所有专栏ID列表（与testVIP一致，1-8）
  static const List<int> allColumnIds = TestUserInitializer.allColumnIds;
  
  /// 密码加密（SHA256）
  /// 与 AuthLocalDatasource 保持一致
  static String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    final hash = sha256.convert(bytes);
    return hash.toString();
  }
  
  /// 初始化Admin测试用户
  /// 创建预定义的Admin测试账号，但不会自动登录
  /// 用户需要使用 adminAccount/adminPassword 手动登录
  static Future<void> initialize() async {
    try {
      final db = await DatabaseHelper().database;
      
      // 检查Admin测试账号是否已存在
      final existing = await db.query(
        DatabaseHelper.tableUsers,
        where: 'account = ?',
        whereArgs: [adminAccount],
        limit: 1,
      );
      
      if (existing.isEmpty) {
        print('[TestAdminInitializer] 创建Admin测试账号: $adminAccount');
        
        // 生成用户ID
        final userId = 'test_admin_${DateTime.now().millisecondsSinceEpoch}';
        final now = DateTime.now().toIso8601String();
        
        // 计算VIP过期时间
        final vipExpireTime = adminIsVip 
            ? DateTime.now().add(Duration(days: adminVipDays)).toIso8601String()
            : null;
        
        // 插入Admin测试用户
        // 注意：is_logged_in = 0，需要手动登录
        await db.insert(
          DatabaseHelper.tableUsers,
          {
            // 认证字段
            'user_id': userId,
            'account': adminAccount,
            'password': _hashPassword(adminPassword),
            'user_name': adminUserName,
            'is_logged_in': 0,  // 不自动登录，需要手动登录
            
            // 用户档案字段（与testVIP一致）
            'job_intention': '产品经理',
            'city': '北京',
            'salary_expect': '15k-25k',
            'pet_memory': '[]',
            'vip_status': adminIsVip ? 1 : 0,
            'vip_expire_time': vipExpireTime,
            'is_onboarded': 1,
            'industry_tag': '互联网',
            'onboarding_report': null,
            'created_at': now,
            'updated_at': now,
          },
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
        
        // 为Admin测试账号初始化所有专栏购买记录（与testVIP一致）
        await _initializeAdminColumnPurchases(db, userId);
        
        print('[TestAdminInitializer] Admin测试账号创建成功');
        print('[TestAdminInitializer] 账号: $adminAccount');
        print('[TestAdminInitializer] 密码: $adminPassword');
        print('[TestAdminInitializer] VIP状态: $adminIsVip');
        print('[TestAdminInitializer] 已解锁所有专栏: ${allColumnIds.length} 个');
      } else {
        print('[TestAdminInitializer] Admin测试账号已存在，跳过创建');
        
        // 检查是否已有专栏购买记录，如果没有则补充
        final userId = existing.first['user_id'] as String;
        await _ensureAdminColumnPurchases(db, userId);
      }
    } catch (e, stackTrace) {
      print('[TestAdminInitializer] 初始化Admin测试用户失败: $e');
      print('[TestAdminInitializer] 堆栈跟踪: $stackTrace');
      // 初始化失败不影响应用启动
    }
  }
  
  /// 为Admin测试账号初始化所有专栏购买记录
  /// VIP用户免费领取所有专栏，purchaseType为'vip'
  /// 与testVIP完全一致
  static Future<void> _initializeAdminColumnPurchases(Database db, String userId) async {
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
      
      print('[TestAdminInitializer] 已为Admin账号初始化 ${allColumnIds.length} 个专栏购买记录');
    } catch (e) {
      print('[TestAdminInitializer] 初始化专栏购买记录失败: $e');
    }
  }
  
  /// 确保已存在的Admin账号有专栏购买记录
  /// 与testVIP完全一致
  static Future<void> _ensureAdminColumnPurchases(Database db, String userId) async {
    try {
      // 检查是否已有购买记录
      final existingPurchases = await db.query(
        DatabaseHelper.tablePurchasedColumns,
        where: 'user_id = ?',
        whereArgs: [userId],
      );
      
      // 如果购买记录数量少于专栏总数，补充缺失的记录
      if (existingPurchases.length < allColumnIds.length) {
        print('[TestAdminInitializer] 补充Admin账号的专栏购买记录');
        
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
        
        print('[TestAdminInitializer] 已补充缺失的专栏购买记录');
      }
    } catch (e) {
      print('[TestAdminInitializer] 检查专栏购买记录失败: $e');
    }
  }
  
  /// 获取Admin测试账号
  static String getAdminAccount() => adminAccount;
  
  /// 获取Admin测试密码
  static String getAdminPassword() => adminPassword;
  
  /// 获取Admin测试用户名
  static String getAdminUserName() => adminUserName;
  
  /// 获取Admin测试用户VIP状态
  static bool getAdminVipStatus() => adminIsVip;
  
  /// 打印Admin测试账号信息（用于调试）
  static void printAdminAccountInfo() {
    print('========================================');
    print('Admin测试账号信息:');
    print('账号: $adminAccount');
    print('密码: $adminPassword');
    print('用户名: $adminUserName');
    print('VIP状态: $adminIsVip');
    print('VIP有效期: $adminVipDays 天');
    print('已解锁专栏: ${allColumnIds.length} 个');
    print('========================================');
  }
  
  /// 打印所有测试账号信息（VIP + Admin）
  static void printAllTestAccountsInfo() {
    print('');
    print('╔══════════════════════════════════════════════════╗');
    print('║              测试账号信息汇总                    ║');
    print('╠══════════════════════════════════════════════════╣');
    print('║                                                  ║');
    print('║  【账号1】testVIP                                ║');
    print('║   密码: 123456                                   ║');
    print('║   用户名: VIP测试账号                            ║');
    print('║   VIP状态: ✅ 已激活                            ║');
    print('║   VIP有效期: 365天                               ║');
    print('║   已解锁专栏: 8个                                ║');
    print('║                                                  ║');
    print('║  【账号2】testAdmin                              ║');
    print('║   密码: 12345600                                 ║');
    print('║   用户名: Admin测试账号                          ║');
    print('║   VIP状态: ✅ 已激活                            ║');
    print('║   VIP有效期: 365天                               ║');
    print('║   已解锁专栏: 8个                                ║');
    print('║                                                  ║');
    print('╚══════════════════════════════════════════════════╝');
    print('');
  }
}
