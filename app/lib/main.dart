import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'dart:io' show Platform;
import 'core/theme/theme.dart';
import 'core/services/test_user_initializer.dart';
import 'core/services/test_admin_initializer.dart';
import 'core/services/app_strings.dart';
import 'core/services/business_config_service.dart';
import 'core/services/theme_service.dart';
import 'core/services/security_service.dart';
import 'core/services/ai_auto_config_service.dart';
import 'core/di/repository_provider.dart';
import 'core/di/service_provider.dart';
import 'data/models/user_profile.dart';
import 'routes/app_routes.dart';
import 'routes/route_generator.dart';
import 'features/pet/providers/pet_provider.dart';
import 'features/park/data/datasources/park_local_datasource.dart';
import 'features/park/services/mock_social_service.dart';
import 'features/park/providers/park_provider.dart';
import 'features/park/providers/friend_provider.dart';
import 'features/park/providers/post_provider.dart';
import 'features/auth/providers/auth_provider.dart';
import 'features/confide/providers/confide_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 初始化 Windows/Linux 平台的 SQLite FFI
  if (Platform.isWindows || Platform.isLinux) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }
  
  // 初始化安全服务
  await _initializeSecurity();
  
  // 初始化配置服务
  await AppStrings.initialize();
  await BusinessConfigService.initialize();
  await ThemeService.initialize();
  
  // 初始化测试用户（保留现有逻辑，但会被登录系统覆盖）
  await TestUserInitializer.initialize();
  
  // 初始化Admin测试用户
  await TestAdminInitializer.initialize();
  
  // 打印所有测试账号信息
  TestAdminInitializer.printAllTestAccountsInfo();
  
  // 自动配置AI服务（后台配置，无需用户输入）
  await AIAutoConfigService.initialize();
  
  runApp(const JobPetApp());
}

/// 初始化安全服务
Future<void> _initializeSecurity() async {
  try {
    // 初始化安全服务
    final securityService = SecurityService();
    await securityService.initialize();

    // 检查设备安全性
    final isSecure = await securityService.isDeviceSecure();
    if (!isSecure) {
      // 设备已Root/越狱，记录日志
      print('[Security] ⚠️ 检测到设备已Root/越狱');
      print('[Security] 建议：不要在Root/越狱设备上使用VIP等付费功能');
      // 可以选择显示警告或限制功能
    } else {
      print('[Security] ✅ 设备安全检查通过');
    }

    print('[Security] 安全服务初始化完成');
  } catch (e) {
    print('[Security] 安全服务初始化失败: $e');
  }
}

class JobPetApp extends StatefulWidget {
  const JobPetApp({super.key});

  @override
  State<JobPetApp> createState() => _JobPetAppState();
}

class _JobPetAppState extends State<JobPetApp> {
  late final PetProvider _petProvider;
  late final ParkLocalDatasource _parkDatasource;
  late final MockSocialService _socialService;
  late final ParkProvider _parkProvider;
  late final FriendProvider _friendProvider;
  late final PostProvider _postProvider;
  late final AuthProvider _authProvider;
  
  // 记录上一个用户ID，用于检测用户切换
  String? _lastUserId;
  
  // 应用初始化Future
  late final Future<void> _initializationFuture;

  @override
  void initState() {
    super.initState();
    
    // 初始化认证Provider
    _authProvider = AuthProvider();
    
    // 初始化公园社交相关服务
    _parkDatasource = ParkLocalDatasource();
    _socialService = MockSocialService(datasource: _parkDatasource);
    
    // 初始化 Provider
    _petProvider = PetProvider();
    _parkProvider = ParkProvider(socialService: _socialService);
    _friendProvider = FriendProvider(socialService: _socialService);
    _postProvider = PostProvider(socialService: _socialService);
    
    // 创建初始化Future
    _initializationFuture = _initializeApp();
  }

  /// 初始化应用
  Future<void> _initializeApp() async {
    // 先初始化认证状态，获取用户ID
    await _authProvider.initialize();
    
    // 根据登录状态获取用户ID
    final userId = _authProvider.currentUser?.userId ?? 'guest_user';
    
    // 使用用户ID初始化全局服务提供者
    await serviceProvider.initialize(userId: userId);
    
    // 获取用户资料（用于VIP状态判断）
    UserProfile? userProfile;
    if (_authProvider.isAuthenticated) {
      try {
        userProfile = await repositoryProvider.userRepository.getUser(userId);
      } catch (e) {
        debugPrint('获取用户资料失败: $e');
      }
    }
    
    await _petProvider.initialize(userId, userProfile: userProfile);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _initializationFuture,
      builder: (context, snapshot) {
        // 如果初始化完成，显示应用
        if (snapshot.connectionState == ConnectionState.done) {
          // 监听AuthProvider变化，切换用户时更新AI配置
          return ListenableBuilder(
            listenable: _authProvider,
            builder: (context, child) {
              // 获取当前用户ID
              final currentUserId = _authProvider.currentUser?.userId ?? 'guest_user';
              
              // 在首次初始化后，监听用户切换
              if (_lastUserId != null && _lastUserId != currentUserId) {
                // 用户切换了，刷新AI配置
                serviceProvider.switchUser(currentUserId);
              }
              _lastUserId = currentUserId;
              
              return MultiProvider(
                providers: [
                  ChangeNotifierProvider<AuthProvider>.value(value: _authProvider),
                  ChangeNotifierProvider<PetProvider>.value(value: _petProvider),
                  ChangeNotifierProvider<ParkProvider>.value(value: _parkProvider),
                  ChangeNotifierProvider<FriendProvider>.value(value: _friendProvider),
                  ChangeNotifierProvider<PostProvider>.value(value: _postProvider),
                  // 添加全局ConfideProvider
                  ChangeNotifierProvider<ConfideProvider>.value(value: serviceProvider.confideProvider),
                ],
                child: MaterialApp(
                  title: '职宠小窝',
                  debugShowCheckedModeBanner: false,
                  theme: AppTheme.light,
                  darkTheme: AppTheme.dark,
                  themeMode: ThemeMode.system,
                  initialRoute: AppRoutes.home,
                  onGenerateRoute: RouteGenerator.generateRoute,
                ),
              );
            },
          );
        }
        
        // 初始化中，显示加载界面
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          home: Scaffold(
            body: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFFF8F7FC), Color(0xFFEEE8F5)],
                ),
              ),
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6366F1)),
                    ),
                    SizedBox(height: 16),
                    Text(
                      '加载中...',
                      style: TextStyle(
                        color: Color(0xFF6366F1),
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
