import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Language {
  final String name;
  final Locale code;

  Language(this.name, this.code);

  static List<Language> languages = [
    Language('አማርኛ', const Locale('am')),
    Language('English', const Locale('en')),
  ];

  static Language selectedLanguage = Language('English', const Locale('en'));

  static Language getSelectedLanguage(BuildContext context) {
    final Locale? currentLocale = Get.locale;
    final Language lang = languages.firstWhere(
        (language) => language.code == currentLocale,
        orElse: () => languages.first);
    return lang;
  }

  static String getLocaleCode() {
    if (selectedLanguage == languages[0]) {
      return "am";
    } else if (selectedLanguage == languages[1]) {
      return "en";
    } else {
      return "it";
    }

    // else if (selectedLanguage == languages[2]){
    //   return "tr";
    // }
  }
}
