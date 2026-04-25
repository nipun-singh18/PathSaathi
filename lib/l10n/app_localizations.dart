import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_hi.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('hi'),
  ];

  /// App name (do not translate — keep as PathSaathi)
  ///
  /// In en, this message translates to:
  /// **'PathSaathi'**
  String get appTitle;

  /// No description provided for @tagline.
  ///
  /// In en, this message translates to:
  /// **'I CAN, AND I WILL.'**
  String get tagline;

  /// No description provided for @getStarted.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get getStarted;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @languageHindi.
  ///
  /// In en, this message translates to:
  /// **'हिन्दी'**
  String get languageHindi;

  /// No description provided for @switchLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get switchLanguage;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @errorGeneric.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get errorGeneric;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @submit.
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get submit;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @chooseYourStream.
  ///
  /// In en, this message translates to:
  /// **'Choose Your Stream'**
  String get chooseYourStream;

  /// No description provided for @streamSelectionSubtitle.
  ///
  /// In en, this message translates to:
  /// **'AI will build your personalized roadmap'**
  String get streamSelectionSubtitle;

  /// No description provided for @streamMedical.
  ///
  /// In en, this message translates to:
  /// **'Medical'**
  String get streamMedical;

  /// No description provided for @streamNonMedical.
  ///
  /// In en, this message translates to:
  /// **'Non-Medical'**
  String get streamNonMedical;

  /// No description provided for @streamCommerce.
  ///
  /// In en, this message translates to:
  /// **'Commerce'**
  String get streamCommerce;

  /// No description provided for @streamArts.
  ///
  /// In en, this message translates to:
  /// **'Arts'**
  String get streamArts;

  /// No description provided for @streamCardSelect.
  ///
  /// In en, this message translates to:
  /// **'Select ✓'**
  String get streamCardSelect;

  /// No description provided for @streamCardExplore.
  ///
  /// In en, this message translates to:
  /// **'Explore →'**
  String get streamCardExplore;

  /// No description provided for @profileTitle.
  ///
  /// In en, this message translates to:
  /// **'Tell Us About Yourself'**
  String get profileTitle;

  /// No description provided for @profileIntro.
  ///
  /// In en, this message translates to:
  /// **'PathSaathi needs a few details\nto find your best career match.'**
  String get profileIntro;

  /// No description provided for @fieldStream.
  ///
  /// In en, this message translates to:
  /// **'Your Stream *'**
  String get fieldStream;

  /// No description provided for @fieldInterests.
  ///
  /// In en, this message translates to:
  /// **'Your Interests *'**
  String get fieldInterests;

  /// No description provided for @fieldStrengths.
  ///
  /// In en, this message translates to:
  /// **'Your Strengths'**
  String get fieldStrengths;

  /// No description provided for @fieldMarks.
  ///
  /// In en, this message translates to:
  /// **'Class 12 Marks (%)'**
  String get fieldMarks;

  /// No description provided for @fieldNeet.
  ///
  /// In en, this message translates to:
  /// **'NEET Score (out of 720) — optional'**
  String get fieldNeet;

  /// No description provided for @fieldJee.
  ///
  /// In en, this message translates to:
  /// **'JEE Main Percentile — optional'**
  String get fieldJee;

  /// No description provided for @fieldIncome.
  ///
  /// In en, this message translates to:
  /// **'Annual Family Income (in ₹ lakh) *'**
  String get fieldIncome;

  /// No description provided for @fieldCategory.
  ///
  /// In en, this message translates to:
  /// **'Category *'**
  String get fieldCategory;

  /// No description provided for @fieldBudget.
  ///
  /// In en, this message translates to:
  /// **'Education Budget per Year'**
  String get fieldBudget;

  /// No description provided for @fieldLocation.
  ///
  /// In en, this message translates to:
  /// **'Your City / State *'**
  String get fieldLocation;

  /// No description provided for @hintInterests.
  ///
  /// In en, this message translates to:
  /// **'e.g. helping people, computers, drawing, science'**
  String get hintInterests;

  /// No description provided for @hintStrengths.
  ///
  /// In en, this message translates to:
  /// **'e.g. good at maths, creative, good communicator'**
  String get hintStrengths;

  /// No description provided for @hintMarks.
  ///
  /// In en, this message translates to:
  /// **'e.g. 72'**
  String get hintMarks;

  /// No description provided for @hintNeet.
  ///
  /// In en, this message translates to:
  /// **'e.g. 310 — leave blank if not given'**
  String get hintNeet;

  /// No description provided for @hintJee.
  ///
  /// In en, this message translates to:
  /// **'e.g. 87.5 — leave blank if not given'**
  String get hintJee;

  /// No description provided for @hintIncome.
  ///
  /// In en, this message translates to:
  /// **'e.g. 3 for ₹3 lakh, 8 for ₹8 lakh'**
  String get hintIncome;

  /// No description provided for @hintBudget.
  ///
  /// In en, this message translates to:
  /// **'e.g. 50 thousand, 1 lakh (optional)'**
  String get hintBudget;

  /// No description provided for @hintLocation.
  ///
  /// In en, this message translates to:
  /// **'e.g. Chandigarh, Punjab'**
  String get hintLocation;

  /// No description provided for @categoryGeneral.
  ///
  /// In en, this message translates to:
  /// **'General'**
  String get categoryGeneral;

  /// No description provided for @categoryOBC.
  ///
  /// In en, this message translates to:
  /// **'OBC'**
  String get categoryOBC;

  /// No description provided for @categorySC.
  ///
  /// In en, this message translates to:
  /// **'SC'**
  String get categorySC;

  /// No description provided for @categoryST.
  ///
  /// In en, this message translates to:
  /// **'ST'**
  String get categoryST;

  /// No description provided for @categoryEWS.
  ///
  /// In en, this message translates to:
  /// **'EWS'**
  String get categoryEWS;

  /// No description provided for @submitFindPath.
  ///
  /// In en, this message translates to:
  /// **'Find My Career Path →'**
  String get submitFindPath;

  /// No description provided for @submitAnalysing.
  ///
  /// In en, this message translates to:
  /// **'PathSaathi is analysing...'**
  String get submitAnalysing;

  /// No description provided for @errorRequiredFields.
  ///
  /// In en, this message translates to:
  /// **'Please fill all required fields'**
  String get errorRequiredFields;

  /// No description provided for @errorIncomeFormat.
  ///
  /// In en, this message translates to:
  /// **'Enter income as a number (e.g. 3 for ₹3 lakh)'**
  String get errorIncomeFormat;

  /// No description provided for @errorNeetRange.
  ///
  /// In en, this message translates to:
  /// **'NEET score must be a number between 0 and 720'**
  String get errorNeetRange;

  /// No description provided for @errorJeeRange.
  ///
  /// In en, this message translates to:
  /// **'JEE percentile must be a number between 0 and 100'**
  String get errorJeeRange;

  /// No description provided for @errorPrefix.
  ///
  /// In en, this message translates to:
  /// **'Error: {message}'**
  String errorPrefix(String message);

  /// AppBar title on the recommendations list screen
  ///
  /// In en, this message translates to:
  /// **'Your Career Matches'**
  String get recommendationsTitle;

  /// Empty state shown when Gemini returns no results
  ///
  /// In en, this message translates to:
  /// **'No recommendations found.\nPlease go back and try again.'**
  String get noRecommendations;

  /// Reality Score band labels (>=71 / 41-70 / <41)
  ///
  /// In en, this message translates to:
  /// **'Highly Suitable'**
  String get scoreHighlySuitable;

  /// No description provided for @scoreModerate.
  ///
  /// In en, this message translates to:
  /// **'Moderate'**
  String get scoreModerate;

  /// No description provided for @scoreLowFeasibility.
  ///
  /// In en, this message translates to:
  /// **'Low Feasibility'**
  String get scoreLowFeasibility;

  /// Bottom-right hint on each recommendation card
  ///
  /// In en, this message translates to:
  /// **'Tap for details →'**
  String get tapForDetails;

  /// AppBar title on the career detail screen
  ///
  /// In en, this message translates to:
  /// **'Career Details'**
  String get careerDetailsTitle;

  /// Empty state when career detail screen is opened without args
  ///
  /// In en, this message translates to:
  /// **'No career data passed.\nGo back and tap a career card.'**
  String get noCareerData;

  /// Detail-screen variant of the Moderate score band (slightly longer than the list version)
  ///
  /// In en, this message translates to:
  /// **'Moderate Feasibility'**
  String get scoreModerateFeasibility;

  /// The Reality Score badge text with score interpolated
  ///
  /// In en, this message translates to:
  /// **'Reality Score: {score}/100'**
  String realityScoreValue(int score);

  /// Section header above the 4 sub-score bars
  ///
  /// In en, this message translates to:
  /// **'Score Breakdown'**
  String get scoreBreakdownTitle;

  /// One of four Reality Score components
  ///
  /// In en, this message translates to:
  /// **'Academic Fit'**
  String get subscoreAcademicFit;

  /// No description provided for @subscoreFinancialFit.
  ///
  /// In en, this message translates to:
  /// **'Financial Fit'**
  String get subscoreFinancialFit;

  /// No description provided for @subscoreEffortPayoff.
  ///
  /// In en, this message translates to:
  /// **'Effort vs Payoff'**
  String get subscoreEffortPayoff;

  /// No description provided for @subscoreInterestMatch.
  ///
  /// In en, this message translates to:
  /// **'Interest Match'**
  String get subscoreInterestMatch;

  /// Section header above the duration/cutoff/cost facts list
  ///
  /// In en, this message translates to:
  /// **'Key Facts'**
  String get keyFactsTitle;

  /// No description provided for @factDuration.
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get factDuration;

  /// No description provided for @factEntranceExam.
  ///
  /// In en, this message translates to:
  /// **'Entrance Exam'**
  String get factEntranceExam;

  /// No description provided for @factRealisticCutoff.
  ///
  /// In en, this message translates to:
  /// **'Realistic Cutoff'**
  String get factRealisticCutoff;

  /// No description provided for @factCourseCost.
  ///
  /// In en, this message translates to:
  /// **'Course Cost'**
  String get factCourseCost;

  /// No description provided for @factExpectedSalary.
  ///
  /// In en, this message translates to:
  /// **'Expected Salary'**
  String get factExpectedSalary;

  /// No description provided for @factEmploymentRate.
  ///
  /// In en, this message translates to:
  /// **'Employment Rate'**
  String get factEmploymentRate;

  /// No description provided for @btnViewRoadmap.
  ///
  /// In en, this message translates to:
  /// **'View Roadmap'**
  String get btnViewRoadmap;

  /// No description provided for @btnViewSchemes.
  ///
  /// In en, this message translates to:
  /// **'View Eligible Schemes'**
  String get btnViewSchemes;

  /// No description provided for @btnAlternatePaths.
  ///
  /// In en, this message translates to:
  /// **'What If I Can\'t Afford This?'**
  String get btnAlternatePaths;

  /// Loading text shown while Gemini call is in progress
  ///
  /// In en, this message translates to:
  /// **'Gemini is analyzing your profile...'**
  String get processingMessage;

  /// Dev shortcut button — should be removed before production
  ///
  /// In en, this message translates to:
  /// **'Skip Loading (Dev Mode)'**
  String get skipLoadingDev;

  /// Shown on detail screens when navigation lost the career argument
  ///
  /// In en, this message translates to:
  /// **'No career data received.'**
  String get errorNoCareerData;

  /// No description provided for @roadmapTitle.
  ///
  /// In en, this message translates to:
  /// **'Your Roadmap'**
  String get roadmapTitle;

  /// No description provided for @roadmapLoading.
  ///
  /// In en, this message translates to:
  /// **'Generating your personalised roadmap...'**
  String get roadmapLoading;

  /// No description provided for @errorRoadmapGeneration.
  ///
  /// In en, this message translates to:
  /// **'Could not generate a roadmap. Please try again.'**
  String get errorRoadmapGeneration;

  /// No description provided for @yourJourney.
  ///
  /// In en, this message translates to:
  /// **'Your Journey'**
  String get yourJourney;

  /// No description provided for @milestonesProgress.
  ///
  /// In en, this message translates to:
  /// **'{completed} of {total} milestones complete'**
  String milestonesProgress(int completed, int total);

  /// No description provided for @summaryEntranceExams.
  ///
  /// In en, this message translates to:
  /// **'Entrance Exams'**
  String get summaryEntranceExams;

  /// No description provided for @summaryKeySkills.
  ///
  /// In en, this message translates to:
  /// **'Key Skills'**
  String get summaryKeySkills;

  /// No description provided for @summaryCostSummary.
  ///
  /// In en, this message translates to:
  /// **'Cost Summary'**
  String get summaryCostSummary;

  /// No description provided for @schemesTitle.
  ///
  /// In en, this message translates to:
  /// **'Eligible Schemes'**
  String get schemesTitle;

  /// No description provided for @schemesLoading.
  ///
  /// In en, this message translates to:
  /// **'Finding scholarships you qualify for...'**
  String get schemesLoading;

  /// No description provided for @schemesEmpty.
  ///
  /// In en, this message translates to:
  /// **'No matching schemes found.\nTry a different career or check back later.'**
  String get schemesEmpty;

  /// No description provided for @schemesQualifyBanner.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{You qualify for 1 scheme based on your profile} other{You qualify for {count} schemes based on your profile}}'**
  String schemesQualifyBanner(int count);

  /// No description provided for @schemeAmount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get schemeAmount;

  /// No description provided for @schemeDeadline.
  ///
  /// In en, this message translates to:
  /// **'Deadline'**
  String get schemeDeadline;

  /// No description provided for @schemeApplyAt.
  ///
  /// In en, this message translates to:
  /// **'Apply at'**
  String get schemeApplyAt;

  /// No description provided for @alternateTitle.
  ///
  /// In en, this message translates to:
  /// **'Affordable Alternatives'**
  String get alternateTitle;

  /// No description provided for @alternateExploring.
  ///
  /// In en, this message translates to:
  /// **'Exploring alternatives to'**
  String get alternateExploring;

  /// No description provided for @alternateBudgetQuestion.
  ///
  /// In en, this message translates to:
  /// **'What is your maximum annual education budget?'**
  String get alternateBudgetQuestion;

  /// No description provided for @alternateBudgetHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. 1 for ₹1 lakh, 0.5 for ₹50K'**
  String get alternateBudgetHint;

  /// No description provided for @alternateBudgetSuffix.
  ///
  /// In en, this message translates to:
  /// **'lakh / year'**
  String get alternateBudgetSuffix;

  /// No description provided for @alternateBudgetError.
  ///
  /// In en, this message translates to:
  /// **'Enter your max budget per year as a number (e.g. 1 for ₹1 lakh)'**
  String get alternateBudgetError;

  /// No description provided for @alternateFindBtn.
  ///
  /// In en, this message translates to:
  /// **'Find Alternatives'**
  String get alternateFindBtn;

  /// No description provided for @alternateSearching.
  ///
  /// In en, this message translates to:
  /// **'Finding alternatives...'**
  String get alternateSearching;

  /// No description provided for @alternateEmpty.
  ///
  /// In en, this message translates to:
  /// **'No alternatives found within this budget.\nTry increasing your budget a bit.'**
  String get alternateEmpty;

  /// No description provided for @alternateResultsHeader.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 alternative within your budget} other{{count} alternatives within your budget}}'**
  String alternateResultsHeader(int count);

  /// No description provided for @alternateSalaryLabel.
  ///
  /// In en, this message translates to:
  /// **'Salary: {value}'**
  String alternateSalaryLabel(String value);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'hi'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'hi':
      return AppLocalizationsHi();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
