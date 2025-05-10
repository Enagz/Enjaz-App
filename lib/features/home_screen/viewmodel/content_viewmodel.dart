import 'package:engaz_app/features/translation%20_request/view/translation_request_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../localization/change_lang.dart';
import '../../printing_with_api/print.dart';

class ContentViewModel extends ChangeNotifier {
  final PageController pageController = PageController();

  final List<String> images = [
    'assets/images/img7.png',
    'assets/images/img7.png',
    'assets/images/img7.png',
  ];

  List<Map<String, dynamic>> getCategories(BuildContext context) {
    final localeCode = context.read<LocalizationProvider>().locale.languageCode;

    return [
      {
        'title': Translations.getText('tran', localeCode),
        'description': Translations.getText('offerr', localeCode),
        'image': 'assets/images/img5.png',
        'page': TranslationOrderApp(),
      },
      {
        'title':Translations.getText('pri', localeCode),
        'description': Translations.getText('oferrr2', localeCode),
        'image': 'assets/images/img6.png',
        'page': PrinterRequestPageWithApi(),
      },
    ];
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }
}
