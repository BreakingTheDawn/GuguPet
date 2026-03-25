import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../shared/widgets/widgets.dart';
import '../../features/confide/pages/confide_page.dart';
import '../../features/jobs/pages/jobs_page.dart';
import '../../features/jobs/providers/jobs_provider.dart';
import '../../features/park/pages/park_page_enhanced.dart';
import '../../features/columns/pages/columns_page.dart';
import '../../features/profile/pages/profile_page.dart';
import '../../features/profile/providers/profile_provider.dart';

/// 主页面
/// 包含底部导航栏和五个主要功能页面
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // 当前选中的页面索引
  int _currentIndex = 0;

  // 页面列表（使用late final延迟初始化）
  late final List<Widget> _pages = [
    const ConfidePage(),
    // 求职看板页面：使用Provider包装
    ChangeNotifierProvider(
      create: (_) => JobsProvider(),
      child: const JobsPage(),
    ),
    const ParkPageEnhanced(),
    const ColumnsPage(),
    // 个人中心页面：使用Provider包装
    ChangeNotifierProvider(
      create: (_) => ProfileProvider(),
      child: const ProfilePage(),
    ),
  ];

  // 底部导航栏配置
  final List<NavItem> _navItems = const [
    NavItem(label: '倾诉室', icon: Icons.pets_outlined, activeIcon: Icons.pets),
    NavItem(label: '求职', icon: Icons.work_outline, activeIcon: Icons.work),
    NavItem(label: '公园', icon: Icons.park_outlined, activeIcon: Icons.park),
    NavItem(label: '专栏', icon: Icons.menu_book_outlined, activeIcon: Icons.menu_book),
    NavItem(label: '我的', icon: Icons.person_outline, activeIcon: Icons.person),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        child: _pages[_currentIndex],
      ),
      bottomNavigationBar: AppBottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: _navItems,
      ),
    );
  }
}
