import 'package:engaz_app/features/auth/forgetPassword/widgets/otp_field.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
  late OtpViewModel otpProvider;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
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
                                Translations.getText('ac', langCode),
                                style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    fontFamily: 'IBM_Plex_Sans_Arabic'),
                              ),
                            ),
                            Center(
                              child: Text(
                                Translations.getText('pleasss', langCode),
                                style: TextStyle(
                                    fontSize: 11,
                                    color: Color(0xffB3B3B3),
                                    fontWeight: FontWeight.w500,
                                    fontFamily: 'IBM_Plex_Sans_Arabic'),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              widget.contactInfo,
                              style: const TextStyle(
                                  fontSize: 12,
                                  color: Color(0xff409EDC),
                                  fontWeight: FontWeight.w500,
                                  fontFamily: 'IBM_Plex_Sans_Arabic'),
                            ),
                            const SizedBox(height: 16),
                            OtpFields(otpValues: viewModel.otpValues),
                            const SizedBox(height: 16),
                            viewModel.isLoading
                                ? const Center(
                                    child: CircularProgressIndicator(
                                    color: Color.fromRGBO(64, 157, 220, 1),
                                  ))
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
                            if (viewModel.message.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  viewModel.message,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: viewModel.message.contains("نجاح")
                                        ? Colors.green
                                        : Colors.red,
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
                                        TextSpan(
                                          text: Translations.getText(
                                              'didnt', langCode),
                                          style: TextStyle(
                                            fontSize: 10,
                                            color: Color(0xff000000),
                                            fontWeight: FontWeight.w600,
                                            fontFamily: 'IBM_Plex_Sans_Arabic',
                                          ),
                                        ),
                                        TextSpan(
                                          text: Translations.getText(
                                              'reee', langCode),
                                          style: const TextStyle(
                                            color: Color(0xff409EDC),
                                            fontWeight: FontWeight.w600,
                                            fontSize: 10,
                                            fontFamily: 'IBM_Plex_Sans_Arabic',
                                          ),
                                          recognizer: TapGestureRecognizer()
                                            ..onTap = () {
                                              viewModel.resetTimer();
                                            },
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  '${viewModel.minutes.toString().padLeft(2, '0')}:${viewModel.seconds.toString().padLeft(2, '0')}',
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
                              child: Image.asset('assets/images/img2.png',
                                  width: screenWidth > 600 ? 120 : 98,
                                  height: screenWidth > 600 ? 40 : 33),
                            ),
                            Row(
                              children: [
                                Text(
                                  Translations.getText('ac', langCode),
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
        },
      ),
    );
  }
}
