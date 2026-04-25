import 'package:flutter/material.dart';
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
  final interestsController = TextEditingController();
  final strengthsController = TextEditingController();
  final incomeController = TextEditingController(); // annual income in lakhs
  final budgetController = TextEditingController(); // education budget / year
  final locationController = TextEditingController();
  final marksController = TextEditingController(); // class 12 marks %
  final neetScoreController = TextEditingController(); // /720 — Medical only
  final jeePercentileController =
      TextEditingController(); // 0-100 — Non-Medical only

  /// Internal English codes — never translated. Used for KB lookups,
  /// Gemini prompts, and Firestore writes.
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

  /// Resolves a stream English code to its localized display label.
  String _streamLabel(String code, AppLocalizations t) {
    switch (code) {
      case 'Medical':
        return t.streamMedical;
      case 'Non-Medical':
        return t.streamNonMedical;
      case 'Commerce':
        return t.streamCommerce;
      case 'Arts':
        return t.streamArts;
      default:
        return code;
    }
  }

  /// Resolves a category English code to its localized display label.
  String _categoryLabel(String code, AppLocalizations t) {
    switch (code) {
      case 'General':
        return t.categoryGeneral;
      case 'OBC':
        return t.categoryOBC;
      case 'SC':
        return t.categorySC;
      case 'ST':
        return t.categoryST;
      case 'EWS':
        return t.categoryEWS;
      default:
        return code;
    }
  }

  /// Save the profile fields to Firestore so other screens (schemes,
  /// alternate paths) can read them without asking again.
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
        SnackBar(content: Text(t.errorRequiredFields)),
      );
      return;
    }

    final incomeText = incomeController.text.trim();
    final incomeLakhs = double.tryParse(incomeText);
    if (incomeLakhs == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(t.errorIncomeFormat)),
      );
      return;
    }
    // Auto-detect: if user typed > 1000, assume they entered rupees directly,
    // not lakhs (protects against users typing "300000" instead of "3")
    final annualIncomeRupees = incomeLakhs > 1000
        ? incomeLakhs.round()
        : (incomeLakhs * 100000).round();

    // Parse optional entrance exam scores — only relevant for the matching stream
    int? neetScore;
    double? jeePercentile;
    if (selectedStream == 'Medical') {
      final s = neetScoreController.text.trim();
      if (s.isNotEmpty) {
        neetScore = int.tryParse(s);
        if (neetScore == null || neetScore < 0 || neetScore > 720) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(t.errorNeetRange)),
          );
          return;
        }
      }
    } else if (selectedStream == 'Non-Medical') {
      final s = jeePercentileController.text.trim();
      if (s.isNotEmpty) {
        jeePercentile = double.tryParse(s);
        if (jeePercentile == null ||
            jeePercentile < 0 ||
            jeePercentile > 100) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(t.errorJeeRange)),
          );
          return;
        }
      }
    }

    setState(() => isLoading = true);

    try {
      // Save profile first so downstream screens can read it
      await _saveProfileToFirestore(
        annualIncomeRupees: annualIncomeRupees,
        category: selectedCategory,
        stream: selectedStream,
        location: locationController.text.trim(),
        class12Marks: marksController.text.trim().isEmpty
            ? null
            : marksController.text.trim(),
        neetScore: neetScore,
        jeePercentile: jeePercentile,
      );

      final gemini = GeminiService();
      final results = await gemini.getCareerRecommendations(
        stream: selectedStream,
        interests: interestsController.text.trim(),
        strengths: strengthsController.text.trim(),
        budget: budgetController.text.trim().isEmpty
            ? 'not specified'
            : budgetController.text.trim(),
        location: locationController.text.trim(),
        category: selectedCategory,
        annualIncome: annualIncomeRupees,
        class12Marks: marksController.text.trim().isEmpty
            ? null
            : '${marksController.text.trim()}%',
        neetScore: neetScore,
        jeePercentile: jeePercentile,
      );

      if (!mounted) return;
      setState(() => isLoading = false);

      Navigator.pushNamed(
        context,
        '/career_recommendations',
        arguments: results,
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(t.errorPrefix(e.toString()))),
      );
    }
  }

  @override
  void dispose() {
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
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        title: Text(
          t.profileTitle,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              t.profileIntro,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1A1A2E),
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),

            _buildLabel(t.fieldStream),
            const SizedBox(height: 6),
            _buildDropdown<String>(
              value: selectedStream,
              items: streamCodes,
              labelFor: (code) => _streamLabel(code, t),
              onChanged: (v) {
                if (v != null) setState(() => selectedStream = v);
              },
            ),
            const SizedBox(height: 16),

            _buildLabel(t.fieldInterests),
            _buildField(
              controller: interestsController,
              hint: t.hintInterests,
              maxLines: 2,
            ),
            const SizedBox(height: 16),

            _buildLabel(t.fieldStrengths),
            _buildField(
              controller: strengthsController,
              hint: t.hintStrengths,
              maxLines: 2,
            ),
            const SizedBox(height: 16),

            _buildLabel(t.fieldMarks),
            _buildField(
              controller: marksController,
              hint: t.hintMarks,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),

            // ── Conditional entrance exam field ──────────────────
            // Medical → NEET score, Non-Medical → JEE percentile
            if (selectedStream == 'Medical') ...[
              _buildLabel(t.fieldNeet),
              _buildField(
                controller: neetScoreController,
                hint: t.hintNeet,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
            ] else if (selectedStream == 'Non-Medical') ...[
              _buildLabel(t.fieldJee),
              _buildField(
                controller: jeePercentileController,
                hint: t.hintJee,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
              ),
              const SizedBox(height: 16),
            ],

            _buildLabel(t.fieldIncome),
            _buildField(
              controller: incomeController,
              hint: t.hintIncome,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),

            _buildLabel(t.fieldCategory),
            const SizedBox(height: 6),
            _buildDropdown<String>(
              value: selectedCategory,
              items: categoryCodes,
              labelFor: (code) => _categoryLabel(code, t),
              onChanged: (v) {
                if (v != null) setState(() => selectedCategory = v);
              },
            ),
            const SizedBox(height: 16),

            _buildLabel(t.fieldBudget),
            _buildField(
              controller: budgetController,
              hint: t.hintBudget,
            ),
            const SizedBox(height: 16),

            _buildLabel(t.fieldLocation),
            _buildField(
              controller: locationController,
              hint: t.hintLocation,
            ),
            const SizedBox(height: 32),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isLoading ? null : analyseCareer,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: isLoading
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(t.submitAnalysing),
                        ],
                      )
                    : Text(
                        t.submitFindPath,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: Color(0xFF1A1A2E),
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String hint,
    int maxLines = 1,
    TextInputType? keyboardType,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey[400], fontSize: 13),
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
    );
  }

  /// Dropdown that displays localized labels but stores English codes.
  /// `labelFor` maps code → user-facing string.
  Widget _buildDropdown<T>({
    required T value,
    required List<T> items,
    required String Function(T) labelFor,
    required ValueChanged<T?> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          isExpanded: true,
          items: items
              .map(
                (code) =>
                    DropdownMenuItem<T>(value: code, child: Text(labelFor(code))),
              )
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}