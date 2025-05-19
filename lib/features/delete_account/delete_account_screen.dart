import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../localization/change_lang.dart';

class DeleteAccountScreen extends StatefulWidget {
  const DeleteAccountScreen({super.key});

  @override
  State<DeleteAccountScreen> createState() => _DeleteAccountScreenState();
}

class _DeleteAccountScreenState extends State<DeleteAccountScreen> {
  Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('userId');
  }

  Future<void> deleteUser(String userId) async {
    final lang = Localizations.localeOf(context).languageCode;
    final url = Uri.parse('https://backend.enjazkw.com/api/user/$userId/delete');

    try {
      final response = await http.delete(url);

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(Translations.getText('account_deleted_success', lang)),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${Translations.getText('delete_failed', lang)}: ${response.statusCode}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${Translations.getText('connection_error', lang)}: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final locale = Provider.of<LocalizationProvider>(context).locale.languageCode;
    final textDirection = locale == 'ar' ? TextDirection.rtl : TextDirection.ltr;

    return FutureBuilder<String?>(
      future: getUserId(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final userId = snapshot.data!;
        return Directionality(
          textDirection: textDirection,
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
                    alignment: Alignment.topRight,
                    child: Image.asset("assets/images/img23.png", width: 40),
                  ),
                  const SizedBox(height: 12),
                  Image.asset("assets/images/img24.png"),
                  const SizedBox(height: 12),
                  Text(
                    Translations.getText('do', locale), // "هل تريد حذف الحساب؟"
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      Translations.getText('re', locale), // "من فضلك اكتب السبب"
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    height: 106,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: const Color(0xFFF2F2F2), width: 1),
                    ),
                    child: TextField(
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: Translations.getText('pl', locale), // "سبب حذف الحساب"
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.all(12),
                      ),
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 150,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: () => Navigator.pop(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xff409EDC),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            Translations.getText('tra', locale), // "تراجع"
                            style: const TextStyle(fontSize: 16, color: Colors.white),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      SizedBox(
                        width: 164,
                        height: 48,
                        child: OutlinedButton(
                          onPressed: () => deleteUser(userId),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xFFE50930), width: 1),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            Translations.getText('del2', locale), // "حذف الحساب"
                            style: const TextStyle(color: Color(0xFFE50930), fontSize: 16),
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
      },
    );
  }
}