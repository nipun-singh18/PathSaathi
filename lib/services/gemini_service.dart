import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'knowledge_base.dart';

class GeminiService {
  late final GenerativeModel _model;

  GeminiService() {
    _model = GenerativeModel(
      model: 'gemini-2.5-flash',
      apiKey: dotenv.env['GEMINI_API_KEY']!,
    );
  }

  // ── PROMPT 1: Career Matching ──────────────────────────
  //
  // Now grounded in verified career data from the knowledge base.
  // Gemini picks FROM a real list — it cannot invent careers or numbers.
  //
  Future<Map<String, dynamic>> getCareerRecommendations({
    required String stream,
    required String interests,
    required String strengths,
    required String budget,
    required String location,
    required String category, // e.g. "General", "OBC", "SC", "ST", "EWS"
    required int annualIncome, // in rupees
    String? class12Marks, // e.g. "72%" — optional but helps scoring
  }) async {
    // Pull the verified career list for this stream (stripped for token efficiency)
    final verifiedCareers = KnowledgeBase.instance.careersForPrompt(stream);
    final careersJson = jsonEncode(verifiedCareers);

    final prompt =
        '''
You are PathSaathi, a brutally honest career advisor for Indian students.

═══════════════════════════════════════════════
STUDENT PROFILE
═══════════════════════════════════════════════
- Stream: $stream
- Interests: $interests
- Strengths: $strengths
- Class 12 marks: ${class12Marks ?? 'not provided'}
- Annual family income: ₹$annualIncome
  (Context: In India, ₹3L/yr = lower-middle income, ₹8L/yr = middle class, ₹15L+ = upper-middle)
- Category: $category
- Stated budget for education: $budget per year
- Location: $location

═══════════════════════════════════════════════
VERIFIED CAREER DATABASE (choose ONLY from this list)
═══════════════════════════════════════════════
All cutoffs, costs, salaries below are verified. Do NOT invent numbers.
Use the exact career name from this list in your response.

$careersJson

═══════════════════════════════════════════════
TASK
═══════════════════════════════════════════════
Pick EXACTLY 5 careers from the verified list above that best match this student.
For each, compute a Reality Score (0–100) using the rubric below.

REALITY SCORE RUBRIC — compute four sub-scores, then combine:

1. ACADEMIC FIT (0–100)
   - If entrance_exam requires NEET and student has no marks info: score 50
   - If student's class 12 marks < (percent_12th_min - 10): score ≤ 20
   - If student meets the cutoff comfortably: score 70–90
   - If student exceeds cutoff significantly: score 90–100

2. FINANCIAL FIT (0–100)
   - Compute total 4-year cost using govt_cost_yr (min) × duration_years
   - If total cost < (annual_income × 2): score 80–100
   - If total cost between (income × 2) and (income × 4): score 50–70
   - If total cost > (income × 4) with no scholarships: score ≤ 30
   - Private costs only matter if student explicitly has budget for them

3. EFFORT-TO-PAYOFF (0–100)
   - Short duration + high salary + high employment_rate = 80+
   - Long duration + low salary = 30–50
   - Consider: monthly_salary × 12 vs total_cost (ROI)

4. INTEREST MATCH (0–100)
   - How well career aligns with student's stated interests and strengths

COMPOSITE: weighted average (30% academic, 30% financial, 20% payoff, 20% interest)

HARD FLOOR RULE:
If ANY sub-score is below 20, composite CANNOT exceed 40.
This prevents "MBBS is a great match!" for a student who can't afford it.

HONESTY RULE:
The "why" field MUST be honest, not motivational. Say "Financially out of reach without major scholarship" if true. Say "Strong fit — government college cost is affordable" if true. Never say "great choice!" or "pursue your dreams." Indian students deserve real talk.

═══════════════════════════════════════════════
OUTPUT — STRICT JSON ONLY
═══════════════════════════════════════════════
{
  "recommendations": [
    {
      "career": "exact name from verified list",
      "reality_score": 0,
      "academic_fit": 0,
      "financial_fit": 0,
      "effort_payoff": 0,
      "interest_match": 0,
      "why": "one honest sentence, max 20 words",
      "cost_estimate": "₹X–Y / year (govt) or ₹X–Y / year (private)",
      "duration": "X years"
    }
  ]
}

RULES:
- Exactly 5 careers
- Career name must match the verified list exactly
- No markdown, no extra text, JSON only
- Sort by reality_score descending
''';

    return await _callGemini(prompt, fallback: {"recommendations": []});
  }

