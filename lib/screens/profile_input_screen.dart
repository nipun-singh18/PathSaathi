import 'package:flutter/material.dart';
import '../services/gemini_service.dart';
import 'results_screen.dart';

class ProfileInputScreen extends StatefulWidget {
  const ProfileInputScreen({super.key});

  @override
  State<ProfileInputScreen> createState() => _ProfileInputScreenState();
}

class _ProfileInputScreenState extends State<ProfileInputScreen> {
  final dreamController = TextEditingController();
  final cityController = TextEditingController();
  final incomeController = TextEditingController();
  final interestsController = TextEditingController();
  final marksController = TextEditingController();

  String selectedCategory = 'General';
  bool isLoading = false;

  final categories = ['General', 'OBC', 'SC', 'ST', 'Minority'];

  Future<void> analyseCareer() async {
    if (dreamController.text.isEmpty ||
        cityController.text.isEmpty ||
        incomeController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please fill all fields')));
      return;
    }

    setState(() => isLoading = true);

    try {
      final gemini = GeminiService();
      final results = await gemini.getCareerRecommendations(
        dreamCareer: dreamController.text.trim(),
        familyIncome: int.tryParse(incomeController.text.trim()) ?? 300000,
        city: cityController.text.trim(),
        category: selectedCategory,
        interests: interestsController.text.trim(),
        expectedMarks: int.tryParse(marksController.text.trim()) ?? 75,
      );

      if (!mounted) return;
      setState(() => isLoading = false);

      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => ResultsScreen(results: results)),
      );
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A73E8),
        foregroundColor: Colors.white,
        title: const Text(
          'Your Career Profile',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Tell us about yourself',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: Color(0xFF1A1A2E),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'PathSaathi will give you honest, financially realistic guidance.',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
            const SizedBox(height: 24),

            _buildField(
              controller: dreamController,
              label: 'Dream Career',
              hint: 'e.g. Doctor, Nurse, Pharmacist',
              icon: Icons.star,
            ),
            const SizedBox(height: 14),
            _buildField(
              controller: marksController,
              label: 'Expected Class 12 Marks (%)',
              hint: 'e.g. 75',
              icon: Icons.percent,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 14),
            _buildField(
              controller: cityController,
              label: 'City / State',
              hint: 'e.g. Ludhiana, Punjab',
              icon: Icons.location_on,
            ),
            const SizedBox(height: 14),
            _buildField(
              controller: incomeController,
              label: 'Family Annual Income (₹)',
              hint: 'e.g. 400000',
              icon: Icons.currency_rupee,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 14),

            // Category Dropdown
            const Text(
              'Category',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1A1A2E),
              ),
            ),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: selectedCategory,
                  isExpanded: true,
                  items: categories
                      .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                      .toList(),
                  onChanged: (val) {
                    if (val != null) {
                      setState(() => selectedCategory = val);
                    }
                  },
                ),
              ),
            ),

            const SizedBox(height: 14),
            _buildField(
              controller: interestsController,
              label: 'Your Interests (optional)',
              hint: 'e.g. helping patients, not interested in research',
              icon: Icons.favorite,
              maxLines: 2,
            ),

            const SizedBox(height: 28),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isLoading ? null : analyseCareer,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1A73E8),
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
          ],
        ),
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1A1A2E),
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey[400], fontSize: 13),
            prefixIcon: Icon(icon, size: 18, color: Colors.grey[500]),
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
              borderSide: const BorderSide(color: Color(0xFF1A73E8)),
            ),
          ),
        ),
      ],
    );
  }
}
