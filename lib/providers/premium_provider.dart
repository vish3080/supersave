import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _kIsPremium = 'is_premium';

class PremiumProvider extends ChangeNotifier {
  bool _isPremium = false;

  bool get isPremium => _isPremium;

  /// Reads the premium flag from SharedPreferences and notifies listeners.
  Future<void> checkPremium() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _isPremium = prefs.getBool(_kIsPremium) ?? false;
      notifyListeners();
    } catch (e) {
      // If SharedPreferences is unavailable, default to false.
      _isPremium = false;
      notifyListeners();
    }
  }

  /// Persists [value] to SharedPreferences and notifies listeners.
  Future<void> setPremium(bool value) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_kIsPremium, value);
      _isPremium = value;
      notifyListeners();
    } catch (e) {
      // Silently fail — premium state stays unchanged.
    }
  }
}
