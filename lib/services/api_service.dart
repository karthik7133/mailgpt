import 'dart:convert';
import 'package:http/http.dart' as http;
import 'token_service.dart';

class UnauthorizedException implements Exception {
  final String message;
  UnauthorizedException(this.message);
  @override
  String toString() => 'UnauthorizedException: $message';
}

class ApiService {
  // IMPORTANT: Ensure this IP is correct for your physical device/emulator.
  static const String baseUrl = 'https://mail-summeriser-backend.onrender.com';

  // Get headers with auth token
  static Map<String, String> _getHeaders() {
    final token = TokenService.getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  static Map<String, dynamic> _handleResponse(http.Response response) {
    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body);
    } else if (response.statusCode == 401) {
      // Clear tokens on unauthorized response. The calling screen must handle navigation.
      TokenService.clearAll();
      throw UnauthorizedException('Authentication failed. Please log in again.');
    } else {
      throw Exception('Server error (${response.statusCode}): ${response.body}');
    }
  }

  // Auth APIs
  static Future<Map<String, dynamic>> verifyUser({
    required String firebaseUid,
    required String email,
    String? name,
    String? profilePic,
    String? googleAccessToken,
    String? googleRefreshToken,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/auth/verify'),
      headers: _getHeaders(),
      body: jsonEncode({
        'firebaseUid': firebaseUid,
        'email': email,
        if (name != null) 'name': name,
        if (profilePic != null) 'profilePic': profilePic,
        if (googleAccessToken != null) 'googleAccessToken': googleAccessToken,
        if (googleRefreshToken != null) 'googleRefreshToken': googleRefreshToken,
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to verify user: ${response.body}');
    }
  }

  // Mail APIs

  static Future<Map<String, dynamic>> getAllMails({int limit = 50}) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/mails?limit=$limit'),
      headers: _getHeaders(),
    );

    return _handleResponse(response);
  }

  static Future<Map<String, dynamic>> getMailById(String id) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/mails/$id'),
      headers: _getHeaders(),
    );

    return _handleResponse(response);
  }

  // Updated to allow passing maxResults (optional)
  static Future<Map<String, dynamic>> fetchGmailEmails({
    int maxResults = 50, // Defaulting to 50 for the primary view
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/mails/fetch'),
      headers: _getHeaders(),
      body: jsonEncode({
        'maxResults': maxResults,
      }),
    );

    return _handleResponse(response);
  }

  static Future<Map<String, dynamic>> summarizeEmail(String id) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/mails/summarize/$id'),
      headers: _getHeaders(),
    );

    return _handleResponse(response);
  }

  static Future<Map<String, dynamic>> deleteMail(String id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/api/mails/$id'),
      headers: _getHeaders(),
    );

    return _handleResponse(response);
  }

  // Chat APIs
  static Future<Map<String, dynamic>> getChatHistory(String mailId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/chat/$mailId'),
      headers: _getHeaders(),
    );

    return _handleResponse(response);
  }

  static Future<Map<String, dynamic>> sendChatMessage({
    required String mailId,
    required String message,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/chat/$mailId'),
      headers: _getHeaders(),
      body: jsonEncode({'message': message}),
    );

    return _handleResponse(response);
  }

  // Health Check
  static Future<Map<String, dynamic>> healthCheck() async {
    final response = await http.get(Uri.parse('$baseUrl/health'));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Server health check failed');
    }
  }
}