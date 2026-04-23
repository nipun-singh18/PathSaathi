import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/gemini_service.dart';

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

  String selectedStream = 'Medical';
  String selectedCategory = 'General';
  bool isLoading = false;

  final streams = const ['Medical', 'Non-Medical', 'Commerce', 'Arts'];

  final categories = const ['General', 'OBC', 'SC', 'ST', 'EWS'];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final arg = ModalRoute.of(context)?.settings.arguments;
    if (arg is String && streams.contains(arg)) {
      selectedStream = arg;
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
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await FirebaseFirestore.instance.collection('students').doc(user.uid).set({
      'stream': stream,
      'annualIncome': annualIncomeRupees,
      'category': category,
      'state': location,
      'class12Marks': class12Marks,
      'lastActive': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> analyseCareer() async {
    if (interestsController.text.trim().isEmpty ||
        incomeController.text.trim().isEmpty ||
        locationController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields')),
      );
      return;
    }

    final incomeText = incomeController.text.trim();
    final incomeLakhs = double.tryParse(incomeText);
    if (incomeLakhs == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Enter income as a number (e.g. 3 for ₹3 lakh)'),
        ),
      );
      return;
    }
    final annualIncomeRupees = (incomeLakhs * 100000).round();

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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
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
          'Tell Us About Yourself',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'PathSaathi needs a few details\nto find your best career match.',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1A1A2E),
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),

            _buildLabel('Your Stream *'),
            const SizedBox(height: 6),
            _buildDropdown<String>(
              value: selectedStream,
              items: streams,
              onChanged: (v) {
                if (v != null) setState(() => selectedStream = v);
              },
            ),
            const SizedBox(height: 16),

            _buildLabel('Your Interests *'),
            _buildField(
              controller: interestsController,
              hint: 'e.g. helping people, computers, drawing, science',
              maxLines: 2,
            ),
            const SizedBox(height: 16),

            _buildLabel('Your Strengths'),
            _buildField(
              controller: strengthsController,
              hint: 'e.g. good at maths, creative, good communicator',
              maxLines: 2,
            ),
            const SizedBox(height: 16),

            _buildLabel('Class 12 Marks (%)'),
            _buildField(
              controller: marksController,
              hint: 'e.g. 72',
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),

            _buildLabel('Annual Family Income (in ₹ lakh) *'),
            _buildField(
              controller: incomeController,
              hint: 'e.g. 3 for ₹3 lakh, 8 for ₹8 lakh',
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),

            _buildLabel('Category *'),
            const SizedBox(height: 6),
            _buildDropdown<String>(
              value: selectedCategory,
              items: categories,
              onChanged: (v) {
                if (v != null) setState(() => selectedCategory = v);
              },
            ),
            const SizedBox(height: 16),

            _buildLabel('Education Budget per Year'),
            _buildField(
              controller: budgetController,
              hint: 'e.g. 50 thousand, 1 lakh (optional)',
            ),
            const SizedBox(height: 16),

            _buildLabel('Your City / State *'),
            _buildField(
              controller: locationController,
              hint: 'e.g. Chandigarh, Punjab',
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
                    ? const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          ),
                          SizedBox(width: 12),
                          Text('PathSaathi is analysing...'),
                        ],
                      )
                    : const Text(
                        'Find My Career Path →',
                        style: TextStyle(
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

  Widget _buildDropdown<T>({
    required T value,
    required List<T> items,
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
                (s) => DropdownMenuItem<T>(value: s, child: Text(s.toString())),
              )
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
