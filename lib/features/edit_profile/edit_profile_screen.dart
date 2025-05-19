import 'dart:convert';
import 'package:engaz_app/features/settings/settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../localization/change_lang.dart';

class EditProfileScreen extends StatelessWidget {
  const EditProfileScreen({super.key});

  Future<Map<String, String>> fetchUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';
    final response = await http.get(
      Uri.parse("https://backend.enjazkw.com/api/user"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token"
      },
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return {
        "firstname": json["firstname"] ?? "",
        "lastname": json["lastname"] ?? ""
      };
    } else {
      throw Exception("Failed to load user data");
    }
  }

  @override
  Widget build(BuildContext context) {
    final TextEditingController firstNameController = TextEditingController();
    final TextEditingController lastNameController = TextEditingController();

    return Consumer<LocalizationProvider>(
      builder: (context, localizationProvider, child) {
        final locale = localizationProvider.locale.languageCode;
        final textDirection = locale == 'ar' ? TextDirection.rtl : TextDirection.ltr;
        final alignment = locale == 'ar' ? Alignment.topRight : Alignment.topLeft;

        return Directionality(
          textDirection: textDirection,
          child: Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              backgroundColor: Colors.white,
              automaticallyImplyLeading: false,
              title: Text(
                Translations.getText('profile', locale),
                textAlign: TextAlign.right,
                style: const TextStyle(color: Colors.black),
              ),
              iconTheme: const IconThemeData(color: Colors.black),
              elevation: 0,
            ),
            body: SafeArea(
              child: FutureBuilder<Map<String, String>>(
                future: fetchUserData(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        Translations.getText('error_loading_data', locale),
                        style: const TextStyle(color: Colors.red),
                      ),
                    );
                  } else {
                    final data = snapshot.data!;
                    firstNameController.text = data["firstname"]!;
                    lastNameController.text = data["lastname"]!;

                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 16),
                      child: Column(
                        children: [
                          Image.asset(
                            "assets/images/img1.png",
                            height: 69,
                            width: 187,
                          ),
                          const SizedBox(height: 24),
                          Align(
                            alignment: alignment,
                            child: Text(
                              Translations.getText('first', locale), // First Name
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                            ),
                          ),
                          buildTextField(
                              Translations.getText('enter_first_name', locale),
                              firstNameController,
                              locale),
                          const SizedBox(height: 16),
                          Align(
                            alignment: alignment,
                            child: Text(
                              Translations.getText('last', locale), // Last Name
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                            ),
                          ),
                          buildTextField(
                              Translations.getText('enter_last_name', locale),
                              lastNameController,
                              locale),
                          const SizedBox(height: 24),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const SettingsScreen(),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              minimumSize: const Size(343, 48),
                              backgroundColor: const Color(0xFF409EDC),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                            ),
                            child: Text(
                              Translations.getText('save', locale),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                },
              ),
            ),
          ),
        );
      },
    );
  }
}

Widget buildTextField(String hint, TextEditingController controller, String languageCode) {
  return Container(
    width: 343,
    height: 48,
    decoration: BoxDecoration(
      color: const Color(0xFFFAFAFA),
      borderRadius: BorderRadius.circular(16),
    ),
    child: TextField(
      controller: controller,
      textAlign: languageCode == 'ar' ? TextAlign.right : TextAlign.left,
      decoration: InputDecoration(
        hintText: hint,
        border: OutlineInputBorder(
          borderSide: BorderSide.none,
          borderRadius: BorderRadius.circular(16),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      ),
      style: const TextStyle(fontSize: 14),
    ),
  );
}