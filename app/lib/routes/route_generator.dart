import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app_routes.dart';
import '../pages/home/home_page.dart';
import '../features/profile/pages/profile_page.dart';
import '../features/profile/providers/profile_provider.dart';
import '../features/confide/pages/confide_page.dart';
import '../features/stats/pages/stats_page.dart';
import '../features/stats/providers/stats_provider.dart';
import '../features/park/pages/park_page_enhanced.dart';
import '../features/park/pages/friend_list_page.dart';
import '../features/park/pages/post_feed_page.dart';
import '../features/jobs/pages/jobs_page.dart';
import '../features/jobs/pages/favorite_jobs_page.dart';
import '../features/jobs/pages/submissions_page.dart';
import '../features/jobs/providers/jobs_provider.dart';
import '../features/jobs/providers/favorite_provider.dart';
import '../features/jobs/providers/submissions_provider.dart';
import '../features/notifications/pages/notification_center_page.dart';
import '../features/notifications/providers/notification_provider.dart';
import '../features/notifications/services/notification_service.dart';
import '../data/repositories/notification_repository_impl.dart';
import '../features/auth/pages/login_page.dart';
import '../features/confide/pages/ai_settings_page.dart';

/// 路由生成器
/// 负责根据路由名称生成对应的页面
/// 为需要Provider的页面自动包装Provider
class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      // 主页面（包含底部导航）
      case AppRoutes.home:
        return MaterialPageRoute(builder: (_) => const HomePage());
      
      // 倾诉室页面
      case AppRoutes.confide:
        return MaterialPageRoute(builder: (_) => const ConfidePage());
      
      // 统计看板页面：需要StatsProvider
      case AppRoutes.stats:
        return MaterialPageRoute(
          builder: (_) => ChangeNotifierProvider(
            create: (_) => StatsProvider(),
            child: const StatsPage(),
          ),
        );
      
      // 公园页面
      case AppRoutes.park:
        return MaterialPageRoute(builder: (_) => const ParkPageEnhanced());
      
      // 好友列表页面
      case AppRoutes.friendList:
        return MaterialPageRoute(builder: (_) => const FriendListPage());
      
      // 动态流页面
      case AppRoutes.postFeed:
        return MaterialPageRoute(builder: (_) => const PostFeedPage());
      
      // 求职看板页面：需要JobsProvider
      case AppRoutes.jobs:
        return MaterialPageRoute(
          builder: (_) => ChangeNotifierProvider(
            create: (_) => JobsProvider(),
            child: const JobsPage(),
          ),
        );
      
      // 个人中心页面：需要ProfileProvider
      case AppRoutes.profile:
        return MaterialPageRoute(
          builder: (_) => ChangeNotifierProvider(
            create: (_) => ProfileProvider(),
            child: const ProfilePage(),
          ),
        );
      
      // 收藏职位页面：需要FavoriteProvider
      case AppRoutes.favoriteJobs:
        return MaterialPageRoute(
          builder: (_) => ChangeNotifierProvider(
            create: (_) => FavoriteProvider(),
            child: const FavoriteJobsPage(),
          ),
        );
      
      // 投递记录页面：需要SubmissionsProvider
      case AppRoutes.submissions:
        return MaterialPageRoute(
          builder: (_) => ChangeNotifierProvider(
            create: (_) => SubmissionsProvider(),
            child: const SubmissionsPage(),
          ),
        );
      
      // 通知中心页面：需要NotificationProvider
      case AppRoutes.notificationCenter:
        return MaterialPageRoute(
          builder: (_) => ChangeNotifierProvider(
            create: (_) => NotificationProvider(
              notificationService: NotificationService(
                repository: NotificationRepositoryImpl(),
              ),
            ),
            child: const NotificationCenterPage(),
          ),
        );
      
      // 登录页面
      case AppRoutes.login:
        return MaterialPageRoute(builder: (_) => const LoginPage());
      
      // AI对话设置页面
      case AppRoutes.aiSettings:
        return MaterialPageRoute(builder: (_) => const AISettingsPage());
      
      // 默认：显示404页面
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            appBar: AppBar(title: const Text('页面不存在')),
            body: Center(
              child: Text('未找到路由: ${settings.name}'),
            ),
          ),
        );
    }
  }
}
