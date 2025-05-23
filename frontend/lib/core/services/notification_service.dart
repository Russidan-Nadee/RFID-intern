import 'package:flutter/material.dart';

class LocalizationService {
  // Supported locales
  static final List<Locale> supportedLocales = [
    const Locale('en', 'US'),
    const Locale('th', 'TH'),
  ];

  // Get current locale
  static Locale? getCurrentLocale() {
    // Implement getting current locale from storage
    return const Locale('en', 'US');
  }

  // Set locale
  static Future<void> setLocale(Locale locale) async {
    // Implement saving locale to storage
  }

  // Get localized string
  static String getString(String key, {Map<String, String>? args}) {
    // Implement string localization
    return key;
  }
}
