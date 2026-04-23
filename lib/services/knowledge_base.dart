import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

/// Loads careers.json, schemes.json, questions.json once at app start
/// and exposes helpers for Gemini prompts and UI filtering.
class KnowledgeBase {
  KnowledgeBase._();
  static final KnowledgeBase instance = KnowledgeBase._();

  List<Map<String, dynamic>> _careers = [];
  List<Map<String, dynamic>> _schemes = [];
  Map<String, List<Map<String, dynamic>>> _questions = {};
  bool _loaded = false;

  bool get isLoaded => _loaded;

  /// Call this once on app startup (e.g. in main() before runApp).
  Future<void> load() async {
    if (_loaded) return;

    final careersRaw = await rootBundle.loadString('assets/data/careers.json');
    final schemesRaw = await rootBundle.loadString('assets/data/schemes.json');
    final questionsRaw = await rootBundle.loadString(
      'assets/data/questions.json',
    );

    _careers = List<Map<String, dynamic>>.from(jsonDecode(careersRaw));
    _schemes = List<Map<String, dynamic>>.from(jsonDecode(schemesRaw));

    final qDecoded = jsonDecode(questionsRaw) as Map<String, dynamic>;
    _questions = qDecoded.map(
      (k, v) => MapEntry(k, List<Map<String, dynamic>>.from(v as List)),
    );

    _loaded = true;
  }

  // -------------------- CAREERS --------------------

  List<Map<String, dynamic>> get allCareers => _careers;

  /// Filter careers by stream: "Medical", "Non-Medical", "Commerce", "Arts"
  List<Map<String, dynamic>> careersForStream(String stream) {
    return _careers.where((c) => c['stream'] == stream).toList();
  }

  /// Lightweight career list for Gemini prompts — strips the raw/verbose
  /// fields to save tokens. Send this as context, not the full dataset.
  List<Map<String, dynamic>> careersForPrompt(String stream) {
    return careersForStream(stream).map((c) {
      return {
        'career': c['career'],
        'category': c['category'],
        'section': c['section'],
        'duration_years': c['duration_years'],
        'entrance_exam': c['entrance_exam'],
        'cutoff_summary': c['cutoff']?['raw'],
        'neet_min': c['cutoff']?['neet_min'],
        'percent_12th_min': c['cutoff']?['percent_12th_min'],
        'govt_cost_yr_min': c['govt_cost_yr']?['min'],
        'govt_cost_yr_max': c['govt_cost_yr']?['max'],
        'private_cost_yr_min': c['private_cost_yr']?['min'],
        'private_cost_yr_max': c['private_cost_yr']?['max'],
        'monthly_salary_min': c['monthly_salary']?['min'],
        'monthly_salary_max': c['monthly_salary']?['max'],
        'employment_rate_pct': c['employment_rate_pct'],
      };
    }).toList();
  }

  /// Find a single career by exact name match.
  Map<String, dynamic>? careerByName(String name) {
    for (final c in _careers) {
      if (c['career'] == name) return c;
    }
    return null;
  }

  // -------------------- SCHEMES --------------------

  List<Map<String, dynamic>> get allSchemes => _schemes;

  /// Return schemes the student is likely eligible for, given their income
  /// (in rupees per year) and category (General / OBC / SC / ST / EWS / etc.).
  List<Map<String, dynamic>> eligibleSchemes({
    required int annualIncome,
    required String category,
  }) {
    return _schemes.where((s) {
      // Income check
      final limit = s['income_limit'];
      if (limit != null) {
        final max = limit['max'];
        if (max != null && annualIncome > (max as num).toInt()) {
          return false;
        }
      }

      // Category check — loose match against the raw string
      final raw = (s['category_eligible_raw'] ?? '').toString().toUpperCase();
      final cat = category.toUpperCase();

      // "All categories" always matches
      if (raw.contains('ALL CATEGORIES') || raw.contains('ALL STUDENTS')) {
        return true;
      }
      // Direct substring match (SC, ST, OBC, EWS, General, Minority, etc.)
      if (raw.contains(cat)) return true;
      // "General" students also eligible for merit-based schemes
      if (cat == 'GENERAL' && (raw.contains('MERIT') || raw.contains('TOP'))) {
        return true;
      }
      return false;
    }).toList();
  }

  // -------------------- QUESTIONS --------------------

  /// Get the 10 quiz questions for a given stream.
  List<Map<String, dynamic>> questionsForStream(String stream) {
    return _questions[stream] ?? [];
  }
}
