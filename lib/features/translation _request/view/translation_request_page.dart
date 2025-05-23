import 'dart:convert';
import 'package:engaz_app/features/chat_orders/chat_orders_screen.dart';
import 'package:engaz_app/features/orders/orders_screen.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../localization/change_lang.dart';
import '../../saved_order/view/saved_order.dart';

class TranslationOrderApp extends StatelessWidget {
  const TranslationOrderApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: TranslationOrderForm(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class TranslationOrderForm extends StatefulWidget {
  const TranslationOrderForm({super.key});

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
  bool _submitted = false;
  String? selectedAddressName;
  String? selectedAddressId;

  final List<String> allLanguages = ['Arabic', 'English', 'French', 'Dutch'];

  Future<String?> _getToken() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
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

  bool isLoading = false;

  Future<void> submitOrder() async {
    setState(() {
      isLoading = true;
    });

    final request = http.MultipartRequest(
      'POST',
      Uri.parse('https://backend.enjazkw.com/api/order/translation'),
    );

    request.headers.addAll({
      "Authorization": "Bearer ${await _getToken()}",
      'Connection': 'keep-alive',
    });

    request.fields['fileLanguge'] = fileLanguage ?? '';
    request.fields['methodOfDelivery'] = deliveryMethod ?? '';
    request.fields['notes'] = notes ?? '';
    request.fields['addressId'] = selectedAddressId ?? '';
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
        final locale = context.read<LocalizationProvider>().locale.languageCode;
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: Text(Translations.getText('error_title', locale)),
            content:
                Text('${Translations.getText('error_msg', locale)}: $result'),
          ),
        );
      }
    } catch (e) {
      print(e);
      setState(() {
        isLoading = false;
      });
      final locale = context.read<LocalizationProvider>().locale.languageCode;
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text(Translations.getText('connection_title', locale)),
          content:
              Text('${Translations.getText('connection_error', locale)}: $e'),
        ),
      );
    }
  }

  void _showLanguageDialog() async {
    final List<String> tempSelected = List.from(translationLanguages);
    final locale = context.read<LocalizationProvider>().locale.languageCode;
    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              title: Text(
                  Translations.getText('select_translation_languages', locale)),
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
                  child: Text(Translations.getText('cancel', locale)),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() => translationLanguages = tempSelected);
                    Navigator.pop(context);
                  },
                  child: Text(Translations.getText('ok', locale)),
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
              title: Center(
                child: Text(
                    Translations.getText(
                      'tranthereq',
                      context.read<LocalizationProvider>().locale.languageCode,
                    ),
                    style: TextStyle(color: Colors.black)),
              ),
              backgroundColor: const Color(0xffF8F8F8),
              elevation: 0,
              iconTheme: const IconThemeData(color: Colors.black),
            ),
            body: SafeArea(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      Image.asset("assets/images/img_new.png"),
                      SizedBox(height: 5),
                       Text(
                        Translations.getText(
                          'newreq',
                          context
                              .read<LocalizationProvider>()
                              .locale
                              .languageCode,
                        ),
                      ),
                      SizedBox(height: 5),
                      Text(
                        Translations.getText(
                          'langneed',
                          context
                              .read<LocalizationProvider>()
                              .locale
                              .languageCode,
                        ),
                      ),
                      SizedBox(height: 5),
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
                      SizedBox(height: 5),
                      DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                          hintText: Translations.getText(
                            'chooose',
                            context
                                .read<LocalizationProvider>()
                                .locale
                                .languageCode,
                          ),
                          filled: true,
                          fillColor: Colors.white,
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
                        validator: (value) => value == null
                            ? Translations.getText('required', locale)
                            : null,
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
                          SizedBox(height: 5),
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
                                  fillColor: Colors.white,
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
                                items: [],
                                onChanged: null,
                                validator: (value) => translationLanguages.isEmpty
                                    ? Translations.getText('required', locale)
                                    : null,
                              ),
                            ),
                          ),
                          SizedBox(height: 5),
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
                          SizedBox(height: 1),
                          Row(
                            children: [
                              Expanded(
                                child: RadioListTile<String>(
                                  title: Text(
                                      Translations.getText('office', locale)),
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
                                  title:
                                      Text(Translations.getText(
                                        'home_value',
                                        context
                                            .read<LocalizationProvider>()
                                            .locale
                                            .languageCode,
                                      )),
                                  value: 'Home',
                                  activeColor: Colors.blue,
                                  groupValue: deliveryMethod,
                                  onChanged: (value) =>
                                      setState(() => deliveryMethod = value),
                                  contentPadding: EdgeInsets.zero,
                                ),
                              ),
                            ],
                          ),
                          if (_submitted && deliveryMethod == null)
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16.0),
                              child: Text(
                                Translations.getText('required', locale),
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
                                labelText:
                                    Translations.getText('address', locale),
                                labelStyle: TextStyle(color: Colors.blue),
                                prefixIcon: Icon(Icons.home_outlined),
                                filled: true,
                                fillColor: Colors.grey.shade200,
                                contentPadding: EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 14),
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
                      Theme(
                        data: Theme.of(context).copyWith(
                          textSelectionTheme: const TextSelectionThemeData(
                            cursorColor: Color.fromRGBO(64, 157, 220, 1),
                            selectionColor: Color.fromRGBO(64, 157, 220, 1),
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
                            labelStyle: const TextStyle(color: Colors.blue),
                            filled: true,
                            fillColor: Colors.grey.shade200,
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 12, vertical: 14),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide:
                                  BorderSide(color: Colors.blue, width: 2),
                            ),
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
                      SizedBox(height: 5),
                      SizedBox(
                        width: double.infinity,
                        child: InkWell(
                          onTap: () async {
                            final files = await openFiles(acceptedTypeGroups: [
                              XTypeGroup(label: 'docs', extensions: [
                                'pdf',
                                'doc',
                                'docx',
                                'ppt',
                                'pptx'
                              ])
                            ]);
                            if (files.isNotEmpty) {
                              setState(() {
                                uploadedFiles.addAll(
                                  files.where((file) => !uploadedFiles
                                      .any((f) => f.path == file.path)),
                                );
                              });
                            }
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                            color: Colors.grey.shade200,
                            child: Row(
                              children: Directionality.of(context) == TextDirection.rtl
                                  ? [
                                Icon(Icons.file_upload, color: Colors.black),
                                const SizedBox(width: 8),
                                Flexible(
                                  child: Text(
                                    Translations.getText('attach2', context.read<LocalizationProvider>().locale.languageCode),
                                    style: TextStyle(color: Colors.black),
                                    textAlign: TextAlign.start,
                                  ),
                                ),
                              ]
                                  : [
                                Flexible(
                                  child: Text(
                                    Translations.getText('attach2', context.read<LocalizationProvider>().locale.languageCode),
                                    style: TextStyle(color: Colors.black),
                                    textAlign: TextAlign.start,
                                  ),
                                ),
                                SizedBox(
                                  width: Directionality.of(context) == TextDirection.rtl ? 88: 65,
                                ),
                                Icon(Icons.file_upload, color: Colors.black),
                              ],
                            )
                          ),
                        ),
                      ),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: uploadedFiles.map((file) {
                          final extension =
                              file.name.split('.').last.toLowerCase();
                          final isPDF = extension == 'pdf';
                          final isDOC = ['doc', 'docx'].contains(extension);
                          final isXLS = ['xls', 'xlsx'].contains(extension);
              
                          IconData icon;
                          Color color;
                          String label;
              
                          if (isPDF) {
                            icon = Icons.picture_as_pdf;
                            color = Colors.red;
                            label = 'PDF';
                          } else if (isDOC) {
                            icon = Icons.description;
                            color = Colors.blue;
                            label = 'DOC';
                          } else if (isXLS) {
                            icon = Icons.table_chart;
                            color = Colors.green;
                            label = 'XLS';
                          } else {
                            icon = Icons.insert_drive_file;
                            color = Colors.grey;
                            label = extension.toUpperCase();
                          }
              
                          return Stack(
                            children: [
                              Container(
                                width: 80,
                                height: 100,
                                padding: EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(icon, size: 36, color: color),
                                    SizedBox(height: 8),
                                    Text(label,
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              ),
                              Positioned(
                                top: 0,
                                left: 0,
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      uploadedFiles.remove(file);
                                    });
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.red,
                                      shape: BoxShape.circle,
                                    ),
                                    padding: EdgeInsets.all(4),
                                    child: Icon(Icons.close,
                                        color: Colors.white, size: 14),
                                  ),
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                      ),
                      SizedBox(height: 10),
                      Text(
                          '${uploadedFiles.length} ${Translations.getText('files_selected', locale)}'),
                      SizedBox(height: 20),
                      SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: isLoading
                                ? null
                                : () {
                                    setState(() {
                                      _submitted = true;
                                    });
                                    bool isValid =
                                        _formKey.currentState!.validate();
                                    if (!isValid ||
                                        translationLanguages.isEmpty ||
                                        uploadedFiles.isEmpty ||
                                        deliveryMethod == null) {
                                      if (translationLanguages.isEmpty) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(SnackBar(
                                          content: Text(Translations.getText(
                                              'select_language_error', locale)),
                                        ));
                                      }
                                      if (uploadedFiles.isEmpty) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            content: Text(Translations.getText(
                                                'upload_file_error', locale)),
                                          ),
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
            ),
          ));
    });
  }
}

class AddressModel {
  final String id;
  final String name;
  final String address;

  AddressModel({required this.id, required this.name, required this.address});

  factory AddressModel.fromJson(Map<String, dynamic> json) {
    return AddressModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      address: json['address'] ?? '',
    );
  }
}
