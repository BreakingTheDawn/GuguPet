import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'dart:io' show Platform;
import 'core/theme/theme.dart';
import 'core/services/test_user_initializer.dart';
import 'core/services/app_strings.dart';
import 'routes/app_routes.dart';
import 'routes/route_generator.dart';
import 'features/pet/providers/pet_provider.dart';
import 'features/park/data/datasources/park_local_datasource.dart';
import 'features/park/services/mock_social_service.dart';
import 'features/park/providers/park_provider.dart';
import 'features/park/providers/friend_provider.dart';
import 'features/park/providers/post_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 初始化 Windows/Linux 平台的 SQLite FFI
  if (Platform.isWindows || Platform.isLinux) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }
  
  // 初始化配置服务
  await AppStrings.initialize();
  
  // 初始化测试用户
  await TestUserInitializer.initialize();
  
  runApp(const JobPetApp());
}

class JobPetApp extends StatefulWidget {
  const JobPetApp({super.key});

  @override
  State<JobPetApp> createState() => _JobPetAppState();
}

class _JobPetAppState extends State<JobPetApp> {
  /// 默认用户ID（后续可接入真实用户系统）
  static const String _defaultUserId = 'default_user_001';
  
  late final PetProvider _petProvider;
  late final ParkLocalDatasource _parkDatasource;
  late final MockSocialService _socialService;
  late final ParkProvider _parkProvider;
  late final FriendProvider _friendProvider;
  late final PostProvider _postProvider;

  @override
  void initState() {
    super.initState();
    
    // 初始化公园社交相关服务
    _parkDatasource = ParkLocalDatasource();
    _socialService = MockSocialService(datasource: _parkDatasource);
    
    // 初始化 Provider
    _petProvider = PetProvider();
    _parkProvider = ParkProvider(socialService: _socialService);
    _friendProvider = FriendProvider(socialService: _socialService);
    _postProvider = PostProvider(socialService: _socialService);
    
    _initializePet();
  }

  /// 初始化宠物数据
  Future<void> _initializePet() async {
    await _petProvider.initialize(_defaultUserId);
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
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
