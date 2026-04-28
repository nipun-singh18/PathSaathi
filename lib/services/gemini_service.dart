import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'knowledge_base.dart';
import 'language_service.dart';

class GeminiService {
  late final GenerativeModel _model;

  GeminiService() {
    _model = GenerativeModel(
      // gemini-2.5-flash is a thinking model — use gemini-2.0-flash for
      // reliable JSON-only output without thinking token interference.
      // Switch back to 'gemini-2.5-flash' only if you handle ThinkingConfig.
      model: 'gemini-2.5-flash-lite',
      apiKey: dotenv.env['GEMINI_API_KEY']!,
    );
  }

  /// Appended to every prompt — instructs Gemini what language to respond in.
  /// In Hindi mode: respond in Hindi but keep technical terms English.
  /// In English mode: returns empty string (no extra instruction needed).
  String _languageInstruction() {
    if (!LanguageService.instance.isHindi) return '';
    return '''


═══════════════════════════════════════════════
LANGUAGE INSTRUCTION
═══════════════════════════════════════════════
Respond entirely in clear, simple Hindi using Devanagari script for all
explanatory text (the "why" sentences, descriptions, advice, eligibility
reasons, phase names, milestone descriptions).

Keep these in English exactly as given (do NOT transliterate or translate):
- Career names (MBBS, B.Sc Nursing, Pharmacy, Engineering, etc.)
- Exam names (NEET, JEE, JEE Main, JEE Advanced, BITSAT)
- Institution names (AIIMS, IIT, NIT, IIIT)
- Scheme names (PM-USP, NSP, Vidyalakshmi, etc.)
- Category codes (SC, ST, OBC, EWS)
- Currency notation (₹, ₹3,00,000, ₹60K)
- URLs (scholarships.gov.in, etc.)
- All numbers, percentages, and JSON keys

The OUTPUT JSON STRUCTURE must remain exactly as specified. Only the
human-readable string values get translated to Hindi.
''';
  }

  // ── PROMPT 1: Career Matching ──────────────────────────
  Future<Map<String, dynamic>> getCareerRecommendations({
    required String stream,
    required String interests,
    required String strengths,
    required String budget,
    required String location,
    required String category,
    required int annualIncome,
    String? class12Marks,
    int? neetScore,
    double? jeePercentile,
  }) async {
    final verifiedCareers = KnowledgeBase.instance.careersForPrompt(stream);
    final careersJson = jsonEncode(verifiedCareers);

    final entranceContext = _buildEntranceContext(
      stream: stream,
      neetScore: neetScore,
      jeePercentile: jeePercentile,
    );

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

ENTRANCE EXAM:
$entranceContext

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
   - If career requires NEET AND student gave NEET score:
       Use the NEET CUTOFF REFERENCE above (with category adjustments).
       Comfortably above the cutoff for this career → 80–95
       Right at the cutoff (±20 marks) → 60–75
       Below cutoff but within reach (<60 marks) → 30–50
       Significantly below (>100 marks gap) → ≤20
   - If career requires JEE AND student gave JEE percentile:
       Use the JEE CUTOFF REFERENCE above.
       Above the tier's percentile → 80–95
       Below by <2 percentile → 50–70
       Below by >5 percentile → ≤30
   - If career has no entrance exam (Commerce, Arts, allied health):
       Use class 12 marks vs percent_12th_min from the verified data.
       Meets cutoff comfortably → 70–90
       Below cutoff → ≤30
   - If no entrance score given, score from class 12 marks only (50 if marks missing too).

2. FINANCIAL FIT (0–100)
   - Compute total cost using govt_cost_yr (min) × duration_years
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
This prevents "MBBS is a great match!" for a student who can't afford it OR
"MBBS great fit!" for a student whose NEET score is way below cutoff.

HONESTY RULE:
The "why" field MUST be honest, not motivational. Say "NEET score 100 marks below SC cutoff for govt MBBS" if true. Say "Strong fit — NEET 310 comfortably clears govt nursing cutoff" if true. Never say "great choice!" or "pursue your dreams." Indian students deserve real talk.

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
- Sort by reality_score descending${_languageInstruction()}
''';

    return await _callGemini(prompt, fallback: {"recommendations": []});
  }

  /// Builds the entrance-exam context block injected into the recommendation prompt.
  String _buildEntranceContext({
    required String stream,
    int? neetScore,
    double? jeePercentile,
  }) {
    if (stream == 'Medical' && neetScore != null) {
      final tier = KnowledgeBase.instance.tierForNeetScore(neetScore);
      return '''
- NEET Score: $neetScore / 720
- Realistic college tier based on this score: $tier

NEET CUTOFF REFERENCE (use for academic_fit scoring):
- 650+ → AIIMS / Top Govt MBBS  (Gen)
- 550–650 → State Govt MBBS  (Gen 550+, OBC 500+, SC/ST 400+)
- 450–550 → Private MBBS or Govt BDS  (Gen 450+)
- 380–500 → AYUSH (BAMS/BHMS)  (NEET 350–450)
- 200–380 → Govt Nursing & Allied Health
- Below 200 → B.Sc Life Sciences (no NEET needed)

CATEGORY ADJUSTMENTS:
- SC: ~150 marks effective advantage  (SC 400 ≈ Gen 550)
- OBC-NCL: ~50 marks advantage
- EWS: ~20–30 marks advantage''';
    }

    if (stream == 'Non-Medical' && jeePercentile != null) {
      final tier = KnowledgeBase.instance.tierForJeePercentile(jeePercentile);
      return '''
- JEE Main Percentile: $jeePercentile
- Realistic college tier based on this percentile: $tier

JEE CUTOFF REFERENCE (use for academic_fit scoring):
- 99.5+ → Top IIT (Bombay/Delhi/Madras) via JEE Advanced
- 99–99.5 → Mid-tier IIT (Roorkee/KGP/Guwahati)
- 98–99 → Newer IIT (BHU/Patna/Mandi)
- 97–99 → Top NIT (Trichy/Warangal/Surathkal)
- 93–97 → Mid-tier NIT, IIIT Hyderabad
- 88–93 → Newer NIT, BITS, DTU/NSUT
- 75–88 → State Govt Engineering, VIT, SRM
- 60–75 → Mid-tier private colleges
- Below 60 → Local private / B.Sc route''';
    }

    return '- (No entrance exam score provided — score academic_fit from class 12 marks only)';
  }

  // ── PROMPT 2: Roadmap Generator ────────────────────────
  Future<Map<String, dynamic>> getRoadmap({
    required String careerName,
    required String educationLevel,
    required String budget,
  }) async {
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
- No markdown, JSON only${_languageInstruction()}
''';

    return await _callGemini(prompt, fallback: {"roadmap": []});
  }

