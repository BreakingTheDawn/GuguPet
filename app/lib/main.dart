import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'dart:io' show Platform;
import 'core/theme/theme.dart';
import 'routes/app_routes.dart';
import 'routes/route_generator.dart';
import 'features/pet/providers/pet_provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 初始化 Windows/Linux 平台的 SQLite FFI
  if (Platform.isWindows || Platform.isLinux) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }
  
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

  @override
  void initState() {
    super.initState();
    _petProvider = PetProvider();
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
