import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageService {
  static LocalStorageService? _instance;
  static SharedPreferences? _preferences;

  // Keys
  static const String userTokenKey = 'user_token';
  static const String userDataKey = 'user_data';
  static const String onboardingCompletedKey = 'onboarding_completed';

  // Private constructor
  LocalStorageService._();

  // Get instance
  static Future<LocalStorageService> getInstance() async {
    _instance ??= LocalStorageService._();
    _preferences ??= await SharedPreferences.getInstance();
    return _instance!;
  }

  // --- String Operations ---
  Future<bool> setString(String key, String value) async {
    return await _preferences!.setString(key, value);
  }

  String? getString(String key) {
    return _preferences!.getString(key);
  }

  // --- Boolean Operations ---
  Future<bool> setBool(String key, bool value) async {
    return await _preferences!.setBool(key, value);
  }

  bool? getBool(String key) {
    return _preferences!.getBool(key);
  }

  // --- Integer Operations ---
  Future<bool> setInt(String key, int value) async {
    return await _preferences!.setInt(key, value);
  }

  int? getInt(String key) {
    return _preferences!.getInt(key);
  }

  // --- Double Operations ---
  Future<bool> setDouble(String key, double value) async {
    return await _preferences!.setDouble(key, value);
  }

  double? getDouble(String key) {
    return _preferences!.getDouble(key);
  }

  // --- List<String> Operations ---
  Future<bool> setStringList(String key, List<String> value) async {
    return await _preferences!.setStringList(key, value);
  }

  List<String>? getStringList(String key) {
    return _preferences!.getStringList(key);
  }

  // --- Common App Operations ---
  // Save user token
  Future<bool> setUserToken(String token) async {
    return await setString(userTokenKey, token);
  }

  // Get user token
  String? getUserToken() {
    return getString(userTokenKey);
  }

  // Save user data as JSON string
  Future<bool> setUserData(String userData) async {
    return await setString(userDataKey, userData);
  }

  // Get user data JSON string
  String? getUserData() {
    return getString(userDataKey);
  }

  // Set onboarding status
  Future<bool> setOnboardingCompleted(bool completed) async {
    return await setBool(onboardingCompletedKey, completed);
  }

  // Check if onboarding is completed
  bool isOnboardingCompleted() {
    return getBool(onboardingCompletedKey) ?? false;
  }

  // Remove specific data
  Future<bool> remove(String key) async {
    return await _preferences!.remove(key);
  }

  // Clear all data
  Future<bool> clear() async {
    return await _preferences!.clear();
  }
}
