import 'dart:convert';
import 'package:quickalert/quickalert.dart';
import 'package:engaz_app/features/auth/forgetPassword/view/otp_screen.dart';
import 'package:engaz_app/features/auth/login/widgets/login_text_feild.dart';
import 'package:engaz_app/features/auth/register/view/register_screen.dart';
import 'package:engaz_app/features/home_screen/view/home_view.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../localization/change_lang.dart';
import '../../../visitor/home_screen_2.dart';
import '../viewmodel/login_viewmodel.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  static String routeName = 'Login';

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  @override
  void initState() {
    super.initState();
    _setupNotification();
  }

  void _setupNotification() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    // طلب صلاحية الإشعارات
    await messaging.requestPermission();

    // إعداد flutter_local_notifications
    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
    InitializationSettings(android: initializationSettingsAndroid);

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  void _showLocalNotification(String title, String body) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
    AndroidNotificationDetails('login_channel', 'Login Notifications',
        importance: Importance.max,
        priority: Priority.high,
        showWhen: false);

    const NotificationDetails platformChannelSpecifics =
    NotificationDetails(android: androidPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.show(
      0, // ID
      title,
      body,
      platformChannelSpecifics,
    );
  }

  Future<UserCredential> signInWithGoogle() async {
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

    if (googleUser == null) {
      throw Exception('User cancelled sign-in');
    }

    final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final userCredential = await FirebaseAuth.instance.signInWithCredential(credential);

    final uid = userCredential.user?.uid;
    final email = userCredential.user?.email;
    final name = userCredential.user?.displayName;

    final String secretKey = r"h@8G$z!X9rF%2pL^vM&*sYQ1JbT7NcW5x!G3dR0PmA*Zq^vU4L&V9mY6C2H";

    final jwt = JWT({
      'uid': uid,
      'email': email,
      'name': name,
      'iat': DateTime.now().millisecondsSinceEpoch,
    });

    final signedToken = jwt.sign(SecretKey(secretKey), algorithm: JWTAlgorithm.HS256);

    print("🔐 JWT Token (HS256): $signedToken");

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', signedToken);

    final storedToken = prefs.getString('token');
    print("📦 Stored Token from SharedPreferences: $storedToken");

    // ✅ ابعت FCM Token للباك إند
    final fcmToken = await FirebaseMessaging.instance.getToken();
    if (fcmToken != null) {
      try {
        final response = await http.post(
          Uri.parse('https://wckb4f4m-3000.euw.devtunnels.ms/api/login/token'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $signedToken',
          },
          body: jsonEncode({"token": fcmToken}),
        );
        print("✅ FCM token sent: ${response.statusCode} - ${response.body}");
      } catch (e) {
        print("❌ Error sending FCM token: $e");
      }
    }

    return userCredential;
  }

  @override
  Widget build(BuildContext context) {
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();
    final langCode = context.watch<LocalizationProvider>().locale.languageCode;

    return Scaffold(
      backgroundColor: Colors.white,
      body: LayoutBuilder(
        builder: (context, constraints) {
          double screenWidth = constraints.maxWidth;
          double padding = screenWidth > 600 ? 48 : 24;
          double imageWidth = screenWidth > 600 ? 250 : 204;
          double buttonHeight = screenWidth > 600 ? 60 : 50;
          return Stack(
            children: [
              SingleChildScrollView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: padding),
                  child: Form(
                    key: formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        SizedBox(height: screenWidth > 600 ? 150 : 130),
                        Image.asset('assets/images/img1.png',
                            width: imageWidth, height: imageWidth * 0.37),
                        const SizedBox(height: 16),
                        Text(
                          Translations.getText('login', langCode),
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'IBM_Plex_Sans_Arabic'),
                        ),
                        Text(
                          Translations.getText('choose_method', langCode),
                          style: TextStyle(
                              fontSize: 12,
                              color: Color(0xffB3B3B3),
                              fontWeight: FontWeight.w500,
                              fontFamily: 'IBM_Plex_Sans_Arabic'),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Consumer<LoginViewModel>(
                              builder: (context, viewModel, child) {
                                return _buildToggleButton(
                                  title: Translations.getText('email', langCode),
                                  isSelected: !viewModel.isPhoneSelected,
                                  onTap: viewModel.toggleLoginMethod,
                                );
                              },
                            ),
                            Consumer<LoginViewModel>(
                              builder: (context, viewModel, child) {
                                return _buildToggleButton(
                                  title: Translations.getText('phone', langCode),
                                  isSelected: viewModel.isPhoneSelected,
                                  onTap: viewModel.toggleLoginMethod,
                                );
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        const LoginTextField(),
                        const SizedBox(height: 16),
                        Consumer<LoginViewModel>(
                          builder: (context, viewModel, _) {
                            return SizedBox(
                              width: double.infinity,
                              height: buttonHeight,
                              child: ElevatedButton(
                                onPressed: viewModel.loginState ==
                                        LoginState.loading
                                    ? () {}
                                    : () async {
                                        if (!formKey.currentState!.validate())
                                          return;
                                        final result =
                                            await viewModel.loginUser();
                                        if (result['success']) {
                                          /*ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                              content: Text(result['message']),
                                              backgroundColor: Colors.green,
                                            ),
                                          );
                                           */
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => OtpScreen(
                                                contactInfo:
                                                    viewModel.userInput,
                                                contactType:
                                                    viewModel.isPhoneSelected
                                                        ? 'phone'
                                                        : 'email',
                                              ),
                                            ),
                                          );
                                        } else {
                                          QuickAlert.show(
                                            context: context,
                                            type: QuickAlertType.error,
                                            title: 'Oops...',
                                            text: 'Sorry, something went wrong',
                                            confirmBtnText : 'Try Again',
                                          );
                                          /*ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                              content: Text(result['message']),
                                              backgroundColor: Colors.red,
                                            ),
                                          );
                                           */
                                        }
                                      },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      viewModel.loginState == LoginState.loading
                                          ? Colors.blue
                                          : Colors.blue,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: viewModel.loginState ==
                                        LoginState.loading
                                    ? const CircularProgressIndicator(
                                        color: Colors.white)
                                    :  Text(
                                  Translations.getText('login', langCode),
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    fontFamily: 'IBM_Plex_Sans_Arabic',
                                    color: Colors.white,
                                        ),
                                      ),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          height: buttonHeight,
                          child: OutlinedButton(
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => HomePage2()));
                            },
                            style: OutlinedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              side: const BorderSide(
                                  color: Color(0xff409EDC), width: 1),
                            ),
                            child: const Text(
                              "الاستمرار كزائر",
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                fontFamily: 'IBM_Plex_Sans_Arabic',
                                color: Color(0xff409EDC),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          height: buttonHeight,
                          child: OutlinedButton(
                            onPressed: () async {
                              try {
                                await signInWithGoogle();
                                /*ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text("✅ تم تسجيل الدخول بجوجل")),
                                );
                                 */
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => HomePage()));
                              } catch (e) {
                                print("❌ Google Sign-In Error: $e");
                                QuickAlert.show(
                                  context: context,
                                  type: QuickAlertType.error,
                                  title: 'Oops...',
                                  text: 'Sorry, something went wrong',
                                  confirmBtnText : 'Try Again',
                                );
                                /*ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content:
                                          Text("❌ فشل تسجيل الدخول بجوجل")),
                                );
                                 */
                              }
                            },
                            style: OutlinedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              side: const BorderSide(
                                color: Color(0xff409EDC),
                                width: 1,
                              ),
                            ),
                            child: Text(
                              Translations.getText('google_login', langCode),
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                fontFamily: 'IBM_Plex_Sans_Arabic',
                                color: Color(0xff409EDC),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text.rich(
                          TextSpan(
                            text: Translations.getText('no_account', langCode) + " ",
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'IBM_Plex_Sans_Arabic',
                            ),
                            children: [
                              TextSpan(
                                text: Translations.getText('signup', langCode),
                                style: const TextStyle(
                                  color: Color(0xff409EDC),
                                  fontWeight: FontWeight.w600,
                                  fontFamily: 'IBM_Plex_Sans_Arabic',
                                ),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              const RegisterScreen()),
                                    );
                                  },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 60,
                left: padding,
                child: GestureDetector(
                  onTap: () {
                    final currentLang = context.read<LocalizationProvider>().locale.languageCode;
                    final newLang = currentLang == 'ar' ? 'en' : 'ar';
                    context.read<LocalizationProvider>().setLocale(Locale(newLang));
                  },
                  child: Image.asset('assets/images/img2.png',
                      width: screenWidth > 600 ? 120 : 98,
                      height: screenWidth > 600 ? 40 : 33),
                ),
              ),
            ],
          );
        },
      ),
    );
  }


  Widget _buildToggleButton({
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          margin: const EdgeInsets.symmetric(horizontal: 0),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xff409EDC) : Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.black,
              fontSize: 14,
              fontWeight: FontWeight.w500,
              fontFamily: 'IBM_Plex_Sans_Arabic',
            ),
          ),
        ),
      ),
    );
  }
}
