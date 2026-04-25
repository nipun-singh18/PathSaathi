import 'package:flutter/services.dart' show rootBundle;

class DataLoader {
  static Future<String> loadCareers() async {
    return await rootBundle.loadString('assets/data/careers.csv');
  }

  static Future<String> loadQuestions() async {
    return await rootBundle.loadString('assets/data/questions.csv');
  }

  static Future<String> loadSchemes() async {
    return await rootBundle.loadString('assets/data/schemes.csv');
  }
}