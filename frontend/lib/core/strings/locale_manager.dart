import 'app_strings.dart';
import 'app_strings_en.dart';
import 'app_strings_es.dart';

enum AppLocale { es, en }

class LocaleManager {
  static AppLocale _current = AppLocale.es;

  static AppLocale get current => _current;

  static AppStrings get strings {
    switch (_current) {
      case AppLocale.en:
        return const AppStringsEn();
      case AppLocale.es:
        return const AppStringsEs();
    }
  }

  static void setLocale(AppLocale locale) {
    _current = locale;
  }
}
