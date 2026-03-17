import 'package:flutter/material.dart';
import '../../../core/theme/theme.dart';
import '../widgets/penguin_svg.dart';

class ParkPage extends StatefulWidget {
  const ParkPage({super.key});

  @override
  State<ParkPage> createState() => _ParkPageState();
}

class _ParkPageState extends State<ParkPage> {
  int _selectedZone = 0;
  bool _showZoneMenu = false;

  static const _zones = ['码农森林', '金币湖畔', '设计师草原', '产品家园'];

  static const _parkBirds = [
    {'id': 1, 'name': '码农阿贤', 'label': '全栈工程师', 'accessory': 'glasses', 'color': Color(0xFF4A78C8), 'x': 0.14, 'y': 0.28},
    {'id': 2, 'name': '设计师小美', 'label': 'UI/UX设计师', 'accessory': 'bow', 'color': Color(0xFFC87AB8), 'x': 0.60, 'y': 0.22},
    {'id': 3, 'name': '产品老王', 'label': '产品经理', 'accessory': 'tie', 'color': Color(0xFF4A9E5A), 'x': 0.35, 'y': 0.50},
    {'id': 4, 'name': '运营小李', 'label': '品牌运营', 'accessory': 'hardhat', 'color': Color(0xFFC89040), 'x': 0.68, 'y': 0.55},
    {'id': 5, 'name': 'HR阿珍', 'label': '人才招募', 'accessory': 'crown', 'color': Color(0xFF7A58C8), 'x': 0.18, 'y': 0.62},
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFE8F5E0),
      child: Stack(
        children: [
          _buildScene(),
          _buildZoneHeader(),
          if (_showZoneMenu) _buildZoneMenu(),
        ],
      ),
    );
  }

  Widget _buildZoneHeader() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 48, 20, 16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.88),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 8,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '当前区域',
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.mutedForeground,
                    letterSpacing: 0.1,
                  ),
                ),
                GestureDetector(
                  onTap: () => setState(() => _showZoneMenu = !_showZoneMenu),
                  child: Row(
                    children: [
                      Text(
                        '🌲 ${_zones[_selectedZone]}',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF2A4A2A),
                        ),
                      ),
                      Icon(
                        Icons.keyboard_arrow_down,
                        size: 18,
                        color: _showZoneMenu ? AppColors.indigo500 : AppColors.mutedForeground,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFD4EDD4),
                borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
              ),
              child: Text(
                '👥 ${12 + _selectedZone * 3} 只咕咕在逛',
                style: AppTypography.labelSmall.copyWith(color: const Color(0xFF3A7A3A)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildZoneMenu() {
    return Positioned(
      top: 100,
      left: 20,
      right: 20,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          boxShadow: AppShadows.modal,
        ),
        child: Column(
          children: List.generate(_zones.length, (index) {
            final isSelected = index == _selectedZone;
            return InkWell(
              onTap: () => setState(() {
                _selectedZone = index;
                _showZoneMenu = false;
              }),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  border: index < _zones.length - 1
                      ? Border(bottom: BorderSide(color: Colors.grey.shade100))
                      : null,
                ),
                child: Row(
                  children: [
                    Text(
                      ['🌲', '💰', '🎨', '📱'][index],
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      _zones[index],
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                        color: isSelected ? const Color(0xFF3A7A3A) : const Color(0xFF444444),
                      ),
                    ),
                    const Spacer(),
                    if (isSelected) const Text('✓', style: TextStyle(color: Colors.green)),
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildScene() {
    return Positioned.fill(
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: [0, 0.45, 0.45, 1],
            colors: [Color(0xFFB8E8FF), Color(0xFFD4F0C0), Color(0xFF90D060), Color(0xFF70B840)],
          ),
        ),
        child: Stack(
          children: [
            ..._parkBirds.map((bird) => _buildBird(bird)),
          ],
        ),
      ),
    );
  }

  Widget _buildBird(Map<String, dynamic> bird) {
    return Positioned(
      left: bird['x'] as double,
      top: (bird['y'] as double) * 500 + 100,
      child: Column(
        children: [
          PenguinSvg(
            color: bird['color'] as Color,
            accessory: bird['accessory'] as String,
            size: 58,
          ),
          Container(
            margin: const EdgeInsets.only(top: 4),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.35),
              borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
            ),
            child: Text(
              '${bird['name']} · ${bird['label']}',
              style: const TextStyle(fontSize: 9, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
