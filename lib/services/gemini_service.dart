import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class GeminiService {
  late final GenerativeModel _model;

  GeminiService() {
    _model = GenerativeModel(
      model: 'gemini-1.5-flash',
      apiKey: dotenv.env['GEMINI_API_KEY']!,
    );
  }

  Future<Map<String, dynamic>> getCareerRecommendations({
    required String dreamCareer,
    required int familyIncome,
    required String city,
    required String category,
    required String interests,
    required int expectedMarks,
  }) async {
    final prompt =
        '''
You are PathSaathi, an honest AI career counsellor for Indian students.

KNOWLEDGE BASE - PCB CAREERS:
1. MBBS: govt_cost=500000, private_cost=7000000, entrance=NEET, cutoff=600, duration=5.5 years, salary=60000-150000, employment=92%
2. BDS: govt_cost=300000, private_cost=3000000, entrance=NEET, cutoff=500, duration=5 years, salary=40000-80000, employment=78%
3. BAMS: govt_cost=200000, private_cost=1500000, entrance=NEET, cutoff=400, duration=5.5 years, salary=30000-60000, employment=71%
4. BHMS: govt_cost=200000, private_cost=1200000, entrance=NEET, cutoff=380, duration=5.5 years, salary=28000-50000, employment=68%
5. BSc_Nursing: govt_cost=80000, private_cost=300000, entrance=State_CET, duration=4 years, salary=25000-60000, employment=96%
6. Physiotherapy: govt_cost=100000, private_cost=500000, entrance=State_CET, duration=4.5 years, salary=30000-70000, employment=88%
7. Medical_Lab_Tech: govt_cost=50000, private_cost=200000, entrance=Merit, duration=3 years, salary=20000-40000, employment=91%
8. Pharmacy: govt_cost=100000, private_cost=400000, entrance=State_CET, duration=4 years, salary=25000-50000, employment=85%
9. Biotech: govt_cost=80000, private_cost=300000, entrance=Merit, duration=4 years, salary=30000-60000, employment=72%
10. Radiology_Tech: govt_cost=60000, private_cost=200000, entrance=Merit, duration=3 years, salary=22000-42000, employment=89%
11. Dietitian: govt_cost=50000, private_cost=150000, entrance=Merit, duration=3 years, salary=20000-40000, employment=80%
12. Optometry: govt_cost=60000, private_cost=200000, entrance=Merit, duration=3 years, salary=22000-45000, employment=82%

GOVERNMENT SCHEMES:
1. Post_Matric_Scholarship: income_limit=250000, category=SC/ST/OBC, amount=Full tuition
2. Central_Sector_Scheme: income_limit=450000, category=All, amount=12000/year
3. PM_USP: income_limit=450000, category=All, amount=2000/month
4. Pragati_Scholarship: income_limit=800000, category=Girls, amount=50000/year
5. Sitaram_Jindal: income_limit=200000, category=All, amount=2000/month
6. Reliance_Foundation: income_limit=250000, category=All, amount=200000

STUDENT PROFILE:
Stream: PCB (Medical)
Dream Career: $dreamCareer
Family Income Per Year: ₹$familyIncome
City: $city
Category: $category
Interests: $interests
Expected Class 12 Marks: $expectedMarks%

TASK: Analyse this student's profile and return ONLY valid JSON. No text outside JSON. No markdown.

Return this exact structure:
{
  "student_analysis": {
    "detected_stream": "",
    "budget_status": ""
  },
  "recommendations": [
    {
      "career_name": "",
      "reality_score": 0,
      "reason": "",
      "entrance_exam": "",
      "govt_cost_estimate": "",
      "avg_salary": ""
    }
  ],
  "alternate_low_cost_path": {
    "career_name": "",
    "why_this": ""
  },
  "eligible_schemes": [
    {
      "scheme_name": "",
      "amount": "",
      "reason_eligible": ""
    }
  ]
}

Rules:
- Give exactly 3 recommendations ordered by best match
- Reality score: 1-40=very hard, 41-70=challenging, 71-90=achievable, 91-100=perfect match
- reason should be in simple Hindi-English mix (Hinglish) that a student understands
- eligible_schemes: only include schemes this student actually qualifies for based on income and category
''';

    try {
      final content = [Content.text(prompt)];
      final response = await _model.generateContent(content);
      final text = response.text ?? '{}';

      // Clean markdown if Gemini adds it
      final cleaned = text
          .replaceAll('```json', '')
          .replaceAll('```', '')
          .trim();

      return jsonDecode(cleaned) as Map<String, dynamic>;
    } catch (e) {
      print('Gemini error: $e');
      return {};
    }
  }
}
