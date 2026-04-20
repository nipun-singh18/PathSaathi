import 'package:flutter/material.dart';

class CareerDetailScreen extends StatelessWidget {
  const CareerDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Career Details')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Software Engineer', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const Text('Reality Score: 85/100', style: TextStyle(color: Colors.green, fontSize: 18)),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/visual_roadmap'),
              child: const Text('View Timeline Roadmap'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/government_schemes'),
              child: const Text('View Eligible Schemes'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red[100]),
              onPressed: () => Navigator.pushNamed(context, '/alternate_paths'),
              child: const Text('What If I Cannot Afford This?'),
            ),
          ],
        ),
      ),
    );
  }
}