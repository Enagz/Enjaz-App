import 'package:flutter/material.dart';
import '../../forgetPassword/view/otp_screen2.dart';
import '../model/register_model.dart';
import '../services/register_services.dart';

enum RegisterState { idle, loading, success, error }

class RegisterViewModel extends ChangeNotifier {
  final SignUpService _signUpService = SignUpService();

  String _firstName = '';
  String _lastName = '';
  String _phone = '';
  String _countryCode = '+20';
  String _email = '';

  RegisterState _registerState = RegisterState.idle;

  RegisterState get registerState => _registerState;
  String get firstName => _firstName;
  String get lastName => _lastName;
  String get phone => _phone;
  String get countryCode => _countryCode;
  String get email => _email;

  void setFirstName(String value) {
    _firstName = value;
    notifyListeners();
  }

  void setLastName(String value) {
    _lastName = value;
    notifyListeners();
  }

  void setPhone(String value) {
    _phone = value;
    notifyListeners();
  }

  void setCountryCode(String value) {
    _countryCode = value;
    notifyListeners();
  }

  void setEmail(String value) {
    _email = value;
    notifyListeners();
  }

  Future<Map<String, dynamic>> registerUser(BuildContext context) async {
    _registerState = RegisterState.loading;
    notifyListeners();

    final model = SignUpModel(
      firstName: _firstName,
      lastName: _lastName,
      phone: _phone,
      countryCode: _countryCode,
      email: _email,
    );

    final result = await _signUpService.signUp(context, model);

    _registerState = result['success'] ? RegisterState.success : RegisterState.error;
    notifyListeners();

    return result;
  }

  void reset() {
    _firstName = '';
    _lastName = '';
    _phone = '';
    _countryCode = '+20';
    _email = '';
    _registerState = RegisterState.idle;
    notifyListeners();
  }
}
