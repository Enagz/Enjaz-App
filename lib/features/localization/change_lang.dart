import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../settings/settings_screen.dart';

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
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        title: Center(
          child: Text(
            Translations.getText(
              'language',
              context.read<LocalizationProvider>().locale.languageCode,
            ),
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
                          .setLocale(const Locale('en'));
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
                          .setLocale(const Locale('ar'));
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
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => SettingsScreen()),
                  );
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
            ? const Color(0xff28C1ED)
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
  Locale _locale = const Locale('en');

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
      'enter_phone': 'Enter Phone Number',
      'enter_email': 'Enter Email Address',
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
      "enter2": "Enter Phone Number",
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
      'home':'Home',
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
      'google_success': 'Signed in with Google successfully',
      'google_error': 'Failed to sign in with Google',
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
      "select_location_or_login": "الرجاء تحديد الموقع أولاً أو تسجيل الدخول",
      "ordernumber": "order number ",
      "ordercal": "Order date ",
      "ordertime": "Order time ",
      "ordertype": "Delivery type",
      "lan1": "Language to be translated",
      "lan2": "Languages to be translated into",
      "noo": "Notes",
      "atta": "Attachments",
      "canc": "Cancel order",
      "continue_as_guest": "Continue as Guest",
      "order_success": "Congratulations! Your request has been sent successfully",
      "order_review_msg": "Your request will be reviewed and the service will be started",
      "new_service_request": "New Service",
      "follow_request": "Follow Request",
      "pleas": "Please enter the reason for cancellation.",
      "know": "Explain the reason for cancellation",
      "tra": "Retreat",
      "res": "Reason Deletion",
      "del": "Delete account",
      "do": "Do you really want to delete your account?",
      "ree": "Reason for deleting account *",
      "pl": "Please explain the reason for deletion.",
      "del2": "Delete",
      'orderChat':'Order Chat',
      "activation_title": "Activation Code",
      "enter_code_prompt": "Please enter the code sent to you:",
      "resend": "Resend",
      "user_already_verified": "User is already verified",
      "user_not_found": "User not found",
      "server_error": "Server connection failed",
      "unexpected_error": "An unexpected error occurred",
      "otp_sent_success": "A new OTP has been sent to your email",
      "something_wrong": "Something went wrong",
      "error_title": "Oops...",
      "try_again": "Try Again",
      "google_signin_failed": "Google Sign-In failed",
      "fill_all_fields": "Please fill in all required fields",
      "register_failed": "Failed to create account",
      "select_location_or_login": "Please select location or login first",
      "add_success": "Address added successfully ",
      "add_failed": "Failed to add address ",
      "add_error": "An error occurred while adding ",
      "update_success": "Address updated successfully ",
      "update_failed": "Failed to update address ",
      "update_error": "An error occurred while updating ",
      "delete_success": "Address deleted successfully ",
      "delete_failed": "Failed to delete address ",
      "delete_error": "An error occurred while deleting ",
      "address_not_found": "Address not found ",
      "chat_title": "Chat",
      "write_message_hint": "Type your message here...",
      "logout_confirm": "Are you sure you want to log out?",
      "cancel": "Cancel",
      "logout": "Log Out",
      "contactus": "Contact Us",
      "through": "Through",
      "or": "Or",
      "name": "Name",
      "name2": "Enter your name",
      "address2": "Phone number",
      "plss": "Enter your phone",
      "email": "Email",
      "email_hint": "Enter your email",
      "msst": "Message",
      "ent": "Write your message here",
      "s": "Send",
      "success": "Success",
      "error": "Error",
      "error_message": "Something went wrong. Please try again.",
      "ok": "OK",
      "try_again": "Try Again",
      'printing_color':"Printing_color",
      "do": "Do you want to delete your account?",
      "re": "Please provide a reason",
      "pl": "Reason for deleting the account",
      "tra": "Cancel",
      "del2": "Delete Account",
      "account_deleted_success": "Account deleted successfully",
      "delete_failed": "Failed to delete",
      "connection_error": "Connection error",
      "profile": "Profile",
      "first": "First Name",
      "last": "Last Name",
      "enter_first_name": "Enter first name",
      "enter_last_name": "Enter last name",
      "save": "Save",
      "error_loading_data": "Error loading data",
      "language": "App Language",
      "confirm": "Confirm",
      "change2": "Change Email",
      "new_email": "New Email Address",
      "pls2": "Please enter your new email address to continue",
      "sure": "Confirm",
      "enter_email": "Enter your email address",
      "server_error": "Failed to connect to the server",
      "unexpected_error": "An unexpected error occurred",
      "enter_required_data": "Please enetr required data",
      "phone_updated_success": "Phone number updated successfully",
      "server_connection_failed": "server_connection_failed",
      "change2": "Change Email",
      "new_email": "New Email",
      "pls2": "Enter new email",
      "sure": "Confirm",
      "email_empty": "Please enter your new email",
      "email_changed_success": "Email changed successfully",
      "unexpected_error": "Failed to change email",
      "server_error": "Server connection failed",
      "activation_title": "Activation Code",
      "choose_activation_method": "Choose how to receive the activation code to activate your account",
      "enter_code": "Enter the activation code",
      "select_method_enter_code": "Select a method and enter the code",
      "confirm": "Confirm",
      "activation_success": "Activation successful",
      "invalid_code": "Invalid code",
      "server_error": "Failed to connect to server",
      "notifications": "Notifications",
      "no_notifications": "No notifications available",
      "error_occurred": "An error occurred",
      "no_data": "No data available",
      "file": "File",
      "something_wrong": "Something went wrong",
      "error": "An error occurred",
      "noorders": "No orders available",
      "language": "Language",
      "attachmentscount": "Attachments Count",
      "add_before_upload": "You must press the add button before uploading a new file",
      "fill_file_data_first": "Please fill in the file data before adding",
      "print_color": "Print Color",
      "cover_type": "Cover Type",
      "copies_count": "Number of Copies",
      "required_field": "Required",
      "address_label": "Address",
      "order_value": "Order Value",
      "services_value": "Services Value",
      "tax": "Tax",
      "total": "Total",
      "send_order": "Send Order",
      "submit_error": "An error occurred while submitting",
      "server_error_with_status": "Error",
      "file_added_success": "File added successfully, you can upload another",
      "fill_file_data_first": "Please fill in the file data before adding",
      "office": "Office",
      "pol": "Privacy Policy",
      "privacy_load_error": "An error occurred while loading the privacy policy",
      "term": "Terms and Conditions",
      "terms_load_error": "Failed to load terms and conditions.",
      "terms_fetch_exception": "An error occurred while connecting to the server",
      "use": "Usage Policy",
      "usage_load_error": "Failed to load usage policy",
      "usage_fetch_exception": "An error occurred while connecting to the server",
      "support_title": "Customer Support",
      "support_hint": "Your message...",
      "oops": "Oops!",
      "please_login_msg": "Please log in first to access the app services",
      "cancel": "Cancel",
      "login": "Log In",
      "home_": "Home",
      "categories": "Categories",
      "translation_title": "Translation",
      "translation_desc": "We offer top-quality translation services in over 10 languages worldwide",
      "printing_title": "Printing",
      "printing_desc": "We provide the best printing quality at competitive prices",
      "more": "More",
      "general_settings": "General Settings",
      "contact_us": "Contact Us",
      "usage_policy": "Usage Policy",
      "terms_conditions": "Terms & Conditions",
      "privacy_policy": "Privacy Policy",
      "login": "Log In",
      "follow_us": "Follow us on",
  "please_add_files": "Please add the files to be printed",
      "orders": "Orders",
      "more": "More",
      "error_title": "Error",
      'home_value':'Home',
      "error_msg": "An error occurred",
      "connection_title": "Connection Issue",
      "connection_error": "Connection error",
      "cancel": "Cancel",
      "ok": "OK",
      "required": "Required",
      "office": "Office",
      "address": "Address",
      "files_selected": "File(s) selected",
      "select_language_error": "Please select at least one translation language.",
      "upload_file_error": "Please upload at least one document.",
      "saved_address": "Saved Addresses",
      "choose": "Choose the delivery address",
      "dilvery": "Deliver to this address",
      "delivery_to": "Delivery selected to",
      "add_to_address": "Add New Address",
      "location": "Location",
      "orders_failed": "Failed to load orders",
      'send_request':"Send Request",
      "enter_phone_register": "Enter phone number",
      "enter_email_register": "Enter email address",
    },
    'ar': {
  "enter_phone_register": "أدخل رقم هاتفك",
  "enter_email_register": "أدخل بريدك الإلكتروني",
  "saved_address": "العناوين المحفوظة",
  "enter_phone": "يرجى إدخال رقم الجوال",
      'home':'المنزل',
      "orders_failed": "فشل في تحميل الطلبات",
      "choose": "اختر العنوان للتوصيل",
  "dilvery": "التوصيل لهذا العنوان",
  "delivery_to": "تم اختيار التوصيل إلى",
  "add_to_address": "إضافة عنوان جديد",
  "location": "الموقع",
  "error_title": "خطأ",
  "error_msg": "حدث خطأ",
  "connection_title": "مشكلة اتصال",
  "connection_error": "خطأ في الاتصال",
  "cancel": "إلغاء",
  "ok": "موافق",
  "required": "مطلوب",
  "office": "المكتب",
  "address": "العنوان",
      "home_value":"المنزل",
  'printing_color':"لون الطباعه",
      'send_request':"طلب طباعه",
  "files_selected": "ملف/ملفات مرفوعة",
  "select_language_error": "يرجى اختيار لغة ترجمة واحدة على الأقل.",
  "upload_file_error": "يرجى رفع ملف واحد على الأقل.",
  "home_": "الرئيسيه",
  "orders": "الطلبات",
  "more": "المزيد",
  "more": "المزيد",
  "general_settings": "الإعدادات العامة",
  "please_add_files": "الرجاء إضافة المرفقات المراد طباعتها",
  "contact_us": "اتصل بنا",
  "usage_policy": "سياسة الاستخدام",
  "terms_conditions": "الشروط والأحكام",
  "privacy_policy": "سياسة الخصوصية",
  "login": "تسجيل الدخول",
  "follow_us": "تابعنا على",
  "categories": "الفئات",
  "translation_title": "الترجمة",
  "translation_desc": "نقدم خدمات ترجمة عالية الجودة بأكثر من 10 لغات حول العالم",
  "printing_title": "الطباعة",
  "printing_desc": "نوفر أفضل جودة طباعة بأسعار تنافسية",
  "oops": "تنبيه!",
  "please_login_msg": "يرجى تسجيل الدخول أولاً للوصول إلى خدمات التطبيق",
  "cancel": "إلغاء",
  "login": "تسجيل الدخول",
  "add_before_upload": "يجب الضغط على زر الإضافة قبل رفع ملف جديد",
  "fill_file_data_first": "يرجى ملء بيانات الملف قبل الإضافة",
  "use": "شروط الاستخدام",
  "usage_load_error": "فشل تحميل شروط الاستخدام",
  "usage_fetch_exception": "حدث خطأ أثناء الاتصال بالخادم",
      "support_title": "خدمة العملاء",
      "support_hint": "رسالتك...",
  "print_color": "لون الطباعة",
  "cover_type": "نوع التغليف",
  "pol": "سياسة الخصوصية",
  "privacy_load_error": "حدث خطأ أثناء تحميل سياسة الخصوصية",
  "term": "الشروط والأحكام",
  "terms_load_error": "فشل تحميل الشروط والأحكام.",
  "terms_fetch_exception": "حدث خطأ أثناء الاتصال بالسيرفر",
  "copies_count": "عدد النسخ",
  "required_field": "مطلوب",
  "address_label": "العنوان",
  "order_value": "قيمة الطلب",
  "services_value": "قيمة الخدمات",
  "tax": "الضريبة",
  "total": "الإجمالي",
  "office": "المكتب",
  "send_order": "إرسال الطلب",
  "submit_error": "حدث خطأ أثناء الإرسال",
  "server_error_with_status": "خطأ",
  "error": "حدث خطأ",
  "file_added_success": "تمت إضافة الملف، يمكنك رفع ملف جديد",
  "fill_file_data_first": "يرجى ملء بيانات الملف قبل الإضافة",
  "noorders": "لا يوجد طلبات",
  "language": "اللغة",
  "attachmentscount": "عدد المرفقات",
  "notifications": "الإشعارات",
  "error_occurred": "حدث خطأ",
  "no_data": "لا توجد بيانات",
  "file": "ملف",
  "something_wrong": "حدث خطأ غير متوقع",
  "no_notifications": "لا يوجد إشعارات",
  "activation_title": "رمز التفعيل",
  "choose_activation_method": "اختر وسيلة استلام رمز التفعيل الخاص بك لتفعيل حسابك",
  "enter_code": "ادخل رمز التفعيل",
  "select_method_enter_code": "اختر وسيلة وأدخل الرمز",
  "confirm": "تأكيد",
  "activation_success": "تم التفعيل بنجاح",
  "invalid_code": "رمز غير صالح",
  "server_error": "فشل الاتصال بالخادم",
      "ac": "تأكيد الحساب",
  "logout_confirm": "هل حقاً تريد تسجيل الخروج؟",
  "cancel": "تراجع",
  "logout": "تسجيل الخروج",
  "contactus": "تواصل معنا",
  "through": "من خلال",
  "or": "أو",
  "enter_required_data": "يرجى إدخال البيانات المطلوبة",
  "phone_updated_success": "تم تحديث رقم الهاتف بنجاح",
  "server_connection_failed": "فشل الاتصال بالخادم",
  "name": "الاسم",
  "name2": "ادخل اسمك",
  "address2": "رقم الهاتف",
  "plss": "ادخل رقم الهاتف",
  "email": "البريد الإلكتروني",
  "change2": "تغيير البريد الالكتروني",
  "new_email": "البريد الالكتروني الجديد",
  "pls2": "ادخل البريد الإلكتروني الجديد",
  "sure": "تأكيد",
  "email_empty": "يرجى إدخال البريد الإلكتروني الجديد",
  "email_changed_success": "تم تغيير البريد الإلكتروني بنجاح",
  "unexpected_error": "فشل في تغيير البريد الإلكتروني",
  "server_error": "فشل الاتصال بالخادم",
  "email_hint": "ادخل البريد الإلكتروني",
  "language": "لغة التطبيق",
  "confirm": "تأكيد",
  "change2": "تغيير البريد الإلكتروني",
  "new_email": "بريد إلكتروني جديد",
  "pls2": "يرجى إدخال بريد إلكتروني جديد لتأكيد التغيير",
  "sure": "تأكيد",
  "enter_email": "ادخل البريد الإلكتروني",
  "server_error": "فشل الاتصال بالخادم",
  "unexpected_error": "حدث خطأ غير متوقع",
  "msst": "رسالتك",
  "ent": "اكتب رسالتك هنا",
  "general": "الإعدادات العامة",
  "change": "تغيير رقم الهاتف",
  "change2": "تغيير البريد الإلكتروني",
  "change3": "تغيير اللغة",
  "make": "تفعيل الإشعارات",
  "delete": "حذف الحساب",
  "general": "General Settings",
  "change": "Change Phone Number",
  "change2": "Change Email",
  "change3": "Change Language",
  "make": "Enable Notifications",
  "delete": "Delete Account",
  "s": "إرسال",
  "success": "تم بنجاح",
  "error": "فشل",
  "error_message": "حدث خطأ ما. حاول مرة أخرى.",
  "ok": "حسناً",
  "try_again": "أعد المحاولة",
  "google_signin_failed": "فشل تسجيل الدخول باستخدام جوجل",
  "error_title": "خطأ",
  "try_again": "حاول مرة أخرى",
  "user_not_found": "المستخدم غير موجود",
  "server_error": "تعذر الاتصال بالخادم",
  "something_wrong": "حدث خطأ ما",
      "pleasss": "يرجى إدخال رمز التحقق",
      "su": "تحقق",
  "activation_title": "رمز التفعيل",
  "enter_code_prompt": ": الرجاء إدخال رمز التفعيل المرسل",
  "chat_title": "المحادثة",
  "write_message_hint": "اكتب رسالتك هنا...",
  "confirm": "تأكيد",
  "didnt": "لم يصلك رمز التفعيل؟ ",
  "resend": "أعد الإرسال",
  "user_already_verified": "المستخدم مفعل بالفعل",
  "unexpected_error": "حدث خطأ غير متوقع",
  "otp_sent_success": "تم إرسال رمز جديد إلى الإيميل",
  "reee": "إعادة الإرسال",
      'login': 'تسجيل الدخول',
  "select_location_or_login": "الرجاء تحديد الموقع أولاً أو تسجيل الدخول",
  "add_success": "تمت الإضافة بنجاح ",
  "add_failed": "فشل في الإضافة ",
  "add_error": "حدث خطأ أثناء الإضافة",
  "update_success": "تم التعديل بنجاح",
  "update_failed": "فشل في التعديل",
  "update_error": "حدث خطأ أثناء التعديل",
  "delete_success": "تم حذف العنوان بنجاح ",
  "delete_failed": "فشل في حذف العنوان",
  "delete_error": "حدث خطأ أثناء الحذف",
  "address_not_found": "لم يتم العثور على العنوان",
      'choose_method': 'الرجاء اختيار وسيلة تسجيل الدخول المناسبة لك',
      'email': 'البريد الإلكتروني',
      'phone': 'رقم الجوال',
      'guest': 'الاستمرار كزائر',
      'google_login': 'تسجيل الدخول بجوجل',
      'no_account': 'لا املك حساب؟',
      'signup': 'تسجيل جديد',
      'google_success': 'تم تسجيل الدخول بجوجل',
      'google_error': ' فشل تسجيل الدخول بجوجل',
      "appTitle": "تطبيقي",
      "language": "لغة التطبيق",
      "arabic": "اللغة العربية",
  "fill_all_fields": "يرجى إدخال كافة البيانات بشكل صحيح",
  "register_failed": "فشل في إنشاء الحساب",
      "english": "الإنجليزية",
     "select_location_or_login": "Please select location first or login",
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
      "do": "هل تريد حذف الحساب؟",
      "re": "يرجى توضيح السبب",
      "pl": "سبب حذف الحساب",
      "tra": "تراجع",
      "del2": "حذف الحساب",
      "account_deleted_success": "تم حذف الحساب بنجاح",
      "delete_failed": "فشل الحذف",
      "connection_error": "خطأ في الاتصال",
      'logout': 'تسجيل الخروج',
      'more': 'المزيد',
  "profile": "الملف الشخصي",
  "first": "الاسم الأول",
  "last": "اسم العائلة",
  "enter_first_name": "ادخل الاسم الأول",
  "enter_last_name": "ادخل اسم العائلة",
  "save": "حفظ",
  "error_loading_data": "حدث خطأ أثناء تحميل البيانات",
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
      "attach2": "الرجاء ارفاق المرفقات المراد ترجمتها",
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
  "order_success": "تهانينا ! تم ارسال طلبك بنجاح",
  "order_review_msg": "سوف يتم مراجعة طلبك من قبلنا و البدء في تنفيذ الخدمة",
  "new_service_request": "طلب خدمة جديدة",
  "follow_request": "متابعة الطلب",
      'orderChat':'المحادثه',
      "continue_as_guest": "الاستمرار كزائر"
    },
  };

  static String getText(String key, String langCode) {
    return translations[langCode]?[key] ?? key;
  }
}
