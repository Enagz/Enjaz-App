import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import '../model/register_model.dart';

class SignUpService {
  Future<Map<String, dynamic>> signUp(BuildContext context, SignUpModel signUpModel) async {
    final url = Uri.parse('https://backend.enjazkw.com/api/signup');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(signUpModel.toJson()),
      );

      final res = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {
          'success': true,
          'message': res['message'] ?? 'Register Success',
          'user': res['user'],
        };
      } else if (response.statusCode == 400) {
        return {
          'success': false,
          'message': res['error'] ?? 'Email or phone is already taken',
        };
      } else {
        QuickAlert.show(
          context: context,
          type: QuickAlertType.error,
          title: 'Oops...',
          text: 'Register Failed',
          confirmBtnText : 'Try Again',
        );
        return {'success': false, 'message': res['message'] ?? 'Register Failed'};
      }
    } catch (e) {
      debugPrint('Signup error: $e');
      QuickAlert.show(
        context: context,
        type: QuickAlertType.error,
        title: '',
        text: 'تعذر الاتصال بالخادم',
        confirmBtnText : 'حاول مجددداََ',
      );
      return {'success': false, 'message': 'تعذر الاتصال بالخادم'};
    }
  }
}
