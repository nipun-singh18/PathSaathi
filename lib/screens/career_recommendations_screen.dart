import 'package:flutter/material.dart';

class CareerRecommendationsScreen extends StatelessWidget {
  const CareerRecommendationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Your Top Matches')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Top 5 Careers Found', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/career_detail'),
              child: const Text('View #1 Match Details'),
            ),
          ],
        ),
      ),
    );
  }
}