import 'package:flutter/material.dart';
import '../../auth/login/view/login_screen.dart';

class LoginRequiredDialog extends StatelessWidget {
  const LoginRequiredDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'عفواً !',
            textAlign: TextAlign.right,
            style: TextStyle(
              fontFamily: 'IBMPlexSansArabic',
              fontWeight: FontWeight.w600, // 600 = semi-bold
              fontSize: 25,
              height: 1.0, // 100% line height
              letterSpacing: 0.0,
            ),
          ),
          const Icon(Icons.warning_amber_rounded, size: 70, color: Colors.red),
          const SizedBox(height: 10),
          const Text(
            'الرجاء تسجيل الدخول أولاً للوصول إلى خدمات التطبيق',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'IBMPlexSansArabic',
              fontWeight: FontWeight.w600, // 600 = semi-bold
              fontSize: 16,
              height: 1.0, // 100% line height
              letterSpacing: 0.0,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('تراجع',style: TextStyle(
                    fontFamily: 'IBMPlexSansArabic',
                    fontWeight: FontWeight.w600, // 600 = semi-bold
                    fontSize: 15,
                    height: 1.0, // 100% line height
                    letterSpacing: 0.0,
                    color: Colors.black
                  ),),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const LoginScreen()),
                    );
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                  child: const Text('تسجيل الدخول',style: TextStyle(
                      fontFamily: 'IBMPlexSansArabic',
                      fontWeight: FontWeight.w600,
                      fontSize: 11.9,
                      height: 1.0,
                      letterSpacing: 0.0,
                      color: Colors.white
                  ),),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
