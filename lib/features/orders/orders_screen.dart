import 'package:flutter/material.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../localization/change_lang.dart';

class OrdersScreen extends StatefulWidget {
  @override
  _OrdersScreenState createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  bool isTranslationSelected = true;
  int _selectedTabIndex = 0;

  //late String userId;
   Future<List<dynamic>>? _ordersFuture;

  final Map<String, Map<String, dynamic>> statusDetails = {
    'Under Review': {
      'tab': 'جديد',
      'text': 'Under Review',
      'color': Colors.orange,
      'image': 'assets/images/img16.png',
      'apiStatus': 'new'
    },
    'In Progress': {
      'tab': 'حالي',
      'text': 'جاري التنفيذ',
      'color': Colors.blue,
      'image': 'assets/images/img16.png',
      'apiStatus': 'current'
    },
    'Completed': {
      'tab': 'منتهي',
      'text': 'مكتمل',
      'color': Colors.green,
      'image': 'assets/images/img16.png',
      'apiStatus': 'finished'
    },
    'Cancelled': {
      'tab': 'ملغي',
      'text': 'ملغى',
      'color': Colors.red,
      'image': 'assets/images/img16.png',
      'apiStatus': 'cancelled'
    },
  };

  @override
  void initState() {
    super.initState();
    _initializeData();

  }

  Future<void> _initializeData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      //userId = prefs.getString('id') ?? '';
    });
    _ordersFuture = _fetchOrders('جديد');

  }

  Future<List<dynamic>> _fetchOrders(String tabStatus) async {
    final type = isTranslationSelected ? 'translation' : 'printing';
    final statusParam = _getApiStatusForTab(tabStatus);

    final token = await _getAuthToken();
    Future<String?> _getToken() async {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      return prefs.getString('token');
    }
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');

    final response = await http.post(
      Uri.parse(
        'https://wckb4f4m-3000.euw.devtunnels.ms/api/order/$userId?type=$type&status=$statusParam',
      ),

      headers: {
        'Content-Type': 'application/json',
        "Authorization": "Bearer ${await _getToken()}",
      },
      body: jsonEncode({
        'type': type,
        'status': statusParam,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load orders: ${response.statusCode}');
    }
  }

  Future<String> _getAuthToken() async {
    return 'token';
  }

  String _getApiStatusForTab(String tabStatus) {
    return statusDetails.values
        .firstWhere((detail) => detail['tab'] == tabStatus)['apiStatus'];
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
        child: DefaultTabController(
          length: 4,
          child: Scaffold(
            backgroundColor: const Color(0xffFAFAFA),
            appBar: AppBar(
              leading: Icon(Icons.arrow_back_ios_new),
              backgroundColor: const Color(0xffFAFAFA),
              title:
                   Text( Translations.getText(
                    'ord',
                    context.read<LocalizationProvider>().locale.languageCode,
                  ), style: TextStyle(color: Colors.black)),
              elevation: 0,
              actions: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Image.asset("assets/images/img9.png"),
                )
              ],
            ),
            body: Column(
              children: [
                Container(
                  width: 360,
                  height: 56,
                  margin:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF2F2F2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      GestureDetector(
                        onTap: () => setState(() {
                          isTranslationSelected = true;
                          _ordersFuture = _fetchOrders('جديد');
                        }),
                        child: _buildTabButton(
                        Translations.getText(
                            'tranorder',
                            context.read<LocalizationProvider>().locale.languageCode,
                          ), isTranslationSelected),
                      ),
                      GestureDetector(
                        onTap: () => setState(() {
                          isTranslationSelected = false;
                          _ordersFuture = _fetchOrders('جديد');
                        }),
                        child: _buildTabButton(
                            Translations.getText(
                              'tranorder2',
                              context.read<LocalizationProvider>().locale.languageCode,
                            ), !isTranslationSelected),
                      ),
                    ],
                  ),
                ),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 10),
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xffF2F2F2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: TabBar(
                    onTap: (index) {
                      setState(() {
                        _selectedTabIndex = index;
                        _ordersFuture = _fetchOrders(_getTabStatus(index));
                      });
                    },
                    labelColor: Color(0xff409EDC),
                    unselectedLabelColor: Color(0xffB3B3B3),
                    indicatorColor: Colors.transparent,
                    tabs: [
                      Tab(
                        text: Translations.getText(
                          'new',
                          context
                              .read<LocalizationProvider>()
                              .locale
                              .languageCode,
                        ),
                      ),
                      Tab(
                        text: Translations.getText(
                          'current',
                          context
                              .read<LocalizationProvider>()
                              .locale
                              .languageCode,
                        ),
                      ),
                      Tab(
                        text: Translations.getText(
                          'finish',
                          context
                              .read<LocalizationProvider>()
                              .locale
                              .languageCode,
                        ),
                      ),
                      Tab(
                        text: Translations.getText(
                          'expire',
                          context
                              .read<LocalizationProvider>()
                              .locale
                              .languageCode,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: FutureBuilder<List<dynamic>>(
                    future: _ordersFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return Center(child: Text('حدث خطأ: ${snapshot.error}'));
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return Center(child: Text('لا يوجد طلبات'));
                      }

                      final orders = snapshot.data!;
                      return



                        ListView.builder(
                        itemCount: orders.length,
                        itemBuilder: (context, index) {
                          final order = orders[index];
                          return


                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [

                                    Text(order['createdAt']??'',),
                                    Text( '#'+ order['number'].toString()??'',style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize :20
                                    ),),

                                  ],
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(  order['delivery']??'',),

                                    Text( 'اللغه ${order['language']??''}'),


                                  ],
                                ),


                                Row(mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Text(  order['filescount'].toString()??'',),

                                    Text(":عدد المرفقات"),
                                      ],
                                ),


                                Align(
                                    alignment: Alignment.topRight,
                                    child: Text( order['status']??'',)),





                              ],
                                                        ),
                            );
                        },
                      );
                    },
                  ),
                ),

              ],
            ),
          ),
        ),
      );
    });
  }

  String _getTabStatus(int index) {
    switch (index) {
      case 0:
        return 'جديد';
      case 1:
        return 'حالي';
      case 2:
        return 'منتهي';
      case 3:
        return 'ملغي';
      default:
        return 'جديد';
    }
  }

}

