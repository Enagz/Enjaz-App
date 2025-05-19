import 'package:engaz_app/features/visitor/view/dialog.dart';
import 'package:engaz_app/features/visitor/view/home_content_2.dart';
import 'package:engaz_app/features/visitor/view/setting_screen_2.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../localization/change_lang.dart';

class HomePage2 extends StatefulWidget {
  @override
  State<HomePage2> createState() => _HomePage2State();
}

class _HomePage2State extends State<HomePage2> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    HomeContent2(),
    const LoginRequiredDialog(),
    const SettingsScreen2(),
  ];

  @override
  Widget build(BuildContext context) {
    final lang = context.read<LocalizationProvider>().locale.languageCode;
    final textDirection = lang == 'ar' ? TextDirection.rtl : TextDirection.ltr;

    return Directionality(
      textDirection: textDirection,
      child: Scaffold(
        backgroundColor: const Color(0xffFDFDFD),
        bottomNavigationBar: BottomNavigationBar(
          backgroundColor: const Color(0xffFDFDFD),
          elevation: 0,
          items: [
            BottomNavigationBarItem(
              icon: Image.asset('assets/images/img13.png'),
              label: Translations.getText('home', lang),
            ),
            BottomNavigationBarItem(
              icon: Image.asset('assets/images/img14.png'),
              label: Translations.getText('orders', lang),
            ),
            BottomNavigationBarItem(
              icon: Image.asset('assets/images/img15.png'),
              label: Translations.getText('more', lang),
            ),
          ],
          selectedItemColor: Colors.blue,
          unselectedItemColor: Colors.grey,
          currentIndex: _selectedIndex,
          onTap: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
        ),
        body: SafeArea(child: _pages[_selectedIndex]),
      ),
    );
  }
}