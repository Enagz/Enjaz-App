import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../auth/login/view/login_screen.dart';
import '../../localization/change_lang.dart';

class LoginRequiredDialog extends StatelessWidget {
  const LoginRequiredDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final lang = context.read<LocalizationProvider>().locale.languageCode;

    return AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            Translations.getText('oops', lang),
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'IBMPlexSansArabic',
              fontWeight: FontWeight.w600,
              fontSize: 25,
              height: 1.0,
              letterSpacing: 0.0,
            ),
          ),
          const Icon(Icons.warning_amber_rounded, size: 70, color: Colors.red),
          const SizedBox(height: 10),
          Text(
            Translations.getText('please_login_msg', lang),
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'IBMPlexSansArabic',
              fontWeight: FontWeight.w600,
              fontSize: 16,
              height: 1.0,
              letterSpacing: 0.0,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    Translations.getText('cancel', lang),
                    style: const TextStyle(
                      fontFamily: 'IBMPlexSansArabic',
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                      height: 1.0,
                      letterSpacing: 0.0,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const LoginScreen()),
                    );
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                  child: Text(
                    Translations.getText('login', lang),
                    style: const TextStyle(
                      fontFamily: 'IBMPlexSansArabic',
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                      height: 1.0,
                      letterSpacing: 0.0,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}