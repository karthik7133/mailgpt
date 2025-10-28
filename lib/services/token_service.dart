import 'package:shared_preferences/shared_preferences.dart';

class TokenService {
  static SharedPreferences? _prefs;

  static const String _tokenKey = 'auth_token';
  static const String _rememberMeKey = 'remember_me';
  static const String _userIdKey = 'user_id';
  static const String _emailKey = 'user_email';
  static const String _nameKey = 'user_name';
  static const String _profilePicKey = 'profile_pic';
  static const String _onboardingKey = 'onboarding_complete';

  // NEW KEYS FOR GMAIL TOKENS
  static const String _googleAccessTokenKey = 'google_access_token';
  static const String _googleRefreshTokenKey = 'google_refresh_token';

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Token Management (Firebase ID Token)
  static Future<void> saveToken(String token) async {
    await _prefs?.setString(_tokenKey, token);
  }

  static String? getToken() {
    return _prefs?.getString(_tokenKey);
  }

  // --- FIX: DEFINED THE MISSING METHOD ---
  static Future<void> removeToken() async {
    await _prefs?.remove(_tokenKey);
  }
  // ----------------------------------------

  // Google Token Management (For Gmail API)
  static Future<void> saveGoogleTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await _prefs?.setString(_googleAccessTokenKey, accessToken);
    await _prefs?.setString(_googleRefreshTokenKey, refreshToken);
  }

  static String? getGoogleAccessToken() {
    return _prefs?.getString(_googleAccessTokenKey);
  }

  static String? getGoogleRefreshToken() {
    return _prefs?.getString(_googleRefreshTokenKey);
  }

  // Remember Me
  static Future<void> setRememberMe(bool value) async {
    await _prefs?.setBool(_rememberMeKey, value);
  }

  static bool getRememberMe() {
    return _prefs?.getBool(_rememberMeKey) ?? false;
  }

  // User Data
  static Future<void> saveUserData({
    required String userId,
    required String email,
    String? name,
    String? profilePic,
  }) async {
    await _prefs?.setString(_userIdKey, userId);
    await _prefs?.setString(_emailKey, email);
    if (name != null) await _prefs?.setString(_nameKey, name);
    if (profilePic != null) await _prefs?.setString(_profilePicKey, profilePic);
  }

  static Map<String, String?> getUserData() {
    return {
      'userId': _prefs?.getString(_userIdKey),
      'email': _prefs?.getString(_emailKey),
      'name': _prefs?.getString(_nameKey),
      'profilePic': _prefs?.getString(_profilePicKey),
    };
  }

  static Future<void> clearUserData() async {
    await _prefs?.remove(_userIdKey);
    await _prefs?.remove(_emailKey);
    await _prefs?.remove(_nameKey);
    await _prefs?.remove(_profilePicKey);
    await _prefs?.remove(_googleAccessTokenKey);
    await _prefs?.remove(_googleRefreshTokenKey);
  }

  // Onboarding
  static Future<void> setOnboardingComplete(bool value) async {
    await _prefs?.setBool(_onboardingKey, value);
  }

  static bool isOnboardingComplete() {
    return _prefs?.getBool(_onboardingKey) ?? false;
  }

  // Check if user is logged in
  static bool isLoggedIn() {
    final token = getToken();
    final rememberMe = getRememberMe();
    return token != null && token.isNotEmpty && rememberMe;
  }

  // Clear all data (logout)
  static Future<void> clearAll() async {
    await removeToken();
    await clearUserData();
    await setRememberMe(false);
  }
}