import 'dart:convert';
import 'package:engaz_app/features/chat_orders/chat_orders_screen.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../auth/register/widgets/custom_text_feild.dart';
import '../localization/change_lang.dart';
import '../orders/orders_screen.dart';
import '../printing_request/widgets/upload_button.dart';
import '../saved_order/view/saved_order.dart';
import 'package:http/http.dart' as http;
import 'dart:io';

class PrinterRequestPageWithApi extends StatefulWidget {
  const PrinterRequestPageWithApi({super.key});

  @override
  _PrinterRequestPageState createState() => _PrinterRequestPageState();
}

class _PrinterRequestPageState extends State<PrinterRequestPageWithApi> {
  final List<PlatformFile> selectedFiles = [];
  List<Map<String, dynamic>> finalizedFiles = [];
  List<Map<String, dynamic>> colorOptions = [];
  List<Map<String, dynamic>> coverOptions = [];
  List<Map<String, dynamic>> fileDetails = [];
  String? deliveryMethod;
  String? address;
  String? notes;
  String? selectedAddressId;
  String? selectedAddressName;
  String? selectedLanguage;
  String? selectedLanguage2;
  bool _isLoading = false;
  final bool _submitted = false;

  final TextEditingController _copiesController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  TextDirection getTextDirection(BuildContext context) {
    String languageCode =
        context.read<LocalizationProvider>().locale.languageCode;
    return languageCode == 'ar' ? TextDirection.rtl : TextDirection.ltr;
  }

  @override
  void initState() {
    super.initState();
    fetchDropdownData();
  }

  Future<void> pickFile() async {
    final locale = context.read<LocalizationProvider>().locale.languageCode;
    try {
      if (selectedFiles.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(Translations.getText('add_file_before', locale))),
        );
        return;
      }

      FilePickerResult? result = await FilePicker.platform.pickFiles();

