import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../auth/login/viewmodel/login_viewmodel.dart';
import '../localization/change_lang.dart';

class OtpScreenChangeEmailScreen extends StatefulWidget {
  final String phone;
  final String email;

  const OtpScreenChangeEmailScreen({required this.phone, required this.email});

  @override
  State<OtpScreenChangeEmailScreen> createState() => _OtpScreenChangeEmailScreenState();
}

class _OtpScreenChangeEmailScreenState extends State<OtpScreenChangeEmailScreen> {
  int? selectedImageIndex;
  final TextEditingController codeController = TextEditingController();

  Future<void> verifyCode(String code) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';
      final userId = JwtDecoder.decode(token)['user_id'];

      final url = Uri.parse('https://backend.enjazkw.com/api/login-account/$userId/code');

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'code': code}),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['message'] ?? Translations.getText('activation_success', langCode))),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['error'] ?? Translations.getText('invalid_code', langCode))),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("${Translations.getText('server_error', langCode)}: $e")),
      );
    }
  }

  String get langCode => Localizations.localeOf(context).languageCode;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => LoginViewModel(),
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
                    keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: padding),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          SizedBox(height: screenWidth > 600 ? 150 : 130),
                          Center(
                            child: Image.asset('assets/images/img1.png',
                                width: imageWidth, height: imageWidth * 0.37),
                          ),
                          const SizedBox(height: 16),
                          Center(
                            child: Text(
                              Translations.getText('activation_title', langCode),
                              textDirection: context.read<LocalizationProvider>().locale.languageCode == 'ar'
                                  ? TextDirection.rtl
                                  : TextDirection.ltr,
                              style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  fontFamily: 'IBM_Plex_Sans_Arabic'),
                            ),
                          ),
                          Text(
                            Translations.getText('choose_activation_method', langCode),
                            style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xffB3B3B3),
                                fontWeight: FontWeight.w500,
                                fontFamily: 'IBM_Plex_Sans_Arabic'),
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            controller: codeController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              hintText: Translations.getText('enter_code', langCode),
                              filled: true,
                              fillColor: const Color(0xffFAFAFA),
                              border: OutlineInputBorder(
                                borderSide: BorderSide.none,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                            ),
                          ),
                          const SizedBox(height: 20),
                          SizedBox(
                            width: double.infinity,
                            height: buttonHeight,
                            child: ElevatedButton(
                              onPressed: () {
                                verifyCode(codeController.text);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xff409EDC),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Text(
                                Translations.getText('confirm', langCode),
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  fontFamily: 'IBM_Plex_Sans_Arabic',
                                  color: Colors.white,
                                ),
                              ),
                            ),
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
                              Text(
                                Translations.getText('activation_title', langCode),
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
        ),
      ),
    );
  }

  /*List<Widget> _buildOptions(double imageWidth) {
    return [
      GestureDetector(
        onTap: () => setState(() => selectedImageIndex = 1),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 60),
          decoration: BoxDecoration(
            border: selectedImageIndex == 1
                ? Border.all(color: const Color(0xff409EDC), width: 1)
                : null,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Image.asset('assets/images/img3.png', width: imageWidth),
        ),
      ),
      const SizedBox(height: 12),
      GestureDetector(
        onTap: () => setState(() => selectedImageIndex = 2),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 60),
          decoration: BoxDecoration(
            border: selectedImageIndex == 2
                ? Border.all(color: const Color(0xff409EDC), width: 1)
                : null,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Image.asset('assets/images/img4.png', width: imageWidth),
        ),
      ),
    ];
  }
   */
}