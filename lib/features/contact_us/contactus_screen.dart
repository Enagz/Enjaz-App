import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import '../localization/change_lang.dart';

class ContactUsScreen extends StatefulWidget {
  const ContactUsScreen({super.key});

  @override
  State<ContactUsScreen> createState() => _ContactUsScreenState();
}

class _ContactUsScreenState extends State<ContactUsScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController messageController = TextEditingController();

  Future<void> sendContactMessage() async {
    final uri = Uri.parse("https://backend.enjazkw.com/api/contactus");

    final body = {
      "name": nameController.text.trim(),
      "phone": phoneController.text.trim(),
      "email": emailController.text.trim(),
      "title": "Contact Request",
      "message": messageController.text.trim(),
    };

    try {
      final response = await http.post(
        uri,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );

      final lang = Localizations.localeOf(context).languageCode;

      if (response.statusCode == 200) {
        final res = jsonDecode(response.body);
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: Text(Translations.getText('success', lang)),
            content: Text(res['message']),
            actions: [
              TextButton(
                child: Text(Translations.getText('ok', lang)),
                onPressed: () => Navigator.pop(context),
              )
            ],
          ),
        );
      } else {
        throw Exception("Failed to send message");
      }
    } catch (e) {
      final lang = Localizations.localeOf(context).languageCode;
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text(Translations.getText('error', lang)),
          content: Text(Translations.getText('error_message', lang)),
          actions: [
            TextButton(
              child: Text(Translations.getText('try_again', lang)),
              onPressed: () => Navigator.pop(context),
            )
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<LocalizationProvider>(
      builder: (context, localizationProvider, child) {
        final locale = localizationProvider.locale.languageCode;
        final textDirection = locale == 'ar' ? TextDirection.rtl : TextDirection.ltr;

        return Directionality(
          textDirection: textDirection,
          child: Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              automaticallyImplyLeading: false,
              backgroundColor: Colors.white,
              elevation: 0,
              title: Text(
                Translations.getText('contactus', locale),
                style: const TextStyle(color: Colors.black),
              ),
              iconTheme: const IconThemeData(color: Colors.black),
            ),
            body: Padding(
              padding: const EdgeInsets.all(16),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment:
                  locale == 'ar' ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                  children: [
                    Center(child: Image.asset('assets/images/img1.png', height: 80)),
                    const SizedBox(height: 16),
                    Center(
                      child: Text(
                        Translations.getText('contactus', locale),
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Center(
                      child: Text(
                        Translations.getText('through', locale),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Color(0xff676767),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset("assets/images/img55.png"),
                        const SizedBox(width: 8),
                        Image.asset("assets/images/img50.png"),
                        const SizedBox(width: 8),
                        Image.asset("assets/images/img49.png"),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Center(
                      child: Text(Translations.getText('or', locale)),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      Translations.getText('name', locale),
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                    _buildInputField(nameController, 'name2', locale),
                    const SizedBox(height: 10),
                    Text(
                      Translations.getText('address2', locale),
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                    _buildInputField(phoneController, 'plss', locale),
                    const SizedBox(height: 10),
                    Text(
                      Translations.getText('email', locale),
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                    _buildInputField(emailController, 'email_hint', locale),
                    const SizedBox(height: 10),
                    Text(
                      Translations.getText('msst', locale),
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                    _buildInputField(messageController, 'ent', locale, lines: 4),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: sendContactMessage,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xff409EDC),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          Translations.getText('s', locale),
                          style: const TextStyle(fontSize: 16, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildInputField(TextEditingController controller, String hintKey, String locale, {int lines = 1}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFFAFAFA),
        borderRadius: BorderRadius.circular(16),
      ),
      child: TextField(
        controller: controller,
        maxLines: lines,
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: Translations.getText(hintKey, locale),
        ),
        style: const TextStyle(fontSize: 14),
      ),
    );
  }
}