  // ── PROMPT 2: Roadmap Generator ────────────────────────
  //
  // Pulls the full career record for grounded, realistic phases.
  //
  Future<Map<String, dynamic>> getRoadmap({
    required String careerName,
    required String educationLevel,
    required String budget,
  }) async {
    // Fetch the verified career record
    final career = KnowledgeBase.instance.careerByName(careerName);
    final careerContext = career != null
        ? jsonEncode({
            'career': career['career'],
            'duration_years': career['duration_years'],
            'entrance_exam': career['entrance_exam'],
            'cutoff': career['cutoff']?['raw'],
            'govt_cost_yr': career['govt_cost_yr'],
            'monthly_salary': career['monthly_salary'],
          })
        : '(career not in database — use general knowledge but flag uncertainty)';

    final prompt =
        '''
You are a career roadmap generator for Indian students.

═══════════════════════════════════════════════
VERIFIED CAREER DATA
═══════════════════════════════════════════════
$careerContext

═══════════════════════════════════════════════
STUDENT CONTEXT
═══════════════════════════════════════════════
- Target career: $careerName
- Current level: $educationLevel
- Budget: $budget

═══════════════════════════════════════════════
TASK
═══════════════════════════════════════════════
Create a phase-wise roadmap from the student's current level to employment.
Each phase must have:
- A clear time window (e.g. "0–3 months", "3–6 months", "Year 1")
- 3–5 specific milestones the student can tick off
- Milestones must be concrete actions, not motivational fluff

Use the verified entrance_exam and duration above. Do not invent exam names.

═══════════════════════════════════════════════
OUTPUT — STRICT JSON ONLY
═══════════════════════════════════════════════
{
  "career": "$careerName",
  "roadmap": [
    {
      "phase": "phase name",
      "duration": "time window",
      "milestones": ["concrete action 1", "concrete action 2"]
    }
  ],
  "entrance_exams": ["exam names"],
  "key_skills": ["skill 1", "skill 2"],
  "cost_breakdown": "honest one-line cost summary"
}

RULES:
- 4–6 phases covering the full journey
- Milestones are SPECIFIC (e.g. "Register for NEET-UG on nta.ac.in by Feb"), not vague ("study hard")
- No motivational text
- No markdown, JSON only
''';

    return await _callGemini(prompt, fallback: {"roadmap": []});
  }

  // ── PROMPT 3: Government Schemes ───────────────────────
  //
  // HARDENED: We no longer let Gemini drop schemes. The prompt enforces
  // exact output count. A Dart-side safety net fills in any missing
  // schemes so the user ALWAYS sees all pre-filtered eligible schemes.
  //
  Future<Map<String, dynamic>> getEligibleSchemes({
    required int annualIncome,
    required String category,
    required String state,
    required String career,
  }) async {
    // Pre-filter schemes using verified data
    final eligible = KnowledgeBase.instance.eligibleSchemes(
      annualIncome: annualIncome,
      category: category,
    );

    if (eligible.isEmpty) {
      return {"eligible_schemes": []};
    }

    // Build the prompt payload with consistent field names
    final schemesForPrompt = eligible.take(10).map((s) {
      return {
        'scheme_name': s['name'],
        'amount': s['amount_raw'],
        'income_limit': s['income_limit_raw'],
        'category_eligible': s['category_eligible_raw'],
        'deadline': s['deadline'],
        'apply_link': s['application_link'],
        'notes': s['notes'],
      };
    }).toList();

    final schemesJson = jsonEncode(schemesForPrompt);

    final prompt =
        '''
You are a government scheme explainer for Indian students.

═══════════════════════════════════════════════
STUDENT
═══════════════════════════════════════════════
- Annual income: ₹$annualIncome
- Category: $category
- State: $state
- Target career: $career

═══════════════════════════════════════════════
ELIGIBLE SCHEMES (student qualifies for ALL of these — verified)
═══════════════════════════════════════════════
$schemesJson

═══════════════════════════════════════════════
TASK
═══════════════════════════════════════════════
Return EVERY scheme from the list above (do not skip any). For each,
write one personalized sentence (max 25 words) explaining why THIS
specific student qualifies — reference their income, category, state,
or career.

OUTPUT must contain the SAME NUMBER of schemes as the input list.
Keep scheme_name, benefit_amount, deadline, apply_link EXACTLY as given.

═══════════════════════════════════════════════
OUTPUT — STRICT JSON ONLY
═══════════════════════════════════════════════
{
  "eligible_schemes": [
    {
      "scheme_name": "copy from input",
      "eligibility_reason": "personalized one-liner",
      "benefit_amount": "copy 'amount' field from input",
      "deadline": "copy from input",
      "apply_link": "copy from input"
    }
  ]
}

STRICT RULES:
- Output list length must equal input list length (${schemesForPrompt.length} schemes)
- Copy scheme_name, benefit_amount, deadline, apply_link VERBATIM
- No markdown fences, JSON only
''';

    final result = await _callGemini(
      prompt,
      fallback: {"eligible_schemes": []},
    );

    // Safety net: if Gemini still drops schemes, fill in the missing ones
    // with a default reason so the user sees all of them.
    final returned = (result['eligible_schemes'] as List?) ?? [];
    if (returned.length < schemesForPrompt.length) {
      final returnedNames = returned
          .map((r) => (r as Map)['scheme_name']?.toString() ?? '')
          .toSet();
      for (final s in schemesForPrompt) {
        final name = s['scheme_name']?.toString() ?? '';
        if (!returnedNames.contains(name)) {
          returned.add({
            'scheme_name': name,
            'eligibility_reason':
                'You qualify for this scheme based on your income and category.',
            'benefit_amount': s['amount'],
            'deadline': s['deadline'],
            'apply_link': s['apply_link'],
          });
        }
      }
      return {"eligible_schemes": returned};
    }

    return result;
  }

