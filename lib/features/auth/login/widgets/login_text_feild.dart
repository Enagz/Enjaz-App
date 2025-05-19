import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../localization/change_lang.dart';
import '../viewmodel/login_viewmodel.dart';

class LoginTextField extends StatefulWidget {
  const LoginTextField({super.key});

  @override
  State<LoginTextField> createState() => _LoginTextFieldState();
}

class _LoginTextFieldState extends State<LoginTextField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    final viewModel = Provider.of<LoginViewModel>(context, listen: false);
    _controller = TextEditingController(text: viewModel.userInput);
    _controller.addListener(() {
      viewModel.setUserInput(_controller.text);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Consumer<LoginViewModel>(
        builder: (context, viewModel, _) {
          return Theme(
              data: Theme.of(context).copyWith(
                textSelectionTheme: const TextSelectionThemeData(
                  cursorColor: Color.fromRGBO(64, 157, 220, 1), // لون المؤشر
                  selectionColor:
                      Color.fromRGBO(64, 157, 220, 1), // لون التحديد
                  selectionHandleColor: Color.fromRGBO(
                      64, 157, 220, 1),
                ),
              ),
              child: TextFormField(
                key: ValueKey(viewModel.isPhoneSelected),
                textInputAction: TextInputAction.next,
                controller: _controller,
                cursorColor: Color.fromRGBO(64, 157, 220, 1),
                textAlign: context.read<LocalizationProvider>().locale.languageCode == 'ar'
                    ? TextAlign.right
                    : TextAlign.left,
                autofillHints: viewModel.isPhoneSelected
                    ? const [AutofillHints.telephoneNumber]
                    : const [AutofillHints.email],
                keyboardType: viewModel.isPhoneSelected
                    ? TextInputType.phone
                    : TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.trim().isEmpty){
                    return viewModel.isPhoneSelected
                        ? 'يرجى إدخال رقم الجوال'
                        : 'يرجى إدخال البريد الإلكتروني';
                  }
                  return null;
                },
                decoration: InputDecoration(
                  hintText: viewModel.isPhoneSelected
                      ? Translations.getText(
                    'enter2',
                    context.read<LocalizationProvider>().locale.languageCode,
                  )
                      : Translations.getText(
                    'enter3',
                    context.read<LocalizationProvider>().locale.languageCode,
                  ),
                  hintStyle: const TextStyle(
                    color: Color(0xffB3B3B3),
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                    fontFamily: 'IBM_Plex_Sans_Arabic',
                  ),
                  filled: true,
                  fillColor: const Color(0xffFAFAFA),
                  border: OutlineInputBorder(
                    borderSide: BorderSide.none,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  contentPadding:
                  const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                ),
              )
          );
        },
      ),
    );
  }
}
