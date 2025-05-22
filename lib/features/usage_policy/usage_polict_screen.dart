import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../localization/change_lang.dart';

class UsagePolicyScreen extends StatefulWidget {
  const UsagePolicyScreen({super.key});

  @override
  State<UsagePolicyScreen> createState() => _UsagePolicyScreenState();
}

class _UsagePolicyScreenState extends State<UsagePolicyScreen> {
  String _usageText = '';
  bool _isLoading = true;

  Future<void> fetchUsagePolicy(String langCode) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    final url = Uri.parse('https://backend.enjazkw.com/api/dashboard/terms/usage');

    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final text = langCode == 'ar'
            ? data['usage']['ArabicUsage']
            : data['usage']['EnglishUsage'];

        setState(() {
          _usageText = text;
          _isLoading = false;
        });
      } else {
        setState(() {
          _usageText = Translations.getText('usage_load_error', langCode);
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _usageText = Translations.getText('usage_fetch_exception', langCode);
        _isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    final lang = WidgetsBinding.instance.platformDispatcher.locale.languageCode;
    fetchUsagePolicy(lang);
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
              title: Text(
                Translations.getText('use', locale),
              ),
            ),
            body: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Center(
                      child: Image.asset('assets/images/img1.png', height: 80),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      width: 346,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFAFAFA),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: _isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : SingleChildScrollView(
                        child: Text(
                          _usageText,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF1D1D1D),
                            fontWeight: FontWeight.bold,
                          ),
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
}