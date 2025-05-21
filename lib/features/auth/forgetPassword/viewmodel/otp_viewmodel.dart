import 'dart:async';
import 'dart:convert';
import 'package:engaz_app/features/home_screen/view/home_view.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../services/otp_services.dart';

enum OtpStatus {
  idle,
  loading,
  success,
  failure,
}

class OtpViewModel extends ChangeNotifier {
  final int maxMinutes = 1;
  final int totalSeconds = 1 * 60;
  int currentSeconds = 0;

  Timer? _timer;
  String? userId;
  String? code;

  int get minutes => currentSeconds ~/ 60;
  int get seconds => currentSeconds % 60;

  OtpStatus _status = OtpStatus.idle;
  String? _errorMessage;
  String _message = '';
  List<String> otpValues = List.generate(4, (_) => '');

  OtpStatus get status => _status;
  String? get errorMessage => _errorMessage;
  String get message => _message;
  bool get isLoading => _status == OtpStatus.loading;

  final OtpService _otpService = OtpService();
  OtpViewModel() {
    startTimer();
  }
  void setMessage(String msg) {
    _message = msg;
    notifyListeners();
  }
  Future<void> verifyOtp(BuildContext context) async {
    String otpCode = otpValues.join('');
    print("codeotp: $otpCode");

    if (otpCode.length != 4) {
      _setError("يرجى إدخال رمز التفعيل الكامل");
      return;
    }

    _setStatus(OtpStatus.loading);

    try {
      final response = await _otpService.verifyOtp(code: otpCode);

      if (response.success) {
        _message = "تم التحقق من رمز التفعيل بنجاح";

        final prefs = await SharedPreferences.getInstance();
        if (response.token != null) {
          await prefs.setString('token', response.token!);
        }

        final fcmToken = await FirebaseMessaging.instance.getToken();
        if (fcmToken != null) {
          final url = Uri.parse('https://backend.enjazkw.com/api/login/token');
          final fcmResponse = await http.post(
            url,
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer ${response.token}',
            },
            body: jsonEncode({"token": fcmToken}),
          );
          print("✅ FCM token sent after OTP: ${fcmResponse.statusCode} - ${fcmResponse.body}");
        }

        if (context.mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => HomePage()),
          );
        }

      } else {
        _setError(response.message.isNotEmpty
            ? response.message
            : "رمز التفعيل غير صحيح أو منتهي");
      }
    } catch (e) {
      _setError("حدث خطأ أثناء الاتصال بالسيرفر");
    }
  }

  void _setStatus(OtpStatus status) {
    _status = status;
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    _message = message;
    _setStatus(OtpStatus.failure);
    print("❌ Error: $message");
  }

  void startTimer() {
    currentSeconds = totalSeconds;
    _timer?.cancel();

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (currentSeconds == 0) {
        timer.cancel();
      } else {
        currentSeconds--;
        notifyListeners();
      }
    });
  }

  void resetTimer() {
    _timer?.cancel();
    currentSeconds = totalSeconds;
    _message = "تم إرسال رمز جديد إلى الإيميل";
    startTimer();
    notifyListeners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
