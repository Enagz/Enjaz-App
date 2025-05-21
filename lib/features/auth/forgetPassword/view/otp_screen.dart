import 'dart:convert';

import 'package:engaz_app/features/auth/forgetPassword/widgets/otp_field.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../localization/change_lang.dart';
import '../viewmodel/otp_viewmodel.dart';

class OtpScreen extends StatefulWidget {
  final String contactInfo;
  final String contactType;

  const OtpScreen({required this.contactInfo, required this.contactType});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final TextEditingController otp1 = TextEditingController();
  final TextEditingController otp2 = TextEditingController();
  final TextEditingController otp3 = TextEditingController();
  final TextEditingController otp4 = TextEditingController();

  void resendOtp() async {
    print("🔄 جاري تحميل userId من SharedPreferences...");
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');

    if (userId == null || userId.isEmpty) {
      print("❌ لم يتم العثور على userId");
      showError("حدث خطأ: معرف المستخدم غير موجود");
      return;
    }

    print("🔄 إعادة إرسال OTP إلى ${widget.contactInfo} باستخدام userId: $userId");

    final url = Uri.parse("https://backend.enjazkw.com/api/verify/resend/$userId");

    try {
      final response = await http.post(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print("✅ Success: ${data['message']}");
        context.read<OtpViewModel>().startTimer();
        setState(() {
          context.read<OtpViewModel>().setMessage("تم إرسال رمز جديد إلى الإيميل");
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
    final langCode = context.watch<LocalizationProvider>().locale.languageCode;

    return ChangeNotifierProvider<OtpViewModel>(
      create: (context) {
        final viewModel = OtpViewModel();
        viewModel.startTimer();
        return viewModel;
      },
      child: Consumer<OtpViewModel>(
        builder: (context, viewModel, child) {
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
                      keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: padding),
                        child: Column(
                          crossAxisAlignment: langCode == 'ar'
                              ? CrossAxisAlignment.end
                              : CrossAxisAlignment.start,
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
                            Center(
                              child: Text(
                                Translations.getText('ac', langCode),
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  fontFamily: 'IBM_Plex_Sans_Arabic',
                                ),
                              ),
                            ),
                            Center(
                              child: Text(
                                Translations.getText('pleasss', langCode),
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: Color(0xffB3B3B3),
                                  fontWeight: FontWeight.w500,
                                  fontFamily: 'IBM_Plex_Sans_Arabic',
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              widget.contactInfo,
                              textAlign: langCode == 'ar'
                                  ? TextAlign.right
                                  : TextAlign.left,
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
                            viewModel.isLoading
                                ? const Center(
                              child: CircularProgressIndicator(
                                color: Color.fromRGBO(64, 157, 220, 1),
                              ),
                            )
                                : SizedBox(
                              width: double.infinity,
                              height: buttonHeight,
                              child: ElevatedButton(
                                onPressed: () {
                                  viewModel.verifyOtp(context);
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color.fromRGBO(
                                      64, 157, 220, 1),
                                  shape: RoundedRectangleBorder(
                                    borderRadius:
                                    BorderRadius.circular(12),
                                  ),
                                ),
                                child: Text(
                                  Translations.getText('su', langCode),
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
                            if (viewModel.message.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  viewModel.message,
                                  textAlign: langCode == 'ar'
                                      ? TextAlign.right
                                      : TextAlign.left,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: viewModel.message.contains("نجاح")
                                        ? Colors.green
                                        : Colors.red,
                                    fontFamily: 'IBM_Plex_Sans_Arabic',
                                  ),
                                ),
                              ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              textDirection: langCode == 'ar'
                                  ? TextDirection.rtl
                                  : TextDirection.ltr,
                              children: [
                                Expanded(
                                  child: Directionality(
                                    textDirection: langCode == 'ar'
                                        ? TextDirection.rtl
                                        : TextDirection.ltr,
                                    child: Text.rich(
                                      TextSpan(
                                        children: [
                                          TextSpan(
                                            text: Translations.getText('didnt', langCode),
                                            style: const TextStyle(
                                              fontSize: 10,
                                              color: Color(0xff000000),
                                              fontWeight: FontWeight.w600,
                                              fontFamily: 'IBM_Plex_Sans_Arabic',
                                            ),
                                          ),
                                          TextSpan(
                                            text: Translations.getText('reee', langCode),
                                            style: TextStyle(
                                              color: viewModel.seconds == 0
                                                  ? const Color(0xff409EDC)
                                                  : Colors.grey,
                                              fontWeight: FontWeight.w600,
                                              fontSize: 10,
                                              fontFamily: 'IBM_Plex_Sans_Arabic',
                                              decoration: viewModel.seconds == 0
                                                  ? TextDecoration.underline
                                                  : TextDecoration.none,
                                            ),
                                            recognizer: TapGestureRecognizer()
                                              ..onTap = () {
                                                if (viewModel.seconds == 0) {
                                                  resendOtp();
                                                  otp1.clear();
                                                  otp2.clear();
                                                  otp3.clear();
                                                  otp4.clear();
                                                }
                                              },
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  '${viewModel.minutes.toString().padLeft(2, '0')}:${viewModel.seconds.toString().padLeft(2, '0')}',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xff409EDC),
                                    fontFamily: 'IBM_Plex_Sans_Arabic',
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
                            GestureDetector(
                              onTap: () {
                                final currentLang = context
                                    .read<LocalizationProvider>()
                                    .locale
                                    .languageCode;
                                final newLang =
                                currentLang == 'ar' ? 'en' : 'ar';
                                context
                                    .read<LocalizationProvider>()
                                    .setLocale(Locale(newLang));
                              },
                              child: Image.asset(
                                'assets/images/img2.png',
                                width: screenWidth > 600 ? 120 : 98,
                                height: screenWidth > 600 ? 40 : 33,
                              ),
                            ),
                            Row(
                              children: [
                                Text(
                                  Translations.getText('ac', langCode),
                                  style: const TextStyle(
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
        },
      ),
    );
  }
}