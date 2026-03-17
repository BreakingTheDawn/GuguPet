import 'package:flutter/material.dart';
import '../../shared/widgets/widgets.dart';
import '../../features/confide/pages/confide_page.dart';
import '../../features/stats/pages/stats_page.dart';
import '../../features/park/pages/park_page.dart';
import '../../features/columns/pages/columns_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    ConfidePage(),
    StatsPage(),
    ParkPage(),
    ColumnsPage(),
    ProfilePage(),
  ];

  final List<NavItem> _navItems = const [
    NavItem(label: '倾诉室', icon: Icons.pets_outlined, activeIcon: Icons.pets),
    NavItem(label: '看板', icon: Icons.bar_chart_outlined, activeIcon: Icons.bar_chart),
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

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('个人中心 - 开发中'),
    );
  }
}
