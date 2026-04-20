import 'package:flutter/material.dart';

class GovernmentSchemesScreen extends StatelessWidget {
  const GovernmentSchemesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Financial Support')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Matched Schemes: 2', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const Text('Based on your income limits'),
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