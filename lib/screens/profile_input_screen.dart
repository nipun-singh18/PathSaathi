import 'package:flutter/material.dart';
import 'dart:ui'; // For Glassmorphism
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/gemini_service.dart';
import '../l10n/app_localizations.dart';

class ProfileInputScreen extends StatefulWidget {
  const ProfileInputScreen({super.key});

  @override
  State<ProfileInputScreen> createState() => _ProfileInputScreenState();
}

class _ProfileInputScreenState extends State<ProfileInputScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  final int _totalPages = 4; // We divided the form into 4 pages

  final interestsController = TextEditingController();
  final strengthsController = TextEditingController();
  final incomeController = TextEditingController();
  final budgetController = TextEditingController();
  final locationController = TextEditingController();
  final marksController = TextEditingController();
  final neetScoreController = TextEditingController();
  final jeePercentileController = TextEditingController();

  String selectedStream = 'Medical';
  String selectedCategory = 'General';
  bool isLoading = false;

  final streamCodes = const ['Medical', 'Non-Medical', 'Commerce', 'Arts'];
  final categoryCodes = const ['General', 'OBC', 'SC', 'ST', 'EWS'];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final arg = ModalRoute.of(context)?.settings.arguments;
    if (arg is String && streamCodes.contains(arg)) {
      selectedStream = arg;
    }
  }

  String _streamLabel(String code, AppLocalizations t) {
    switch (code) {
      case 'Medical': return t.streamMedical;
      case 'Non-Medical': return t.streamNonMedical;
      case 'Commerce': return t.streamCommerce;
      case 'Arts': return t.streamArts;
      default: return code;
    }
  }

  String _categoryLabel(String code, AppLocalizations t) {
    switch (code) {
      case 'General': return t.categoryGeneral;
      case 'OBC': return t.categoryOBC;
      case 'SC': return t.categorySC;
      case 'ST': return t.categoryST;
      case 'EWS': return t.categoryEWS;
      default: return code;
    }
  }

  Future<void> _saveProfileToFirestore({
    required int annualIncomeRupees,
    required String category,
    required String stream,
    required String location,
    String? class12Marks,
    int? neetScore,
    double? jeePercentile,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await FirebaseFirestore.instance.collection('students').doc(user.uid).set({
      'stream': stream,
      'annualIncome': annualIncomeRupees,
      'category': category,
      'state': location,
      'class12Marks': class12Marks,
      'neetScore': neetScore,
      'jeePercentile': jeePercentile,
      'lastActive': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> analyseCareer() async {
    final t = AppLocalizations.of(context)!;

    if (interestsController.text.trim().isEmpty ||
        incomeController.text.trim().isEmpty ||
        locationController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(t.errorRequiredFields), backgroundColor: Colors.redAccent),
      );
      return;
    }

    final incomeText = incomeController.text.trim();
    final incomeLakhs = double.tryParse(incomeText);
    if (incomeLakhs == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(t.errorIncomeFormat), backgroundColor: Colors.redAccent),
      );
      return;
    }
    
    final annualIncomeRupees = incomeLakhs > 1000 ? incomeLakhs.round() : (incomeLakhs * 100000).round();

    int? neetScore;
    double? jeePercentile;
    if (selectedStream == 'Medical') {
      final s = neetScoreController.text.trim();
      if (s.isNotEmpty) {
        neetScore = int.tryParse(s);
        if (neetScore == null || neetScore < 0 || neetScore > 720) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(t.errorNeetRange), backgroundColor: Colors.redAccent),
          );
          return;
        }
      }
    } else if (selectedStream == 'Non-Medical') {
      final s = jeePercentileController.text.trim();
      if (s.isNotEmpty) {
        jeePercentile = double.tryParse(s);
        if (jeePercentile == null || jeePercentile < 0 || jeePercentile > 100) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(t.errorJeeRange), backgroundColor: Colors.redAccent),
          );
          return;
        }
      }
    }

    setState(() => isLoading = true);

    try {
      await _saveProfileToFirestore(
        annualIncomeRupees: annualIncomeRupees,
        category: selectedCategory,
        stream: selectedStream,
        location: locationController.text.trim(),
        class12Marks: marksController.text.trim().isEmpty ? null : marksController.text.trim(),
        neetScore: neetScore,
        jeePercentile: jeePercentile,
      );

      final gemini = GeminiService();
      final results = await gemini.getCareerRecommendations(
        stream: selectedStream,
        interests: interestsController.text.trim(),
        strengths: strengthsController.text.trim(),
        budget: budgetController.text.trim().isEmpty ? 'not specified' : budgetController.text.trim(),
        location: locationController.text.trim(),
        category: selectedCategory,
        annualIncome: annualIncomeRupees,
        class12Marks: marksController.text.trim().isEmpty ? null : '${marksController.text.trim()}%',
        neetScore: neetScore,
        jeePercentile: jeePercentile,
      );

      if (!mounted) return;
      setState(() => isLoading = false);

      // Guard: if AI returned empty list, surface an error instead of showing blank screen
      final recs = results['recommendations'] as List?;
      if (recs == null || recs.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('AI returned no results. Check your API key or try again.'),
            backgroundColor: Colors.redAccent,
            duration: Duration(seconds: 5),
          ),
        );
        return;
      }

      Navigator.pushNamed(context, '/career_recommendations', arguments: results);
    } catch (e) {
      if (!mounted) return;
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(t.errorPrefix(e.toString())), backgroundColor: Colors.redAccent),
      );
    }
  }

  void _nextPage() {
    if (_currentPage < _totalPages - 1) {
      _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    }
  }

  void _prevPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    interestsController.dispose();
    strengthsController.dispose();
    incomeController.dispose();
    budgetController.dispose();
    locationController.dispose();
    marksController.dispose();
    neetScoreController.dispose();
    jeePercentileController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: const Color(0xFF0B0E14), // Elite dark background
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          t.profileTitle,
          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 1),
        ),
      ),
      body: Stack(
        children: [
          // Background Glow Orbs for consistency
          Positioned(
            top: -50,
            right: -50,
            child: Container(
              width: 250, height: 250,
              decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.blueAccent.withOpacity(0.15), boxShadow: [BoxShadow(color: Colors.blueAccent.withOpacity(0.2), blurRadius: 100)]),
            ),
          ),
          Positioned(
            bottom: 50,
            left: -50,
            child: Container(
              width: 300, height: 300,
              decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.purpleAccent.withOpacity(0.1), boxShadow: [BoxShadow(color: Colors.purpleAccent.withOpacity(0.15), blurRadius: 120)]),
            ),
          ),
          
          SafeArea(
            child: Column(
              children: [
                // Custom Progress Bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 10),
                  child: Row(
                    children: List.generate(_totalPages, (index) {
                      return Expanded(
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          height: 6,
                          decoration: BoxDecoration(
                            color: _currentPage >= index ? Colors.blueAccent : Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(3),
                            boxShadow: _currentPage >= index ? [BoxShadow(color: Colors.blueAccent.withOpacity(0.5), blurRadius: 8)] : [],
                          ),
                        ),
                      );
                    }),
                  ),
                ),
                
                // Stepper Forms
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    physics: const NeverScrollableScrollPhysics(), // Disable swipe, force button use
                    onPageChanged: (int page) {
                      setState(() { _currentPage = page; });
                    },
                    children: [
                      _buildStep1Basics(t),
                      _buildStep2Academics(t),
                      _buildStep3Logistics(t),
                      _buildStep4Core(t),
                    ],
                  ),
                ),
                
                // Bottom Navigation Bar
                Container(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.3),
                    border: Border(top: BorderSide(color: Colors.white.withOpacity(0.05))),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Back Button
                      _currentPage > 0 
                        ? TextButton(
                            onPressed: isLoading ? null : _prevPage,
                            child: const Text("Back", style: TextStyle(color: Colors.white70, fontSize: 16)),
                          )
                        : const SizedBox(width: 60), // Placeholder to keep layout balanced
                      
                      // Next / Analyze Button (UPDATED WITH TEXT SPINNER)
                      _currentPage < _totalPages - 1
                        ? ElevatedButton(
                            onPressed: _nextPage,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blueAccent,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                            ),
                            child: const Text("Next", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1)),
                          )
                        : ElevatedButton(
                            onPressed: isLoading ? null : analyseCareer,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blueAccent,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                              elevation: 10,
                              shadowColor: Colors.blueAccent.withOpacity(0.5),
                            ),
                            child: isLoading
                                ? Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)),
                                      const SizedBox(width: 12),
                                      Text(t.submitAnalysing, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1, color: Colors.white)),
                                    ],
                                  )
                                : Text(t.submitFindPath, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1)),
                          ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- Step 1: Basics ---
  Widget _buildStep1Basics(AppLocalizations t) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Let's cover the basics 🚀", style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: Colors.white)),
          const SizedBox(height: 10),
          Text(t.profileIntro, style: TextStyle(fontSize: 14, color: Colors.white.withOpacity(0.7))),
          const SizedBox(height: 40),
          
          _buildLabel(t.fieldStream),
          _buildDarkDropdown<String>(
            value: selectedStream,
            items: streamCodes,
            labelFor: (code) => _streamLabel(code, t),
            onChanged: (v) { if (v != null) setState(() => selectedStream = v); },
          ),
          const SizedBox(height: 24),

          _buildLabel(t.fieldCategory),
          _buildDarkDropdown<String>(
            value: selectedCategory,
            items: categoryCodes,
            labelFor: (code) => _categoryLabel(code, t),
            onChanged: (v) { if (v != null) setState(() => selectedCategory = v); },
          ),
        ],
      ),
    );
  }

  // --- Step 2: Academics ---
  Widget _buildStep2Academics(AppLocalizations t) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Academic Profile 📚", style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: Colors.white)),
          const SizedBox(height: 10),
          Text("Help AI understand your academic standing.", style: TextStyle(fontSize: 14, color: Colors.white.withOpacity(0.7))),
          const SizedBox(height: 40),

          _buildLabel(t.fieldMarks),
          _buildDarkField(controller: marksController, hint: t.hintMarks, keyboardType: TextInputType.number),
          const SizedBox(height: 24),

          if (selectedStream == 'Medical') ...[
            _buildLabel(t.fieldNeet),
            _buildDarkField(controller: neetScoreController, hint: t.hintNeet, keyboardType: TextInputType.number),
          ] else if (selectedStream == 'Non-Medical') ...[
            _buildLabel(t.fieldJee),
            _buildDarkField(controller: jeePercentileController, hint: t.hintJee, keyboardType: const TextInputType.numberWithOptions(decimal: true)),
          ],
        ],
      ),
    );
  }

  // --- Step 3: Logistics ---
  Widget _buildStep3Logistics(AppLocalizations t) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Logistics & Reality 💸", style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: Colors.white)),
          const SizedBox(height: 10),
          Text("We use this to find the best government schemes for you.", style: TextStyle(fontSize: 14, color: Colors.white.withOpacity(0.7))),
          const SizedBox(height: 40),

          _buildLabel(t.fieldIncome),
          _buildDarkField(controller: incomeController, hint: t.hintIncome, keyboardType: TextInputType.number),
          const SizedBox(height: 24),

          _buildLabel(t.fieldBudget),
          _buildDarkField(controller: budgetController, hint: t.hintBudget),
          const SizedBox(height: 24),

          _buildLabel(t.fieldLocation),
          _buildDarkField(controller: locationController, hint: t.hintLocation),
        ],
      ),
    );
  }

  // --- Step 4: The Core (AI Part) ---
  Widget _buildStep4Core(AppLocalizations t) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("What drives you? 🧠", style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: Colors.white)),
          const SizedBox(height: 10),
          Text("This is where the magic happens. Be descriptive!", style: TextStyle(fontSize: 14, color: Colors.white.withOpacity(0.7))),
          const SizedBox(height: 40),

          _buildLabel(t.fieldInterests),
          _buildDarkField(controller: interestsController, hint: t.hintInterests, maxLines: 3),
          const SizedBox(height: 24),

          _buildLabel(t.fieldStrengths),
          _buildDarkField(controller: strengthsController, hint: t.hintStrengths, maxLines: 3),
        ],
      ),
    );
  }

  // --- Elite UI Components ---
  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, left: 4),
      child: Text(
        text,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white, letterSpacing: 0.5),
      ),
    );
  }

  Widget _buildDarkField({required TextEditingController controller, required String hint, int maxLines = 1, TextInputType? keyboardType}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: TextField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          style: const TextStyle(color: Colors.white, fontSize: 16),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 14),
            filled: true,
            fillColor: Colors.white.withOpacity(0.05),
            contentPadding: const EdgeInsets.all(18),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.white.withOpacity(0.1))),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Colors.blueAccent, width: 1.5)),
          ),
        ),
      ),
    );
  }

  Widget _buildDarkDropdown<T>({required T value, required List<T> items, required String Function(T) labelFor, required ValueChanged<T?> onChanged}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: Theme(
            data: Theme.of(context).copyWith(canvasColor: const Color(0xFF1A1A2E)), // Dark dropdown menu
            child: DropdownButtonHideUnderline(
              child: DropdownButton<T>(
                value: value,
                isExpanded: true,
                icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.white70),
                style: const TextStyle(color: Colors.white, fontSize: 16),
                items: items.map((code) => DropdownMenuItem<T>(value: code, child: Text(labelFor(code)))).toList(),
                onChanged: onChanged,
              ),
            ),
          ),
        ),
      ),
    );
  }
}