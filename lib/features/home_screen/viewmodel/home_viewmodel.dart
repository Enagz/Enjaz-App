import 'package:engaz_app/features/orders/orders_screen.dart';
import 'package:flutter/material.dart';
import '../../settings/settings_screen.dart';
import '../view/home_content.dart';

class HomeViewModel extends ChangeNotifier {
  int selectedIndex = 0;

  final List<Widget> pages = [
    HomeContent(),
    OrdersScreen(),
    const SettingsScreen(), // OrdersScreen(),
      // SettingsScreen(),
  ];

  void changeTab(int index) {
    selectedIndex = index;
    notifyListeners();
  }
}