Widget _buildTabButton(String text, bool isSelected) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
    decoration: BoxDecoration(
      color: isSelected ? const Color(0xff409EDC) : Colors.transparent,
      borderRadius: BorderRadius.circular(16),
    ),
    child: Text(
      text,
      style: TextStyle(
        color: isSelected ? Colors.white : Colors.black,
        fontWeight: FontWeight.bold,
      ),
    ),
  );
}

class OrderItem extends StatelessWidget {
  final String orderNumber;
  final String createdAt;
  final String language;
  final String filesCount;
  final String statusText;
  final Color statusColor;
  final String statusImage;
  final String deliveryType;
  final String orderId;

  const OrderItem({
    Key? key,
    required this.orderNumber,
    required this.createdAt,
    required this.language,
    required this.filesCount,
    required this.statusText,
    required this.statusColor,
    required this.statusImage,
    required this.deliveryType,
    required this.orderId,
  }) : super(key: key);

  String _mapDelivery(String delivery) {
    return delivery == 'Office' ? 'استلام من الفرع' : 'توصيل';
  }

  void _showOrderDetails(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('تفاصيل الطلب #$orderNumber'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailItem('الحالة', statusText),
            _buildDetailItem('تاريخ الإنشاء', createdAt),
            _buildDetailItem('طريقة التسليم', _mapDelivery(deliveryType)),
            _buildDetailItem('اللغة', language),
            _buildDetailItem('عدد المرفقات', filesCount),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('إغلاق'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text('$title: ', style: TextStyle(fontWeight: FontWeight.bold)),
          SizedBox(width: 8),
          Text(value),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Card(
        elevation: 0,
        color: Colors.white,
        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('#$orderNumber',
                      style: const TextStyle(
                          color: Color(0xff1D1D1D),
                          fontWeight: FontWeight.bold)),
                  Text(createdAt, style: const TextStyle(color: Colors.grey)),
                ],
              ),
              const SizedBox(height: 5),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Text('اللغه:',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color(0xff1D1D1D))),
                      const SizedBox(width: 5),
                      Text(language,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, color: Colors.blue)),
                    ],
                  ),
                  Text(
                    _mapDelivery(deliveryType),
                  )
                ],
              ),
              const SizedBox(height: 5),
              Row(
                children: [
                  const Text('عدد المرفقات:',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xff1D1D1D))),
                  const SizedBox(width: 5),
                  Text(filesCount,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.blue)),
                ],
              ),
              const Divider(color: Color(0xffF2F2F2)),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Image.asset(statusImage, width: 20),
                      const SizedBox(width: 5),
                      Text(statusText, style: TextStyle(color: statusColor)),
                    ],
                  ),
                  TextButton(
                    onPressed: () => _showOrderDetails(context),
                    child: Row(
                      children: [
                        Image.asset("assets/images/img17.png"),
                        const SizedBox(width: 5),
                        const Text('عرض الطلب',
                            style: TextStyle(color: Colors.blue)),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
