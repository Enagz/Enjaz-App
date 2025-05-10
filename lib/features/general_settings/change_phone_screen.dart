import 'dart:convert';
import 'package:engaz_app/features/auth/login/widgets/login_text_feild.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../auth/forgetPassword/view/otp_screen.dart';
import '../auth/login/viewmodel/login_viewmodel.dart';
import '../localization/change_lang.dart';

class ChangePhoneScreen extends StatelessWidget {
  const ChangePhoneScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<LocalizationProvider>(
        builder: (context, localizationProvider, child) {
      final locale = localizationProvider.locale.languageCode;
      final textDirection =
          locale == 'ar' ? TextDirection.rtl : TextDirection.ltr;

      return Directionality(
          textDirection: textDirection,
          child: ChangeNotifierProvider(
            create: (context) => LoginViewModel(),
            child: Scaffold(
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
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: padding),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              SizedBox(height: screenWidth > 600 ? 70 : 50),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Text(
                                    Translations.getText(
                                      'change',
                                      context
                                          .read<LocalizationProvider>()
                                          .locale
                                          .languageCode,
                                    ),
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
                              SizedBox(height: screenWidth > 600 ? 50 : 30),
                              Image.asset('assets/images/img1.png',
                                  width: imageWidth, height: imageWidth * 0.37),
                              const SizedBox(height: 16),
                              Text(
                                Translations.getText(
                                  'new_phone',
                                  context
                                      .read<LocalizationProvider>()
                                      .locale
                                      .languageCode,
                                ),
                                style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    fontFamily: 'IBM_Plex_Sans_Arabic'),
                              ),
                              Text(
                                Translations.getText(
                                  'pls',
                                  context
                                      .read<LocalizationProvider>()
                                      .locale
                                      .languageCode,
                                ),
                                style: TextStyle(
                                    fontSize: 12,
                                    color: Color(0xffB3B3B3),
                                    fontWeight: FontWeight.w500,
                                    fontFamily: 'IBM_Plex_Sans_Arabic'),
                              ),
                              const SizedBox(height: 16),
                              const LoginTextField(),
                              const SizedBox(height: 16),
                              SizedBox(
                                width: double.infinity,
                                height: buttonHeight,
                                child: ElevatedButton(
                                  onPressed: () async {
                                    final viewModel =
                                        Provider.of<LoginViewModel>(context,
                                            listen: false);
                                    final phone = viewModel.userInput;

                                    if (phone.isEmpty) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            "يرجى إدخال البيانات المطلوبة",
                                            style: TextStyle(
                                                fontFamily:
                                                    'IBM_Plex_Sans_Arabic'),
                                          ),
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                      return;
                                    }

                                    try {
                                      final prefs =
                                          await SharedPreferences.getInstance();
                                       final token = prefs.getString('token') ?? '';
                                      // final userId = JwtDecoder.decode(token)['id'];
                                      // final token =
                                      //     'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOiI2YWJkMWIzNi0xZGQxLTQ2MDktYTE2NC1kZTg5YmM1YWYwMWQiLCJ1c2VybmFtZSI6IkJhc3NlbCBTYWxsYW0iLCJlbWFpbCI6ImJhc3NlbGEuc2FsYW1AZ21haWwuY29tIiwidmVyZmllZCI6dHJ1ZSwiaWF0IjoxNzQyNzY2OTkzfQ.-LuSsU2AombLwf1YUm91fNe_VmXtfIDEn9Z8h3N1PAc';
                                      // final userId =
                                      //     '6abd1b36-1dd1-4609-a164-de89bc5af01d';

                                      final response = await http.put(
                                        Uri.parse(
                                            "https://wckb4f4m-3000.euw.devtunnels.ms/api/user/changephone"),
                                        headers: {
                                          "Content-Type": "application/json",
                                          "Authorization": "Bearer $token"
                                        },
                                        body: jsonEncode({
                                          "phone": phone,
                                          "countrycode": "+20",
                                          // ثابت مؤقتًا، تقدر تخليه قابل للتعديل لو حبيت
                                        }),
                                      );

                                      final data = jsonDecode(response.body);

                                      if (response.statusCode == 200) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              "Phone number updated successfully",
                                              style: const TextStyle(
                                                  fontFamily:
                                                  'IBM_Plex_Sans_Arabic'),
                                            ),
                                            backgroundColor: Colors.green,
                                          ),
                                        );
                                      } else {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              data['message'] ??
                                                  'حدث خطأ غير متوقع',
                                              style: const TextStyle(
                                                  fontFamily:
                                                      'IBM_Plex_Sans_Arabic'),
                                            ),
                                            backgroundColor: Colors.red,
                                          ),
                                        );
                                      }
                                    } catch (e) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            "فشل الاتصال بالخادم: $e",
                                            style: const TextStyle(
                                                fontFamily:
                                                    'IBM_Plex_Sans_Arabic'),
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
                                    Translations.getText(
                                      'sure',
                                      context
                                          .read<LocalizationProvider>()
                                          .locale
                                          .languageCode,
                                    ),
                                    style: TextStyle(
                                      fontSize: 15,
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
                    ],
                  );
                },
              ),
            ),
          ));
    });
  }
}
