import 'package:flutter/material.dart';

class VisualRoadmapScreen extends StatelessWidget {
  const VisualRoadmapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Step-by-Step Roadmap')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Phase 1: Learn Basics', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Back to Details'),
            ),
          ],
        ),
      ),
    );
  }
}