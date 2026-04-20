import 'package:flutter/material.dart';

class AlternatePathsScreen extends StatelessWidget {
  const AlternatePathsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Alternate Paths')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Recalculating with Budget Constraint...', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold), textAlign: TextAlign.center,),
            const SizedBox(height: 20),
            const Text('Suggested: B.Sc Computer Science + Free Certs'),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () => Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false),
              child: const Text('Start Over'),
            ),
          ],
        ),
      ),
    );
  }
}