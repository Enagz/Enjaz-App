import 'package:engaz_app/features/general_settings/change_email_screen.dart';
import 'package:engaz_app/features/general_settings/change_phone_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';

import '../delete_account/delete_account_screen.dart';
import '../localization/change_lang.dart';
import '../notifications_history/notifications_history.dart';

class GeneralSettingsScreen extends StatefulWidget {
  const GeneralSettingsScreen({super.key});

  @override
  State<GeneralSettingsScreen> createState() => _GeneralSettingsScreenState();
}

class _GeneralSettingsScreenState extends State<GeneralSettingsScreen> {
  bool _isImage44 = true;

  void _toggleImage() {
    setState(() {
      _isImage44 = !_isImage44;
    });
  }

  @override
  Widget build(BuildContext context) {
    final locale = context
        .read<LocalizationProvider>()
        .locale
        .languageCode;
    final isArabic = locale == 'ar';
    final textDirection = isArabic ? TextDirection.rtl : TextDirection.ltr;
    return Directionality(
      textDirection: textDirection,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  children: [
                    const SizedBox(width: 8),
                    Text(
                      Translations.getText('general', locale),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Center(
                  child: Image.asset("assets/images/img1.png", width: 120),
                ),
                const SizedBox(height: 32),
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFFAFAFA),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      _buildSettingsItem(
                        context,
                        title: Translations.getText('change', locale),
                        icon: "assets/images/img40.png",
                        onTap: () =>
                            Navigator.push(context,
                                MaterialPageRoute(
                                    builder: (_) => const ChangePhoneScreen())),
                      ),
                      _buildSettingsItem(
                        context,
                        title: Translations.getText('change2', locale),
                        icon: "assets/images/img41.png",
                        onTap: () =>
                            Navigator.push(context,
                                MaterialPageRoute(
                                    builder: (_) => const ChangeEmailScreen())),
                      ),
                      _buildSettingsItem(
                        context,
                        title: Translations.getText('change3', locale),
                        icon: "assets/images/img42.png",
                        onTap: () =>
                            Navigator.push(context,
                                MaterialPageRoute(
                                    builder: (_) => const LanguageScreen())),
                      ),
                      _buildSwitchItem(
                          context, Translations.getText('make', locale)),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (_) => const DeleteAccountScreen(),
                    );
                  },
                  child: Text(
                    Translations.getText('delete', locale),
                    style: const TextStyle(
                      color: Colors.red,
                      decoration: TextDecoration.underline,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsItem(BuildContext context,
      {required String title, required String icon, required VoidCallback onTap}) {
    final locale = context.read<LocalizationProvider>().locale.languageCode;
    final isArabic = locale == 'ar';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: GestureDetector(
        onTap: onTap,
        child: Row(
          mainAxisAlignment:
          isArabic ? MainAxisAlignment.end : MainAxisAlignment.start,
          children: [
            Image.asset(icon, width: 24, height: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(fontSize: 14),
                textAlign: isArabic ? TextAlign.right : TextAlign.left,
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildSwitchItem(BuildContext context, String title) {
    final locale = context.read<LocalizationProvider>().locale.languageCode;
    final isArabic = locale == 'ar';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        mainAxisAlignment:
        isArabic ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          Image.asset("assets/images/img43.png", width: 24, height: 24),
          const SizedBox(width: 12),
          Expanded(
            child: InkWell(
              onTap: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const NotificationsHistoryScreen())),
              child: Text(
                title,
                style: const TextStyle(fontSize: 14),
                textAlign: isArabic ? TextAlign.right : TextAlign.left,
              ),
            ),
          ),
          GestureDetector(
            onTap: _toggleImage,
            child: Image.asset(
              _isImage44 ? "assets/images/img44.png" : "assets/images/img45.png",
              width: 40,
              height: 24,
            ),
          ),
        ],
      ),
    );
  }
}
