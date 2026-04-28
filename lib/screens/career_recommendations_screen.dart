import 'package:flutter/material.dart';
import 'dart:ui'; // For Glassmorphism
import '../l10n/app_localizations.dart';

class CareerRecommendationsScreen extends StatelessWidget {
  const CareerRecommendationsScreen({super.key});

  // Upgraded to Neon Colors for Dark Theme
  Color _scoreColor(int score) {
    if (score >= 71) return Colors.greenAccent;
    if (score >= 41) return Colors.orangeAccent;
    return Colors.redAccent;
  }

  String _scoreLabel(int score, AppLocalizations t) {
    if (score >= 71) return t.scoreHighlySuitable;
    if (score >= 41) return t.scoreModerate;
    return t.scoreLowFeasibility;
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final results = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final recommendations = results?['recommendations'] as List<dynamic>? ?? [];

    return Scaffold(
      backgroundColor: const Color(0xFF0B0E14), // Elite dark background
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          t.recommendationsTitle,
          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 1),
        ),
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // ------------------------------------
          // Background Neon Orbs
          // ------------------------------------
          Positioned(
            top: 50,
            left: -100,
            child: Container(
              width: 300, height: 300,
              decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.blueAccent.withOpacity(0.15), boxShadow: [BoxShadow(color: Colors.blueAccent.withOpacity(0.2), blurRadius: 150)]),
            ),
          ),
          Positioned(
            bottom: 50,
            right: -100,
            child: Container(
              width: 400, height: 400,
              decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.purpleAccent.withOpacity(0.1), boxShadow: [BoxShadow(color: Colors.purpleAccent.withOpacity(0.15), blurRadius: 180)]),
            ),
          ),

          // Glassmorphism Overlay
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 40.0, sigmaY: 40.0),
            child: Container(color: Colors.transparent),
          ),

          // ------------------------------------
          // Main List Content
          // ------------------------------------
          SafeArea(
            child: recommendations.isEmpty
                ? Center(
                    child: Text(
                      t.noRecommendations,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 16, color: Colors.white70),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                    itemCount: recommendations.length,
                    itemBuilder: (context, index) {
                      final career = recommendations[index];
                      final score = (career['reality_score'] as num?)?.toInt() ?? 0;
                      final scoreColor = _scoreColor(score);
                      final scoreLabel = _scoreLabel(score, t);

                      return _EliteCareerCard(
                        career: career,
                        score: score,
                        scoreColor: scoreColor,
                        scoreLabel: scoreLabel,
                        tapText: t.tapForDetails,
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------
// CUSTOM ELITE CARD WIDGET FOR HOVER EFFECTS
// ---------------------------------------------------------
class _EliteCareerCard extends StatefulWidget {
  final Map<dynamic, dynamic> career;
  final int score;
  final Color scoreColor;
  final String scoreLabel;
  final String tapText;

  const _EliteCareerCard({
    required this.career,
    required this.score,
    required this.scoreColor,
    required this.scoreLabel,
    required this.tapText,
  });

  @override
  State<_EliteCareerCard> createState() => _EliteCareerCardState();
}

class _EliteCareerCardState extends State<_EliteCareerCard> {
  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => isHovered = true),
      onExit: (_) => setState(() => isHovered = false),
      child: GestureDetector(
        onTap: () {
          Navigator.pushNamed(context, '/career_detail', arguments: widget.career);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOutCubic,
          margin: const EdgeInsets.only(bottom: 20),
          transform: Matrix4.identity()..scale(isHovered ? 1.02 : 1.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: Colors.white.withOpacity(0.05),
            border: Border.all(
              color: isHovered ? widget.scoreColor.withOpacity(0.5) : Colors.white.withOpacity(0.1),
              width: isHovered ? 1.5 : 1.0,
            ),
            boxShadow: [
              if (isHovered)
                BoxShadow(
                  color: widget.scoreColor.withOpacity(0.2),
                  blurRadius: 20,
                  spreadRadius: 2,
                )
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header: Title & Score
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            widget.career['career'] ?? '',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        // Neon Score Badge
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                          decoration: BoxDecoration(
                            color: widget.scoreColor.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: widget.scoreColor.withOpacity(0.5)),
                            boxShadow: [
                              BoxShadow(color: widget.scoreColor.withOpacity(0.3), blurRadius: 8)
                            ]
                          ),
                          child: Text(
                            '${widget.score}%',
                            style: TextStyle(
                              color: widget.scoreColor,
                              fontWeight: FontWeight.w900,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    
                    // Feasibility Label
                    Text(
                      widget.scoreLabel,
                      style: TextStyle(
                        fontSize: 13,
                        color: widget.scoreColor,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 12),
                    
                    // AI Explanation
                    Text(
                      widget.career['why'] ?? '',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.7),
                        height: 1.6,
                      ),
                    ),
                    const SizedBox(height: 20),
                    
                    // Chips Row
                    Row(
                      children: [
                        _GlassChip(icon: Icons.access_time_rounded, label: widget.career['duration'] ?? ''),
                        const SizedBox(width: 10),
                        _GlassChip(icon: Icons.currency_rupee_rounded, label: widget.career['cost_estimate'] ?? ''),
                      ],
                    ),
                    
                    const SizedBox(height: 12),
                    
                    // Tap for details indicator
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          widget.tapText,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.blueAccent.shade100,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(Icons.arrow_forward_rounded, size: 14, color: Colors.blueAccent.shade100),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------
// CUSTOM GLASS CHIP
// ---------------------------------------------------------
class _GlassChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _GlassChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.white70),
          const SizedBox(width: 6),
          Text(
            label, 
            style: const TextStyle(fontSize: 12, color: Colors.white70, fontWeight: FontWeight.w500)
          ),
        ],
      ),
    );
  }
}