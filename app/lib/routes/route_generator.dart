import 'package:flutter/material.dart';

import 'app_routes.dart';
import '../pages/home/home_page.dart';
import '../features/confide/pages/confide_page.dart';
import '../features/stats/pages/stats_page.dart';
import '../features/park/pages/park_page.dart';
import '../features/jobs/pages/jobs_page.dart';

class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.home:
        return MaterialPageRoute(builder: (_) => const HomePage());
      case AppRoutes.confide:
        return MaterialPageRoute(builder: (_) => const ConfidePage());
      case AppRoutes.stats:
        return MaterialPageRoute(builder: (_) => const StatsPage());
      case AppRoutes.park:
        return MaterialPageRoute(builder: (_) => const ParkPage());
      case AppRoutes.jobs:
        return MaterialPageRoute(builder: (_) => const JobsPage());
      case AppRoutes.profile:
        return MaterialPageRoute(builder: (_) => const ProfilePage());
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          ),
        );
    }
  }
}
