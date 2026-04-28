import 'package:flutter/material.dart';
import 'dart:ui'; // For Glassmorphism
import '../services/gemini_service.dart';
import '../l10n/app_localizations.dart';

class VisualRoadmapScreen extends StatefulWidget {
  const VisualRoadmapScreen({super.key});

  @override
  State<VisualRoadmapScreen> createState() => _VisualRoadmapScreenState();
}

class _VisualRoadmapScreenState extends State<VisualRoadmapScreen> {
  bool _loading = true;
  String? _error;
  Map<String, dynamic>? _roadmap;
  String _careerName = '';

  // Tracks which milestones the student has ticked off.
  final Set<String> _completed = {};
  bool _initialised = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialised) return;
    _initialised = true;

    final t = AppLocalizations.of(context)!;
    final career = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    if (career == null) {
      setState(() {
        _loading = false;
        _error = t.errorNoCareerData;
      });
      return;
    }

    _careerName = (career['career'] ?? 'Unknown Career').toString();
    _fetchRoadmap();
  }

  Future<void> _fetchRoadmap() async {
    final t = AppLocalizations.of(context)!;
    try {
      final gemini = GeminiService();
      final result = await gemini.getRoadmap(
        careerName: _careerName,
        educationLevel: 'Just completed 12th',
        budget: 'as per profile',
      );

      if (!mounted) return;

      final phases = result['roadmap'];
      if (phases is! List || phases.isEmpty) {
        setState(() {
          _loading = false;
          _error = t.errorRoadmapGeneration;
        });
        return;
      }

      setState(() {
        _roadmap = result;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = t.errorPrefix(e.toString());
      });
    }
  }

  int _totalMilestones() {
    final phases = _roadmap?['roadmap'] as List? ?? [];
    int total = 0;
    for (final p in phases) {
      final ms = (p as Map)['milestones'] as List? ?? [];
      total += ms.length;
    }
    return total;
  }

  double _progress() {
    final total = _totalMilestones();
    if (total == 0) return 0;
    return _completed.length / total;
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: const Color(0xFF0B0E14), // Elite Dark Background
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          t.roadmapTitle,
          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 1),
        ),
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background Neon Orbs
          Positioned(
            top: 0,
            left: -100,
            child: Container(
              width: 300, height: 300,
              decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.blueAccent.withOpacity(0.15), boxShadow: [BoxShadow(color: Colors.blueAccent.withOpacity(0.2), blurRadius: 150)]),
            ),
          ),
          Positioned(
            bottom: -50,
            right: -100,
            child: Container(
              width: 350, height: 350,
              decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.purpleAccent.withOpacity(0.1), boxShadow: [BoxShadow(color: Colors.purpleAccent.withOpacity(0.15), blurRadius: 180)]),
            ),
          ),

          // Glassmorphism Overlay
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 40.0, sigmaY: 40.0),
            child: Container(color: Colors.transparent),
          ),

          // Main Content
          SafeArea(
            child: _loading
                ? _buildLoadingState(t)
                : _error != null
                    ? _buildErrorState()
                    : _buildRoadmapContent(t),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState(AppLocalizations t) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(
            height: 60, width: 60,
            child: CircularProgressIndicator(color: Colors.blueAccent, strokeWidth: 3),
          ),
          const SizedBox(height: 20),
          Text(
            t.roadmapLoading,
            style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 16, letterSpacing: 1),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(
          _error!,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 16, color: Colors.redAccent),
        ),
      ),
    );
  }

  Widget _buildRoadmapContent(AppLocalizations t) {
    final phases = _roadmap!['roadmap'] as List;
    final exams = (_roadmap!['entrance_exams'] as List?) ?? [];
    final skills = (_roadmap!['key_skills'] as List?) ?? [];
    final cost = _roadmap!['cost_breakdown']?.toString() ?? '';

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Progress Header Card
          _glassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _careerName,
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 0.5),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      t.milestonesProgress(_completed.length, _totalMilestones()),
                      style: TextStyle(fontSize: 13, color: Colors.white.withOpacity(0.6), fontWeight: FontWeight.w600),
                    ),
                    Text(
                      '${(_progress() * 100).toInt()}%',
                      style: const TextStyle(fontSize: 14, color: Colors.blueAccent, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                // Glowing Progress Bar
                Stack(
                  children: [
                    Container(height: 8, decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), borderRadius: BorderRadius.circular(4))),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 500),
                          curve: Curves.easeOutCubic,
                          height: 8,
                          width: constraints.maxWidth * _progress(),
                          decoration: BoxDecoration(
                            color: Colors.blueAccent,
                            borderRadius: BorderRadius.circular(4),
                            boxShadow: [BoxShadow(color: Colors.blueAccent.withOpacity(0.6), blurRadius: 8, spreadRadius: 1)],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // 2. Timeline Title
          Text(
            t.yourJourney,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 1),
          ),
          const SizedBox(height: 20),

          // 3. Phases Timeline
          ...List.generate(phases.length, (phaseIndex) {
            final phase = phases[phaseIndex] as Map;
            final phaseName = phase['phase']?.toString() ?? 'Phase';
            final phaseDuration = phase['duration']?.toString() ?? '';
            final milestones = (phase['milestones'] as List?) ?? [];
            final isLast = phaseIndex == phases.length - 1;

            return _phaseCard(
              phaseIndex: phaseIndex,
              phaseName: phaseName,
              phaseDuration: phaseDuration,
              milestones: milestones,
              isLast: isLast,
            );
          }),

          const SizedBox(height: 20),

          // 4. Summary Info Cards
          if (exams.isNotEmpty) _infoCard(t.summaryEntranceExams, exams.join(' • '), Icons.school_rounded),
          if (skills.isNotEmpty) _infoCard(t.summaryKeySkills, skills.join(' • '), Icons.psychology_rounded),
          if (cost.isNotEmpty) _infoCard(t.summaryCostSummary, cost, Icons.account_balance_wallet_rounded),

          const SizedBox(height: 40),
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
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 10, offset: const Offset(0, 5))],
          ),
          child: child,
        ),
      ),
    );
  }

  Widget _phaseCard({required int phaseIndex, required String phaseName, required String phaseDuration, required List milestones, required bool isLast}) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline Node (Glowing Dot & Line)
          Column(
            children: [
              Container(
                width: 28, height: 28,
                decoration: BoxDecoration(
                  color: const Color(0xFF0B0E14),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.blueAccent, width: 2.5),
                  boxShadow: [BoxShadow(color: Colors.blueAccent.withOpacity(0.5), blurRadius: 10, spreadRadius: 1)],
                ),
                child: Center(
                  child: Text('${phaseIndex + 1}', style: const TextStyle(color: Colors.blueAccent, fontSize: 12, fontWeight: FontWeight.bold)),
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(width: 2, margin: const EdgeInsets.symmetric(vertical: 4), color: Colors.blueAccent.withOpacity(0.3)),
                ),
            ],
          ),
          const SizedBox(width: 16),
          
          // Phase Content Glass Card
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(bottom: 24),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.03),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white.withOpacity(0.08)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(phaseName, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: 0.5)),
                        if (phaseDuration.isNotEmpty) ...[
                          const SizedBox(height: 6),
                          Text(phaseDuration, style: TextStyle(fontSize: 13, color: Colors.white.withOpacity(0.5), fontWeight: FontWeight.w600)),
                        ],
                        const SizedBox(height: 16),
                        ...List.generate(milestones.length, (mIndex) {
                          final milestone = milestones[mIndex].toString();
                          final key = '$phaseIndex:$mIndex';
                          final done = _completed.contains(key);
                          
                          return InkWell(
                            onTap: () => setState(() { done ? _completed.remove(key) : _completed.add(key); }),
                            borderRadius: BorderRadius.circular(8),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    margin: const EdgeInsets.only(top: 2),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: done ? Colors.greenAccent : Colors.transparent,
                                      border: Border.all(color: done ? Colors.greenAccent : Colors.white.withOpacity(0.3), width: 1.5),
                                      boxShadow: done ? [BoxShadow(color: Colors.greenAccent.withOpacity(0.4), blurRadius: 8)] : [],
                                    ),
                                    child: Icon(Icons.check, size: 16, color: done ? const Color(0xFF0B0E14) : Colors.transparent),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: AnimatedDefaultTextStyle(
                                      duration: const Duration(milliseconds: 200),
                                      style: TextStyle(
                                        fontSize: 14, height: 1.5,
                                        color: done ? Colors.white.withOpacity(0.4) : Colors.white.withOpacity(0.85),
                                        decoration: done ? TextDecoration.lineThrough : TextDecoration.none,
                                        fontFamily: 'Inter', // Or whatever default font you use
                                      ),
                                      child: Text(milestone),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoCard(String label, String value, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blueAccent.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blueAccent.withOpacity(0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.blueAccent.shade100, size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.blueAccent.shade100, letterSpacing: 0.5)),
                const SizedBox(height: 6),
                Text(value, style: TextStyle(fontSize: 14, color: Colors.white.withOpacity(0.85), height: 1.5)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}