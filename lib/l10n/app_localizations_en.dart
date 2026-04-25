// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'PathSaathi';

  @override
  String get tagline => 'I CAN, AND I WILL.';

  @override
  String get getStarted => 'Get Started';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageHindi => 'हिन्दी';

  @override
  String get switchLanguage => 'Language';

  @override
  String get loading => 'Loading...';

  @override
  String get errorGeneric => 'Something went wrong. Please try again.';

  @override
  String get back => 'Back';

  @override
  String get next => 'Next';

  @override
  String get submit => 'Submit';

  @override
  String get cancel => 'Cancel';

  @override
  String get chooseYourStream => 'Choose Your Stream';

  @override
  String get streamSelectionSubtitle =>
      'AI will build your personalized roadmap';

  @override
  String get streamMedical => 'Medical';

  @override
  String get streamNonMedical => 'Non-Medical';

  @override
  String get streamCommerce => 'Commerce';

  @override
  String get streamArts => 'Arts';

  @override
  String get streamCardSelect => 'Select ✓';

  @override
  String get streamCardExplore => 'Explore →';

  @override
  String get profileTitle => 'Tell Us About Yourself';

  @override
  String get profileIntro =>
      'PathSaathi needs a few details\nto find your best career match.';

  @override
  String get fieldStream => 'Your Stream *';

  @override
  String get fieldInterests => 'Your Interests *';

  @override
  String get fieldStrengths => 'Your Strengths';

  @override
  String get fieldMarks => 'Class 12 Marks (%)';

  @override
  String get fieldNeet => 'NEET Score (out of 720) — optional';

  @override
  String get fieldJee => 'JEE Main Percentile — optional';

  @override
  String get fieldIncome => 'Annual Family Income (in ₹ lakh) *';

  @override
  String get fieldCategory => 'Category *';

  @override
  String get fieldBudget => 'Education Budget per Year';

  @override
  String get fieldLocation => 'Your City / State *';

  @override
  String get hintInterests =>
      'e.g. helping people, computers, drawing, science';

  @override
  String get hintStrengths => 'e.g. good at maths, creative, good communicator';

  @override
  String get hintMarks => 'e.g. 72';

  @override
  String get hintNeet => 'e.g. 310 — leave blank if not given';

  @override
  String get hintJee => 'e.g. 87.5 — leave blank if not given';

  @override
  String get hintIncome => 'e.g. 3 for ₹3 lakh, 8 for ₹8 lakh';

  @override
  String get hintBudget => 'e.g. 50 thousand, 1 lakh (optional)';

  @override
  String get hintLocation => 'e.g. Chandigarh, Punjab';

  @override
  String get categoryGeneral => 'General';

  @override
  String get categoryOBC => 'OBC';

  @override
  String get categorySC => 'SC';

  @override
  String get categoryST => 'ST';

  @override
  String get categoryEWS => 'EWS';

  @override
  String get submitFindPath => 'Find My Career Path →';

  @override
  String get submitAnalysing => 'PathSaathi is analysing...';

  @override
  String get errorRequiredFields => 'Please fill all required fields';

  @override
  String get errorIncomeFormat =>
      'Enter income as a number (e.g. 3 for ₹3 lakh)';

  @override
  String get errorNeetRange => 'NEET score must be a number between 0 and 720';

  @override
  String get errorJeeRange =>
      'JEE percentile must be a number between 0 and 100';

  @override
  String errorPrefix(String message) {
    return 'Error: $message';
  }

  @override
  String get recommendationsTitle => 'Your Career Matches';

  @override
  String get noRecommendations =>
      'No recommendations found.\nPlease go back and try again.';

  @override
  String get scoreHighlySuitable => 'Highly Suitable';

  @override
  String get scoreModerate => 'Moderate';

  @override
  String get scoreLowFeasibility => 'Low Feasibility';

  @override
  String get tapForDetails => 'Tap for details →';

  @override
  String get careerDetailsTitle => 'Career Details';

  @override
  String get noCareerData =>
      'No career data passed.\nGo back and tap a career card.';

  @override
  String get scoreModerateFeasibility => 'Moderate Feasibility';

  @override
  String realityScoreValue(int score) {
    return 'Reality Score: $score/100';
  }

  @override
  String get scoreBreakdownTitle => 'Score Breakdown';

  @override
  String get subscoreAcademicFit => 'Academic Fit';

  @override
  String get subscoreFinancialFit => 'Financial Fit';

  @override
  String get subscoreEffortPayoff => 'Effort vs Payoff';

  @override
  String get subscoreInterestMatch => 'Interest Match';

  @override
  String get keyFactsTitle => 'Key Facts';

  @override
  String get factDuration => 'Duration';

  @override
  String get factEntranceExam => 'Entrance Exam';

  @override
  String get factRealisticCutoff => 'Realistic Cutoff';

  @override
  String get factCourseCost => 'Course Cost';

  @override
  String get factExpectedSalary => 'Expected Salary';

  @override
  String get factEmploymentRate => 'Employment Rate';

  @override
  String get btnViewRoadmap => 'View Roadmap';

  @override
  String get btnViewSchemes => 'View Eligible Schemes';

  @override
  String get btnAlternatePaths => 'What If I Can\'t Afford This?';

  @override
  String get processingMessage => 'Gemini is analyzing your profile...';

  @override
  String get skipLoadingDev => 'Skip Loading (Dev Mode)';

  @override
  String get errorNoCareerData => 'No career data received.';

  @override
  String get roadmapTitle => 'Your Roadmap';

  @override
  String get roadmapLoading => 'Generating your personalised roadmap...';

  @override
  String get errorRoadmapGeneration =>
      'Could not generate a roadmap. Please try again.';

  @override
  String get yourJourney => 'Your Journey';

  @override
  String milestonesProgress(int completed, int total) {
    return '$completed of $total milestones complete';
  }

  @override
  String get summaryEntranceExams => 'Entrance Exams';

  @override
  String get summaryKeySkills => 'Key Skills';

  @override
  String get summaryCostSummary => 'Cost Summary';

  @override
  String get schemesTitle => 'Eligible Schemes';

  @override
  String get schemesLoading => 'Finding scholarships you qualify for...';

  @override
  String get schemesEmpty =>
      'No matching schemes found.\nTry a different career or check back later.';

  @override
  String schemesQualifyBanner(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'You qualify for $count schemes based on your profile',
      one: 'You qualify for 1 scheme based on your profile',
    );
    return '$_temp0';
  }

  @override
  String get schemeAmount => 'Amount';

  @override
  String get schemeDeadline => 'Deadline';

  @override
  String get schemeApplyAt => 'Apply at';

  @override
  String get alternateTitle => 'Affordable Alternatives';

  @override
  String get alternateExploring => 'Exploring alternatives to';

  @override
  String get alternateBudgetQuestion =>
      'What is your maximum annual education budget?';

  @override
  String get alternateBudgetHint => 'e.g. 1 for ₹1 lakh, 0.5 for ₹50K';

  @override
  String get alternateBudgetSuffix => 'lakh / year';

  @override
  String get alternateBudgetError =>
      'Enter your max budget per year as a number (e.g. 1 for ₹1 lakh)';

  @override
  String get alternateFindBtn => 'Find Alternatives';

  @override
  String get alternateSearching => 'Finding alternatives...';

  @override
  String get alternateEmpty =>
      'No alternatives found within this budget.\nTry increasing your budget a bit.';

  @override
  String alternateResultsHeader(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count alternatives within your budget',
      one: '1 alternative within your budget',
    );
    return '$_temp0';
  }

  @override
  String alternateSalaryLabel(String value) {
    return 'Salary: $value';
  }
}
