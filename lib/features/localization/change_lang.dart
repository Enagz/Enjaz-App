import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LanguageScreen extends StatefulWidget {
  const LanguageScreen({super.key});

  @override
  State<LanguageScreen> createState() => _LanguageScreenState();
}

class _LanguageScreenState extends State<LanguageScreen> {
  bool isArabicSelected = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Image.asset("assets/images/img23.png"),
        title: Text(
          Translations.getText(
            'language',
            context.read<LocalizationProvider>().locale.languageCode,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        isArabicSelected = false;
                      });
                      context
                          .read<LocalizationProvider>()
                          .setLocale(Locale('en'));
                    },
                    child: _buildLanguageOption(
                      context,
                      Translations.getText(
                        'english',
                        context
                            .read<LocalizationProvider>()
                            .locale
                            .languageCode,
                      ),
                      'assets/images/img46.png',
                      !isArabicSelected,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        isArabicSelected = true;
                      });
                      context
                          .read<LocalizationProvider>()
                          .setLocale(Locale('ar'));
                    },
                    child: _buildLanguageOption(
                      context,
                      Translations.getText(
                        'arabic',
                        context
                            .read<LocalizationProvider>()
                            .locale
                            .languageCode,
                      ),
                      'assets/images/img47.png',
                      isArabicSelected,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xff28C1ED),
                borderRadius: BorderRadius.circular(16),
              ),
              child: ElevatedButton(
                onPressed: () {
                  String selectedLang = isArabicSelected ? "ar" : "en";
                  context
                      .read<LocalizationProvider>()
                      .setLocale(Locale(selectedLang));
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xff28C1ED),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  elevation: 0,
                ),
                child: Text(
                  Translations.getText(
                    'confirm',
                    context.read<LocalizationProvider>().locale.languageCode,
                  ),
                  style: const TextStyle(fontSize: 18),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageOption(
      BuildContext context, String label, String asset, bool selected) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: selected
            ? const Color(0xff28C1ED).withOpacity(.2)
            : const Color(0xffF2F2F2),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: selected ? const Color(0xff409EDC) : const Color(0xffF2F2F2),
          width: 2,
        ),
      ),
      child: Column(
        children: [
          Image.asset(asset, height: 40),
          const SizedBox(height: 8),
          Text(label),
        ],
      ),
    );
  }
}

class LocalizationProvider extends ChangeNotifier {
  Locale _locale = Locale('en');

  Locale get locale => _locale;

  void setLocale(Locale locale) {
    _locale = locale;
    notifyListeners();
  }
}

