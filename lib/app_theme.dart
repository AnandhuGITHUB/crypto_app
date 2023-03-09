import 'package:shared_preferences/shared_preferences.dart';

class AppTheme {
  static bool isDarkModeEnabled = false;

  static Future<void> getThemeValue() async {
    SharedPreferences _pref = await SharedPreferences.getInstance();
    isDarkModeEnabled = _pref.getBool("isDarkMode") ?? false;
  }
}
