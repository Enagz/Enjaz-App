/*import 'dart:async';
import 'dart:convert';
import 'package:engaz_app/features/auth/login/view/login_screen.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../widgets/otp_field.dart';

class OtpScreen2 extends StatefulWidget {
  final String contactInfo;
  final String userId;

  const OtpScreen2({required this.contactInfo, required this.userId});

  @override
  State<OtpScreen2> createState() => _OtpScreen2State();
}

class _OtpScreen2State extends State<OtpScreen2> {
  List<String> otpValues = List.filled(6, "");
  int seconds = 0;
  int minutes = 1;
  Timer? _timer;
  String message = "";
  bool isLoading = false;

  Future<void> verifyOtp() async {
    setState(() => isLoading = true);

    final otpCode = otpValues.join();
    final url = Uri.parse('https://backend.enjazkw.com/api/verify/${widget.userId}');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({"code": otpCode}),
      );

      final res = jsonDecode(response.body);

      if (response.statusCode == 200) {
        setState(() {
          message = res['message'] ?? "تم التحقق بنجاح";
        });

        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
      } else {
        setState(() {
          message = res['error'] ?? "رمز غير صحيح";
        });
      }
    } catch (e) {
      setState(() {
        message = "فشل الاتصال بالخادم";
      });
    } finally {
      setState(() => isLoading = false);
    }
  }


  @override
  void initState() {
    super.initState();
    startTimer();
  }

  void startTimer() {
    setState(() {
      minutes = 1;
      seconds = 0;
    });
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (minutes == 0 && seconds == 0) {
        timer.cancel();
      } else {
        setState(() {
          if (seconds == 0) {
            minutes--;
            seconds = 59;
          } else {
            seconds--;
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void resendOtp() async {
    final userId = widget.userId;
    print("🔄 إعادة إرسال OTP إلى ${widget.contactInfo}");
    final url = Uri.parse("https://backend.enjazkw.com/api/verify/resend/$userId");

    try {
      final response = await http.post(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print("✅ Success: ${data['message']}");
        startTimer();
        setState(() {
          message = "تم إرسال رمز جديد إلى الإيميل";
        });
      } else if (response.statusCode == 400) {
        final data = json.decode(response.body);
        print("⚠️ User already verified: ${data['error']}");
        showError("المستخدم مفعل بالفعل");
      } else if (response.statusCode == 404) {
        final data = json.decode(response.body);
        print("❌ User not found: ${data['error']}");
        showError("المستخدم غير موجود");
      } else {
        print("❗ Unexpected Error: ${response.body}");
        showError("حدث خطأ غير متوقع");
      }
    } catch (e) {
      print("❌ Exception: $e");
      showError("فشل الاتصال بالسيرفر");
    }
  }
  void showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.red),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: LayoutBuilder(
        builder: (context, constraints) {
          double screenWidth = constraints.maxWidth;
          double padding = screenWidth > 600 ? 48 : 24;
          double imageWidth = screenWidth > 600 ? 250 : 204;
          double buttonHeight = screenWidth > 600 ? 60 : 50;
          return Stack(
            children: [
              SingleChildScrollView(
                keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: padding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      SizedBox(height: screenWidth > 600 ? 150 : 130),
                      Center(
                        child: Image.asset(
                          'assets/images/img1.png',
                          width: imageWidth,
                          height: imageWidth * 0.37,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        "رمز التفعيل",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'IBM_Plex_Sans_Arabic',
                        ),
                      ),
                      const Text(
                        ": الرجاء ادخال رمز التفعيل المرسل",
                        style: TextStyle(
                          fontSize: 11,
                          color: Color(0xffB3B3B3),
                          fontWeight: FontWeight.w500,
                          fontFamily: 'IBM_Plex_Sans_Arabic',
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        widget.contactInfo,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xff409EDC),
                          fontWeight: FontWeight.w500,
                          fontFamily: 'IBM_Plex_Sans_Arabic',
                        ),
                      ),
                      const SizedBox(height: 16),
                      OtpFields(),
                      const SizedBox(height: 16),
                      isLoading
                          ? const Center(
                        child: CircularProgressIndicator(
                          color: Color(0xff409EDC),
                        ),
                      )
                          : SizedBox(
                        width: double.infinity,
                        height: buttonHeight,
                        child: ElevatedButton(
                          onPressed: () {
                            print("OTP Submitted: $otpValues");
                            verifyOtp();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xff409EDC),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            "تأكيد",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'IBM_Plex_Sans_Arabic',
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      if (message.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            message,
                            style: TextStyle(
                              fontSize: 14,
                              color: message.contains("تم") ? Colors.green : Colors.red,
                            ),
                          ),
                        ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        textDirection: TextDirection.rtl,
                        children: [
                          Directionality(
                            textDirection: TextDirection.rtl,
                            child: Text.rich(
                              TextSpan(
                                children: [
                                  const TextSpan(
                                    text: "لم يصلك رمز التفعيل؟ ",
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Color(0xff000000),
                                      fontWeight: FontWeight.w600,
                                      fontFamily: 'IBM_Plex_Sans_Arabic',
                                    ),
                                  ),
                                  TextSpan(
                                    text: "أعد الإرسال",
                                    style: const TextStyle(
                                      color: Color(0xff409EDC),
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                      fontFamily: 'IBM_Plex_Sans_Arabic',
                                    ),
                                    recognizer: TapGestureRecognizer()
                                      ..onTap = () {
                                        resendOtp();
                                      },
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Color(0xff409EDC),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                top: 60,
                left: padding,
                child: SizedBox(
                  width: screenWidth * .9,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Image.asset(
                        'assets/images/img2.png',
                        width: screenWidth > 600 ? 120 : 98,
                        height: screenWidth > 600 ? 40 : 33,
                      ),
                      Row(
                        children: [
                          const Text(
                            "رمز التفعيل ",
                            style: TextStyle(
                              color: Color(0xff1D1D1D),
                              fontWeight: FontWeight.w600,
                              fontSize: 18,
                              fontFamily: 'IBM_Plex_Sans_Arabic',
                            ),
                          ),
                          InkWell(
                            onTap: () {
                              Navigator.pop(context);
                            },
                            child: const Icon(Icons.arrow_forward_ios),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
 */
