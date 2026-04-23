import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/gemini_service.dart';

class GovernmentSchemesScreen extends StatefulWidget {
  const GovernmentSchemesScreen({super.key});

  @override
  State<GovernmentSchemesScreen> createState() =>
      _GovernmentSchemesScreenState();
}

class _GovernmentSchemesScreenState extends State<GovernmentSchemesScreen> {
  bool _loading = true;
  String? _error;
  List<dynamic> _schemes = [];
  String _careerName = '';

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
        _loading = false;
        _error = 'No career data received.';
      });
      return;
    }

    _careerName = (career['career'] ?? 'your career').toString();
    _fetchSchemes();
  }

  /// Pulls student profile from Firestore so we know their category,
  /// income, and state. Falls back to sensible defaults if unavailable.
  Future<Map<String, dynamic>> _loadStudentProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return {'annualIncome': 500000, 'category': 'General', 'state': 'India'};
    }

    try {
      final doc = await FirebaseFirestore.instance
          .collection('students')
          .doc(user.uid)
          .get();

      if (!doc.exists) {
        return {
          'annualIncome': 500000,
          'category': 'General',
          'state': 'India',
        };
      }

      final data = doc.data()!;
      return {
        'annualIncome': (data['annualIncome'] as num?)?.toInt() ?? 500000,
        'category': data['category']?.toString() ?? 'General',
        'state': data['state']?.toString() ?? 'India',
      };
    } catch (_) {
      return {'annualIncome': 500000, 'category': 'General', 'state': 'India'};
    }
  }

  Future<void> _fetchSchemes() async {
    try {
      final profile = await _loadStudentProfile();
      final gemini = GeminiService();
      final result = await gemini.getEligibleSchemes(
        annualIncome: profile['annualIncome'] as int,
        category: profile['category'] as String,
        state: profile['state'] as String,
        career: _careerName,
      );

      if (!mounted) return;

      final list = result['eligible_schemes'];
      setState(() {
        _schemes = (list is List) ? list : [];
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
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        title: const Text(
          'Eligible Schemes',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: _loading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text(
                    'Finding scholarships you qualify for...',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            )
          : _error != null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(_error!, textAlign: TextAlign.center),
              ),
            )
          : _schemes.isEmpty
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'No matching schemes found.\nTry a different career or check back later.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ),
            )
          : _buildSchemeList(),
    );
  }

  Widget _buildSchemeList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _schemes.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.green.withOpacity(0.25)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.green, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'You qualify for ${_schemes.length} scheme${_schemes.length == 1 ? '' : 's'} based on your profile',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1A4D2E),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        final scheme = _schemes[index - 1] as Map<String, dynamic>;
        return _schemeCard(scheme);
      },
    );
  }

  Widget _schemeCard(Map<String, dynamic> scheme) {
    final name = scheme['scheme_name']?.toString() ?? 'Scheme';
    final reason = scheme['eligibility_reason']?.toString() ?? '';
    final amount = scheme['benefit_amount']?.toString() ?? '';
    final deadline = scheme['deadline']?.toString() ?? '';
    final link = scheme['apply_link']?.toString() ?? '';

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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.account_balance,
                  color: Colors.blue,
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
          if (reason.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              reason,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[700],
                height: 1.4,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
          const SizedBox(height: 12),
          if (amount.isNotEmpty)
            _infoRow(Icons.currency_rupee, 'Amount', amount),
          if (deadline.isNotEmpty)
            _infoRow(Icons.calendar_today, 'Deadline', deadline),
          if (link.isNotEmpty) _infoRow(Icons.link, 'Apply at', link),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 14, color: Colors.grey[500]),
          const SizedBox(width: 8),
          SizedBox(
            width: 70,
            child: Text(
              label,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1A1A2E),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
