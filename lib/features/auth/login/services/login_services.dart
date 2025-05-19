import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginService {
  static const String baseUrl = "https://backend.enjazkw.com/api";

  Future<Map<String, dynamic>> login({required String method, required String id}) async {
    final url = Uri.parse("$baseUrl/login-account");

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({"method": method, "id": id}),
      );

      print("🔄 RESPONSE: ${response.statusCode} - ${response.body}");

      final data = jsonDecode(response.body);

      final prefs = await SharedPreferences.getInstance();
      final token = data['token'] ?? "";
      print(token);
      await prefs.setString('token', token);

      final fcmToken = await FirebaseMessaging.instance.getToken();
      if (fcmToken != null) {
        await _sendFcmTokenToBackend(fcmToken, token);
      }

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': data['message'],
          'userId': data['userId'],
        };
      } else {
        return {
          'success': false,
          'message': data['message_key'] ?? 'user_not_found',
        };
      }
    } catch (e) {
      print("❌ EXCEPTION: $e");
      return {
        'success': false,
        'message': 'server_error',
      };
    }
  }

  Future<void> _sendFcmTokenToBackend(String fcmToken, String authToken) async {
    final url = Uri.parse('$baseUrl/login/token');
    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
        body: jsonEncode({"token": fcmToken}),
      );
      print("✅ FCM token sent: ${response.statusCode} - ${response.body}");
    } catch (e) {
      print("❌ Error sending FCM token: $e");
    }
  }
}
