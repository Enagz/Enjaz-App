import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../localization/change_lang.dart';

class AddAddressViewModel extends ChangeNotifier {
  TextEditingController locationController = TextEditingController();
  bool isLoading = false;
  LatLng selectedPosition = LatLng(24.7136, 46.6753);

  Future<void> getAddressFromLatLng(LatLng position) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;
        String address =
            "${place.name ?? ''}, ${place.street ?? ''}, ${place.locality ?? ''}, ${place.country ?? ''}";
        locationController.text = address;
      } else {
        locationController.text = "موقع غير معروف";
      }
      notifyListeners();
    } catch (e) {
      locationController.text = "موقع غير معروف";
      notifyListeners();
    }
  }

  Future<String?> _getToken() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<void> addAddress(BuildContext context) async {
    isLoading = true;
    notifyListeners();

    final langCode = Localizations.localeOf(context).languageCode;
    final token = await _getToken();
    if (locationController.text.trim().isEmpty || token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            Translations.getText('select_location_or_login', langCode),
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              fontFamily: 'IBM_Plex_Sans_Arabic',
            ),
          ),
        ),
      );
      isLoading = false;
      notifyListeners();
      return;
    }

    final url = 'https://backend.enjazkw.com/api/address';
    final headers = {
      "Content-Type": "application/json",
      "Authorization": "Bearer $token",
    };

    final Map<String, dynamic> requestBody = {
      "name": locationController.text.substring(0, 10),
      "address": locationController.text,
      "location": locationController.text,
    };

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: json.encode(requestBody),
      );

      final langCode = Localizations.localeOf(context).languageCode;

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseBody = json.decode(response.body);
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('address_id', responseBody['data']['id']);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(Translations.getText('add_success', langCode)),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(Translations.getText('add_failed', langCode)),
          ),
        );
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(Translations.getText('add_error', langCode)),
        ),
      );
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateAddress(BuildContext context) async {
    isLoading = true;
    notifyListeners();

    final langCode = Localizations.localeOf(context).languageCode;
    final prefs = await SharedPreferences.getInstance();
    String? addressId = prefs.getString('addressId');
    String? token = prefs.getString('token');

    if (addressId == null || token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(Translations.getText('address_not_found', langCode)),
        ),
      );
      isLoading = false;
      notifyListeners();
      return;
    }

    final url = 'https://backend.enjazkw.com/api/address/$addressId';
    final headers = {
      "Content-Type": "application/json",
      "Authorization": "Bearer $token",
    };

    final Map<String, dynamic> requestBody = {
      "name": "Home",
      "address": locationController.text,
      "location": locationController.text.isNotEmpty
          ? locationController.text
          : null,
    };

    try {
      final response = await http.put(
        Uri.parse(url),
        headers: headers,
        body: json.encode(requestBody),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(Translations.getText('update_success', langCode)),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(Translations.getText('update_failed', langCode)),
          ),
        );
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(Translations.getText('update_error', langCode)),
        ),
      );
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteAddress(BuildContext context) async {
    isLoading = true;
    notifyListeners();

    final langCode = Localizations.localeOf(context).languageCode;
    final prefs = await SharedPreferences.getInstance();
    String? addressId = prefs.getString('addressId');

    if (addressId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(Translations.getText('address_not_found', langCode)),
        ),
      );
      isLoading = false;
      notifyListeners();
      return;
    }

    final url = 'https://backend.enjazkw.com/api/address/$addressId';
    final headers = {
      "Content-Type": "application/json",
      "Authorization": "Bearer ${await _getToken()}",
    };

    try {
      final response = await http.delete(
        Uri.parse(url),
        headers: headers,
      );

      if (response.statusCode == 200) {
        await prefs.remove('address_id');
        locationController.clear();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(Translations.getText('delete_success', langCode)),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(Translations.getText('delete_failed', langCode)),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(Translations.getText('delete_error', langCode)),
        ),
      );
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
