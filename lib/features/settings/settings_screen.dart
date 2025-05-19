import 'package:engaz_app/features/notifications_history/notifications_history.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import '../contact_us/contactus_screen.dart';
import '../edit_profile/edit_profile_screen.dart';
import '../general_settings/general_settings_screen.dart';
import '../localization/change_lang.dart';
import '../logout/logout_screen.dart';
import '../privacy_policy/privacy_policy_screen.dart';
import '../saved_order/view/saved_order.dart';
import '../terms_and_conditions/terms_and_conditions_screen.dart';
import '../usage_policy/usage_polict_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<LocalizationProvider>(
        builder: (context, localizationProvider, child) {
      final locale = localizationProvider.locale.languageCode;
      final textDirection =
          locale == 'ar' ? TextDirection.rtl : TextDirection.ltr;

      return Directionality(
        textDirection: textDirection,
        child: Scaffold(
          backgroundColor: const Color(0xFFF5F5F5),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Row(
                    children: [
                      Text(
                        Translations.getText(
                          'more',
                          context
                              .read<LocalizationProvider>()
                              .locale
                              .languageCode,
                        ),
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 20),
                      ),
                      const Spacer(),
                      InkWell(
                        onTap: (){
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => NotificationsHistoryScreen()));
                        },
                          child: Image.asset("assets/images/img9.png", height: 40)),
                    ],
                  ),
                  const SizedBox(height: 24),
                  buildSection([
                    buildSettingItem(
                        context,
                        Translations.getText(
                            'profile',
                            context
                                .read<LocalizationProvider>()
                                .locale
                                .languageCode),
                        Icons.person,
                        "assets/images/img26.png",
                        EditProfileScreen()),
                    buildSettingItem(
                        context,
                        Translations.getText(
                            'addresses',
                            context
                                .read<LocalizationProvider>()
                                .locale
                                .languageCode),
                        Icons.info,
                        "assets/images/img27.png",
                        SavedAddress()),
                  ]),
                  const SizedBox(height: 12),
                  buildSection([
                    buildSettingItem(
                        context,
                        Translations.getText(
                            'general_settings',
                            context
                                .read<LocalizationProvider>()
                                .locale
                                .languageCode),
                        Icons.settings,
                        "assets/images/img28.png",
                        GeneralSettingsScreen()),
                    buildSettingItem(
                        context,
                        Translations.getText(
                            'contact_us',
                            context
                                .read<LocalizationProvider>()
                                .locale
                                .languageCode),
                        Icons.phone,
                        "assets/images/img29.png",
                        ContactUsScreen()),
                  ]),
                  const SizedBox(height: 12),
                  buildSection([
                    buildSettingItem(
                        context,
                        Translations.getText(
                            'usage_policy',
                            context
                                .read<LocalizationProvider>()
                                .locale
                                .languageCode),
                        Icons.security,
                        "assets/images/img30.png",
                        UsagePolicyScreen()),
                    buildSettingItem(
                        context,
                        Translations.getText(
                            'terms_and_conditions',
                            context
                                .read<LocalizationProvider>()
                                .locale
                                .languageCode),
                        Icons.rule,
                        "assets/images/img31.png",
                        TermsAndConditionsScreen()),
                    buildSettingItem(
                        context,
                        Translations.getText(
                            'privacy_policy',
                            context
                                .read<LocalizationProvider>()
                                .locale
                                .languageCode),
                        Icons.privacy_tip,
                        "assets/images/img32.png",
                        PrivacyPolicyScreen()),
                  ]),
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        vertical: 12, horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.red.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: InkWell(
                      onTap: () {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          builder: (context) => const LogOutModal(),
                        );
                      },
                      child: Row(
                        children: [
                          Image.asset("assets/images/img33.png"),
                          const SizedBox(width: 8),
                          Text(
                              Translations.getText(
                                  'logout',
                                  context
                                      .read<LocalizationProvider>()
                                      .locale
                                      .languageCode),
                              style: TextStyle(color: Color(0xffE50930))),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Center(
                    child: Text(
                        Translations.getText(
                            'follow',
                            context
                                .read<LocalizationProvider>()
                                .locale
                                .languageCode),
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 20)),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Image.asset("assets/images/img34.png"),
                      Image.asset("assets/images/img35.png"),
                      Image.asset("assets/images/img36.png"),
                      Image.asset("assets/images/img37.png"),
                      Image.asset("assets/images/img38.png"),
                      Image.asset("assets/images/img39.png"),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }

  Widget buildSettingItem(
    BuildContext context,
    String title,
    IconData icon,
    String imagePath,
    Widget targetScreen,
  ) {
    return ListTile(
      tileColor: Colors.white,
      leading: Image.asset(imagePath, width: 24, height: 24),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      trailing: const Icon(Icons.arrow_forward_ios),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => targetScreen),
        );
      },
    );
  }

  Widget buildSection(List<Widget> items) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: List.generate(items.length, (index) {
          return Column(
            children: [
              items[index],
            ],
          );
        }),
      ),
    );
  }
}
