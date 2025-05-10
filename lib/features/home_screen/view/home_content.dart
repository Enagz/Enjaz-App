import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../../Support Chat/support_chat.dart';
import '../../localization/change_lang.dart';
import '../../notifications_history.dart';
import '../viewmodel/content_viewmodel.dart';
import '../widgets/category_card.dart';

class HomeContent extends StatefulWidget {
  @override
  State<HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  bool hasUnreadNotifications = false;

  @override
  void initState() {
    super.initState();
    checkUnreadNotifications();
  }

  Future<void> checkUnreadNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) return;

    try {
      final response = await http.get(
        Uri.parse("https://wckb4f4m-3000.euw.devtunnels.ms/api/coustmer/notification"),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final List notifications = jsonDecode(response.body);
        final unreadExists = notifications.any((n) => n['isRead'] == false);
        setState(() => hasUnreadNotifications = unreadExists);
      }
    } catch (e) {
      print("❌ Error checking notifications: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
        create: (_) => ContentViewModel(),
        child: Consumer<ContentViewModel>(builder: (context, viewModel, child) {
          return Consumer<LocalizationProvider>(
            builder: (context, localizationProvider, child) {
              final locale = localizationProvider.locale.languageCode;
              final textDirection =
                  locale == 'ar' ? TextDirection.rtl : TextDirection.ltr;
              return Directionality(
                textDirection: textDirection,
                child: Scaffold(
                  backgroundColor: const Color(0xffFDFDFD),
                  body: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  Translations.getText(
                                    'home',
                                    context
                                        .read<LocalizationProvider>()
                                        .locale
                                        .languageCode,
                                  ),
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w600,
                                      fontFamily: 'IBM_Plex_Sans_Arabic'),
                                ),
                                Row(
                                  children: [
                                    InkWell(
                                      onTap: (){
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(builder: (context) => SupportChatScreen()),
                                        );
                                      },
                                        child: Image.asset("assets/images/img8.png")),
                                    const SizedBox(width: 10),
                                    InkWell(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(builder: (context) => const NotificationsHistoryScreen()),
                                        );
                                      },
                                      child: Stack(
                                        children: [
                                          Image.asset("assets/images/img9.png", width: 30, height: 30),
                                          if (hasUnreadNotifications)
                                            Positioned(
                                              top: 0,
                                              right: 0,
                                              child: Container(
                                                width: 10,
                                                height: 10,
                                                decoration: BoxDecoration(
                                                  color: Colors.red,
                                                  shape: BoxShape.circle,
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Center(
                              child: Column(
                                children: [
                                  SizedBox(
                                    height: MediaQuery.maybeOf(context)
                                                ?.size
                                                .height !=
                                            null
                                        ? MediaQuery.of(context).size.height *
                                            0.25
                                        : 200,
                                    child: PageView.builder(
                                      controller: viewModel.pageController,
                                      itemCount: viewModel.images.length,
                                      itemBuilder: (context, index) {
                                        return Container(
                                          margin: const EdgeInsets.symmetric(
                                              horizontal: .5),
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(15),
                                            image: DecorationImage(
                                              image: AssetImage(
                                                  viewModel.images[index]),
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  Align(
                                    alignment: Alignment.center,
                                    child: SmoothPageIndicator(
                                      controller: viewModel.pageController,
                                      count: viewModel.images.length,
                                      effect: const ExpandingDotsEffect(
                                        dotHeight: 8,
                                        dotWidth: 8,
                                        activeDotColor: Color(0xff409EDC),
                                        dotColor: Colors.grey,
                                        expansionFactor: 2,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              Translations.getText(
                                'cat',
                                context
                                    .read<LocalizationProvider>()
                                    .locale
                                    .languageCode,
                              ),
                              style: TextStyle(
                                fontSize: 16,
                                color: Color(0xff1D1D1D),
                                fontWeight: FontWeight.w600,
                                fontFamily: 'IBM_Plex_Sans_Arabic',
                              ),
                            ),
                            const SizedBox(height: 10),
                            ...viewModel
                                .getCategories(context)
                                .map((cat) => CategoryCard(
                                      title: cat['title'],
                                      description: cat['description'],
                                      image: cat['image'],
                                      destinationPage: cat['page'],
                                    )),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        }));
  }
}