      if (result != null && result.files.isNotEmpty) {
        setState(() {
          selectedFiles.add(result.files.first);
        });
      }
    } catch (e) {
      print("\u274C خطأ أثناء اختيار الملف: \$e");
    }
  }

  Future<void> fetchDropdownData() async {
    try {
      final colorResponse = await http
          .get(Uri.parse("https://backend.enjazkw.com/api/dashboard/color"));
      final coverResponse = await http
          .get(Uri.parse("https://backend.enjazkw.com/api/dashboard/cover"));

      if (colorResponse.statusCode == 200) {
        final body = jsonDecode(colorResponse.body);
        colorOptions =
            List<Map<String, dynamic>>.from(body['printingcolors'] ?? []);
      }

      if (coverResponse.statusCode == 200) {
        final body = jsonDecode(coverResponse.body);
        coverOptions =
            List<Map<String, dynamic>>.from(body['printngcover'] ?? []);
      }
    } catch (e) {
      print('❌ فشل تحميل بيانات القوائم المنسدلة: \$e');
    }
  }

  Future<void> _submitOrder() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final locale = context.read<LocalizationProvider>().locale.languageCode;

    if (finalizedFiles.isEmpty || deliveryMethod == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content:
                Text(Translations.getText('add_file_and_delivery', locale))),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('https://backend.enjazkw.com/api/order/printing'),
      );

      request.headers['Authorization'] = 'Bearer $token';

      List<Map<String, dynamic>> detailsList = [];

      for (var fileData in finalizedFiles) {
        PlatformFile file = fileData['file'];

        if (file.path != null && File(file.path!).existsSync()) {
          request.files
              .add(await http.MultipartFile.fromPath('otherDocs', file.path!));

          detailsList.add({
            "color": fileData['color'],
            "cover": fileData['cover'],
            "copies": fileData['copies'],
          });
        }
      }

      request.fields['details'] = jsonEncode(detailsList);
      request.fields['methodOfDelivery'] = deliveryMethod ?? '';
      request.fields['notes'] = _notesController.text;

      if (selectedAddressId != null) {
        request.fields['address'] = selectedAddressId!;
      }

      if (_notesController.text.isNotEmpty) {
        request.fields['notes'] = _notesController.text;
      }

      var response = await request.send();
      final responseBody = await response.stream.bytesToString();
      final locale = context.read<LocalizationProvider>().locale.languageCode;
      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(Translations.getText('send_success', locale))),
        );
        showSuccessBottomSheet(context);
      } else {
        print('🔴 خطأ في الاستجابة: $responseBody');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  '${Translations.getText('send_failed', locale)}: ${response.statusCode}')),
        );
      }
    } catch (e) {
      print("Exception while sending order: $e");
      final locale = context.read<LocalizationProvider>().locale.languageCode;
      print(' استثناء أثناء الإرسال: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                '${Translations.getText('exception_occurred', locale)}: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Widget _buildSummaryCard() {
    return Card(
      color: Colors.white,
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (finalizedFiles.isNotEmpty)
              Column(
                children: List.generate(finalizedFiles.length, (index) {
                  final file = finalizedFiles[index]['file'] as PlatformFile;
                  final color = finalizedFiles[index]['color'];
                  final cover = finalizedFiles[index]['cover'];
                  final copies = finalizedFiles[index]['copies'].toString();
                  final extension = file.extension ?? "";
                  final iconPath = getFileIcon(extension);
                  final locale =
                      context.read<LocalizationProvider>().locale.languageCode;
                  return Card(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                    color: Colors.white,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              if (color != null)
                                _buildSummaryItem(
                                    Translations.getText(
                                        'printing_color', locale),
                                    color!),
                              if (cover != null)
                                _buildSummaryItem(
                                    Translations.getText('cover_type', locale),
                                    cover!),
                              GestureDetector(
                                onTap: () => setState(
                                    () => selectedFiles.removeAt(index)),
                                child: Image.asset(
                                  "assets/images/img59.png",
                                  width: 40,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              if (copies.isNotEmpty)
                                _buildSummaryItem(
                                    Translations.getText(
                                        'copies_count', locale),
                                    copies),
                              Image.asset(iconPath, width: 40, height: 40),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ),
          ],
        ),
      ),
    );
  }

  Future<List<AddressModel>> fetchAddresses() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    final response = await http.get(
      Uri.parse('https://backend.enjazkw.com/api/address'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return List<AddressModel>.from(
          data['addresses'].map((e) => AddressModel.fromJson(e)));
    } else {
      throw Exception('Failed to load addresses');
    }
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
                  child: /*OutlinedButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => HomePage()));
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
                 */
                      OutlinedButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => OrderChatScreen()));
                    },
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Color(0xff409EDC)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      Translations.getText('orderChat', langCode),
                      style: TextStyle(color: Color(0xff409EDC)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => OrdersScreen()));
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

  Widget _buildSummaryItem(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        children: [
          Text(title, style: const TextStyle(color: Color(0xffB3B3B3))),
          Text(value,
              style: const TextStyle(
                  fontWeight: FontWeight.bold, color: Color(0xff409EDC))),
        ],
      ),
    );
  }

  Widget _buildDropdown(String label, List<String> options, String? value,
      Function(String?) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Container(
          width: 343,
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              icon: const Icon(Icons.keyboard_arrow_down),
              items: options
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: onChanged,
              hint: Text('$label'),
              focusColor: Colors.white,
            ),
          ),
        ),
      ],
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
            title: Center(
              child: Text(
                  Translations.getText(
                    'tranorder3',
                    context.read<LocalizationProvider>().locale.languageCode,
                  ),
                  style: TextStyle(color: Colors.black)),
            ),
            backgroundColor: const Color(0xffF8F8F8),
            automaticallyImplyLeading: false,
            elevation: 0,
            iconTheme: const IconThemeData(color: Colors.black),
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Image.asset('assets/images/img56.png', height: 100),
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: Text(
                        Translations.getText(
                          'nn',
                          context
                              .read<LocalizationProvider>()
                              .locale
                              .languageCode,
                        ),
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(height: 4),
                  Center(
                    child: Text(
                      Translations.getText(
                        'please',
                        context
                            .read<LocalizationProvider>()
                            .locale
                            .languageCode,
                      ),
                      style: TextStyle(fontSize: 14, color: Color(0xffB3B3B3)),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                      Translations.getText(
                        'att',
                        context
                            .read<LocalizationProvider>()
                            .locale
                            .languageCode,
                      ),
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  UploadButton(
                    onPressed: () {
                      pickFile();
                    },
                  ),
                  const SizedBox(height: 8),
                  _buildSelectedFilesList(),
                  const SizedBox(height: 4),
                  _buildDropdown(
                    Translations.getText(
                        'cho',
                        context
                            .read<LocalizationProvider>()
                            .locale
                            .languageCode),
                    colorOptions.map((e) => e['color'].toString()).toList(),
                    selectedLanguage,
                    (value) => setState(() => selectedLanguage = value),
                  ),
                  const SizedBox(height: 16),
                  _buildDropdown(
                    Translations.getText(
                        'cho2',
                        context
                            .read<LocalizationProvider>()
                            .locale
                            .languageCode),
                    coverOptions.map((e) => e['name'].toString()).toList(),
                    selectedLanguage2,
                    (value) => setState(() => selectedLanguage2 = value),
                  ),
                  const SizedBox(height: 16),
                  Text(
                      Translations.getText(
                        'num3',
                        context
                            .read<LocalizationProvider>()
                            .locale
                            .languageCode,
                      ),
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  TextField(
                    controller: _copiesController,
                    keyboardType: TextInputType.number,
                    onChanged: (value) => setState(() {}),
                    decoration: InputDecoration(
                      hintText: Translations.getText(
                        'num4',
                        context
                            .read<LocalizationProvider>()
                            .locale
                            .languageCode,
                      ),
                      filled: true,
                      fillColor: const Color(0xffF2F2F2),
                      border: OutlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 12, horizontal: 16),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton(
                      onPressed: () {
                        if (selectedFiles.isNotEmpty &&
                            selectedLanguage != null &&
                            selectedLanguage2 != null &&
                            _copiesController.text.isNotEmpty) {
                          finalizedFiles.add({
                            "file": selectedFiles.first,
                            "color": selectedLanguage,
                            "cover": selectedLanguage2,
                            "copies": int.tryParse(_copiesController.text) ?? 1,
                          });

                          setState(() {
                            selectedFiles.clear();
                            selectedLanguage = null;
                            selectedLanguage2 = null;
                            _copiesController.clear();
                          });

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text(
                              Translations.getText(
                                'file_added_success',
                                context
                                    .read<LocalizationProvider>()
                                    .locale
                                    .languageCode,
                              ),
                            )),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text(
                              Translations.getText(
                                'fill_file_data_first',
                                context
                                    .read<LocalizationProvider>()
                                    .locale
                                    .languageCode,
                              ),
                            )),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xff409EDC),
                        shape: const CircleBorder(),
                        padding: const EdgeInsets.all(5),
                        elevation: 4,
                      ),
                      child: Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: const Icon(Icons.add,
                            size: 18, color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
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
                              title: Text(
                                Translations.getText(
                                  'office',
                                  context
                                      .read<LocalizationProvider>()
                                      .locale
                                      .languageCode,
                                ),
                              ),
                              value: 'Office',
                              activeColor: Colors.blue,
                              groupValue: deliveryMethod,
                              onChanged: (value) =>
                                  setState(() => deliveryMethod = value),
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                          Expanded(
                            child: RadioListTile<String>(
                              title: Text(Translations.getText(
                                'home_value',
                                context
                                    .read<LocalizationProvider>()
                                    .locale
                                    .languageCode,
                              )),
                              value: 'Home',
                              groupValue: deliveryMethod,
                              activeColor: Colors.blue,
                              onChanged: (value) =>
                                  setState(() => deliveryMethod = value),
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                        ],
                      ),
                      if (_submitted && deliveryMethod == null)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Text(
                            Translations.getText('choose_delivery', locale),
                            style: TextStyle(color: Colors.red, fontSize: 12),
                          ),
                        ),
                    ],
                  ),
                  if (deliveryMethod == 'Home') ...[
                    Column(
                      children: [
                        TextFormField(
                          decoration: InputDecoration(
                            labelText: Translations.getText('address', locale),
                            labelStyle: TextStyle(color: Colors.blue),
                            prefixIcon: Icon(Icons.home_outlined),
                            filled: true,
                            fillColor: Colors.grey.shade200,
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 16, vertical: 14),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: Colors.transparent),
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
                          onChanged: (value) => address = value,
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        FutureBuilder(
                          future: fetchAddresses(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return Center(
                                  child: CircularProgressIndicator(
                                color: Colors.blue,
                              ));
                            } else if (snapshot.hasError) {
                              /*return Text(Translations.getText(
                                    'fetch_error', locale));
                                 */
                              return Text('');
                            } else {
                              final addresses = snapshot.data!;
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    Translations.getText(
                                        'choose_address', locale),
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16),
                                  ),
                                  const SizedBox(height: 10),
                                  ListView.builder(
                                    shrinkWrap: true,
                                    physics: NeverScrollableScrollPhysics(),
                                    itemCount: addresses.length,
                                    itemBuilder: (context, index) {
                                      final address = addresses[index];
                                      return GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            selectedAddressId = address.id;
                                            selectedAddressName = address.name;
                                          });
                                        },
                                        child: Container(
                                          margin: const EdgeInsets.only(bottom: 12),
                                          padding: const EdgeInsets.all(12),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(12),
                                            border: Border.all(
                                              color: selectedAddressId == address.id
                                                  ? Color(0xff409EDC)
                                                  : Colors.transparent,
                                              width: 1.5,
                                            ),
                                          ),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              /// ✅ العنوان الكامل
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      '${address.name}',
                                                      style: const TextStyle(
                                                        fontWeight: FontWeight.bold,
                                                        color: Color(0xff409EDC),
                                                        fontSize: 14,
                                                      ),
                                                    ),
                                                    const SizedBox(height: 4),
                                                    Text(
                                                      '${Translations.getText('address', locale)}: ${address.address}',
                                                      style: const TextStyle(
                                                        color: Colors.black,
                                                        fontSize: 13,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),

                                              /// ✅ زر التحديد
                                              Radio<String>(
                                                value: address.id,
                                                groupValue: selectedAddressId,
                                                onChanged: (value) {
                                                  setState(() {
                                                    selectedAddressId = value!;
                                                    selectedAddressName = address.name;
                                                  });
                                                },
                                                activeColor: Color(0xff409EDC),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              );
                            }
                          },
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        Align(
                          alignment:
                              Directionality.of(context) == TextDirection.rtl
                                  ? Alignment.centerLeft
                                  : Alignment.centerRight,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => SavedAddress()));
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xff409EDC),
                              shape: const CircleBorder(),
                              padding: const EdgeInsets.all(5),
                              elevation: 4,
                            ),
                            child: Container(
                              width: 30,
                              height: 30,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border:
                                    Border.all(color: Colors.white, width: 2),
                              ),
                              child: const Icon(Icons.add,
                                  size: 18, color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),
                  ],
                  SizedBox(height: 10),
                  Theme(
                    data: Theme.of(context).copyWith(
                      textSelectionTheme: const TextSelectionThemeData(
                        cursorColor:
                            Color.fromRGBO(64, 157, 220, 1), // لون المؤشر
                        selectionColor:
                            Color.fromRGBO(64, 157, 220, 1), // لون التحديد
                        selectionHandleColor: Color.fromRGBO(64, 157, 220, 1),
                      ),
                    ),
                    child: TextFormField(
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
                        labelStyle: TextStyle(color: Colors.blue),
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
                  ),
                  SizedBox(height: 20),
                  /*Text(
                      Translations.getText(
                        'no',
                        context
                            .read<LocalizationProvider>()
                            .locale
                            .languageCode,
                      ),
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  _buildTextField(Translations.getText(
                    'en',
                    context.read<LocalizationProvider>().locale.languageCode,
                  )),
                  const SizedBox(height: 16),
                  // Card(
                  //   color: Colors.white,
                  //   child: Padding(
                  //     padding: const EdgeInsets.all(12.0),
                  //     child: Column(
                  //       children: [
                  //         const Text('قيمه الطلب',
                  //             style: TextStyle(
                  //                 fontSize: 16, fontWeight: FontWeight.bold)),
                  //         const Divider(),
                  //         _buildPriceRow('قيمه الخدمات', '70'),
                  //         const Divider(),
                  //         _buildPriceRow('الضريبه', '15'),
                  //         const Divider(),
                  //         _buildPriceRow('الاجمالي', '85', isTotal: true),
                  //       ],
                  //     ),
                  //   ),
                  // ),
                   */
                  _buildSummaryCard(),
                  const SizedBox(height: 16),
                  _buildSubmitButton(),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }

  Widget _buildTextField(String label) {
    return Container(
      width: 343,
      height: 109,
      decoration: BoxDecoration(
        color: const Color(0xFFF2F2F2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Stack(
        children: [
          Positioned(
            top: 10,
            right: 10,
            child: Text(label,
                style: const TextStyle(
                  color: Color(0xFFB3B3B3),
                  fontSize: 14,
                )),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 30),
            child: TextField(
              controller: _notesController,
              maxLines: 3,
              decoration: const InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 10),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectedFilesList() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: selectedFiles.map((file) {
          final extension = file.extension ?? "";
          final iconPath = getFileIcon(extension);

          return Stack(
            children: [
              GestureDetector(
                onTap: () => OpenFile.open(file.path),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Image.asset(iconPath, width: 60, height: 60),
                ),
              ),
              Positioned(
                top: -15,
                left: -10,
                child: IconButton(
                  icon: const Icon(Icons.close, size: 20, color: Colors.red),
                  onPressed: () => setState(() => selectedFiles.remove(file)),
                ),
              )
            ],
          );
        }).toList(),
      ),
    );
  }

  String getFileIcon(String extension) {
    switch (extension.toLowerCase()) {
      case 'pdf':
        return 'assets/images/img10.png';
      case 'doc':
      case 'docx':
        return 'assets/images/img12.png';
      case 'xls':
      case 'xlsx':
        return 'assets/images/img11.png';
      default:
        return 'assets/file.png';
    }
  }

  Widget _buildSubmitButton() {
    final locale = context.read<LocalizationProvider>().locale.languageCode;
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: () {
          if (!_isLoading) {
            _submitOrder();
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xff409EDC),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        child: _isLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : Text(Translations.getText('send_request', locale),
                style: TextStyle(fontSize: 16, color: Colors.white)),
      ),
    );
  }
}