import 'dart:async';
import 'dart:convert';
import 'package:engaz_app/features/auth/login/view/login_screen.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../../localization/change_lang.dart';
import '../widgets/otp_field.dart';

class OtpScreen2 extends StatefulWidget {
  final String contactInfo;
  final String userId;

  const OtpScreen2({required this.contactInfo, required this.userId});

  @override
  State<OtpScreen2> createState() => _OtpScreen2State();
}

class _OtpScreen2State extends State<OtpScreen2> {
  List<String> otpValues = List.filled(6, "");
  int seconds = 0;
  int minutes = 1;
  Timer? _timer;
  String message = "";
  bool isLoading = false;
  final TextEditingController otp1 = TextEditingController();
  final TextEditingController otp2 = TextEditingController();
  final TextEditingController otp3 = TextEditingController();
  final TextEditingController otp4 = TextEditingController();


  Future<void> verifyOtp() async {
    setState(() => isLoading = true);

    final otpCode = otpValues.join();
    final url = Uri.parse('https://backend.enjazkw.com/api/verify/${widget.userId}');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({"code": otpCode}),
      );

      final res = jsonDecode(response.body);

      if (response.statusCode == 200) {
        setState(() {
          message = res['message'] ?? "تم التحقق بنجاح";
        });

        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
      } else {
        setState(() {
          message = res['error'] ?? "رمز غير صحيح";
        });
      }
    } catch (e) {
      setState(() {
        message = "فشل الاتصال بالخادم";
      });
    } finally {
      setState(() => isLoading = false);
    }
  }

  void startTimer() {
    setState(() {
      minutes = 1;
      seconds = 0;
    });
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (minutes == 0 && seconds == 0) {
        timer.cancel();
      } else {
        setState(() {
          if (seconds == 0) {
            minutes--;
            seconds = 59;
          } else {
            seconds--;
          }
        });
      }
    });
  }

  void resendOtp() async {
    final userId = widget.userId;
    final url = Uri.parse("https://backend.enjazkw.com/api/verify/resend/$userId");

    try {
      final response = await http.post(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        startTimer();
        setState(() {
          message = Translations.getText('otp_sent_success', Localizations.localeOf(context).languageCode);
        });
      } else if (response.statusCode == 400) {
        final data = json.decode(response.body);
        showError('user_already_verified');
      } else if (response.statusCode == 404) {
        final data = json.decode(response.body);
        showError('user_not_found');
      } else {
        showError('unexpected_error');
      }
    } catch (e) {
      showError('server_error');
    }
  }

  void showError(String msgKey) {
    final langCode = Localizations.localeOf(context).languageCode;
    final message = Translations.getText(msgKey, langCode);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  void initState() {
    super.initState();
    startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final langCode = Localizations.localeOf(context).languageCode;
    final isArabic = langCode == 'ar';
    final textDir = isArabic ? TextDirection.rtl : TextDirection.ltr;
    final textAlign = isArabic ? TextAlign.right : TextAlign.left;

    return Scaffold(
      backgroundColor: Colors.white,
      body: LayoutBuilder(
        builder: (context, constraints) {
          double screenWidth = constraints.maxWidth;
          double padding = screenWidth > 600 ? 48 : 24;
          double imageWidth = screenWidth > 600 ? 250 : 204;
          double buttonHeight = screenWidth > 600 ? 60 : 50;
          return Stack(
            children: [
              SingleChildScrollView(
                keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: padding),
                  child: Column(
                    crossAxisAlignment:
                    isArabic ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: screenWidth > 600 ? 150 : 130),
                      Center(
                        child: Image.asset(
                          'assets/images/img1.png',
                          width: imageWidth,
                          height: imageWidth * 0.37,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        Translations.getText('activation_title', langCode),
                        textAlign: textAlign,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'IBM_Plex_Sans_Arabic',
                        ),
                      ),
                      Text(
                        Translations.getText('enter_code_prompt', langCode),
                        textAlign: textAlign,
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xffB3B3B3),
                          fontWeight: FontWeight.w500,
                          fontFamily: 'IBM_Plex_Sans_Arabic',
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        widget.contactInfo,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xff409EDC),
                          fontWeight: FontWeight.w500,
                          fontFamily: 'IBM_Plex_Sans_Arabic',
                        ),
                      ),
                      const SizedBox(height: 16),
                      OtpFields(),
                      const SizedBox(height: 16),
                      isLoading
                          ? const Center(
                        child: CircularProgressIndicator(color: Color(0xff409EDC)),
                      )
                          : SizedBox(
                        width: double.infinity,
                        height: buttonHeight,
                        child: ElevatedButton(
                          onPressed: verifyOtp,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xff409EDC),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            Translations.getText('confirm', langCode),
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'IBM_Plex_Sans_Arabic',
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      if (message.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            message,
                            textAlign: textAlign,
                            style: TextStyle(
                              fontSize: 14,
                              color: message.contains("تم") ? Colors.green : Colors.red,
                            ),
                          ),
                        ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        textDirection: textDir,
                        children: [
                          Expanded(
                            child: Text.rich(
                              TextSpan(
                                children: [
                                  TextSpan(
                                    text: Translations.getText('didnt', langCode),
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: Color(0xff000000),
                                      fontWeight: FontWeight.w600,
                                      fontFamily: 'IBM_Plex_Sans_Arabic',
                                    ),
                                  ),
                                  TextSpan(
                                    text: Translations.getText('resend', langCode),
                                    style: TextStyle(
                                      color: seconds == 0 ? const Color(0xff409EDC) : Colors.grey,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                      fontFamily: 'IBM_Plex_Sans_Arabic',
                                      decoration: seconds == 0 ? TextDecoration.underline : null,
                                    ),
                                    recognizer: TapGestureRecognizer()
                                      ..onTap = () {
                                        if (seconds == 0) resendOtp();
                                        otp1.clear();
                                        otp2.clear();
                                        otp3.clear();
                                        otp4.clear();
                                      },
                                  ),
                                ],
                              ),
                              textDirection: textDir,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Color(0xff409EDC),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
