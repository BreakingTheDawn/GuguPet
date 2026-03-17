import 'package:flutter/material.dart';
import 'core/theme/theme.dart';
import 'routes/app_routes.dart';
import 'routes/route_generator.dart';

void main() {
  runApp(const JobPetApp());
}

class JobPetApp extends StatelessWidget {
  const JobPetApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '职宠小窝',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      initialRoute: AppRoutes.home,
      onGenerateRoute: RouteGenerator.generateRoute,
    );
  }
}
