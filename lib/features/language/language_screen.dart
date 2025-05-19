import 'package:engaz_app/features/settings/settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../localization/change_lang.dart';

class LanguageScreen extends StatefulWidget {
  const LanguageScreen({super.key});

  @override
  State<LanguageScreen> createState() => _LanguageScreenState();
}

class _LanguageScreenState extends State<LanguageScreen> {
  String selectedLang = 'ar';

  @override
  void initState() {
    super.initState();
    final currentLang = context.read<LocalizationProvider>().locale.languageCode;
    selectedLang = currentLang;
  }

  void changeLanguage(String langCode) {
    setState(() {
      selectedLang = langCode;
    });
  }

  @override
  Widget build(BuildContext context) {
    final langCode = context.watch<LocalizationProvider>().locale.languageCode;

    return Directionality(
      textDirection: langCode == 'ar' ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Center(child: Text(Translations.getText('language', langCode))),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: _buildLanguageOption(
                      context,
                      'English',
                      'assets/images/img46.png',
                      selectedLang == 'en',
                          () => changeLanguage('en'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildLanguageOption(
                      context,
                      'العربية',
                      'assets/images/img47.png',
                      selectedLang == 'ar',
                          () => changeLanguage('ar'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    context.read<LocalizationProvider>().setLocale(Locale(selectedLang));
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => const SettingsScreen()),
                      );
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff28C1ED),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    Translations.getText('confirm', langCode),
                    style: const TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLanguageOption(
      BuildContext context,
      String label,
      String asset,
      bool selected,
      VoidCallback onTap,
      ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: selected
              ? const Color(0xff28C1ED)
              : const Color(0xffF2F2F2),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected ? const Color(0xff409EDC) : const Color(0xffF2F2F2),
            width: 2,
          ),
        ),
        child: Column(
          children: [
            Image.asset(asset, height: 40),
            const SizedBox(height: 8),
            Text(label),
          ],
        ),
      ),
    );
  }
}