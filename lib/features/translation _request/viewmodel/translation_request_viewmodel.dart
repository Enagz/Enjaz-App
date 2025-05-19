import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;

class ApiService {
  static const String _baseUrl = 'https://backend.enjazkw.com/api';

  static Future<bool> submitTranslationRequest({
    required String fileLanguage,
    required String translationLanguage,
    required String notes,
    required String deliveryMethod,
    String? address,
    required List<PlatformFile> files,
    required String token,
  }) async {
    final uri = Uri.parse('$_baseUrl/order/translation');

    try {
      var request = http.MultipartRequest('POST', uri);

      request.headers['Authorization'] = 'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOiI2YWJkMWIzNi0xZGQxLTQ2MDktYTE2NC1kZTg5YmM1YWYwMWQiLCJ1c2VybmFtZSI6IkJhc3NlbCBTYWxsYW0iLCJlbWFpbCI6ImJhc3NlbGEuc2FsYW1AZ21haWwuY29tIiwidmVyZmllZCI6dHJ1ZSwiaWF0IjoxNzQyNzY2OTkzfQ.-LuSsU2AombLwf1YUm91fNe_VmXtfIDEn9Z8h3N1PAc';
      request.headers['Accept'] = 'application/json';

      final Map<String, String> languageMap = {
        'Arabic': 'Arabic',
        'English': 'English',
        'Dutch': 'Dutch',
        'French': 'French',
        'Italian': 'Italian',
        'Japanese': 'Japanese',
      };

      request.fields['fileLanguage'] = languageMap[fileLanguage]!;
      request.fields['translationLanguges'] = jsonEncode(["English", "Dutch"]);
      request.fields['methodOfDelivery'] = _mapDeliveryMethod(deliveryMethod);
      request.fields['notes'] = notes.isNotEmpty ? notes : "";
      if (deliveryMethod == 'توصيل' && address != null) {
        request.fields['Address'] = address!;
      }

      for (var file in files) {
        if (file.path != null) {
          request.files.add(
            await http.MultipartFile.fromPath(
              'otherDocs',
              file.path!,
              filename: file.name,
            ),
          );
        }
      }

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        print('API Error: ${response.statusCode}');
        print('Response body: $responseBody');
        return false;
      }
    } catch (e) {
      print('API Exception: $e');
      return false;
    }
  }


  static String _mapDeliveryMethod(String method) {
    switch (method) {
      case 'استلام من الفرع':
        return 'branch_pickup';
      case 'توصيل':
        return 'delivery';
      case 'Office':
        return 'office';
      default:
        throw Exception('طريقة التوصيل غير صالحة: $method');
    }
  }
}