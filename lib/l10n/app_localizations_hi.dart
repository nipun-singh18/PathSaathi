// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hindi (`hi`).
class AppLocalizationsHi extends AppLocalizations {
  AppLocalizationsHi([String locale = 'hi']) : super(locale);

  @override
  String get appTitle => 'PathSaathi';

  @override
  String get tagline => 'मैं कर सकता हूँ, और मैं करूँगा।';

  @override
  String get getStarted => 'शुरू करें';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageHindi => 'हिन्दी';

  @override
  String get switchLanguage => 'भाषा';

  @override
  String get loading => 'लोड हो रहा है...';

  @override
  String get errorGeneric => 'कुछ गलत हो गया। कृपया पुनः प्रयास करें।';

  @override
  String get back => 'वापस';

  @override
  String get next => 'आगे';

  @override
  String get submit => 'जमा करें';

  @override
  String get cancel => 'रद्द करें';

  @override
  String get chooseYourStream => 'अपनी स्ट्रीम चुनें';

  @override
  String get streamSelectionSubtitle => 'AI आपका व्यक्तिगत रोडमैप तैयार करेगा';

  @override
  String get streamMedical => 'मेडिकल';

  @override
  String get streamNonMedical => 'नॉन-मेडिकल';

  @override
  String get streamCommerce => 'कॉमर्स';

  @override
  String get streamArts => 'आर्ट्स';

  @override
  String get streamCardSelect => 'चयनित ✓';

  @override
  String get streamCardExplore => 'देखें →';

  @override
  String get profileTitle => 'अपने बारे में बताएं';

  @override
  String get profileIntro =>
      'PathSaathi को सबसे अच्छा करियर मैच\nखोजने के लिए कुछ जानकारी चाहिए।';

  @override
  String get fieldStream => 'आपकी स्ट्रीम *';

  @override
  String get fieldInterests => 'आपकी रुचियाँ *';

  @override
  String get fieldStrengths => 'आपकी ताकतें';

  @override
  String get fieldMarks => '12वीं के अंक (%)';

  @override
  String get fieldNeet => 'NEET स्कोर (720 में से) — वैकल्पिक';

  @override
  String get fieldJee => 'JEE मेन परसेंटाइल — वैकल्पिक';

  @override
  String get fieldIncome => 'पारिवारिक वार्षिक आय (₹ लाख में) *';

  @override
  String get fieldCategory => 'श्रेणी *';

  @override
  String get fieldBudget => 'प्रति वर्ष शिक्षा बजट';

  @override
  String get fieldLocation => 'आपका शहर / राज्य *';

  @override
  String get hintInterests => 'जैसे लोगों की मदद, कंप्यूटर, ड्राइंग, विज्ञान';

  @override
  String get hintStrengths => 'जैसे गणित में अच्छे, रचनात्मक, अच्छे वक्ता';

  @override
  String get hintMarks => 'जैसे 72';

  @override
  String get hintNeet => 'जैसे 310 — न दिया हो तो खाली छोड़ें';

  @override
  String get hintJee => 'जैसे 87.5 — न दिया हो तो खाली छोड़ें';

  @override
  String get hintIncome => 'जैसे ₹3 लाख के लिए 3, ₹8 लाख के लिए 8';

  @override
  String get hintBudget => 'जैसे 50 हज़ार, 1 लाख (वैकल्पिक)';

  @override
  String get hintLocation => 'जैसे चंडीगढ़, पंजाब';

  @override
  String get categoryGeneral => 'सामान्य';

  @override
  String get categoryOBC => 'OBC';

  @override
  String get categorySC => 'SC';

  @override
  String get categoryST => 'ST';

  @override
  String get categoryEWS => 'EWS';

  @override
  String get submitFindPath => 'मेरा करियर पथ खोजें →';

  @override
  String get submitAnalysing => 'PathSaathi विश्लेषण कर रहा है...';

  @override
  String get errorRequiredFields => 'कृपया सभी आवश्यक फ़ील्ड भरें';

  @override
  String get errorIncomeFormat =>
      'आय एक संख्या के रूप में दर्ज करें (जैसे ₹3 लाख के लिए 3)';

  @override
  String get errorNeetRange => 'NEET स्कोर 0 से 720 के बीच होना चाहिए';

  @override
  String get errorJeeRange => 'JEE परसेंटाइल 0 से 100 के बीच होना चाहिए';

  @override
  String errorPrefix(String message) {
    return 'त्रुटि: $message';
  }

  @override
  String get recommendationsTitle => 'आपके करियर मैच';

  @override
  String get noRecommendations =>
      'कोई सिफारिश नहीं मिली।\nकृपया वापस जाकर पुनः प्रयास करें।';

  @override
  String get scoreHighlySuitable => 'अत्यंत उपयुक्त';

  @override
  String get scoreModerate => 'मध्यम';

  @override
  String get scoreLowFeasibility => 'कम संभावना';

