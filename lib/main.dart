import 'package:flutter/material.dart';
import 'screens/welcome_screen.dart';
import 'screens/stream_selection_screen.dart';
import 'screens/interest_quiz_screen.dart';
import 'screens/processing_screen.dart';
import 'screens/career_recommendations_screen.dart';
import 'screens/career_detail_screen.dart';
import 'screens/visual_roadmap_screen.dart';
import 'screens/government_schemes_screen.dart';
import 'screens/alternate_paths_screen.dart';

void main() {
  runApp(const PathSaathiApp());
}

class PathSaathiApp extends StatelessWidget {
  const PathSaathiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PathSaathi',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const WelcomeScreen(),
        '/stream_selection': (context) => const StreamSelectionScreen(),
        '/interest_quiz': (context) => const InterestQuizScreen(),
        '/processing': (context) => const ProcessingScreen(),
        '/career_recommendations': (context) => const CareerRecommendationsScreen(),
        '/career_detail': (context) => const CareerDetailScreen(),
        '/visual_roadmap': (context) => const VisualRoadmapScreen(),
        '/government_schemes': (context) => const GovernmentSchemesScreen(),
        '/alternate_paths': (context) => const AlternatePathsScreen(),
      },
    );
  }
}