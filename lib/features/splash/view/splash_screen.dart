import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodel/splash_viewmodel.dart';
import '../../../../core/utils/responsive.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    final viewModel = Provider.of<SplashViewModel>(context, listen: false);
    viewModel.handleStartup(context);
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Image.asset(
          'assets/images/img1.png',
          width: Responsive.isMobile(context) ? 150 : 200,
          height: Responsive.isMobile(context) ? 150 : 200,
        ),
      ),
    );
  }
}
