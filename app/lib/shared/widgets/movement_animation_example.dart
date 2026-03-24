import 'package:flutter/material.dart';
import 'pet_animation_widget_v2.dart';

/// 移动动画使用示例
class MovementAnimationExample extends StatefulWidget {
  const MovementAnimationExample({super.key});

  @override
  State<MovementAnimationExample> createState() => _MovementAnimationExampleState();
}

class _MovementAnimationExampleState extends State<MovementAnimationExample> {
  final GlobalKey<PetAnimationWidgetV2State> _petAnimKey = GlobalKey();
  late MovementAnimationController _movementController;
  bool _isFlipped = false;
  String _status = '待机中';
  double _petPosition = 0.0; // -1 = 左侧, 0 = 中心, 1 = 右侧

  @override
  void initState() {
    super.initState();
    _movementController = MovementAnimationController(
      widgetState: _petAnimKey.currentState!,
      onFlipChanged: (flipped) {
        setState(() {
          _isFlipped = flipped;
        });
      },
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _movementController = MovementAnimationController(
      widgetState: _petAnimKey.currentState!,
      onFlipChanged: (flipped) {
        setState(() {
          _isFlipped = flipped;
        });
      },
    );
  }

  void _moveToLeft() {
    setState(() {
      _status = '向左移动中...';
    });
    _movementController.moveToLeft(onComplete: () {
      setState(() {
        _status = '已到达左侧';
        _petPosition = -1.0;
      });
    });
  }

  void _moveToRight() {
    setState(() {
      _status = '向右移动中...';
    });
    _movementController.moveToRight(onComplete: () {
      setState(() {
        _status = '已到达右侧';
        _petPosition = 1.0;
      });
    });
  }

  void _returnToCenter() {
    setState(() {
      _status = '返回中心中...';
    });
    _movementController.returnToCenter(
      fromLeft: _petPosition < 0,
      onComplete: () {
        setState(() {
          _status = '已回到中心';
          _petPosition = 0.0;
        });
      },
    );
  }

  void _playFullCycle() {
    setState(() {
      _status = '播放完整循环...';
    });
    _movementController.playFullCycle(onComplete: () {
      setState(() {
        _status = '循环完成';
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('宠物移动动画示例')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 状态显示
            Text(
              _status,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            // 宠物动画
            AnimatedPositioned(
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeInOut,
              left: MediaQuery.of(context).size.width / 2 - 105 + (_petPosition * 100),
              child: PetAnimationWidgetV2(
                key: _petAnimKey,
                animationType: PetAnimationTypeV2.move,
                size: 210,
                segmentName: 'full_cycle',
                flipHorizontal: _isFlipped,
                onAnimationComplete: () {
                  debugPrint('动画播放完成');
                },
              ),
            ),

            const SizedBox(height: 40),

            // 控制按钮
            Wrap(
              spacing: 10,
              runSpacing: 10,
              alignment: WrapAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: _moveToLeft,
                  child: const Text('向左移动'),
                ),
                ElevatedButton(
                  onPressed: _moveToRight,
                  child: const Text('向右移动'),
                ),
                ElevatedButton(
                  onPressed: _returnToCenter,
                  child: const Text('返回中心'),
                ),
                ElevatedButton(
                  onPressed: _playFullCycle,
                  child: const Text('完整循环'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// 简单使用示例 - 直接播放片段
class SimpleMovementExample extends StatelessWidget {
  const SimpleMovementExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('简单移动示例')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 播放完整循环动画
            const PetAnimationWidgetV2(
              animationType: PetAnimationTypeV2.move,
              segmentName: 'full_cycle',
              size: 210,
            ),

            const SizedBox(height: 20),

            // 播放向右移动（镜像翻转）
            const PetAnimationWidgetV2(
              animationType: PetAnimationTypeV2.move,
              segmentName: 'move_to_side',
              flipHorizontal: true,
              size: 150,
            ),
          ],
        ),
      ),
    );
  }
}
