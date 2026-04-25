import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';

class CareerRecommendationsScreen extends StatelessWidget {
  const CareerRecommendationsScreen({super.key});

  Color _scoreColor(int score) {
    if (score >= 71) return Colors.green;
    if (score >= 41) return Colors.orange;
    return Colors.red;
  }

  /// Returns the localized label for a score band.
  String _scoreLabel(int score, AppLocalizations t) {
    if (score >= 71) return t.scoreHighlySuitable;
    if (score >= 41) return t.scoreModerate;
    return t.scoreLowFeasibility;
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final results =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final recommendations = results?['recommendations'] as List<dynamic>? ?? [];

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        title: Text(
          t.recommendationsTitle,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: recommendations.isEmpty
          ? Center(
              child: Text(
                t.noRecommendations,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: recommendations.length,
              itemBuilder: (context, index) {
                final career = recommendations[index];
                final score = (career['reality_score'] as num?)?.toInt() ?? 0;

                return GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      '/career_detail',
                      arguments: career,
                    );
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 14),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.grey.shade200),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                // Career name — always English (per design)
                                career['career'] ?? '',
                                style: const TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF1A1A2E),
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: _scoreColor(score).withOpacity(0.12),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                '$score%',
                                style: TextStyle(
                                  color: _scoreColor(score),
                                  fontWeight: FontWeight.w800,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _scoreLabel(score, t),
                          style: TextStyle(
                            fontSize: 12,
                            color: _scoreColor(score),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          // Already in user's language — Gemini handled it
                          career['why'] ?? '',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[700],
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            _Chip(
                              icon: Icons.access_time,
                              label: career['duration'] ?? '',
                            ),
                            const SizedBox(width: 8),
                            _Chip(
                              icon: Icons.currency_rupee,
                              label: career['cost_estimate'] ?? '',
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              t.tapForDetails,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.blue[600],
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}

class _Chip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _Chip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F3F4),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: Colors.grey[600]),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(fontSize: 11, color: Colors.grey[700])),
        ],
      ),
    );
  }
}