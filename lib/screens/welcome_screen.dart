import 'package:flutter/material.dart';
import 'dart:ui'; // Glassmorphism ke blur effect ke liye
import 'package:lottie/lottie.dart'; // Animations ke liye

import '../services/language_service.dart';
import '../l10n/app_localizations.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with SingleTickerProviderStateMixin {
  double _opacity = 0.0;
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    // Bouncy scale animation setup
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );

    // Fade-in trigger
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        setState(() {
          _opacity = 1.0;
        });
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: const Color(0xFF0B0E14), // Deep premium dark background
      body: Stack(
        fit: StackFit.expand,
        children: [
          // ------------------------------------
          // 1. NEON GLOWING ORBS (Background)
          // ------------------------------------

          // Top Left Blue Orb
          Positioned(
            top: -100,
            left: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.blueAccent.withOpacity(0.4),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blueAccent.withOpacity(0.5),
                    blurRadius: 150,
                    spreadRadius: 50,
                  ),
                ],
              ),
            ),
          ),

          // Bottom Right Purple Orb
          Positioned(
            bottom: -150,
            right: -100,
            child: Container(
              width: 400,
              height: 400,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.purpleAccent.withOpacity(0.3),
                boxShadow: [
                  BoxShadow(
                    color: Colors.purpleAccent.withOpacity(0.4),
                    blurRadius: 180,
                    spreadRadius: 60,
                  ),
                ],
              ),
            ),
          ),

          // ------------------------------------
          // 2. GLASSMORPHISM OVERLAY
          // ------------------------------------
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 40.0, sigmaY: 40.0),
            child: Container(color: Colors.transparent),
          ),

          // ------------------------------------
          // 3. MAIN ANIMATED CONTENT
          // ------------------------------------
          AnimatedOpacity(
            opacity: _opacity,
            duration: const Duration(seconds: 2),
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Lottie 3D/AI Animation (loads from web)
                    SizedBox(
                      height: 250,
                      child: Lottie.network(
                        'https://lottie.host/80ce2e44-d36c-4bfa-ba3e-c6e00122e2a0/W12o4XpS2P.json',
                        // Agar internet issue ho toh error na aaye, ye icon dikh jayega:
                        errorBuilder: (context, error, stackTrace) =>
                            const Icon(
                              Icons.psychology_rounded,
                              size: 120,
                              color: Colors.blueAccent,
                            ),
                      ),
                    ),
                    const SizedBox(height: 30),

                    // App Name Header
                    Text(
                      t.appTitle,
                      style: const TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 5),

                    // Motivational Subtitle (translated)
                    Text(
                      t.tagline,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.blueAccent,
                        letterSpacing: 8,
                      ),
                    ),
                    const SizedBox(height: 60),

                    // Elite Glassy Button (translated)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(30),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 15.0, sigmaY: 15.0),
                        child: InkWell(
                          onTap: () => Navigator.pushNamed(
                            context,
                            '/stream_selection',
                          ),
                          borderRadius: BorderRadius.circular(30),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 40,
                              vertical: 18,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(30),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.2),
                                width: 1.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.blueAccent.withOpacity(0.1),
                                  blurRadius: 20,
                                  spreadRadius: 1,
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  t.getStarted,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    letterSpacing: 1.2,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                const Icon(
                                  Icons.arrow_forward_ios_rounded,
                                  color: Colors.white,
                                  size: 18,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ------------------------------------
          // 4. LANGUAGE TOGGLE (top-right glass pill)
          // ------------------------------------
          SafeArea(
            child: Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.only(top: 16, right: 16),
                child: const _LanguageTogglePill(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Glass-styled pill that matches the welcome screen aesthetic.
/// Tapping it switches between English and Hindi instantly.
class _LanguageTogglePill extends StatelessWidget {
  const _LanguageTogglePill();

  @override
  Widget build(BuildContext context) {
    final isHindi = LanguageService.instance.isHindi;

    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: InkWell(
          onTap: () => LanguageService.instance.toggle(),
          borderRadius: BorderRadius.circular(24),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.08),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: Colors.white.withOpacity(0.18),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.language_rounded,
                  color: Colors.white,
                  size: 16,
                ),
                const SizedBox(width: 8),
                _LangChip(label: 'EN', active: !isHindi),
                const SizedBox(width: 4),
                Text(
                  '|',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.4),
                    fontSize: 12,
                  ),
                ),
                const SizedBox(width: 4),
                _LangChip(label: 'हिं', active: isHindi),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LangChip extends StatelessWidget {
  final String label;
  final bool active;
  const _LangChip({required this.label, required this.active});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: TextStyle(
        fontSize: 13,
        fontWeight: active ? FontWeight.w800 : FontWeight.w400,
        color: active
            ? Colors.blueAccent.shade100
            : Colors.white.withOpacity(0.5),
        letterSpacing: 0.5,
      ),
    );
  }
}