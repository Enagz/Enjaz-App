import 'package:engaz_app/features/visitor/view/dialog.dart';
import 'package:engaz_app/features/visitor/view/home_content_2.dart';
import 'package:engaz_app/features/visitor/view/setting_screen_2.dart';
import 'package:flutter/material.dart';

class HomePage2 extends StatefulWidget {
  @override
  State<HomePage2> createState() => _HomePage2State();
}

class _HomePage2State extends State<HomePage2> {
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
      textDirection: TextDirection.ltr,
      child: Scaffold(
        backgroundColor: const Color(0xffFDFDFD),
        bottomNavigationBar: BottomNavigationBar(
          backgroundColor: const Color(0xffFDFDFD),
          elevation: 0,
          items: [
            BottomNavigationBarItem(
              icon: Image.asset('assets/images/img13.png'),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Image.asset('assets/images/img14.png'),
              label: 'Orders',
            ),
            BottomNavigationBarItem(
              icon: Image.asset('assets/images/img15.png'),
              label: 'More',
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
