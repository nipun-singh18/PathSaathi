import 'package:flutter/material.dart';
import 'dart:ui'; // For Glassmorphism
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/gemini_service.dart';
import '../l10n/app_localizations.dart';

class GovernmentSchemesScreen extends StatefulWidget {
  const GovernmentSchemesScreen({super.key});

  @override
  State<GovernmentSchemesScreen> createState() => _GovernmentSchemesScreenState();
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

    final t = AppLocalizations.of(context)!;
    final career = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    if (career == null) {
      setState(() {
        _loading = false;
        _error = t.errorNoCareerData;
      });
      return;
    }

    _careerName = (career['career'] ?? 'your career').toString();
    _fetchSchemes();
  }

  Future<Map<String, dynamic>> _loadStudentProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return {'annualIncome': 500000, 'category': 'General', 'state': 'India'};
    }

    try {
      final doc = await FirebaseFirestore.instance.collection('students').doc(user.uid).get();
      if (!doc.exists) {
        return {'annualIncome': 500000, 'category': 'General', 'state': 'India'};
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
    final t = AppLocalizations.of(context)!;
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
        _error = t.errorPrefix(e.toString());
      });
    }
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
          t.schemesTitle,
          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 1),
        ),
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background Neon Orbs for Financial Elite Theme
          Positioned(
            top: 0,
            left: -100,
            child: Container(
              width: 300, height: 300,
              decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.blueAccent.withOpacity(0.12), boxShadow: [BoxShadow(color: Colors.blueAccent.withOpacity(0.2), blurRadius: 150)]),
            ),
          ),
          Positioned(
            bottom: -50,
            right: -100,
            child: Container(
              width: 350, height: 350,
              decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.greenAccent.withOpacity(0.1), boxShadow: [BoxShadow(color: Colors.greenAccent.withOpacity(0.15), blurRadius: 180)]),
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
                    : _schemes.isEmpty
                        ? _buildEmptyState(t)
                        : _buildSchemeList(t),
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
            t.schemesLoading,
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

  Widget _buildEmptyState(AppLocalizations t) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(
          t.schemesEmpty,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16, color: Colors.white.withOpacity(0.6), fontStyle: FontStyle.italic),
        ),
      ),
    );
  }

  Widget _buildSchemeList(AppLocalizations t) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      itemCount: _schemes.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          return _buildSuccessBanner(t);
        }
        final scheme = _schemes[index - 1] as Map<String, dynamic>;
        return _EliteSchemeCard(scheme: scheme, t: t);
      },
    );
  }

  Widget _buildSuccessBanner(AppLocalizations t) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.greenAccent.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.greenAccent.withOpacity(0.3)),
        boxShadow: [BoxShadow(color: Colors.greenAccent.withOpacity(0.2), blurRadius: 15, spreadRadius: 1)],
      ),
      child: Row(
        children: [
          const Icon(Icons.verified_rounded, color: Colors.greenAccent, size: 26),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              t.schemesQualifyBanner(_schemes.length),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.greenAccent,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------
// CUSTOM ELITE SCHEME CARD (WITH HOVER)
// ---------------------------------------------------------
class _EliteSchemeCard extends StatefulWidget {
  final Map<String, dynamic> scheme;
  final AppLocalizations t;

  const _EliteSchemeCard({required this.scheme, required this.t});

  @override
  State<_EliteSchemeCard> createState() => _EliteSchemeCardState();
}

class _EliteSchemeCardState extends State<_EliteSchemeCard> {
  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    final name = widget.scheme['scheme_name']?.toString() ?? 'Scheme';
    final reason = widget.scheme['eligibility_reason']?.toString() ?? '';
    final amount = widget.scheme['benefit_amount']?.toString() ?? '';
    final deadline = widget.scheme['deadline']?.toString() ?? '';
    final link = widget.scheme['apply_link']?.toString() ?? '';

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
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isHovered ? Colors.blueAccent.withOpacity(0.5) : Colors.white.withOpacity(0.1),
            width: isHovered ? 1.5 : 1.0,
          ),
          boxShadow: [
            if (isHovered)
              BoxShadow(color: Colors.blueAccent.withOpacity(0.2), blurRadius: 20, spreadRadius: 2)
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
                  // Header
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.blueAccent.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.blueAccent.withOpacity(0.3)),
                        ),
                        child: const Icon(Icons.account_balance_rounded, color: Colors.blueAccent, size: 24),
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
                  
                  if (reason.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.03),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.white.withOpacity(0.05)),
                      ),
                      child: Text(
                        reason,
                        style: TextStyle(fontSize: 14, color: Colors.white.withOpacity(0.7), fontStyle: FontStyle.italic, height: 1.5),
                      ),
                    ),
                  ],
                  
                  const SizedBox(height: 16),
                  
                  // Info Rows
                  if (amount.isNotEmpty) _infoRow(Icons.currency_rupee_rounded, widget.t.schemeAmount, amount),
                  if (deadline.isNotEmpty) _infoRow(Icons.calendar_today_rounded, widget.t.schemeDeadline, deadline),
                  if (link.isNotEmpty) _infoRow(Icons.link_rounded, widget.t.schemeApplyAt, link, isLink: true),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value, {bool isLink = false}) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: Colors.white54),
          const SizedBox(width: 10),
          SizedBox(
            width: 80,
            child: Text(label, style: const TextStyle(fontSize: 13, color: Colors.white54, fontWeight: FontWeight.w500)),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isLink ? FontWeight.bold : FontWeight.w600,
                color: isLink ? Colors.blueAccent.shade100 : Colors.white,
                decoration: isLink ? TextDecoration.underline : TextDecoration.none,
              ),
            ),
          ),
        ],
      ),
    );
  }
}