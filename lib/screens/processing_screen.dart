import 'package:flutter/material.dart';
import 'dart:ui';
import 'dart:async';
import 'package:lottie/lottie.dart';
import '../l10n/app_localizations.dart';

class ProcessingScreen extends StatefulWidget {
  const ProcessingScreen({super.key});

  @override
  State<ProcessingScreen> createState() => _ProcessingScreenState();
}

class _ProcessingScreenState extends State<ProcessingScreen> {
  int _currentStep = 0;
  Timer? _timer;

  // Elite dynamic phrases to keep the user engaged
  final List<String> _loadingSteps = [
    "Initializing Gemini AI...",
    "Scanning academic profile...",
    "Analyzing reality score...",
    "Finding eligible government schemes...",
    "Crafting personalized roadmap...",
    "Finalizing details..."
  ];

  @override
  void initState() {
    super.initState();
    // Changes the text every 2.5 seconds to show progression
    _timer = Timer.periodic(const Duration(milliseconds: 2500), (timer) {
      if (mounted) {
        setState(() {
          if (_currentStep < _loadingSteps.length - 1) {
            _currentStep++;
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: const Color(0xFF0B0E14), // Elite dark background
      body: Stack(
        fit: StackFit.expand,
        children: [
          // ------------------------------------
          // Background Neon Orbs
          // ------------------------------------
          Positioned(
            top: 100,
            left: -50,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.blueAccent.withOpacity(0.2),
                boxShadow: [
                  BoxShadow(color: Colors.blueAccent.withOpacity(0.3), blurRadius: 150, spreadRadius: 50),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 100,
            right: -50,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.purpleAccent.withOpacity(0.2),
                boxShadow: [
                  BoxShadow(color: Colors.purpleAccent.withOpacity(0.3), blurRadius: 150, spreadRadius: 50),
                ],
              ),
            ),
          ),

          // Glassmorphism blur overlay
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 40.0, sigmaY: 40.0),
            child: Container(color: Colors.transparent),
          ),

          // ------------------------------------
          // Main Content
          // ------------------------------------
          SafeArea(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Lottie AI Scanner Animation
                  SizedBox(
                    height: 200,
                    child: Lottie.network(
                      'https://lottie.host/80ce2e44-d36c-4bfa-ba3e-c6e00122e2a0/W12o4XpS2P.json',
                      // Fallback icon if internet is slow
                      errorBuilder: (context, error, stackTrace) => Stack(
                        alignment: Alignment.center,
                        children: [
                          const SizedBox(
                            height: 120, width: 120,
                            child: CircularProgressIndicator(color: Colors.blueAccent, strokeWidth: 2),
                          ),
                          Icon(Icons.psychology_rounded, size: 60, color: Colors.blueAccent.withOpacity(0.8)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Smooth text transition effect
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 800),
                    transitionBuilder: (Widget child, Animation<double> animation) {
                      return FadeTransition(opacity: animation, child: child);
                    },
                    child: Text(
                      _loadingSteps[_currentStep],
                      key: ValueKey<int>(_currentStep),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        letterSpacing: 1.2,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  // Localization fallback / subtitle
                  Text(
                    t.processingMessage, // Original processing message as a subtle subtitle
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.5),
                    ),
                  ),

                  const SizedBox(height: 60),

                  // Dev Skip Button - Made subtle and premium
                  TextButton(
                    onPressed: () => Navigator.pushReplacementNamed(
                      context,
                      '/career_recommendations',
                    ),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: BorderSide(color: Colors.white.withOpacity(0.1)),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          t.skipLoadingDev,
                          style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 12),
                        ),
                        const SizedBox(width: 8),
                        Icon(Icons.fast_forward_rounded, size: 14, color: Colors.white.withOpacity(0.6)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}