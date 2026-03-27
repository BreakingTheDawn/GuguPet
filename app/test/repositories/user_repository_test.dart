import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:jobpet/data/models/user_profile.dart';
import 'package:jobpet/data/datasources/local/user_local_datasource.dart';
import 'package:jobpet/data/repositories/user_repository_impl.dart';

import 'user_repository_test.mocks.dart';

/// UserRepository 单元测试
/// 使用 MockUserLocalDatasourceGenerated 进行隔离测试
/// 注意：重命名生成的 Mock 类以避免与 user_local_datasource.dart 中的 MockUserLocalDatasource 冲突
@GenerateNiceMocks([MockSpec<UserLocalDatasource>(as: #MockUserLocalDatasourceGenerated)])
void main() {
  late UserRepositoryImpl repository;
  late MockUserLocalDatasourceGenerated mockDatasource;

  setUp(() {
    mockDatasource = MockUserLocalDatasourceGenerated();
    repository = UserRepositoryImpl(localDatasource: mockDatasource);
  });

  group('UserRepository CRUD测试', () {
    test('应该正确保存用户', () async {
      final user = UserProfile(
        userId: 'save_test_user',
        userName: '保存测试用户',
      );

      when(mockDatasource.saveUser(any))
          .thenAnswer((_) async {});

      await repository.saveUser(user);

      verify(mockDatasource.saveUser(user)).called(1);
    });

    test('应该正确获取用户', () async {
      final user = UserProfile(
        userId: 'get_test_user',
        userName: '获取测试用户',
        jobIntention: '前端开发',
        city: '上海',
      );

      when(mockDatasource.getUser('get_test_user'))
          .thenAnswer((_) async => user);

      final result = await repository.getUser('get_test_user');

      expect(result, isNotNull);
      expect(result!.userId, equals('get_test_user'));
      expect(result.userName, equals('获取测试用户'));
      expect(result.jobIntention, equals('前端开发'));
      expect(result.city, equals('上海'));
    });

    test('获取不存在的用户应该返回null', () async {
      when(mockDatasource.getUser('non_existent_user'))
          .thenAnswer((_) async => null);

      final result = await repository.getUser('non_existent_user');

      expect(result, isNull);
    });

    test('应该正确更新用户', () async {
      final user = UserProfile(
        userId: 'update_test_user',
        userName: '更新后用户名',
        city: '深圳',
      );

      when(mockDatasource.updateUser(any))
          .thenAnswer((_) async {});

      await repository.updateUser(user);

      verify(mockDatasource.updateUser(user)).called(1);
    });

    test('应该正确删除用户', () async {
      when(mockDatasource.deleteUser('delete_test_user'))
          .thenAnswer((_) async {});

      await repository.deleteUser('delete_test_user');

      verify(mockDatasource.deleteUser('delete_test_user')).called(1);
    });

    test('应该正确获取所有用户', () async {
      final users = [
        UserProfile(userId: 'user_1', userName: '用户1'),
        UserProfile(userId: 'user_2', userName: '用户2'),
        UserProfile(userId: 'user_3', userName: '用户3'),
      ];

      when(mockDatasource.getAllUsers())
          .thenAnswer((_) async => users);

      final result = await repository.getAllUsers();

      expect(result.length, equals(3));
      expect(result[0].userId, equals('user_1'));
    });
  });

  group('UserRepository VIP状态测试', () {
    test('应该正确保存VIP用户', () async {
      final vipUser = UserProfile(
        userId: 'vip_test_user',
        userName: 'VIP用户',
        vipStatus: true,
        vipExpireTime: DateTime.now().add(Duration(days: 365)),
      );

      when(mockDatasource.saveUser(any))
          .thenAnswer((_) async {});

      await repository.saveUser(vipUser);

      verify(mockDatasource.saveUser(argThat(
        isA<UserProfile>()
            .having((u) => u.vipStatus, 'vipStatus', isTrue)
            .having((u) => u.vipExpireTime, 'vipExpireTime', isNotNull),
      ))).called(1);
    });

    test('应该正确获取VIP用户信息', () async {
      final vipExpireTime = DateTime.now().add(Duration(days: 100));
      final vipUser = UserProfile(
        userId: 'vip_get_user',
        userName: 'VIP获取测试',
        vipStatus: true,
        vipExpireTime: vipExpireTime,
      );

      when(mockDatasource.getUser('vip_get_user'))
          .thenAnswer((_) async => vipUser);

      final result = await repository.getUser('vip_get_user');

      expect(result, isNotNull);
      expect(result!.vipStatus, isTrue);
      expect(result.vipExpireTime, isNotNull);
    });
  });

  group('UserRepository 入职状态测试', () {
    test('应该正确检查入职状态', () async {
      final user = UserProfile(
        userId: 'onboard_test_user',
        userName: '入职测试用户',
        isOnboarded: true,
      );

      when(mockDatasource.getUser('onboard_test_user'))
          .thenAnswer((_) async => user);

      final result = await repository.isOnboarded('onboard_test_user');

      expect(result, isTrue);
    });

    test('未入职用户应该返回false', () async {
      final user = UserProfile(
        userId: 'not_onboard_user',
        userName: '未入职用户',
        isOnboarded: false,
      );

      when(mockDatasource.getUser('not_onboard_user'))
          .thenAnswer((_) async => user);

      final result = await repository.isOnboarded('not_onboard_user');

      expect(result, isFalse);
    });

    test('不存在的用户应该返回false', () async {
      when(mockDatasource.getUser('non_existent_user'))
          .thenAnswer((_) async => null);

      final result = await repository.isOnboarded('non_existent_user');

      expect(result, isFalse);
    });

    test('应该正确设置入职状态', () async {
      final user = UserProfile(
        userId: 'set_onboard_user',
        userName: '设置入职用户',
        isOnboarded: false,
      );

      when(mockDatasource.getUser('set_onboard_user'))
          .thenAnswer((_) async => user);
      when(mockDatasource.updateUser(any))
          .thenAnswer((_) async {});

      await repository.setOnboarded('set_onboard_user', true);

      verify(mockDatasource.updateUser(argThat(
        isA<UserProfile>()
            .having((u) => u.isOnboarded, 'isOnboarded', isTrue),
      ))).called(1);
    });
  });

  group('UserRepository 边界条件测试', () {
    test('应该正确处理空字符串用户ID', () async {
      when(mockDatasource.getUser(''))
          .thenAnswer((_) async => null);

      final result = await repository.getUser('');

      expect(result, isNull);
    });

    test('应该正确处理特殊字符用户名', () async {
      final user = UserProfile(
        userId: 'special_char_user',
        userName: '用户<>&"\'特殊字符',
      );

      when(mockDatasource.getUser('special_char_user'))
          .thenAnswer((_) async => user);

      final result = await repository.getUser('special_char_user');

      expect(result!.userName, equals('用户<>&"\'特殊字符'));
    });
  });
}
