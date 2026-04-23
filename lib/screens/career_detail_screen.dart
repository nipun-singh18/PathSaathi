import 'package:flutter/material.dart';
import '../services/knowledge_base.dart';

class CareerDetailScreen extends StatelessWidget {
  const CareerDetailScreen({super.key});

  Color _scoreColor(int score) {
    if (score >= 71) return Colors.green;
    if (score >= 41) return Colors.orange;
    return Colors.red;
  }

  String _scoreLabel(int score) {
    if (score >= 71) return 'Highly Suitable';
    if (score >= 41) return 'Moderate Feasibility';
    return 'Low Feasibility';
  }

  @override
  Widget build(BuildContext context) {
    // The career object was passed from the recommendations screen.
    final career =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    if (career == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Career Details')),
        body: const Center(
          child: Text(
            'No career data passed.\nGo back and tap a career card.',
            textAlign: TextAlign.center,
          ),
        ),
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

    // Pull extra verified data from the knowledge base if available
    final kbEntry = KnowledgeBase.instance.careerByName(careerName);
    final entranceExam = kbEntry?['entrance_exam']?.toString() ?? '—';
    final cutoff = kbEntry?['cutoff']?['raw']?.toString() ?? '—';
    final employmentRate = kbEntry?['employment_rate_pct'];
    final monthlySalary = kbEntry?['monthly_salary_raw']?.toString() ?? '—';

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        title: const Text(
          'Career Details',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // -- CAREER HEADER CARD --
            _card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    careerName,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A1A2E),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: _scoreColor(score).withOpacity(0.12),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'Reality Score: $score/100',
                          style: TextStyle(
                            color: _scoreColor(score),
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        _scoreLabel(score),
                        style: TextStyle(
                          color: _scoreColor(score),
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                  if (why.isNotEmpty) ...[
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Text(
                        why,
                        style: TextStyle(
                          color: Colors.grey[800],
                          fontSize: 13,
                          fontStyle: FontStyle.italic,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 14),

            // -- SCORE BREAKDOWN CARD --
            _card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Score Breakdown',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A1A2E),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _scoreBar('Academic Fit', academicFit),
                  const SizedBox(height: 10),
                  _scoreBar('Financial Fit', financialFit),
                  const SizedBox(height: 10),
                  _scoreBar('Effort vs Payoff', effortPayoff),
                  const SizedBox(height: 10),
                  _scoreBar('Interest Match', interestMatch),
                ],
              ),
            ),

            const SizedBox(height: 14),

            // -- FACTS CARD --
            _card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Key Facts',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A1A2E),
                    ),
                  ),
                  const SizedBox(height: 10),
                  _factRow(Icons.access_time, 'Duration', duration),
                  _factRow(Icons.school, 'Entrance Exam', entranceExam),
                  _factRow(Icons.bar_chart, 'Realistic Cutoff', cutoff),
                  _factRow(Icons.currency_rupee, 'Course Cost', costEstimate),
                  _factRow(Icons.work, 'Expected Salary', monthlySalary),
                  if (employmentRate != null)
                    _factRow(
                      Icons.trending_up,
                      'Employment Rate',
                      '$employmentRate%',
                    ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // -- ACTION BUTTONS --
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => Navigator.pushNamed(
                  context,
                  '/visual_roadmap',
                  arguments: career,
                ),
                style: _primaryBtn(),
                icon: const Icon(Icons.timeline),
                label: const Text('View Roadmap'),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => Navigator.pushNamed(
                  context,
                  '/government_schemes',
                  arguments: career,
                ),
                style: _secondaryBtn(),
                icon: const Icon(Icons.account_balance),
                label: const Text('View Eligible Schemes'),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => Navigator.pushNamed(
                  context,
                  '/alternate_paths',
                  arguments: career,
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange[50],
                  foregroundColor: Colors.orange[900],
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.swap_horiz),
                label: const Text("What If I Can't Afford This?"),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // ───────────── UI HELPERS ─────────────

  Widget _card({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _scoreBar(String label, int value) {
    final color = _scoreColor(value);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1A1A2E),
              ),
            ),
            Text(
              '$value/100',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: value / 100,
            minHeight: 8,
            backgroundColor: Colors.grey[200],
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }

  Widget _factRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: Colors.grey[600]),
          const SizedBox(width: 10),
          SizedBox(
            width: 130,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[700],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1A1A2E),
              ),
            ),
          ),
        ],
      ),
    );
  }

  ButtonStyle _primaryBtn() => ElevatedButton.styleFrom(
    backgroundColor: Colors.blue,
    foregroundColor: Colors.white,
    padding: const EdgeInsets.symmetric(vertical: 14),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  );

  ButtonStyle _secondaryBtn() => ElevatedButton.styleFrom(
    backgroundColor: Colors.white,
    foregroundColor: Colors.blue,
    side: const BorderSide(color: Colors.blue),
    padding: const EdgeInsets.symmetric(vertical: 14),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  );
}
