import 'package:flutter/material.dart';

class ConfidePage extends StatefulWidget {
  const ConfidePage({super.key});

  @override
  State<ConfidePage> createState() => _ConfidePageState();
}

class _ConfidePageState extends State<ConfidePage> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('宠物倾诉室'),
      ),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Center(
                      child: Text('咕咕鸟占位'),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    '…',
                    style: TextStyle(fontSize: 24),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: '向咕咕鸟倾诉你的求职心情...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () {
                    _controller.clear();
                  },
                ),
              ),
              maxLines: null,
            ),
          ),
        ],
      ),
    );
  }
}
