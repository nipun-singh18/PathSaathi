import 'package:flutter/material.dart';

class InterestQuizScreen extends StatelessWidget {
  const InterestQuizScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Catches the stream name passed from the previous screen
    final String selectedStream = ModalRoute.of(context)?.settings.arguments as String? ?? 'General';

    return Scaffold(
      appBar: AppBar(title: Text('$selectedStream Quiz')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Evaluating for: $selectedStream', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blue)),
            const SizedBox(height: 20),
            const Text('Question 1 of 10', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500)),
            const SizedBox(height: 10),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                'Placeholder Question: Which of these activities appeals to you the most?',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/processing'),
              child: const Text('Submit Quiz & Process'),
            ),
          ],
        ),
      ),
    );
  }
}