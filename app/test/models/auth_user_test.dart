import 'package:flutter_test/flutter_test.dart';
import 'package:jobpet/features/auth/data/models/auth_user.dart';
import '../helpers/mock_factories.dart';

/// AuthUser 模型单元测试
void main() {
  group('AuthUser Model Tests', () {

    group('构造函数测试', () {
      test('应该正确创建AuthUser实例', () {
        final createdAt = DateTime(2026, 1, 1);
        final user = MockFactories.createTestAuthUser(
          userId: 'user_001',
          account: 'testaccount',
          userName: '测试用户',
          isLoggedIn: true,
          createdAt: createdAt,
        );

        expect(user.userId, equals('user_001'));
        expect(user.account, equals('testaccount'));
        expect(user.userName, equals('测试用户'));
        expect(user.isLoggedIn, isTrue);
        expect(user.createdAt, equals(createdAt));
      });

      test('应该使用默认值创建AuthUser', () {
        final user = AuthUser(
          userId: 'test_id',
          account: 'test',
          userName: '测试',
        );

        expect(user.isLoggedIn, isFalse);
        expect(user.createdAt, isNull);
      });
    });

    group('fromDatabase测试', () {
      test('应该正确从数据库记录创建实例', () {
        final dbMap = MockFactories.createTestAuthUserDatabaseMap(
          userId: 'db_user_001',
          account: 'dbaccount',
          userName: '数据库用户',
          isLoggedIn: 1,
        );

        final user = AuthUser.fromDatabase(dbMap);

        expect(user.userId, equals('db_user_001'));
        expect(user.account, equals('dbaccount'));
        expect(user.userName, equals('数据库用户'));
        expect(user.isLoggedIn, isTrue);
      });

      test('未登录用户应该正确解析', () {
        final dbMap = MockFactories.createTestAuthUserDatabaseMap(
          isLoggedIn: 0,
        );

        final user = AuthUser.fromDatabase(dbMap);

        expect(user.isLoggedIn, isFalse);
      });

      test('包含创建时间应该正确解析', () async {
        final createdAt = DateTime(2026, 3, 27, 10, 30);
        final dbMap = {
          'user_id': 'user_001',
          'account': 'test',
          'user_name': '测试',
          'is_logged_in': 1,
          'created_at': createdAt.toIso8601String(),
        };

        final user = AuthUser.fromDatabase(dbMap);

        expect(user.createdAt, isNotNull);
        expect(user.createdAt!.year, equals(2026));
        expect(user.createdAt!.month, equals(3));
        expect(user.createdAt!.day, equals(27));
      });
    });

    group('toDatabaseMap测试', () {
      test('应该正确转换为数据库格式', () {
        final user = MockFactories.createTestAuthUser(
          userId: 'user_002',
          account: 'account002',
          userName: '用户002',
          isLoggedIn: true,
        );

        final dbMap = user.toDatabaseMap();

        expect(dbMap['user_id'], equals('user_002'));
        expect(dbMap['account'], equals('account002'));
        expect(dbMap['user_name'], equals('用户002'));
        expect(dbMap['is_logged_in'], equals(1));
      });

      test('未登录用户应该输出正确的登录状态', () {
        final user = MockFactories.createTestAuthUser(isLoggedIn: false);

        final dbMap = user.toDatabaseMap();

        expect(dbMap['is_logged_in'], equals(0));
      });

      test('创建时间应该正确输出', () {
        final createdAt = DateTime(2026, 3, 27);
        final user = MockFactories.createTestAuthUser(createdAt: createdAt);

        final dbMap = user.toDatabaseMap();

        expect(dbMap['created_at'], isNotNull);
        expect(dbMap['created_at'], equals(createdAt.toIso8601String()));
      });
    });

    group('copyWith测试', () {
      test('应该正确复制并更新字段', () {
        final original = MockFactories.createTestAuthUser(
          userId: 'original_id',
          account: 'original_account',
          userName: '原始用户',
          isLoggedIn: false,
        );

        final copied = original.copyWith(
          userName: '新用户名',
          isLoggedIn: true,
        );

        expect(copied.userId, equals('original_id'));
        expect(copied.account, equals('original_account'));
        expect(copied.userName, equals('新用户名'));
        expect(copied.isLoggedIn, isTrue);
      });

      test('不传参数应该返回相同值的副本', () {
        final original = MockFactories.createTestAuthUser();

        final copied = original.copyWith();

        expect(copied.userId, equals(original.userId));
        expect(copied.account, equals(original.account));
        expect(copied.userName, equals(original.userName));
        expect(copied.isLoggedIn, equals(original.isLoggedIn));
      });

      test('应该能更新所有字段', () {
        final original = MockFactories.createTestAuthUser();
        final newCreatedAt = DateTime(2025, 1, 1);

        final copied = original.copyWith(
          userId: 'new_id',
          account: 'new_account',
          userName: '新用户',
          isLoggedIn: false,
          createdAt: newCreatedAt,
        );

        expect(copied.userId, equals('new_id'));
        expect(copied.account, equals('new_account'));
        expect(copied.userName, equals('新用户'));
        expect(copied.isLoggedIn, isFalse);
        expect(copied.createdAt, equals(newCreatedAt));
      });
    });

    group('序列化往返测试', () {
      test('toDatabaseMap和fromDatabase应该互逆', () {
        final original = MockFactories.createTestAuthUser(
          userId: 'round_trip_user',
          account: 'roundtrip',
          userName: '往返测试',
          isLoggedIn: true,
          createdAt: DateTime.now(),
        );

        final dbMap = original.toDatabaseMap();
        final restored = AuthUser.fromDatabase(dbMap);

        expect(restored.userId, equals(original.userId));
        expect(restored.account, equals(original.account));
        expect(restored.userName, equals(original.userName));
        expect(restored.isLoggedIn, equals(original.isLoggedIn));
      });
    });

    group('边界条件测试', () {
      test('空字符串字段应该正确处理', () {
        final user = AuthUser(
          userId: '',
          account: '',
          userName: '',
        );

        final dbMap = user.toDatabaseMap();
        final restored = AuthUser.fromDatabase(dbMap);

        expect(restored.userId, isEmpty);
        expect(restored.account, isEmpty);
        expect(restored.userName, isEmpty);
      });

      test('特殊字符应该正确处理', () {
        final user = AuthUser(
          userId: 'user_测试_123',
          account: 'account<>&"\'',
          userName: '用户名@#\$%',
        );

        final dbMap = user.toDatabaseMap();
        final restored = AuthUser.fromDatabase(dbMap);

        expect(restored.userId, equals('user_测试_123'));
        expect(restored.account, equals('account<>&"\''));
        expect(restored.userName, equals('用户名@#\$%'));
      });
    });
  });
}
