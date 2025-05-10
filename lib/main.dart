import 'dart:convert';
import 'package:engaz_app/features/order_details/order_details_page.dart';
import 'package:engaz_app/features/saved_order/view/saved_order.dart';
import 'package:engaz_app/features/splash/view/splash_screen.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:engaz_app/features/auth/login/view/login_screen.dart';
import 'package:engaz_app/features/auth/login/viewmodel/login_viewmodel.dart';
import 'package:engaz_app/features/splash/viewmodel/splash_viewmodel.dart';
import 'package:file_selector/file_selector.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'features/address/view_model/add_address_view_model.dart';
import 'features/auth/forgetPassword/viewmodel/otp_viewmodel.dart';
import 'features/localization/change_lang.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

/*Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print("📥 [Background] Full message as Map → ${jsonEncode(message.toMap())}");
  print("📦 message.data → ${message.data}");
  _showNotification(message);
}
 */

void _showNotification(RemoteMessage message) {
  RemoteNotification? notification = message.notification;
  AndroidNotification? android = message.notification?.android;

  final title = message.data['title'] ?? notification?.title ?? 'Notification';
  final body = message.data['body'] ?? notification?.body ?? '';

  if (android != null) {
    flutterLocalNotificationsPlugin.show(
      notification.hashCode,
      title,
      body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'high_importance_channel',
          'High Importance Notifications',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
    );
  }

  print("🔔 Title: $title");
  print("📃 Body: $body");
}

Future<void> sendTokenToBackend(String fcmToken) async {
  final prefs = await SharedPreferences.getInstance();
  final authToken = prefs.getString('fcm_token');

  if (authToken == null) {
    print("⚠️ No auth token saved, skipping FCM token upload.");
    return;
  }

  final url =
      Uri.parse('https://wckb4f4m-3000.euw.devtunnels.ms/api/login/token');
  try {
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $authToken',
      },
      body: jsonEncode({"token": fcmToken}),
    );
    print("✅ Token sent → ${response.statusCode}: ${response.body}");
  } catch (e) {
    print("❌ Failed to send token: $e");
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
  const initSettings = InitializationSettings(android: androidSettings);
  await flutterLocalNotificationsPlugin.initialize(initSettings);

  //FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    print(
        "📥 [Foreground] Full message as Map → ${jsonEncode(message.toMap())}");
    print("📦 message.data → ${message.data}");
    _showNotification(message);
  });

  final token = await FirebaseMessaging.instance.getToken();
  print("📱 FCM Token: $token");

  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => SplashViewModel()),
      ChangeNotifierProvider(create: (_) => LoginViewModel()),
      ChangeNotifierProvider(create: (_) => AddAddressViewModel()),
      ChangeNotifierProvider(create: (_) => LocalizationProvider()),
      ChangeNotifierProvider(create: (_) => OtpViewModel()),
    ],
    child: const MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final localeProvider = Provider.of<LocalizationProvider>(context);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue),
      locale: localeProvider.locale,
      supportedLocales: const [Locale('en'), Locale('ar')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: const SplashScreen(),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/translate': (context) => TranslationOrderApp(),
      },
    );
  }
}

class TranslationOrderApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: TranslationOrderForm(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class TranslationOrderForm extends StatefulWidget {
  @override
  _TranslationOrderFormState createState() => _TranslationOrderFormState();
}

class _TranslationOrderFormState extends State<TranslationOrderForm> {
  final _formKey = GlobalKey<FormState>();
  String? fileLanguage;

  List<String> translationLanguages = [];
  String? deliveryMethod;
  String? address;
  String? notes;
  List<XFile> uploadedFiles = [];

  final List<String> allLanguages = ['Arabic', 'English', 'French', 'Dutch'];

  Future<String?> _getToken() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  void showSuccessBottomSheet(BuildContext context) {
    final langCode = context.read<LocalizationProvider>().locale.languageCode;

    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              Translations.getText('order_success', langCode),
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              Translations.getText('order_review_msg', langCode),
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey[700]),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Color(0xff409EDC)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      Translations.getText('new_service_request', langCode),
                      style: TextStyle(color: Color(0xff409EDC)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {/////////////////////////////////////هنا يا هاجر
                    //  Navigator.push(context, MaterialPageRoute(builder: (context)=>OrderDetailsPage(orderNumber: ,)));
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xff409EDC),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      Translations.getText('follow_request', langCode),
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  bool isLoading = false;

  Future<void> submitOrder() async {
    setState(() {
      isLoading = true;
    });

    final request = http.MultipartRequest(
      'POST',
      Uri.parse(
          'https://wckb4f4m-3000.euw.devtunnels.ms/api/order/translation'),
    );

    request.headers.addAll({
      "Authorization": "Bearer ${await _getToken()}",
      'Connection': 'keep-alive',
    });

    request.fields['fileLanguge'] = fileLanguage ?? '';
    request.fields['methodOfDelivery'] = deliveryMethod ?? '';
    request.fields['notes'] = notes ?? '';
    request.fields['Address'] = address ?? '';
    request.fields['translationLanguges'] = jsonEncode(translationLanguages);

    for (var file in uploadedFiles) {
      if (file.path != null) {
        request.files
            .add(await http.MultipartFile.fromPath('otherDocs', file.path!));
      }
    }

    try {
      final response = await request.send();
      final result = await response.stream.bytesToString();

      setState(() {
        isLoading = false;
      });

      if (response.statusCode == 200 || response.statusCode == 201) {
        showSuccessBottomSheet(context);
      } else {
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: Text('خطأ'),
            content: Text('❌ Error: $result'),
          ),
        );
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });

      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text('مشكلة اتصال'),
          content: Text('❌ Connection error: $e'),
        ),
      );
    }
  }

  void _showLanguageDialog() async {
    final List<String> tempSelected = List.from(translationLanguages);

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text('Select Translation Languages'),
              content: SingleChildScrollView(
                child: Column(
                  children: allLanguages.map((lang) {
                    return CheckboxListTile(
                      title: Text(lang),
                      value: tempSelected.contains(lang),
                      onChanged: (selected) {
                        setDialogState(() {
                          selected == true
                              ? tempSelected.add(lang)
                              : tempSelected.remove(lang);
                        });
                      },
                    );
                  }).toList(),
                ),
              ),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text('Cancel')),
                ElevatedButton(
                  onPressed: () {
                    setState(() => translationLanguages = tempSelected);
                    Navigator.pop(context);
                  },
                  child: Text('OK'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<LocalizationProvider>(
        builder: (context, localizationProvider, child) {
      final locale = localizationProvider.locale.languageCode;
      final textDirection =
          locale == 'ar' ? TextDirection.rtl : TextDirection.ltr;

      return Directionality(
          textDirection: textDirection,
          child: Scaffold(
            backgroundColor: const Color(0xffF8F8F8),
            appBar: AppBar(
              leading: const Icon(Icons.arrow_back_ios),
              title: Text(
                  Translations.getText(
                    'tranthereq',
                    context.read<LocalizationProvider>().locale.languageCode,
                  ),
                  style: TextStyle(color: Colors.black)),
              backgroundColor: const Color(0xffF8F8F8),
              elevation: 0,
              iconTheme: const IconThemeData(color: Colors.black),
            ),
            body: SingleChildScrollView(
              padding: EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    Image.asset("assets/images/img_new.png"),
                    Text(
                      Translations.getText(
                        'newreq',
                        context
                            .read<LocalizationProvider>()
                            .locale
                            .languageCode,
                      ),
                    ),
                    Text(
                      Translations.getText(
                        'langneed',
                        context
                            .read<LocalizationProvider>()
                            .locale
                            .languageCode,
                      ),
                    ),
                    Align(
                      alignment: AlignmentDirectional.topStart,
                      child: Text(
                        Translations.getText(
                          'edjat',
                          context
                              .read<LocalizationProvider>()
                              .locale
                              .languageCode,
                        ),
                        style: TextStyle(fontWeight: FontWeight.bold),
                        textAlign: TextAlign.start,
                      ),
                    ),
                    DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        labelText: Translations.getText(
                          'chooose',
                          context
                              .read<LocalizationProvider>()
                              .locale
                              .languageCode,
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade200,
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.transparent),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.blue, width: 2),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.red),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.red, width: 2),
                        ),
                      ),
                      items: ['Arabic', 'English']
                          .map((lang) =>
                              DropdownMenuItem(value: lang, child: Text(lang)))
                          .toList(),
                      onChanged: (value) =>
                          setState(() => fileLanguage = value),
                      validator: (value) => value == null ? 'مطلوب' : null,
                    ),
                    SizedBox(height: 15),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Align(
                          alignment: AlignmentDirectional.topStart,
                          child: Text(
                            Translations.getText(
                              'attach',
                              context
                                  .read<LocalizationProvider>()
                                  .locale
                                  .languageCode,
                            ),
                            style: TextStyle(fontWeight: FontWeight.bold),
                            textAlign: TextAlign.start,
                          ),
                        ),

                        GestureDetector(
                          onTap: _showLanguageDialog,
                          child: AbsorbPointer(
                            child: DropdownButtonFormField<String>(
                              decoration: InputDecoration(
                                labelText: Translations.getText(
                                  'chooose',
                                  context
                                      .read<LocalizationProvider>()
                                      .locale
                                      .languageCode,
                                ),
                                filled: true,
                                fillColor: Colors.grey.shade200,
                                contentPadding: EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 14),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide:
                                      BorderSide(color: Colors.transparent),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide:
                                      BorderSide(color: Colors.blue, width: 2),
                                ),
                                errorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(color: Colors.red),
                                ),
                                focusedErrorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide:
                                      BorderSide(color: Colors.red, width: 2),
                                ),
                              ),
                              value: null,
                              // hint: Text("اضغط لاختيار اللغة"),
                              items: [],

                              onChanged: null,

                              validator: (value) =>
                                  translationLanguages.isEmpty ? 'مطلوب' : null,
                            ),
                          ),
                        ),

                        SizedBox(height: 5),
                        // ElevatedButton(onPressed: _showLanguageDialog, child: Text("Select Languages")),
                        Wrap(
                          spacing: 6.0,
                          children: translationLanguages
                              .map((lang) => Chip(label: Text(lang)))
                              .toList(),
                        ),
                      ],
                    ),
                    SizedBox(height: 15),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          Translations.getText(
                            'addressway',
                            context
                                .read<LocalizationProvider>()
                                .locale
                                .languageCode,
                          ),
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: RadioListTile<String>(
                                title: Text('Office'),
                                value: 'Office',
                                groupValue: deliveryMethod,
                                onChanged: (value) =>
                                    setState(() => deliveryMethod = value),
                                contentPadding: EdgeInsets.zero,
                              ),
                            ),
                            Expanded(
                              child: RadioListTile<String>(
                                title: Text('Home'),
                                value: 'Home',
                                groupValue: deliveryMethod,
                                onChanged: (value) =>
                                    setState(() => deliveryMethod = value),
                                contentPadding: EdgeInsets.zero,
                              ),
                            ),
                          ],
                        ),
                        if (deliveryMethod == null)
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 16.0),
                            child: Text(
                              'Required',
                              style: TextStyle(color: Colors.red, fontSize: 12),
                            ),
                          ),
                      ],
                    ),
                    if (deliveryMethod == 'Home')
                      TextFormField(
                        decoration: InputDecoration(labelText: 'Address'),
                        onChanged: (value) => address = value,
                      ),