  // ── PROMPT 4: Alternate Paths (for "What if I can't afford this?") ──
  //
  Future<Map<String, dynamic>> getAlternatePaths({
    required String stream,
    required String originalCareer,
    required int maxAnnualBudget,
    required String category,
    required int annualIncome,
  }) async {
    // Filter careers within budget before asking Gemini
    final all = KnowledgeBase.instance.careersForPrompt(stream);
    final affordable = all.where((c) {
      final maxCost = c['govt_cost_yr_max'];
      if (maxCost == null) return true;
      return (maxCost as num) <= maxAnnualBudget;
    }).toList();

    final careersJson = jsonEncode(affordable);

    final prompt =
        '''
You are helping a student whose dream career is too expensive.

═══════════════════════════════════════════════
SITUATION
═══════════════════════════════════════════════
- Original career they wanted: $originalCareer
- Max annual budget they can afford: ₹$maxAnnualBudget
- Category: $category
- Annual income: ₹$annualIncome

═══════════════════════════════════════════════
AFFORDABLE CAREERS IN THEIR STREAM (verified)
═══════════════════════════════════════════════
$careersJson

═══════════════════════════════════════════════
TASK
═══════════════════════════════════════════════
Pick 3 careers from the list above that are:
1. Conceptually close to their original dream (similar domain/skills)
2. Within their budget
3. Have decent employment rates

For each, explain in one honest sentence why it's a strong alternative.

═══════════════════════════════════════════════
OUTPUT — STRICT JSON ONLY
═══════════════════════════════════════════════
{
  "alternate_careers": [
    {
      "career": "exact name from list",
      "why_alternative": "one sentence linking back to original dream",
      "cost_estimate": "₹X–Y / year",
      "duration": "X years",
      "monthly_salary_range": "₹X–Y"
    }
  ]
}

RULES:
- Exactly 3 careers
- Must be genuinely within budget
- No markdown, JSON only
''';

    return await _callGemini(prompt, fallback: {"alternate_careers": []});
  }

  // ── SHARED GEMINI CALLER (with 503 retry) ─────────────
  Future<Map<String, dynamic>> _callGemini(
    String prompt, {
    required Map<String, dynamic> fallback,
    int retries = 2,
  }) async {
    for (int attempt = 0; attempt <= retries; attempt++) {
      try {
        final content = [Content.text(prompt)];
        final response = await _model.generateContent(content);
        final text = response.text ?? '';

        // Clean markdown if Gemini adds it despite instructions
        var cleaned = text.trim();
        if (cleaned.startsWith('```')) {
          cleaned = cleaned
              .replaceAll(RegExp(r'^```(?:json)?\s*'), '')
              .replaceAll(RegExp(r'\s*```$'), '')
              .trim();
        }

        return jsonDecode(cleaned) as Map<String, dynamic>;
      } catch (e) {
        // ignore: avoid_print
        print('Gemini error (attempt ${attempt + 1}): $e');
        // Retry on 503 (overloaded) — wait and try again
        if (attempt < retries && e.toString().contains('503')) {
          await Future.delayed(Duration(seconds: 2 * (attempt + 1)));
          continue;
        }
        return fallback;
      }
    }
    return fallback;
  }
}
