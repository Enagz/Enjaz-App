import 'package:engaz_app/features/auth/login/view/login_screen.dart';
import 'package:engaz_app/features/notifications_history/notifications_history.dart';
import 'package:engaz_app/features/translation%20_request/view/translation_request_page.dart';
import 'package:flutter/material.dart';
import '../../features/splash/view/splash_screen.dart';

class AppRoutes {
  static Map<String, WidgetBuilder> get routes => {
    '/': (context) => const SplashScreen(),
    '/login': (context) => const LoginScreen(),
    '/translate': (context) =>  TranslationOrderApp(),
    'notifications': (context) => const NotificationsHistoryScreen(),
  };
}