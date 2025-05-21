import 'package:engaz_app/features/auth/login/viewmodel/login_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl_phone_field/intl_phone_field.dart';

import '../../../localization/change_lang.dart';

class CustomTextField extends StatefulWidget {
  final String hintKey;
  final Function(String)? onChanged;
  final bool isPhoneField;
  final Function(String)? onCountryCodeChanged;

  const CustomTextField({
    Key? key,
    required this.hintKey,
    this.onChanged,
    this.isPhoneField = false,
    this.onCountryCodeChanged,
  }) : super(key: key);

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  late TextEditingController _controller;
  String? countryCode;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final langCode = Localizations.localeOf(context).languageCode;
    late final String translatedHint;
    switch (widget.hintKey) {
      case 'Enter phone number':
        translatedHint = Translations.getText('enter_phone_register', langCode);
        break;
      case 'Enter email':
        translatedHint = Translations.getText('enter_email_register', langCode);
        break;
      default:
        translatedHint = Translations.getText(widget.hintKey, langCode);
    }
    return Directionality(
      textDirection: langCode == 'ar' ? TextDirection.rtl : TextDirection.ltr,
      child: Theme(
        data: Theme.of(context).copyWith(
          textSelectionTheme: const TextSelectionThemeData(
            cursorColor: Color.fromRGBO(64, 157, 220, 1),
            selectionColor: Color.fromRGBO(64, 157, 220, 1),
            selectionHandleColor: Color.fromRGBO(64, 157, 220, 1),
          ),
        ),
        child: widget.isPhoneField
            ? IntlPhoneField(
          controller: _controller,
          initialCountryCode: 'EG',
          decoration: InputDecoration(
            hintText: translatedHint,
            hintStyle: const TextStyle(
              color: Color(0xffB3B3B3),
              fontWeight: FontWeight.w500,
              fontFamily: 'IBM_Plex_Sans_Arabic',
              fontSize: 13,
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
          onChanged: (phone) {
            if (widget.onChanged != null) widget.onChanged!(phone.number);
          },
          onCountryChanged: (country) {
            countryCode = country.dialCode;
            if (widget.onCountryCodeChanged != null) {
              widget.onCountryCodeChanged!(countryCode!);
            }
          },
        )
            : TextFormField(
          controller: _controller,
          cursorColor: const Color.fromRGBO(64, 157, 220, 1),
          textInputAction: TextInputAction.next,
          textAlign:
          langCode == 'ar' ? TextAlign.right : TextAlign.left,
          textDirection:
          langCode == 'ar' ? TextDirection.rtl : TextDirection.ltr,
          onChanged: (value) {
            if (widget.onChanged != null) {
              widget.onChanged!(value);
            }
          },
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              if (widget.hintKey == 'first_name') {
                return Translations.getText('enter_first_name', langCode);
              } else if (widget.hintKey == 'last_name') {
                return Translations.getText('enter_last_name', langCode);
              } else if (widget.hintKey.contains('phone')) {
                return Translations.getText('enter_phone', langCode);
              } else if (widget.hintKey.contains('email')) {
                return Translations.getText('enter_email', langCode);
              }
              return Translations.getText('required_field', langCode);
            }
            return null;
          },
          decoration: InputDecoration(
            hintText: translatedHint,
            hintStyle: const TextStyle(
              color: Color(0xffB3B3B3),
              fontWeight: FontWeight.w500,
              fontFamily: 'IBM_Plex_Sans_Arabic',
              fontSize: 13,
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
        ),
      ),
    );
  }
}