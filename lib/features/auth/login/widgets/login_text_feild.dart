import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
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
    final localeCode = context.read<LocalizationProvider>().locale.languageCode;
    final viewModel = context.watch<LoginViewModel>();

    return Directionality(
      textDirection: localeCode == 'ar' ? TextDirection.rtl : TextDirection.ltr,
      child: Theme(
        data: Theme.of(context).copyWith(
          textSelectionTheme: const TextSelectionThemeData(
            cursorColor: Color.fromRGBO(64, 157, 220, 1),
            selectionColor: Color.fromRGBO(64, 157, 220, 1),
            selectionHandleColor: Color.fromRGBO(64, 157, 220, 1),
          ),
        ),
        child: viewModel.isPhoneSelected
            ? IntlPhoneField(
          controller: _controller,
          decoration: InputDecoration(
            hintText: Translations.getText('enter2', localeCode),
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
          ),
          initialCountryCode: 'EG',
          onChanged: (phone) {
            viewModel.setUserInput(phone.completeNumber);
          },
          dropdownIcon: const Icon(Icons.arrow_drop_down, color: Color(0xff409EDC)),
          style: const TextStyle(color: Colors.black),
          cursorColor: const Color(0xff409EDC),
        )
            : TextFormField(
          key: ValueKey(viewModel.isPhoneSelected),
          textInputAction: TextInputAction.next,
          controller: _controller,
          cursorColor: const Color(0xff409EDC),
          textAlign: localeCode == 'ar' ? TextAlign.right : TextAlign.left,
          autofillHints: const [AutofillHints.email],
          keyboardType: TextInputType.emailAddress,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return Translations.getText('enter_email', localeCode);
            }
            return null;
          },
          decoration: InputDecoration(
            hintText: Translations.getText('enter3', localeCode),
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
            contentPadding: const EdgeInsets.symmetric(
                vertical: 12, horizontal: 16),
          ),
        ),
      ),
    );
  }
}