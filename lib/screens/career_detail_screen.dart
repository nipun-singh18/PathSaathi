import 'package:flutter/material.dart';
import 'dart:ui'; // For Glassmorphism
import '../services/knowledge_base.dart';
import '../l10n/app_localizations.dart';

class CareerDetailScreen extends StatelessWidget {
  const CareerDetailScreen({super.key});

  // Neon Color Palette for Dark Theme
  Color _scoreColor(int score) {
    if (score >= 71) return Colors.greenAccent;
    if (score >= 41) return Colors.orangeAccent;
    return Colors.redAccent;
  }

  String _scoreLabel(int score, AppLocalizations t) {
    if (score >= 71) return t.scoreHighlySuitable;
    if (score >= 41) return t.scoreModerateFeasibility;
    return t.scoreLowFeasibility;
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final career = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    if (career == null) {
      return Scaffold(
        backgroundColor: const Color(0xFF0B0E14),
        appBar: AppBar(
          backgroundColor: Colors.transparent, 
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: Center(child: Text(t.noCareerData, style: const TextStyle(color: Colors.white70))),
      );
    }

    final careerName = (career['career'] ?? 'Unknown Career').toString();
    final score = (career['reality_score'] as num?)?.toInt() ?? 0;
    final why = (career['why'] ?? '').toString();
    final duration = (career['duration'] ?? '').toString();
    final costEstimate = (career['cost_estimate'] ?? '').toString();
    final academicFit = (career['academic_fit'] as num?)?.toInt() ?? 0;
    final financialFit = (career['financial_fit'] as num?)?.toInt() ?? 0;
    final effortPayoff = (career['effort_payoff'] as num?)?.toInt() ?? 0;
    final interestMatch = (career['interest_match'] as num?)?.toInt() ?? 0;

    final kbEntry = KnowledgeBase.instance.careerByName(careerName);
    final entranceExam = kbEntry?['entrance_exam']?.toString() ?? '—';
    final cutoff = kbEntry?['cutoff']?['raw']?.toString() ?? '—';
    final employmentRate = kbEntry?['employment_rate_pct'];
    final monthlySalary = kbEntry?['monthly_salary_raw']?.toString() ?? '—';

    return Scaffold(
      backgroundColor: const Color(0xFF0B0E14), // Elite Dark Background
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          t.careerDetailsTitle,
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
            top: 0,
            right: -100,
            child: Container(
              width: 350, height: 350,
              decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.blueAccent.withOpacity(0.15), boxShadow: [BoxShadow(color: Colors.blueAccent.withOpacity(0.2), blurRadius: 150)]),
            ),
          ),
          Positioned(
            bottom: -50,
            left: -100,
            child: Container(
              width: 300, height: 300,
              decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.purpleAccent.withOpacity(0.12), boxShadow: [BoxShadow(color: Colors.purpleAccent.withOpacity(0.15), blurRadius: 180)]),
            ),
          ),

