import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:jobpet/features/auth/providers/auth_provider.dart';
import 'package:jobpet/features/auth/data/models/auth_user.dart';
import 'package:jobpet/features/auth/data/models/auth_state.dart';
import 'package:jobpet/features/auth/data/repositories/auth_repository.dart';

import 'auth_provider_test.mocks.dart';

/// AuthProvider 单元测试
@GenerateMocks([AuthRepository])
void main() {
  late AuthProvider authProvider;
  late MockAuthRepository mockRepository;

  setUp(() {
    mockRepository = MockAuthRepository();
    authProvider = AuthProvider(repository: mockRepository);
  });

  group('AuthProvider 初始化测试', () {
    test('初始状态应该是loading', () {
      expect(authProvider.state, equals(AuthState.loading));
    });

    test('初始化时应该检查当前用户', () async {
      when(mockRepository.getCurrentUser())
          .thenAnswer((_) async => null);

      await authProvider.initialize();

      verify(mockRepository.getCurrentUser()).called(1);
      expect(authProvider.state, equals(AuthState.unauthenticated));
    });

    test('有登录用户时应该变为authenticated状态', () async {
      final testUser = AuthUser(
        userId: 'test_user',
        account: 'test',
        userName: '测试用户',
        isLoggedIn: true,
      );

      when(mockRepository.getCurrentUser())
          .thenAnswer((_) async => testUser);

      await authProvider.initialize();

      expect(authProvider.state, equals(AuthState.authenticated));
      expect(authProvider.currentUser, equals(testUser));
    });

    test('无登录用户时应该变为unauthenticated状态', () async {
      when(mockRepository.getCurrentUser())
          .thenAnswer((_) async => null);

      await authProvider.initialize();

      expect(authProvider.state, equals(AuthState.unauthenticated));
      expect(authProvider.currentUser, isNull);
    });

    test('初始化失败时应该变为unauthenticated状态', () async {
      when(mockRepository.getCurrentUser())
          .thenThrow(Exception('数据库错误'));

      await authProvider.initialize();

      expect(authProvider.state, equals(AuthState.unauthenticated));
      expect(authProvider.errorMessage, isNotNull);
    });
  });

  group('AuthProvider 注册测试', () {
    test('注册成功应该更新状态为authenticated', () async {
      final testUser = AuthUser(
        userId: 'new_user',
        account: 'newuser',
        userName: '新用户',
        isLoggedIn: true,
      );

      when(mockRepository.register(
        account: anyNamed('account'),
        password: anyNamed('password'),
        userName: anyNamed('userName'),
      )).thenAnswer((_) async => testUser);

      final result = await authProvider.register(
        account: 'newuser',
        password: '123456',
        userName: '新用户',
      );

      expect(result, isTrue);
      expect(authProvider.state, equals(AuthState.authenticated));
      expect(authProvider.currentUser, equals(testUser));
    });

    test('注册失败应该设置错误信息', () async {
      when(mockRepository.register(
        account: anyNamed('account'),
        password: anyNamed('password'),
        userName: anyNamed('userName'),
      )).thenAnswer((_) async => null);

      final result = await authProvider.register(
        account: 'existinguser',
        password: '123456',
        userName: '已存在用户',
      );

      expect(result, isFalse);
      expect(authProvider.errorMessage, isNotNull);
    });

    test('注册异常应该设置错误信息', () async {
      when(mockRepository.register(
        account: anyNamed('account'),
        password: anyNamed('password'),
        userName: anyNamed('userName'),
      )).thenThrow(Exception('网络错误'));

      final result = await authProvider.register(
        account: 'test',
        password: '123456',
        userName: '测试',
      );

      expect(result, isFalse);
      expect(authProvider.errorMessage, contains('注册失败'));
    });
  });

  group('AuthProvider 登录测试', () {
    test('登录成功应该更新状态为authenticated', () async {
      final testUser = AuthUser(
        userId: 'login_user',
        account: 'loginuser',
        userName: '登录用户',
        isLoggedIn: true,
      );

      when(mockRepository.login(
        account: anyNamed('account'),
        password: anyNamed('password'),
      )).thenAnswer((_) async => testUser);

      final result = await authProvider.login(
        account: 'loginuser',
        password: '123456',
      );

      expect(result, isTrue);
      expect(authProvider.state, equals(AuthState.authenticated));
      expect(authProvider.currentUser, equals(testUser));
    });

    test('登录失败应该设置错误信息', () async {
      when(mockRepository.login(
        account: anyNamed('account'),
        password: anyNamed('password'),
      )).thenAnswer((_) async => null);

      final result = await authProvider.login(
        account: 'wronguser',
        password: 'wrongpass',
      );

      expect(result, isFalse);
      expect(authProvider.errorMessage, equals('账号或密码错误'));
    });

    test('登录异常应该设置错误信息', () async {
      when(mockRepository.login(
        account: anyNamed('account'),
        password: anyNamed('password'),
      )).thenThrow(Exception('服务器错误'));

      final result = await authProvider.login(
        account: 'test',
        password: '123456',
      );

      expect(result, isFalse);
      expect(authProvider.errorMessage, contains('登录失败'));
    });
  });

  group('AuthProvider 登出测试', () {
    test('登出成功应该更新状态为unauthenticated', () async {
      // 先登录
      final testUser = AuthUser(
        userId: 'logout_user',
        account: 'logoutuser',
        userName: '登出用户',
        isLoggedIn: true,
      );

      when(mockRepository.login(
        account: anyNamed('account'),
        password: anyNamed('password'),
      )).thenAnswer((_) async => testUser);

      await authProvider.login(account: 'logoutuser', password: '123456');

      // 然后登出
      when(mockRepository.logout()).thenAnswer((_) async {});
      when(mockRepository.getCurrentUser()).thenAnswer((_) async => null);

      await authProvider.logout();

      expect(authProvider.state, equals(AuthState.unauthenticated));
      expect(authProvider.currentUser, isNull);
    });
  });

  group('AuthProvider 状态判断测试', () {
    test('isAuthenticated应该正确判断', () async {
      final testUser = AuthUser(
        userId: 'auth_user',
        account: 'authuser',
        userName: '认证用户',
        isLoggedIn: true,
      );

      when(mockRepository.getCurrentUser())
          .thenAnswer((_) async => testUser);

      await authProvider.initialize();

      expect(authProvider.isAuthenticated, isTrue);
      expect(authProvider.isUnauthenticated, isFalse);
    });

    test('isUnauthenticated应该正确判断', () async {
      when(mockRepository.getCurrentUser())
          .thenAnswer((_) async => null);

      await authProvider.initialize();

      expect(authProvider.isUnauthenticated, isTrue);
      expect(authProvider.isAuthenticated, isFalse);
    });
  });

  group('AuthProvider 错误处理测试', () {
    test('clearError应该清除错误信息', () async {
      when(mockRepository.login(
        account: anyNamed('account'),
        password: anyNamed('password'),
      )).thenAnswer((_) async => null);

      await authProvider.login(account: 'test', password: 'wrong');
      expect(authProvider.errorMessage, isNotNull);

      authProvider.clearError();
      expect(authProvider.errorMessage, isNull);
    });
  });

  group('AuthProvider 账号检查测试', () {
    test('isAccountExists应该返回正确结果', () async {
      when(mockRepository.isAccountExists('existinguser'))
          .thenAnswer((_) async => true);
      when(mockRepository.isAccountExists('nonexistentuser'))
          .thenAnswer((_) async => false);

      final exists = await authProvider.isAccountExists('existinguser');
      final notExists = await authProvider.isAccountExists('nonexistentuser');

      expect(exists, isTrue);
      expect(notExists, isFalse);
    });
  });
}
