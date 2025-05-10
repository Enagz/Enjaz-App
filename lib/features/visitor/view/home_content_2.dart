import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../../home_screen/widgets/category_card.dart';
import '../home_screen_2.dart';

class HomeContent2 extends StatelessWidget {
  final PageController _pageController = PageController();

  final List<String> images = [
    'assets/images/img7.png',
    'assets/images/img7.png',
    'assets/images/img7.png',
  ];

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
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
                    children: const [
                      Text(
                        'Home',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'IBM_Plex_Sans_Arabic',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Center(
                    child: Column(
                      children: [
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.25,
                          child: PageView.builder(
                            controller: _pageController,
                            itemCount: images.length,
                            itemBuilder: (context, index) {
                              return Container(
                                margin: const EdgeInsets.symmetric(horizontal: .5),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(15),
                                  image: DecorationImage(
                                    image: AssetImage(images[index]),
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
                            controller: _pageController,
                            count: images.length,
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
                  const Text(
                    'Categories',
                    style: TextStyle(
                      fontSize: 16,
                      color: Color(0xff1D1D1D),
                      fontWeight: FontWeight.w600,
                      fontFamily: 'IBM_Plex_Sans_Arabic',
                    ),
                  ),
                  const SizedBox(height: 10),
                  CategoryCard(
                    title: 'Translation',
                    description: 'We offer top-quality translation services in over 10 languages worldwide.',
                    image: 'assets/images/img5.png',
                    destinationPage: HomePage2(),
                  ),
                  const SizedBox(height: 10),
                  CategoryCard(
                    title: 'Printing',
                    description: 'We provide the best printing quality at competitive prices.',
                    image: 'assets/images/img6.png',
                    destinationPage: HomePage2(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
