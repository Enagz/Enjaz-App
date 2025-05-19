import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../localization/change_lang.dart';

class LogOutModal extends StatelessWidget {
  const LogOutModal({super.key});

  Future<void> _logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    Navigator.of(context).pop();
    Navigator.of(context).pushReplacementNamed('/login');
  }

  @override
  Widget build(BuildContext context) {
    final langCode = Localizations.localeOf(context).languageCode;

    return Directionality(
      textDirection: langCode == 'ar' ? TextDirection.rtl : TextDirection.ltr,
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Align(
                alignment: langCode == 'ar' ? Alignment.topRight : Alignment.topLeft,
                child: Image.asset("assets/images/img23.png", width: 40),
              ),
              const SizedBox(height: 12),
              Image.asset("assets/images/img24.png"),
              const SizedBox(height: 12),
              Text(
                Translations.getText('logout_confirm', langCode),
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 150,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop(); // رجوع فقط
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xff409EDC),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        Translations.getText('cancel', langCode),
                        style: const TextStyle(fontSize: 16, color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  SizedBox(
                    width: 164,
                    height: 48,
                    child: OutlinedButton(
                      onPressed: () => _logout(context),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(
                            color: Color(0xFFE50930), width: 1),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        Translations.getText('logout', langCode),
                        style: const TextStyle(
                          color: Color(0xFFE50930),
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}