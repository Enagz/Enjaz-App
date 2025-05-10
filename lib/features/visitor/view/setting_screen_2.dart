import 'package:flutter/material.dart';

import '../../privacy_policy/privacy_policy_screen.dart';
import '../../terms_and_conditions/terms_and_conditions_screen.dart';
import '../../usage_policy/usage_polict_screen.dart';
import '../home_screen_2.dart';
import 'dialog.dart';

class SettingsScreen2 extends StatelessWidget {
  const SettingsScreen2({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F5F5),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Align(
                  alignment: Alignment.topLeft,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: const Text(
                      "More",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                buildSection([
                  buildSettingItem(context, "General Settings", Icons.settings,
                      "assets/images/img28.png", const LoginRequiredDialog()),
                  buildSettingItem(context, "Contact Us", Icons.phone,
                      "assets/images/img29.png", const LoginRequiredDialog()),
                ]),
                const SizedBox(height: 12),
                buildSection([
                  buildSettingItem(context, "Usage Policy", Icons.security,
                      "assets/images/img30.png", const UsagePolicyScreen()),
                  buildSettingItem(context, "Terms & Conditions", Icons.rule,
                      "assets/images/img31.png", const TermsAndConditionsScreen()),
                  buildSettingItem(context, "Privacy Policy", Icons.privacy_tip,
                      "assets/images/img32.png", const PrivacyPolicyScreen()),
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
                        MaterialPageRoute(builder: (context) => HomePage2()),
                      );
                    },
                    child: Row(
                      children: [
                        Image.asset("assets/images/img60.png"),
                        const SizedBox(width: 8),
                        const Text("Log In",
                            style: TextStyle(color: Color(0xff409EDC))),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                const Center(
                  child: Text("Follow us on",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
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