import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class OtpService {
  Future<OtpResponse> verifyOtp({
    required String code,
  }) async {

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('userId');

    if (userId == null) {
      throw Exception('User ID not found in SharedPreferences');
    }

    final url =
        'https://backend.enjazkw.com/api/login-account/$userId/code';

    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'code': code}),
    );

    final data = json.decode(response.body);
    return OtpResponse.fromJson(data);
  }
}
class OtpResponse {
  final String message;
  final String? token;

  OtpResponse({
    required this.message,
    required this.token,
  });

  // Factory method to create OtpResponse from JSON
  factory OtpResponse.fromJson(Map<String, dynamic> json) {
    return OtpResponse(
      message: json['message'] ?? '',
      token: json['token'] ?? '',
    );
  }

  bool get success => message.toLowerCase().contains('success') && token != null;
}
