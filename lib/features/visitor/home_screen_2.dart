import 'package:engaz_app/features/visitor/view/dialog.dart';
import 'package:engaz_app/features/visitor/view/home_content_2.dart';
import 'package:engaz_app/features/visitor/view/order_screen.dart';
import 'package:engaz_app/features/visitor/view/setting_screen_2.dart';
import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../home_screen/widgets/category_card.dart';
import '../printing_request/view/printer_request_page.dart';
import '../translation _request/view/translation_request_page.dart';

class HomePage2 extends StatefulWidget {
  @override
  State<HomePage2> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage2> {
  final PageController _pageController = PageController();

  final List<String> images = [
    'assets/images/img7.png',
    'assets/images/img7.png',
    'assets/images/img7.png',
  ];

  int _selectedIndex = 0;

  final List<Widget> _pages = [
    HomeContent2(),
    const LoginRequiredDialog(),
    const SettingsScreen2(),
  ];

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xffFDFDFD),
        bottomNavigationBar: BottomNavigationBar(
          backgroundColor: const Color(0xffFDFDFD),
          elevation: 0,
          items: [
            BottomNavigationBarItem(
                icon: Image.asset('assets/images/img13.png'),
                label: 'الرئيسية'),
            BottomNavigationBarItem(
                icon: Image.asset('assets/images/img14.png'), label: 'طلباتي'),
            BottomNavigationBarItem(
                icon: Image.asset('assets/images/img15.png'), label: 'المزيد'),
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



