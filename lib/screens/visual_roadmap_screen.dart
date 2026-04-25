import 'package:flutter/material.dart';
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
  // Key format: "phaseIndex:milestoneIndex"
  final Set<String> _completed = {};

  bool _initialised = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialised) return;
    _initialised = true;

    final t = AppLocalizations.of(context)!;

    final career =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

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
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        title: Text(
          t.roadmapTitle,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: _loading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text(
                    t.roadmapLoading,
                    style: const TextStyle(color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
          : _error != null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  _error!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 14),
                ),
              ),
            )
          : _buildRoadmap(t),
    );
  }

  Widget _buildRoadmap(AppLocalizations t) {
    final phases = _roadmap!['roadmap'] as List;
    final exams = (_roadmap!['entrance_exams'] as List?) ?? [];
    final skills = (_roadmap!['key_skills'] as List?) ?? [];
    final cost = _roadmap!['cost_breakdown']?.toString() ?? '';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with career name and progress
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _careerName, // career name stays English by design
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A1A2E),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  t.milestonesProgress(_completed.length, _totalMilestones()),
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: _progress(),
                    minHeight: 8,
                    backgroundColor: Colors.grey[200],
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Colors.blue,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Phase timeline
          Text(
            t.yourJourney,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A1A2E),
            ),
          ),
          const SizedBox(height: 12),

          ...List.generate(phases.length, (phaseIndex) {
            final phase = phases[phaseIndex] as Map;
            final phaseName = phase['phase']?.toString() ?? 'Phase';
            final phaseDuration = phase['duration']?.toString() ?? '';
            final milestones = (phase['milestones'] as List?) ?? [];
            final isLast = phaseIndex == phases.length - 1;

            return _phaseCard(
              phaseIndex: phaseIndex,
              phaseName: phaseName, // already in user's language (Gemini)
              phaseDuration: phaseDuration,
              milestones: milestones,
              isLast: isLast,
            );
          }),

          const SizedBox(height: 16),

          // Summary info
          if (exams.isNotEmpty) _infoCard(t.summaryEntranceExams, exams.join(' • ')),
          if (skills.isNotEmpty) _infoCard(t.summaryKeySkills, skills.join(' • ')),
          if (cost.isNotEmpty) _infoCard(t.summaryCostSummary, cost),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _phaseCard({
    required int phaseIndex,
    required String phaseName,
    required String phaseDuration,
    required List milestones,
    required bool isLast,
  }) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline dot + line
          Column(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: Colors.blue,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 3),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.withOpacity(0.3),
                      blurRadius: 6,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    '${phaseIndex + 1}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    color: Colors.blue.withOpacity(0.3),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 14),
          // Phase card
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    phaseName,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A1A2E),
                    ),
                  ),
                  if (phaseDuration.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      phaseDuration,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                  const SizedBox(height: 10),
                  ...List.generate(milestones.length, (mIndex) {
                    final milestone = milestones[mIndex].toString();
                    final key = '$phaseIndex:$mIndex';
                    final done = _completed.contains(key);
                    return InkWell(
                      onTap: () {
                        setState(() {
                          if (done) {
                            _completed.remove(key);
                          } else {
                            _completed.add(key);
                          }
                        });
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              done
                                  ? Icons.check_circle
                                  : Icons.radio_button_unchecked,
                              color: done ? Colors.green : Colors.grey[400],
                              size: 20,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                milestone,
                                style: TextStyle(
                                  fontSize: 13,
                                  height: 1.4,
                                  color: done
                                      ? Colors.grey[500]
                                      : const Color(0xFF1A1A2E),
                                  decoration: done
                                      ? TextDecoration.lineThrough
                                      : TextDecoration.none,
                                ),
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
        ],
      ),
    );
  }

  Widget _infoCard(String label, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.05),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.blue.withOpacity(0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.blue[800],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF1A1A2E),
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}