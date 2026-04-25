import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Singleton that holds the current app language and notifies listeners
/// when it changes. Persists choice to Firestore so it survives reload.
class LanguageService extends ChangeNotifier {
  LanguageService._();
  static final LanguageService instance = LanguageService._();

  Locale _locale = const Locale('en');
  Locale get locale => _locale;

  bool get isHindi => _locale.languageCode == 'hi';
  bool get isEnglish => _locale.languageCode == 'en';

  /// The language code passed to Gemini prompts so AI output also matches.
  String get geminiLanguageInstruction => isHindi
      ? 'Respond in simple, clear Hindi using Devanagari script. Keep technical terms (career names like MBBS, NEET, JEE, names of institutions, scheme names) in English.'
      : 'Respond in clear, simple English.';

  /// Load the user's saved preference from Firestore on app start.
  Future<void> loadFromFirestore() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    try {
      final doc = await FirebaseFirestore.instance
          .collection('students')
          .doc(user.uid)
          .get();
      final lang = doc.data()?['language'] as String?;
      if (lang == 'hi') {
        _locale = const Locale('hi');
        notifyListeners();
      }
    } catch (_) {
      // Silent failure — fall back to English default
    }
  }

  /// Switch the language and persist to Firestore.
  Future<void> setLanguage(String code) async {
    if (code != 'en' && code != 'hi') return;
    _locale = Locale(code);
    notifyListeners();

    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance
          .collection('students')
          .doc(user.uid)
          .set({'language': code}, SetOptions(merge: true));
    }
  }

  /// Convenience toggle.
  Future<void> toggle() async {
    await setLanguage(isHindi ? 'en' : 'hi');
  }
}