          // Glassmorphism Overlay
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 40.0, sigmaY: 40.0),
            child: Container(color: Colors.transparent),
          ),

          // ------------------------------------
          // Main Scrollable Content
          // ------------------------------------
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // -- CAREER HEADER CARD --
                  _glassCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          careerName,
                          style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 0.5),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                              decoration: BoxDecoration(
                                color: _scoreColor(score).withOpacity(0.15),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: _scoreColor(score).withOpacity(0.5)),
                                boxShadow: [BoxShadow(color: _scoreColor(score).withOpacity(0.3), blurRadius: 10)],
                              ),
                              child: Text(
                                t.realityScoreValue(score),
                                style: TextStyle(color: _scoreColor(score), fontWeight: FontWeight.w900, fontSize: 16),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              _scoreLabel(score, t),
                              style: TextStyle(color: _scoreColor(score), fontWeight: FontWeight.w700, fontSize: 14, letterSpacing: 0.5),
                            ),
                          ],
                        ),
                        if (why.isNotEmpty) ...[
                          const SizedBox(height: 20),
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.white.withOpacity(0.1)),
                            ),
                            child: Text(
                              why,
                              style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 14, fontStyle: FontStyle.italic, height: 1.6),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // -- SCORE BREAKDOWN CARD --
                  _glassCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          t.scoreBreakdownTitle,
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 0.5),
                        ),
                        const SizedBox(height: 20),
                        _neonScoreBar(t.subscoreAcademicFit, academicFit),
                        const SizedBox(height: 16),
                        _neonScoreBar(t.subscoreFinancialFit, financialFit),
                        const SizedBox(height: 16),
                        _neonScoreBar(t.subscoreEffortPayoff, effortPayoff),
                        const SizedBox(height: 16),
                        _neonScoreBar(t.subscoreInterestMatch, interestMatch),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // -- FACTS CARD --
                  _glassCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          t.keyFactsTitle,
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 0.5),
                        ),
                        const SizedBox(height: 16),
                        _factRow(Icons.access_time_rounded, t.factDuration, duration),
                        _factRow(Icons.school_rounded, t.factEntranceExam, entranceExam),
                        _factRow(Icons.bar_chart_rounded, t.factRealisticCutoff, cutoff),
                        _factRow(Icons.currency_rupee_rounded, t.factCourseCost, costEstimate),
                        _factRow(Icons.work_rounded, t.factExpectedSalary, monthlySalary),
                        if (employmentRate != null)
                          _factRow(Icons.trending_up_rounded, t.factEmploymentRate, '$employmentRate%'),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),

                  // -- ACTION BUTTONS --
                  _actionButton(
                    context: context,
                    label: t.btnViewRoadmap,
                    icon: Icons.timeline_rounded,
                    route: '/visual_roadmap',
                    args: career,
                    color: Colors.blueAccent,
                    isPrimary: true,
                  ),
                  const SizedBox(height: 14),
                  _actionButton(
                    context: context,
                    label: t.btnViewSchemes,
                    icon: Icons.account_balance_rounded,
                    route: '/government_schemes',
                    args: career,
                    color: Colors.blueAccent.shade100,
                    isPrimary: false,
                  ),
                  const SizedBox(height: 14),
                  _actionButton(
                    context: context,
                    label: t.btnAlternatePaths,
                    icon: Icons.swap_horiz_rounded,
                    route: '/alternate_paths',
                    args: career,
                    color: Colors.orangeAccent,
                    isPrimary: false,
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ───────────── ELITE UI HELPERS ─────────────

  Widget _glassCard({required Widget child}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 10, offset: const Offset(0, 5)),
            ],
          ),
          child: child,
        ),
      ),
    );
  }

  Widget _neonScoreBar(String label, int value) {
    final color = _scoreColor(value);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white70)),
            Text('$value/100', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: color)),
          ],
        ),
        const SizedBox(height: 8),
        Stack(
          children: [
            // Background Track
            Container(
              height: 8,
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
            ),
            // Glowing Progress Bar
            LayoutBuilder(
              builder: (context, constraints) {
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 1000),
                  curve: Curves.easeOutCubic,
                  height: 8,
                  width: constraints.maxWidth * (value / 100),
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(4),
                    boxShadow: [BoxShadow(color: color.withOpacity(0.6), blurRadius: 8, spreadRadius: 1)],
                  ),
                );
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _factRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.white54),
          const SizedBox(width: 12),
          SizedBox(
            width: 140,
            child: Text(label, style: const TextStyle(fontSize: 14, color: Colors.white54, fontWeight: FontWeight.w500)),
          ),
          Expanded(
            child: Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _actionButton({
    required BuildContext context,
    required String label,
    required IconData icon,
    required String route,
    required dynamic args,
    required Color color,
    required bool isPrimary,
  }) {
    return InkWell(
      onTap: () => Navigator.pushNamed(context, route, arguments: args),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isPrimary ? color.withOpacity(0.2) : Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isPrimary ? color.withOpacity(0.5) : color.withOpacity(0.3), width: 1.5),
          boxShadow: [
            if (isPrimary) BoxShadow(color: color.withOpacity(0.2), blurRadius: 15, spreadRadius: 2),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: isPrimary ? Colors.white : color, size: 22),
            const SizedBox(width: 10),
            Text(
              label,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isPrimary ? Colors.white : color, letterSpacing: 0.5),
            ),
          ],
        ),
      ),
    );
  }
}