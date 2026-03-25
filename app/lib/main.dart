import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'dart:io' show Platform;
import 'core/theme/theme.dart';
import 'core/services/test_user_initializer.dart';
import 'core/services/app_strings.dart';
import 'core/services/business_config_service.dart';
import 'core/services/theme_service.dart';
import 'routes/app_routes.dart';
import 'routes/route_generator.dart';
import 'features/pet/providers/pet_provider.dart';
import 'features/park/data/datasources/park_local_datasource.dart';
import 'features/park/services/mock_social_service.dart';
import 'features/park/providers/park_provider.dart';
import 'features/park/providers/friend_provider.dart';
import 'features/park/providers/post_provider.dart';
import 'features/auth/providers/auth_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 初始化 Windows/Linux 平台的 SQLite FFI
  if (Platform.isWindows || Platform.isLinux) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }
  
  // 初始化配置服务
  await AppStrings.initialize();
  await BusinessConfigService.initialize();
  await ThemeService.initialize();
  
  // 初始化测试用户（保留现有逻辑，但会被登录系统覆盖）
  await TestUserInitializer.initialize();
  
  runApp(const JobPetApp());
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
    
    _initializeApp();
  }

  /// 初始化应用
  Future<void> _initializeApp() async {
    // 先初始化认证状态
    await _authProvider.initialize();
    
    // 根据登录状态初始化宠物数据
    // 未登录时使用游客ID，已登录时使用用户ID
    final userId = _authProvider.currentUser?.userId ?? 'guest_user';
    await _petProvider.initialize(userId);
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>.value(value: _authProvider),
        ChangeNotifierProvider<PetProvider>.value(value: _petProvider),
        ChangeNotifierProvider<ParkProvider>.value(value: _parkProvider),
        ChangeNotifierProvider<FriendProvider>.value(value: _friendProvider),
        ChangeNotifierProvider<PostProvider>.value(value: _postProvider),
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
  }
}