  // ── PROMPT 3: Government Schemes ───────────────────────
  Future<Map<String, dynamic>> getEligibleSchemes({
    required int annualIncome,
    required String category,
    required String state,
    required String career,
  }) async {
    final eligible = KnowledgeBase.instance.eligibleSchemes(
      annualIncome: annualIncome,
      category: category,
    );

    if (eligible.isEmpty) {
      return {"eligible_schemes": []};
    }

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
- No markdown fences, JSON only${_languageInstruction()}
''';

    final result = await _callGemini(
      prompt,
      fallback: {"eligible_schemes": []},
    );

    final returned = (result['eligible_schemes'] as List?) ?? [];
    if (returned.length < schemesForPrompt.length) {
      final returnedNames = returned
          .map((r) => (r as Map)['scheme_name']?.toString() ?? '')
          .toSet();
      // Fallback eligibility reason — language-aware
      final fallbackReason = LanguageService.instance.isHindi
          ? 'आपकी आय और श्रेणी के आधार पर आप इस योजना के लिए पात्र हैं।'
          : 'You qualify for this scheme based on your income and category.';
      for (final s in schemesForPrompt) {
        final name = s['scheme_name']?.toString() ?? '';
        if (!returnedNames.contains(name)) {
          returned.add({
            'scheme_name': name,
            'eligibility_reason': fallbackReason,
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

  // ── PROMPT 4: Alternate Paths ──────────────────────────
  Future<Map<String, dynamic>> getAlternatePaths({
    required String stream,
    required String originalCareer,
    required int maxAnnualBudget,
    required String category,
    required int annualIncome,
  }) async {
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
- No markdown, JSON only${_languageInstruction()}
''';

    return await _callGemini(prompt, fallback: {"alternate_careers": []});
  }

  // ── SHARED GEMINI CALLER (with retry + error propagation) ──────────────
  Future<Map<String, dynamic>> _callGemini(
    String prompt, {
    required Map<String, dynamic> fallback,
    int retries = 2,
  }) async {
    Object? lastError;

    for (int attempt = 0; attempt <= retries; attempt++) {
      try {
        final content = [Content.text(prompt)];
        final response = await _model.generateContent(content);
        final text = response.text ?? '';

        var cleaned = text.trim();

        // Strip markdown fences (```json ... ```)
        if (cleaned.startsWith('```')) {
          cleaned = cleaned
              .replaceAll(RegExp(r'^```(?:json)?\s*'), '')
              .replaceAll(RegExp(r'\s*```$'), '')
              .trim();
        }

        // Strip thinking-model tags if present (<think>...</think> or <thinking>...</thinking>)
        cleaned = cleaned
            .replaceAll(RegExp(r'<think>.*?</think>', dotAll: true), '')
            .replaceAll(RegExp(r'<thinking>.*?</thinking>', dotAll: true), '')
            .trim();

        // Extract first JSON object/array if there's surrounding text
        final jsonMatch = RegExp(r'\{[\s\S]*\}').firstMatch(cleaned);
        if (jsonMatch != null) {
          cleaned = jsonMatch.group(0)!;
        }

        return jsonDecode(cleaned) as Map<String, dynamic>;
      } catch (e) {
        lastError = e;
        // ignore: avoid_print
        print('Gemini error (attempt ${attempt + 1}): $e');

        final errStr = e.toString();
        // Retry on 503 (overloaded) and 429 (rate limit)
        if (attempt < retries &&
            (errStr.contains('503') || errStr.contains('429'))) {
          await Future.delayed(Duration(seconds: 3 * (attempt + 1)));
          continue;
        }
        break;
      }
    }

    // Re-throw so the caller (analyseCareer) can show a proper error message
    // instead of silently navigating with empty data.
    throw Exception(
      lastError?.toString() ?? 'Gemini API call failed after $retries retries',
    );
  }
}