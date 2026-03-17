import 'package:flutter/material.dart';

class JobBoardPage extends StatelessWidget {
  const JobBoardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('求职进度看板'),
      ),
      body: const Center(
        child: Text('求职进度看板 - 开发中'),
      ),
    );
  }
}
