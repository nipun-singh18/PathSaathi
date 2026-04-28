import 'package:flutter/material.dart';
import 'dart:ui'; // For Glassmorphism
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/gemini_service.dart';
import '../services/knowledge_base.dart';
import '../l10n/app_localizations.dart';

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

    final t = AppLocalizations.of(context)!;
    final career = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    
    if (career == null) {
      setState(() => _error = t.errorNoCareerData);
      return;
    }

    _originalCareer = (career['career'] ?? 'Unknown').toString();
    final kbEntry = KnowledgeBase.instance.careerByName(_originalCareer);
    _stream = kbEntry?['stream']?.toString() ?? 'Medical';
  }

  Future<Map<String, dynamic>> _loadStudentProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return {'annualIncome': 300000, 'category': 'General'};
    }
    try {
      final doc = await FirebaseFirestore.instance.collection('students').doc(user.uid).get();
      if (!doc.exists) return {'annualIncome': 300000, 'category': 'General'};
      
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
    final t = AppLocalizations.of(context)!;
    final budgetText = budgetController.text.trim();
    final budgetLakhs = double.tryParse(budgetText);
    if (budgetLakhs == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(t.alternateBudgetError), backgroundColor: Colors.redAccent),
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
        _error = t.errorPrefix(e.toString());
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
    final t = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: const Color(0xFF0B0E14), // Elite Dark Background
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          t.alternateTitle,
          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 1),
        ),
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background Neon Orbs (Amber & Blue Mix)
          Positioned(
            top: 50,
            left: -100,
            child: Container(
              width: 300, height: 300,
              decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.orangeAccent.withOpacity(0.12), boxShadow: [BoxShadow(color: Colors.orangeAccent.withOpacity(0.2), blurRadius: 150)]),
            ),
          ),
          Positioned(
            bottom: -50,
            right: -100,
            child: Container(
              width: 350, height: 350,
              decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.blueAccent.withOpacity(0.1), boxShadow: [BoxShadow(color: Colors.blueAccent.withOpacity(0.15), blurRadius: 180)]),
            ),
          ),

          // Glassmorphism Overlay
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 40.0, sigmaY: 40.0),
            child: Container(color: Colors.transparent),
          ),

          // Main Content
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Context Banner
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.orangeAccent.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.orangeAccent.withOpacity(0.3)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.lightbulb_outline_rounded, color: Colors.orangeAccent, size: 22),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    t.alternateExploring,
                                    style: const TextStyle(fontSize: 13, color: Colors.orangeAccent, fontWeight: FontWeight.w700, letterSpacing: 0.5),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _originalCareer,
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 0.5),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Input Section
                  Text(
                    t.alternateBudgetQuestion,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white, letterSpacing: 0.5),
                  ),
                  const SizedBox(height: 12),
                  
                  // Glassy TextField
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: TextField(
                        controller: budgetController,
                        keyboardType: TextInputType.number,
                        style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                        decoration: InputDecoration(
                          hintText: t.alternateBudgetHint,
                          hintStyle: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 14, fontWeight: FontWeight.normal),
                          prefixText: '₹ ',
                          prefixStyle: const TextStyle(color: Colors.blueAccent, fontSize: 18, fontWeight: FontWeight.bold),
                          suffixText: t.alternateBudgetSuffix,
                          suffixStyle: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 14),
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.05),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.white.withOpacity(0.1))),
                          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Colors.blueAccent, width: 1.5)),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Glowing Search Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _loading ? null : _findAlternatives,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 10,
                        shadowColor: Colors.blueAccent.withOpacity(0.5),
                      ),
                      icon: _loading
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : const Icon(Icons.travel_explore_rounded),
                      label: Text(
                        _loading ? t.alternateSearching : t.alternateFindBtn,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Results Handling
                  if (_error != null)
                    Center(child: Text(_error!, style: const TextStyle(color: Colors.redAccent, fontSize: 14), textAlign: TextAlign.center))
                  else if (_hasSearched && !_loading && _alternates.isEmpty)
                    Center(child: Text(t.alternateEmpty, textAlign: TextAlign.center, style: TextStyle(fontSize: 15, color: Colors.white.withOpacity(0.6), fontStyle: FontStyle.italic)))
                  else if (_alternates.isNotEmpty) ...[
                    Text(
                      t.alternateResultsHeader(_alternates.length),
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 0.5),
                    ),
                    const SizedBox(height: 16),
                    ..._alternates.map((a) => _EliteAlternateCard(alt: a as Map<String, dynamic>, t: t)),
                  ],
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------
// CUSTOM ELITE ALTERNATE CARD (WITH HOVER)
// ---------------------------------------------------------
class _EliteAlternateCard extends StatefulWidget {
  final Map<String, dynamic> alt;
  final AppLocalizations t;

  const _EliteAlternateCard({required this.alt, required this.t});

  @override
  State<_EliteAlternateCard> createState() => _EliteAlternateCardState();
}

class _EliteAlternateCardState extends State<_EliteAlternateCard> {
  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    final name = widget.alt['career']?.toString() ?? 'Alternative';
    final why = widget.alt['why_alternative']?.toString() ?? '';
    final cost = widget.alt['cost_estimate']?.toString() ?? '';
    final duration = widget.alt['duration']?.toString() ?? '';
    final salary = widget.alt['monthly_salary_range']?.toString() ?? '';

    return MouseRegion(
      onEnter: (_) => setState(() => isHovered = true),
      onExit: (_) => setState(() => isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        margin: const EdgeInsets.only(bottom: 16),
        transform: Matrix4.identity()..scale(isHovered ? 1.02 : 1.0),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isHovered ? Colors.greenAccent.withOpacity(0.5) : Colors.white.withOpacity(0.1),
            width: isHovered ? 1.5 : 1.0,
          ),
          boxShadow: [
            if (isHovered)
              BoxShadow(color: Colors.greenAccent.withOpacity(0.15), blurRadius: 20, spreadRadius: 2)
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.greenAccent.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.greenAccent.withOpacity(0.3)),
                        ),
                        child: const Icon(Icons.alt_route_rounded, color: Colors.greenAccent, size: 20),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Text(
                          name,
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 0.5),
                        ),
                      ),
                    ],
                  ),
                  if (why.isNotEmpty) ...[
                    const SizedBox(height: 14),
                    Text(
                      why,
                      style: TextStyle(fontSize: 14, color: Colors.white.withOpacity(0.7), fontStyle: FontStyle.italic, height: 1.5),
                    ),
                  ],
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      if (duration.isNotEmpty) _glassChip(Icons.access_time_rounded, duration),
                      if (cost.isNotEmpty) _glassChip(Icons.currency_rupee_rounded, cost),
                      if (salary.isNotEmpty) _glassChip(Icons.work_rounded, widget.t.alternateSalaryLabel(salary)),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _glassChip(IconData icon, String label) {
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
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.white70, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}