class Translations {
  static Map<String, Map<String, String>> translations = {
    'en': {
      'create_account': 'Create New Account',
      'fill_details': 'Please fill in the details to create your account',
      'first_name': 'First Name',
      'enter_first_name': 'Enter first name',
      'last_name': 'Last Name',
      'enter_last_name': 'Enter last name',
      'phone_number': 'Phone Number',
      'enter_phone': 'Enter phone number',
      'enter_email': 'Enter email address',
      'have_account': 'Already have an account?',
      "appTitle": "My App",
      "language": "Language",
      "confirm": "Confirm",
      "arabic": "Arabic",
      "english": "English",
      'profile': 'Profile',
      'addresses': 'Addresses',
      'general_settings': 'General Settings',
      'contact_us': 'Contact Us',
      'usage_policy': 'Usage Policy',
      'terms_and_conditions': 'Terms & Conditions',
      'privacy_policy': 'Privacy Policy',
      'logout': 'Log Out',
      'more': 'More',
      "follow": "Follow us on",
      "first": "First Name",
      "last": "Last Name",
      "save": "Save",
      "saved_address": "Saved addresses",
      "choose": "Choose one of your saved addresses.",
      "add_to_address": "Add a new address",
      "dilvery": "Delivery to this address",
      "general": "General Setting",
      "change": "Change Phone Number",
      "change2": "Change Email Address",
      "change3": "Change Application Language",
      "make": "Activate notifications",
      "delete": "Delete Account",
      "new_phone": "New Mobile Number",
      "pls":
          "Please enter the new mobile number to receive the activation code.",
      "pls2":
          "Please enter the new Email Address to receive the activation code.",
      "sure": "Save",
      "enter2": "Enter mobile number",
      "enter3": "Enter Email Address",
      "new_email": "New Email",
      "contactus": "Contact Us",
      "through": "Through",
      "or": "Or send us a message",
      "name": "Name",
      "name2": "Please Enter Name",
      "address2": "Message title",
      "plss": "Please clarify the subject of your message.",
      "msst": "Message text",
      "ent": "Enter Message Text",
      "s": "Send",
      "term": "Terms and Conditions",
      "use": "Usage policy",
      "pol": "privacy policy",
      "home": "Home",
      "offerr":
          "We provide the best translation services for more than 10 languages around the world.",
      "oferrr2": "We offer the best printing quality at competitive prices.",
      "cat": "Categories",
      "req": "Request",
      "req2": "Request Offer",
      "tran": "Translate",
      "pri": "Print",
      "new": "New",
      "current": "Current",
      "finish": "Finished",
      "expire": "Expired",
      "ord": "My Order",
      "tranorder": "Translate Request",
      "tranorder2": "Printing Request",
      "tranorder3": "Printing Request",
      "nn": "New Print Request",
      "please": "Please attach the files to be printed",
      "att": "Attachments to be printed",
      "please2": "Please add the attachments to be printed",
      "cho": " Choose the printer color",
      "cho2": "Choose the packaging type",
      "num": "Number of pages",
      "num2": "Number of pages to print",
      "num4": "Number of copies to print",
      "num3": "Number of copies",
      "no": "Notes",
      'login': 'Login',
      'choose_method': 'Please choose your preferred login method',
      'email': 'Email',
      'phone': 'Phone',
      'guest': 'Continue as Guest',
      'google_login': 'Sign in with Google',
      'no_account': "Don't have an account?",
      'signup': 'Sign Up',
      'google_success': '✅ Signed in with Google successfully',
      'google_error': '❌ Failed to sign in with Google',
      "en": "Enter your notes if any.",
      "se": "Send",
      "dis": "Discount code",
      "enen": "Enter the discount code",
      "reqv": "Request value",
      "v": "services Value",
      "t": "Tax",
      "tt": "Total",
      "p": "Payment",
      "ff": "Follow",
      "nnn": "New Request",
      "rrr": "Retreat",
      "ordsuc": "The order value has been paid successfully.",
      "editadd": "Edit Address",
      "locname": "Location Name",
      "location": "Location",
      "addadd": "Add Address",
      "savee": "Save Changes",
      "tranthereq": "Translation request",
      "newreq": "New translation request",
      "langneed": "Language to be translated",
      "edjat": "Click to select language",
      "addressway": "Method Of Delivery",
      "attach": "Attachments to be translated",
      "attach2": "Please attach the attachments ",
      "chooose": "Choose",
      "notess": "Notes",
      "send_req": "Send Request",
      "ac": "Activation code",
      "pleasss": "Please enter the activation code sent",
      "su": "Sure",
      "didnt": "Didn't receive the activation code?",
      "reee": "Resend",
      "orderdetail": "Order details",
      "ordernumber": "order number ",
      "ordercal": "Order date ",
      "ordertime": "Order time ",
      "ordertype": "Delivery type",
      "lan1": "Language to be translated",
      "lan2": "Languages to be translated into",
      "noo": "Notes",
      "atta": "Attachments",
      "canc": "Cancel order",

      "order_success": "Congratulations! Your request has been sent successfully",
      "order_review_msg": "Your request will be reviewed and the service will be started",
      "new_service_request": "New Service Request",
      "follow_request": "Follow Request",
      "pleas": "Please enter the reason for cancellation.",
      "know": "Explain the reason for cancellation",
      "tra": "Retreat",
      "res": "Reason Deletion",
      "del": "Delete account",
      "do": "Do you really want to delete your account?",
      "ree": "Reason for deleting account *",
      "pl": "Please explain the reason for deletion.",
      "del2": "Delete"
    },
    'ar': {
      'login': 'تسجيل الدخول',
      'choose_method': 'الرجاء اختيار وسيلة تسجيل الدخول المناسبة لك',
      'email': 'البريد الإلكتروني',
      'phone': 'رقم الجوال',
      'guest': 'الاستمرار كزائر',
      'google_login': 'تسجيل الدخول بجوجل',
      'no_account': 'لا املك حساب؟',
      'signup': 'تسجيل جديد',
      'google_success': '✅ تم تسجيل الدخول بجوجل',
      'google_error': '❌ فشل تسجيل الدخول بجوجل',
      "appTitle": "تطبيقي",
      "language": "لغة التطبيق",
      "confirm": "تأكيد",
      "arabic": "اللغة العربية",
      "english": "الإنجليزية",
      'create_account': 'انشاء حساب جديد',
      'fill_details': 'الرجاء ملئ البيانات التالية لانشاء حسابك',
      'first_name': 'الاسم الاول',
      'enter_first_name': 'ادخل الاسم الاول',
      'last_name': 'اسم العائله',
      'enter_last_name': 'ادخل اسم العائلة',
      'phone_number': 'رقم الجوال',
      'enter_phone': 'ادخل رقم الجوال',
      'enter_email': 'ادخل البريد الإلكتروني',
      'have_account': 'لديك حساب بالفعل؟ ',
      'profile': 'الملف الشخصي',
      'addresses': 'عناويني',
      'general_settings': 'إعدادات عامة',
      'contact_us': 'تواصل معنا',
      'usage_policy': 'سياسة الاستخدام',
      'terms_and_conditions': 'الشروط والأحكام',
      'privacy_policy': 'سياسة الخصوصية',
      'logout': 'تسجيل الخروج',
      'more': 'المزيد',
      "follow": "تابعنا عبر",
      "first": "الاسم الاول",
      "last": "اسم العائله",
      "save": "حفظ التعديلات",
      "saved_address": "العناوين المحفوظه",
      "choose": "اختر احد العناوين الخاصه بك",
      "add_to_address": "اضافه الي عنوان جديد",
      "dilvery": "التوصيل الي هذا العنوان",
      "general": "اعدادات عامه",
      "change": "تغيير رقم الجوال",
      "change2": "تغيير البريد الالكتروني",
      "change3": "تغيير لغه التطبيق",
      "make": "تفعيل الاشعارات",
      "delete": "حدف الحساب",
      "new_phone": "رقم الجوال الجديد",
      "pls": "الرجاء ادخال رقم الجوال الجديد لاستقبال رمز التفعيل",
      "sure": "تأكيد",
      "enter2": "ادخل رقم الجوال",
      "enter3": "ادخل البريد الالكتروني",
      "new_email": "البريد الالكتروني الجديد",
      "pls2": "الرجاء ادخال البريد الالكتروني الجديد لاستقبال رمز التفعيل",
      "contactus": "تواصل معنا",
      "through": "من خلال",
      "or": "او ارسل لنا رساله",
      "name": "الاسم",
      "name2": "ادخل الاسم فضلا",
      "address2": "عنوان الرساله",
      "plss": "الرجاء توضيح عنوان رسالتك",
      "msst": "نص الرساله",
      "ent": "ادخل نص الرساله",
      "s": "Send",
      "use": "سياسه الاستخدام",
      "term": "الشروط والأحكام",
      "pol": "سياسة الخصوصية",
      "home": "الرئيسيه",
      "offerr": "نقدم افضل خدماتالترجمه لاكثر من 10 لغات حول العالم ",
      "oferrr2": "نقدم افضل جوده للطباعه باسعار تنافسيه",
      "cat": "التصنيفات",
      "req": "طلباتي",
      "req2": "طلب الخدمه",
      "tran": "الترجمه",
      "pri": "الطباعه",
      "new": "جديد",
      "current": "حالي",
      "finish": "ملغي",
      "expire": "منتهي",
      "ord": "طلباتي",
      "tranorder": "طلبات ترجمه",
      "tranorder2": "طلبات طباعه",
      "tranorder3": "طلب طباعه",
      "nn": "طلب طباعه جديد",
      "please": " الرجاء ارفاق ابملفات المراد طباعتها",
      "att": " المرفقات المراد طباعتها",
      "please2": ".الرجاء اضافه المرفقات المراد طباعتها",
      "cho": " اختر لون الطابعه",
      "cho2": "اختر نوع التغليف",
      "num": " عدد الصفحات",
      "num2": " عدد الصفحات المراد طباعتها",
      "num3": "عدد النسخ",
      "num4": "عدد النسخ المراد طباعتها",
      "no": "الملاحظات",
      "en": " ادخل الملاحظات الخاصه بك ان وجدت",
      "se": "تاكيد الطلب",
      "dis": "كود الخصم",
      "enen": "ادخل كود الخصم",
      "reqv": "قيمه الطلب",
      "v": "قيمه الخدمات",
      "t": "الضريبه",
      "tt": "الاجمالي",
      "p": "الدفع",
      "ff": "متابعه الطلب",
      "nnn": "طلب خدمه جديده",
      "rrr": "تراجع",
      "ordsuc": "تم تسدسد قيمه الطلب بنجاح",
      "editadd": "تعديل العنوان",
      "locname": "اسم الموقع",
      "location": "الموقع",
      "addadd": "اضافه عنوان",
      "savee": "حفظ التعديلات",
      "tranthereq": "طلب ترجمه",
      "newreq": "طلب ترجمه جديد",
      "langneed": "الرجاء اختيار اللغه المراد ترجمتها",
      "edjat": "اضغط لاختيار اللغه",
      "addressway": "طريقه التوصيل",
      "attach": "المرفقات المراد ترجمتها",
      "attach2": "الرجاء ارفاق المرفقات المراد ترجتها",
      "chooose": "اختر",
      "notess": "الملاحظات",
      "send_req": "ارسال الطلب",
      "orderdetail": "تفاصيل الطلب",
      "ordernumber": "رقم الطلب ",
      "ordercal": "تاريخ الطلب ",
      "ordertime": "وقت الطلب ",
      "ordertype": "نوع التوصيل",
      "lan1": "اللغة المراد ترجمتها",
      "lan2": "اللغات المراد الترجمة إليها:",
      "noo": "ملاحظات",
      "atta": "المرفقات",
      "canc": "الغاء الطلب",
      "res": "سبب الالغاء",
      "pleas": "من فضلك أدخل سبب الإلغاء",
      "know": "توضيح سبب الالغاء",
      "tra": "تراجع",
      "del": "حذف الحساب",
      "do": "هل حقاً تريد حذف حسابك؟",
      "re": "سبب حذف الحساب *",
      "pl": "الرجاء توضيح سبب الحذف",
      "del2": "حذف",
      "ac": "رمز التفعيل",
      "pleasss": "الرجاء ادخال رمز التفعيل المرسل:",
      "su": "تأكيد",
      "didnt": "لم يصلك رمز التفعيل؟",
      "reee": "اعد الارسال",
  "order_success": "تهانينا ! تم ارسال طلبك بنجاح",
  "order_review_msg": "سوف يتم مراجعة طلبك من قبلنا و البدء في تنفيذ الخدمة",
  "new_service_request": "طلب خدمة جديدة",
  "follow_request": "متابعة الطلب",
    },
  };

  static String getText(String key, String langCode) {
    return translations[langCode]?[key] ?? key;
  }
}
