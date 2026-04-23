import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/gemini_service.dart';
import '../services/knowledge_base.dart';

class AlternatePathsScreen extends StatefulWidget {
  const AlternatePathsScreen({super.key});

  @override
  State<AlternatePathsScreen> createState() => _AlternatePathsScreenState();
}

class _AlternatePathsScreenState extends State<AlternatePathsScreen> {
  final budgetController = TextEditingController();

  bool _loading = false;
  String? _error;
  List<dynamic> _alternates = [];
  bool _hasSearched = false;

  String _originalCareer = '';
  String _stream = '';
  bool _initialised = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialised) return;
    _initialised = true;

    final career =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    if (career == null) {
      setState(() {
        _error = 'No career data received. Go back and try again.';
      });
      return;
    }

    _originalCareer = (career['career'] ?? 'Unknown').toString();
    // Infer stream from knowledge base lookup
    final kbEntry = KnowledgeBase.instance.careerByName(_originalCareer);
    _stream = kbEntry?['stream']?.toString() ?? 'Medical';
  }

  Future<Map<String, dynamic>> _loadStudentProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return {'annualIncome': 300000, 'category': 'General'};
    }
    try {
      final doc = await FirebaseFirestore.instance
          .collection('students')
          .doc(user.uid)
          .get();
      if (!doc.exists) {
        return {'annualIncome': 300000, 'category': 'General'};
      }
      final data = doc.data()!;
      return {
        'annualIncome': (data['annualIncome'] as num?)?.toInt() ?? 300000,
        'category': data['category']?.toString() ?? 'General',
      };
    } catch (_) {
      return {'annualIncome': 300000, 'category': 'General'};
    }
  }

  Future<void> _findAlternatives() async {
    final budgetText = budgetController.text.trim();
    final budgetLakhs = double.tryParse(budgetText);

    if (budgetLakhs == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Enter your max budget per year as a number (e.g. 1 for ₹1 lakh)',
          ),
        ),
      );
      return;
    }

    final maxBudgetRupees = (budgetLakhs * 100000).round();

    setState(() {
      _loading = true;
      _error = null;
      _hasSearched = true;
    });

    try {
      final profile = await _loadStudentProfile();
      final gemini = GeminiService();
      final result = await gemini.getAlternatePaths(
        stream: _stream,
        originalCareer: _originalCareer,
        maxAnnualBudget: maxBudgetRupees,
        category: profile['category'] as String,
        annualIncome: profile['annualIncome'] as int,
      );

      if (!mounted) return;

      final list = result['alternate_careers'];
      setState(() {
        _alternates = (list is List) ? list : [];
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = 'Something went wrong: $e';
      });
    }
  }

  @override
  void dispose() {
    budgetController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        title: const Text(
          'Affordable Alternatives',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Context banner
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.orange.withOpacity(0.25)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.lightbulb_outline,
                        color: Colors.orange[800],
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Exploring alternatives to',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.orange[800],
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _originalCareer,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A1A2E),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              'What is your maximum annual education budget?',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1A1A2E),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: budgetController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: 'e.g. 1 for ₹1 lakh, 0.5 for ₹50K',
                hintStyle: TextStyle(color: Colors.grey[400], fontSize: 13),
                prefixText: '₹ ',
                suffixText: 'lakh / year',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.blue),
                ),
              ),
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _loading ? null : _findAlternatives,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: _loading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(Icons.search),
                label: Text(
                  _loading ? 'Finding alternatives...' : 'Find Alternatives',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            if (_error != null) ...[
              Text(
                _error!,
                style: const TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),
            ] else if (_loading) ...[
              // Loading handled by button state
            ] else if (_hasSearched && _alternates.isEmpty) ...[
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Text(
                    'No alternatives found within this budget.\nTry increasing your budget a bit.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ),
              ),
            ] else if (_alternates.isNotEmpty) ...[
              Text(
                '${_alternates.length} alternative${_alternates.length == 1 ? '' : 's'} within your budget',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1A2E),
                ),
              ),
              const SizedBox(height: 12),
              ..._alternates.map(
                (a) => _alternateCard(a as Map<String, dynamic>),
              ),
            ],

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _alternateCard(Map<String, dynamic> alt) {
    final name = alt['career']?.toString() ?? 'Alternative';
    final why = alt['why_alternative']?.toString() ?? '';
    final cost = alt['cost_estimate']?.toString() ?? '';
    final duration = alt['duration']?.toString() ?? '';
    final salary = alt['monthly_salary_range']?.toString() ?? '';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.alt_route,
                  color: Colors.green,
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  name,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A1A2E),
                  ),
                ),
              ),
            ],
          ),
          if (why.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              why,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[700],
                fontStyle: FontStyle.italic,
                height: 1.4,
              ),
            ),
          ],
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              if (duration.isNotEmpty) _chip(Icons.access_time, duration),
              if (cost.isNotEmpty) _chip(Icons.currency_rupee, cost),
              if (salary.isNotEmpty) _chip(Icons.work, 'Salary: $salary'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _chip(IconData icon, String label) {
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
