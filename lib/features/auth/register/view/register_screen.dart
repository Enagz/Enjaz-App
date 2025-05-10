import 'package:engaz_app/features/auth/register/widgets/custom_text_feild.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../localization/change_lang.dart';
import '../../forgetPassword/view/otp_screen2.dart';
import '../viewmodel/register_viewmodel.dart';
import '../../login/view/login_screen.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();
    final langCode = context.watch<LocalizationProvider>().locale.languageCode;

    return ChangeNotifierProvider<RegisterViewModel>(
      create: (_) => RegisterViewModel(),
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
                  keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: padding),
                    child: Form(
                      key: formKey,
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
                              Translations.getText('create_account', langCode),
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
                              Translations.getText('fill_details', langCode),
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xffB3B3B3),
                                fontWeight: FontWeight.w500,
                                fontFamily: 'IBM_Plex_Sans_Arabic',
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // First Name
                          _buildLabel(Translations.getText('first_name', langCode), langCode),
                          CustomTextField(
                            hintText: Translations.getText('enter_first_name', langCode),
                            onChanged: (value) => context.read<RegisterViewModel>().setFirstName(value),
                          ),
                          const SizedBox(height: 8),

                          // Last Name
                          _buildLabel(Translations.getText('last_name', langCode), langCode),
                          CustomTextField(
                            hintText: Translations.getText('enter_last_name', langCode),
                            onChanged: (value) => context.read<RegisterViewModel>().setLastName(value),
                          ),
                          const SizedBox(height: 8),
                          _buildLabel(Translations.getText('phone_number', langCode), langCode),
                          CustomTextField(
                            hintText: Translations.getText('enter_phone', langCode),
                            onChanged: (value) => context.read<RegisterViewModel>().setPhone(value),
                          ),
                          const SizedBox(height: 8),

                          // Email
                          _buildLabel(Translations.getText('email', langCode), langCode),
                          CustomTextField(
                            hintText: Translations.getText('enter_email', langCode),
                            onChanged: (value) => context.read<RegisterViewModel>().setEmail(value),
                          ),
                          const SizedBox(height: 16),

                          Consumer<RegisterViewModel>(
                            builder: (context, viewModel, _) {
                              return SizedBox(
                                width: double.infinity,
                                height: buttonHeight,
                                child: ElevatedButton(
                                  onPressed: viewModel.registerState == RegisterState.loading
                                      ? null
                                      : () async {
                                    if (!formKey.currentState!.validate()) return;

                                    if (viewModel.email.isEmpty || viewModel.phone.isEmpty) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text("يرجى إدخال كافة البيانات بشكل صحيح"),
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                      return;
                                    }

                                    final result = await viewModel.registerUser(context);
                                    if (result['success']) {
                                      final userId = result['user'];
                                      print(userId);
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => OtpScreen2(
                                            contactInfo: viewModel.email,
                                            userId: result['user'],
                                          ),
                                        ),
                                      );
                                    } else {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text(result['message']),
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color.fromRGBO(64, 157, 220, 1),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: viewModel.registerState == RegisterState.loading
                                      ? const CircularProgressIndicator(color: Colors.white)
                                      : Text(
                                    Translations.getText('signup', langCode),
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
                          const SizedBox(height: 12),
                          _buildLoginLink(context, langCode),
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 60,
                  left: 24,
                  child: GestureDetector(
                    onTap: () {
                      final currentLang = context.read<LocalizationProvider>().locale.languageCode;
                      final newLang = currentLang == 'ar' ? 'en' : 'ar';
                      context.read<LocalizationProvider>().setLocale(Locale(newLang));
                    },
                    child: Image.asset(
                      'assets/images/img2.png',
                      width: screenWidth > 600 ? 120 : 98,
                      height: screenWidth > 600 ? 40 : 33,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildLabel(String text, String langCode) {
    return Align(
      alignment: langCode == 'ar' ? Alignment.centerRight : Alignment.centerLeft,
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          fontFamily: 'IBM_Plex_Sans_Arabic',
        ),
      ),
    );
  }

  Widget _buildLoginLink(BuildContext context, String langCode) {
    return Align(
      alignment: langCode == 'ar' ? Alignment.centerRight : Alignment.centerLeft,
      child: Text.rich(
        TextSpan(
          text: Translations.getText('have_account', langCode) + " ",
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            fontFamily: 'IBM_Plex_Sans_Arabic',
          ),
          children: [
            TextSpan(
              text: Translations.getText('login', langCode),
              style: const TextStyle(
                color: Color(0xff409EDC),
                fontWeight: FontWeight.w600,
                fontFamily: 'IBM_Plex_Sans_Arabic',
              ),
              recognizer: TapGestureRecognizer()
                ..onTap = () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginScreen()),
                  );
                },
            ),
          ],
        ),
        textAlign: langCode == 'ar' ? TextAlign.right : TextAlign.left,
      ),
    );
  }
}