class SaveOrder extends StatelessWidget {
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
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.white,
            title: Text(
                Translations.getText(
                  'se',
                  context.read<LocalizationProvider>().locale.languageCode,
                ),
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
            centerTitle: true,
          ),
          body: Column(
            children: [
              const SizedBox(
                height: 30,
              ),
              Directionality(
                  textDirection: getTextDirection(context),
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Align(
                      alignment: getTextAlignment(context),
                      child: Text(
                          Translations.getText(
                            'dis',
                            context
                                .read<LocalizationProvider>()
                                .locale
                                .languageCode,
                          ),
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 15)),
                    ),
                  )),
              CustomTextField(
                hintKey: 'enen',
              ),
              Card(
                color: Colors.white,
                elevation: 0,
                child: Padding(
                  padding: EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                          Translations.getText(
                            'reqv',
                            context
                                .read<LocalizationProvider>()
                                .locale
                                .languageCode,
                          ),
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                      Divider(),
                      Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                                Translations.getText(
                                  'v',
                                  context
                                      .read<LocalizationProvider>()
                                      .locale
                                      .languageCode,
                                ),
                                style: TextStyle()),
                            Text("70"),
                          ]),
                      Divider(),
                      Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                                Translations.getText(
                                  't',
                                  context
                                      .read<LocalizationProvider>()
                                      .locale
                                      .languageCode,
                                ),
                                style: TextStyle()),
                            Text("15"),
                          ]),
                      Divider(),
                      Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                                Translations.getText(
                                  'tt',
                                  context
                                      .read<LocalizationProvider>()
                                      .locale
                                      .languageCode,
                                ),
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 14)),
                            Text("85"),
                          ]),
                    ],
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => SuccessOrder()));
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xff409EDC),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 12),
                      minimumSize: const Size(164, 5),
                    ),
                    child: Text(
                      Translations.getText(
                        'p',
                        context
                            .read<LocalizationProvider>()
                            .locale
                            .languageCode,
                      ),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  OutlinedButton(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(
                      side:
                          const BorderSide(color: Color(0xFF409EDC), width: 1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 12),
                      minimumSize: const Size(164, 5),
                      foregroundColor: Colors.white,
                    ),
                    child: Text(
                      Translations.getText(
                        'rrr',
                        context
                            .read<LocalizationProvider>()
                            .locale
                            .languageCode,
                      ),
                      style: TextStyle(
                        color: Color(0xFF409EDC),
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    });
  }

  TextDirection getTextDirection(BuildContext context) {
    String languageCode =
        context.read<LocalizationProvider>().locale.languageCode;
    return languageCode == 'ar' ? TextDirection.rtl : TextDirection.ltr;
  }

  Alignment getTextAlignment(BuildContext context) {
    String languageCode =
        context.read<LocalizationProvider>().locale.languageCode;
    return languageCode == 'ar' ? Alignment.topRight : Alignment.topLeft;
  }
}

class SuccessOrder extends StatelessWidget {
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
          backgroundColor: Colors.white,
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                    Translations.getText(
                      'ordsuc',
                      context.read<LocalizationProvider>().locale.languageCode,
                    ),
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                const SizedBox(
                  height: 60,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xff409EDC),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 12),
                        minimumSize: const Size(164, 5),
                      ),
                      child: Text(
                        Translations.getText(
                          'ff',
                          context
                              .read<LocalizationProvider>()
                              .locale
                              .languageCode,
                        ),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    OutlinedButton(
                      onPressed: () {},
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(
                            color: Color(0xFF409EDC), width: 1),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 12),
                        minimumSize: const Size(164, 5),
                        foregroundColor: Colors.white,
                      ),
                      child: Text(
                        Translations.getText(
                          'nnn',
                          context
                              .read<LocalizationProvider>()
                              .locale
                              .languageCode,
                        ),
                        style: TextStyle(
                          color: Color(0xFF409EDC),
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}
