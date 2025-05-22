import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../auth/forgetPassword/view/otp_screen.dart';
import '../auth/login/viewmodel/login_viewmodel.dart';
import '../localization/change_lang.dart';

class ChangeEmailScreen extends StatelessWidget {
  const ChangeEmailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final langCode = context.watch<LocalizationProvider>().locale.languageCode;
    final isArabic = langCode == 'ar';
    final textDirection = isArabic ? TextDirection.rtl : TextDirection.ltr;

    return Directionality(
      textDirection: textDirection,
      child: ChangeNotifierProvider(
        create: (context) => LoginViewModel(),
        child: Scaffold(
          backgroundColor: Colors.white,
          body: SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                double screenWidth = constraints.maxWidth;
                double padding = screenWidth > 600 ? 48 : 24;
                double imageWidth = screenWidth > 600 ? 250 : 204;
                double buttonHeight = screenWidth > 600 ? 60 : 50;
            
                return Stack(
                  children: [
                    SingleChildScrollView(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: padding),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: screenWidth > 600 ? 70 : 50),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  Translations.getText('change2', langCode),
                                  textDirection: context.read<LocalizationProvider>().locale.languageCode == 'ar'
                                      ? TextDirection.rtl
                                      : TextDirection.ltr,
                                  style: const TextStyle(
                                    color: Color(0xff1D1D1D),
                                    fontWeight: FontWeight.w600,
                                    fontSize: 18,
                                    fontFamily: 'IBM_Plex_Sans_Arabic',
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 30),
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
                                Translations.getText('new_email', langCode),
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  fontFamily: 'IBM_Plex_Sans_Arabic',
                                ),
                              ),
                            ),
                            Center(
                              child: Text(
                                Translations.getText('pls2', langCode),
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Color(0xffB3B3B3),
                                  fontWeight: FontWeight.w500,
                                  fontFamily: 'IBM_Plex_Sans_Arabic',
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            CustomTextFeild2(langCode: langCode),
                            const SizedBox(height: 16),
                            Consumer<LoginViewModel>(
                              builder: (context, viewModel, _) {
                                return SizedBox(
                                  width: double.infinity,
                                  height: buttonHeight,
                                  child: ElevatedButton(
                                    onPressed: () async {
                                      final email = viewModel.userInput;
            
                                      if (email.isEmpty) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              Translations.getText('enter_email', langCode),
                                              style: const TextStyle(
                                                  fontFamily: 'IBM_Plex_Sans_Arabic'),
                                            ),
                                            backgroundColor: Colors.red,
                                          ),
                                        );
                                        return;
                                      }
            
                                      try {
                                        final prefs = await SharedPreferences.getInstance();
                                        final token = prefs.getString('token');
            
                                        final response = await http.post(
                                          Uri.parse('https://backend.enjazkw.com/api/user/chgnageemail'),
                                          headers: {
                                            'Content-Type': 'application/json',
                                            'Authorization': 'Bearer $token',
                                          },
                                          body: jsonEncode({"email": email}),
                                        );
            
                                        final data = jsonDecode(response.body);
            
                                        if (response.statusCode == 200) {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => OtpScreen(
                                                contactInfo: email,
                                                contactType: 'email',
                                              ),
                                            ),
                                          );
                                        } else {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                data['message'] ?? Translations.getText('unexpected_error', langCode),
                                                style: const TextStyle(fontFamily: 'IBM_Plex_Sans_Arabic'),
                                              ),
                                              backgroundColor: Colors.red,
                                            ),
                                          );
                                        }
                                      } catch (e) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              '${Translations.getText('server_error', langCode)}: $e',
                                              style: const TextStyle(fontFamily: 'IBM_Plex_Sans_Arabic'),
                                            ),
                                            backgroundColor: Colors.red,
                                          ),
                                        );
                                      }
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.blue,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    child: Text(
                                      Translations.getText('sure', langCode),
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                        fontFamily: 'IBM_Plex_Sans_Arabic',
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class CustomTextFeild2 extends StatelessWidget {
  final String langCode;
  const CustomTextFeild2({super.key, required this.langCode});

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<LoginViewModel>(context, listen: false);
    final controller = TextEditingController();
    controller.addListener(() => viewModel.setUserInput(controller.text));

    return TextField(
      controller: controller,
      keyboardType: TextInputType.emailAddress,
      textAlign: langCode == 'ar' ? TextAlign.right : TextAlign.left,
      decoration: InputDecoration(
        hintText: Translations.getText('enter_email', langCode),
        hintStyle: const TextStyle(
          color: Color(0xffB3B3B3),
          fontWeight: FontWeight.w500,
          fontSize: 13,
          fontFamily: 'IBM_Plex_Sans_Arabic',
        ),
        filled: true,
        fillColor: const Color(0xffFAFAFA),
        border: OutlineInputBorder(
          borderSide: BorderSide.none,
          borderRadius: BorderRadius.circular(16),
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      ),
    );
  }
}