  @override
  String get tapForDetails => 'विवरण के लिए टैप करें →';

  @override
  String get careerDetailsTitle => 'करियर विवरण';

  @override
  String get noCareerData =>
      'कोई करियर डेटा नहीं मिला।\nवापस जाकर करियर कार्ड पर टैप करें।';

  @override
  String get scoreModerateFeasibility => 'मध्यम संभावना';

  @override
  String realityScoreValue(int score) {
    return 'Reality Score: $score/100';
  }

  @override
  String get scoreBreakdownTitle => 'स्कोर विश्लेषण';

  @override
  String get subscoreAcademicFit => 'शैक्षणिक अनुकूलता';

  @override
  String get subscoreFinancialFit => 'आर्थिक अनुकूलता';

  @override
  String get subscoreEffortPayoff => 'मेहनत बनाम लाभ';

  @override
  String get subscoreInterestMatch => 'रुचि मेल';

  @override
  String get keyFactsTitle => 'मुख्य जानकारी';

  @override
  String get factDuration => 'अवधि';

  @override
  String get factEntranceExam => 'प्रवेश परीक्षा';

  @override
  String get factRealisticCutoff => 'वास्तविक कटऑफ';

  @override
  String get factCourseCost => 'कोर्स की लागत';

  @override
  String get factExpectedSalary => 'अनुमानित वेतन';

  @override
  String get factEmploymentRate => 'रोज़गार दर';

  @override
  String get btnViewRoadmap => 'रोडमैप देखें';

  @override
  String get btnViewSchemes => 'पात्र योजनाएँ देखें';

  @override
  String get btnAlternatePaths => 'क्या मैं इसका खर्च नहीं उठा सकता?';

  @override
  String get processingMessage =>
      'Gemini आपकी प्रोफ़ाइल का विश्लेषण कर रहा है...';

  @override
  String get skipLoadingDev => 'लोडिंग छोड़ें (डेव मोड)';

  @override
  String get errorNoCareerData => 'कोई करियर डेटा नहीं मिला।';

  @override
  String get roadmapTitle => 'आपका रोडमैप';

  @override
  String get roadmapLoading => 'आपका व्यक्तिगत रोडमैप तैयार किया जा रहा है...';

  @override
  String get errorRoadmapGeneration =>
      'रोडमैप तैयार नहीं हो सका। कृपया पुनः प्रयास करें।';

  @override
  String get yourJourney => 'आपकी यात्रा';

  @override
  String milestonesProgress(int completed, int total) {
    return '$completed में से $total माइलस्टोन पूरे';
  }

  @override
  String get summaryEntranceExams => 'प्रवेश परीक्षाएँ';

  @override
  String get summaryKeySkills => 'मुख्य कौशल';

  @override
  String get summaryCostSummary => 'लागत सारांश';

  @override
  String get schemesTitle => 'पात्र योजनाएँ';

  @override
  String get schemesLoading => 'आपकी पात्र छात्रवृत्तियाँ खोजी जा रही हैं...';

  @override
  String get schemesEmpty =>
      'कोई मिलती-जुलती योजना नहीं मिली।\nकोई दूसरा करियर देखें या बाद में जाँच करें।';

  @override
  String schemesQualifyBanner(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'आपकी प्रोफ़ाइल के आधार पर आप $count योजनाओं के लिए पात्र हैं',
      one: 'आपकी प्रोफ़ाइल के आधार पर आप 1 योजना के लिए पात्र हैं',
    );
    return '$_temp0';
  }

  @override
  String get schemeAmount => 'राशि';

  @override
  String get schemeDeadline => 'अंतिम तिथि';

  @override
  String get schemeApplyAt => 'आवेदन करें';

  @override
  String get alternateTitle => 'किफायती विकल्प';

  @override
  String get alternateExploring => 'इसके विकल्प खोज रहे हैं';

  @override
  String get alternateBudgetQuestion =>
      'आपका अधिकतम वार्षिक शिक्षा बजट क्या है?';

  @override
  String get alternateBudgetHint => 'जैसे ₹1 लाख के लिए 1, ₹50K के लिए 0.5';

  @override
  String get alternateBudgetSuffix => 'लाख / वर्ष';

  @override
  String get alternateBudgetError =>
      'अधिकतम वार्षिक बजट संख्या में दर्ज करें (जैसे ₹1 लाख के लिए 1)';

  @override
  String get alternateFindBtn => 'विकल्प खोजें';

  @override
  String get alternateSearching => 'विकल्प खोजे जा रहे हैं...';

  @override
  String get alternateEmpty =>
      'इस बजट में कोई विकल्प नहीं मिला।\nथोड़ा बजट बढ़ाकर पुनः प्रयास करें।';

  @override
  String alternateResultsHeader(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'आपके बजट में $count विकल्प',
      one: 'आपके बजट में 1 विकल्प',
    );
    return '$_temp0';
  }

  @override
  String alternateSalaryLabel(String value) {
    return 'वेतन: $value';
  }
}