Padding(
  padding: const EdgeInsets.all(8.0),
  child: Align(
    alignment: Alignment.topLeft,
    child: InkWell(
    onTap: (){
      Navigator.push(context, MaterialPageRoute(builder: (context)=>SavedAddress()));
    }
    ,child: Image.asset("assets/images/img222.png")),
  ),
),

                    TextFormField(
                      maxLines: 3,
                      onChanged: (value) => notes = value,
                      decoration: InputDecoration(
                        labelText: Translations.getText(
                          'notess',
                          context
                              .read<LocalizationProvider>()
                              .locale
                              .languageCode,
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade200,
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.blue, width: 2),
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    Align(
                      alignment: AlignmentDirectional.topStart,
                      child: Text(
                        Translations.getText(
                          'attach',
                          context
                              .read<LocalizationProvider>()
                              .locale
                              .languageCode,
                        ),
                        style: TextStyle(fontWeight: FontWeight.bold),
                        textAlign: TextAlign.start,
                      ),
                    ),
                    SizedBox(
                      width: double.infinity,
                      child: Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        color: Colors.grey.shade200,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                Translations.getText(
                                  'attach2',
                                  context
                                      .read<LocalizationProvider>()
                                      .locale
                                      .languageCode,
                                ),
                                textAlign: TextAlign.right,
                                style: TextStyle(color: Colors.black),
                              ),
                            ),
                            InkWell(
                              onTap: () async {
                                final files =
                                    await openFiles(acceptedTypeGroups: [
                                  XTypeGroup(label: 'docs', extensions: [
                                    'pdf',
                                    'doc',
                                    'docx',
                                    'ppt',
                                    'pptx'
                                  ])
                                ]);
                                if (files.isNotEmpty) {
                                  setState(() => uploadedFiles = files);
                                }
                              },
                              child:
                                  Icon(Icons.file_upload, color: Colors.black),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                    Text('${uploadedFiles.length} file(s) selected'),
                    SizedBox(height: 20),
                    SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: isLoading
                              ? null
                              : () {
                                  bool isValid =
                                      _formKey.currentState!.validate();
                                  if (!isValid ||
                                      translationLanguages.isEmpty ||
                                      uploadedFiles.isEmpty) {
                                    if (translationLanguages.isEmpty) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                            content: Text(
                                                'Please select at least one translation language.')),
                                      );
                                    }
                                    if (uploadedFiles.isEmpty) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                            content: Text(
                                                'Please upload at least one document.')),
                                      );
                                    }
                                    return;
                                  }
                                  submitOrder();
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xff409EDC),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            padding: EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: isLoading
                              ? SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : Text(
                                  Translations.getText(
                                    'send_req',
                                    context
                                        .read<LocalizationProvider>()
                                        .locale
                                        .languageCode,
                                  ),
                                  style: TextStyle(color: Colors.white),
                                ),
                        ))
                  ],
                ),
              ),
            ),
          ));
    });
  }
}
