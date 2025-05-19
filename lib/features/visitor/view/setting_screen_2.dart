import 'package:engaz_app/features/auth/login/view/login_screen.dart';
import 'package:engaz_app/features/contact_us/contactus_screen.dart';
import 'package:engaz_app/features/visitor/view/order_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../privacy_policy/privacy_policy_screen.dart';
import '../../terms_and_conditions/terms_and_conditions_screen.dart';
import '../../usage_policy/usage_polict_screen.dart';
import '../../localization/change_lang.dart';

class SettingsScreen2 extends StatelessWidget {
  const SettingsScreen2({super.key});

  @override
  Widget build(BuildContext context) {
    final lang = context.read<LocalizationProvider>().locale.languageCode;
    final textDirection = lang == 'ar' ? TextDirection.rtl : TextDirection.ltr;

    return Directionality(
      textDirection: textDirection,
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F5F5),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Align(
                  alignment: textDirection == TextDirection.rtl
                      ? Alignment.topRight
                      : Alignment.topLeft,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                    child: Text(
                      Translations.getText('more', lang),
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 20),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                buildSection([
                  buildSettingItem(context, Translations.getText('general_settings', lang),
                      Icons.settings, "assets/images/img28.png", const OrdersScreenVistor()),
                  buildSettingItem(context, Translations.getText('contact_us', lang),
                      Icons.phone, "assets/images/img29.png", const ContactUsScreen()),
                ]),
                const SizedBox(height: 12),
                buildSection([
                  buildSettingItem(context, Translations.getText('usage_policy', lang),
                      Icons.security, "assets/images/img30.png", const UsagePolicyScreen()),
                  buildSettingItem(context, Translations.getText('terms_conditions', lang),
                      Icons.rule, "assets/images/img31.png", const TermsAndConditionsScreen()),
                  buildSettingItem(context, Translations.getText('privacy_policy', lang),
                      Icons.privacy_tip, "assets/images/img32.png", const PrivacyPolicyScreen()),
                ]),
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xff28C1ED).withOpacity(.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const LoginScreen()),
                      );
                    },
                    child: Row(
                      children: [
                        Image.asset("assets/images/img60.png"),
                        const SizedBox(width: 8),
                        Text(
                          Translations.getText('login', lang),
                          style: const TextStyle(color: Color(0xff409EDC)),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Center(
                  child: Text(
                    Translations.getText('follow_us', lang),
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                  ),
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
        children: items,
      ),
    );
  }
}