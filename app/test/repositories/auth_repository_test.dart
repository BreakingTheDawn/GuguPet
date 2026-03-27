import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:jobpet/features/auth/data/datasources/auth_datasource.dart';
import 'package:jobpet/features/auth/data/models/auth_user.dart';
import 'package:jobpet/features/auth/data/repositories/auth_repository_impl.dart';

import 'auth_repository_test.mocks.dart';

/// AuthRepository 单元测试
/// 使用 Mock AuthDatasource 进行隔离测试
@GenerateMocks([AuthDatasource])
void main() {
  late AuthRepositoryImpl repository;
  late MockAuthDatasource mockDatasource;

  setUp(() {
    mockDatasource = MockAuthDatasource();
    repository = AuthRepositoryImpl(localDatasource: mockDatasource);
  });

  group('AuthRepository 注册测试', () {
    test('应该成功注册新用户', () async {
      final testUser = AuthUser(
        userId: 'user_001',
        account: 'testuser',
        userName: '测试用户',
        isLoggedIn: true,
        createdAt: DateTime.now(),
      );

      when(mockDatasource.register(
        account: anyNamed('account'),
        password: anyNamed('password'),
        userName: anyNamed('userName'),
      )).thenAnswer((_) async => testUser);

      final result = await repository.register(
        account: 'testuser',
        password: '123456',
        userName: '测试用户',
      );

      expect(result, isNotNull);
      expect(result!.account, equals('testuser'));
      expect(result.userName, equals('测试用户'));
      verify(mockDatasource.register(
        account: 'testuser',
        password: '123456',
        userName: '测试用户',
      )).called(1);
    });

    test('账号太短应该注册失败', () async {
      final result = await repository.register(
        account: 'ab',
        password: '123456',
        userName: '测试用户',
      );

      expect(result, isNull);
      verifyNever(mockDatasource.register(
        account: anyNamed('account'),
        password: anyNamed('password'),
        userName: anyNamed('userName'),
      ));
    });

    test('密码太短应该注册失败', () async {
      final result = await repository.register(
        account: 'testuser',
        password: '12345',
        userName: '测试用户',
      );

      expect(result, isNull);
      verifyNever(mockDatasource.register(
        account: anyNamed('account'),
        password: anyNamed('password'),
        userName: anyNamed('userName'),
      ));
    });

    test('用户名太短应该注册失败', () async {
      final result = await repository.register(
        account: 'testuser',
        password: '123456',
        userName: 'A',
      );

      expect(result, isNull);
      verifyNever(mockDatasource.register(
        account: anyNamed('account'),
        password: anyNamed('password'),
        userName: anyNamed('userName'),
      ));
    });

    test('数据源返回null时应该注册失败', () async {
      when(mockDatasource.register(
        account: anyNamed('account'),
        password: anyNamed('password'),
        userName: anyNamed('userName'),
      )).thenAnswer((_) async => null);

      final result = await repository.register(
        account: 'existinguser',
        password: '123456',
        userName: '已存在用户',
      );

      expect(result, isNull);
    });
  });

  group('AuthRepository 登录测试', () {
    test('应该成功登录', () async {
      final testUser = AuthUser(
        userId: 'user_001',
        account: 'loginuser',
        userName: '登录用户',
        isLoggedIn: true,
      );

      when(mockDatasource.login(
        account: anyNamed('account'),
        password: anyNamed('password'),
      )).thenAnswer((_) async => testUser);

      final result = await repository.login(
        account: 'loginuser',
        password: '123456',
      );

      expect(result, isNotNull);
      expect(result!.account, equals('loginuser'));
      expect(result.isLoggedIn, isTrue);
    });

    test('错误凭证应该登录失败', () async {
      when(mockDatasource.login(
        account: anyNamed('account'),
        password: anyNamed('password'),
      )).thenAnswer((_) async => null);

      final result = await repository.login(
        account: 'wronguser',
        password: 'wrongpass',
      );

      expect(result, isNull);
    });
  });

  group('AuthRepository 登出测试', () {
    test('应该成功登出', () async {
      final testUser = AuthUser(
        userId: 'user_001',
        account: 'logoutuser',
        userName: '登出用户',
        isLoggedIn: true,
      );

      when(mockDatasource.getCurrentUser())
          .thenAnswer((_) async => testUser);
      when(mockDatasource.logout(any))
          .thenAnswer((_) async {});

      await repository.logout();

      verify(mockDatasource.logout('user_001')).called(1);
    });

    test('无登录用户时登出不应报错', () async {
      when(mockDatasource.getCurrentUser())
          .thenAnswer((_) async => null);

      await repository.logout();

      verifyNever(mockDatasource.logout(any));
    });
  });

  group('AuthRepository 会话管理测试', () {
    test('应该获取当前登录用户', () async {
      final testUser = AuthUser(
        userId: 'current_user',
        account: 'currentuser',
        userName: '当前用户',
        isLoggedIn: true,
      );

      when(mockDatasource.getCurrentUser())
          .thenAnswer((_) async => testUser);

      final result = await repository.getCurrentUser();

      expect(result, isNotNull);
      expect(result!.account, equals('currentuser'));
    });

    test('未登录时应该返回null', () async {
      when(mockDatasource.getCurrentUser())
          .thenAnswer((_) async => null);

      final result = await repository.getCurrentUser();

      expect(result, isNull);
    });

    test('应该正确判断认证状态', () async {
      final testUser = AuthUser(
        userId: 'auth_user',
        account: 'authuser',
        userName: '认证用户',
        isLoggedIn: true,
      );

      when(mockDatasource.getCurrentUser())
          .thenAnswer((_) async => testUser);

      final result = await repository.isAuthenticated();

      expect(result, isTrue);
    });

    test('未登录用户应该返回false', () async {
      when(mockDatasource.getCurrentUser())
          .thenAnswer((_) async => null);

      final result = await repository.isAuthenticated();

      expect(result, isFalse);
    });
  });

  group('AuthRepository 账号检查测试', () {
    test('存在的账号应该返回true', () async {
      when(mockDatasource.isAccountExists('existinguser'))
          .thenAnswer((_) async => true);

      final result = await repository.isAccountExists('existinguser');

      expect(result, isTrue);
    });

    test('不存在的账号应该返回false', () async {
      when(mockDatasource.isAccountExists('nonexistentuser'))
          .thenAnswer((_) async => false);

      final result = await repository.isAccountExists('nonexistentuser');

      expect(result, isFalse);
    });
  });
}
