import 'package:engaz_app/features/notifications_history/notifications_history.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../localization/change_lang.dart';
import '../order_details/order_details_page.dart';

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

    final response = await http.get(
      Uri.parse(
        'https://backend.enjazkw.com/api/order?type=$type&status=$statusParam',
      ),

      headers: {
        'Content-Type': 'application/json',
        "Authorization": "Bearer ${await _getToken()}",
      },
      // body: jsonEncode({
      //   'type': type,
      //   'status': statusParam,
      // }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      final langCode = Provider.of<LocalizationProvider>(context, listen: false).locale.languageCode;
      throw Exception(Translations.getText('orders_failed', langCode));
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
              backgroundColor: const Color(0xffFAFAFA),
              title: Text(
                  Translations.getText(
                    'ord',
                    context.read<LocalizationProvider>().locale.languageCode,
                  ),
                  style: const TextStyle(color: Colors.black)),
              elevation: 0,
              actions: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: InkWell(
                    onTap: (){
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => const NotificationsHistoryScreen()),
                      );
                    },
                      child: Image.asset("assets/images/img9.png")),
                )
              ],
            ),
            body: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
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
                                context
                                    .read<LocalizationProvider>()
                                    .locale
                                    .languageCode,
                              ),
                              isTranslationSelected),
                        ),
                        GestureDetector(
                          onTap: () => setState(() {
                            isTranslationSelected = false;
                            _ordersFuture = _fetchOrders('جديد');
                          }),
                          child: _buildTabButton(
                              Translations.getText(
                                'tranorder2',
                                context
                                    .read<LocalizationProvider>()
                                    .locale
                                    .languageCode,
                              ),
                              !isTranslationSelected),
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
                          return Center(child: CircularProgressIndicator(
                            color: Colors.blue),
                          );
                        } else if (snapshot.hasError) {
                          return Center(
                              child: Text('${Translations.getText("error", locale)}: ${snapshot.error}'));
                        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                          return Center(child: Text(Translations.getText('noorders', locale)));
                        }
                        final orders = snapshot.data!;
                        return ListView.builder(
                          itemCount: orders.length,
                          itemBuilder: (context, index) {
                            final order = orders[index];
                            return Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        order['createdAt'] ?? '',
                                      ),
                                      Text(
                                        '#' + order['number'].toString() ?? '',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 20),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        order['delivery'] ?? '',
                                      ),
                                      Text('${Translations.getText("language", locale)} ${order['language'] ?? ''}'),
                                    ],
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Text(
                                        order['filescount'].toString() ?? '',
                                      ),
                                      Text('${Translations.getText("attachmentscount", locale)}:')
                                    ],
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      GestureDetector(
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  OrderDetailsPage(
                                                orderNumber:
                                                    order['number'].toString(),
                                              ),
                                            ),
                                          );
                                        },
                                        child: Image.asset(
                                            "assets/images/img17.png"),
                                      ),
                                      Align(
                                          alignment: Alignment.topRight,
                                          child: Text(
                                            order['status'] ?? '',
                                          )),
                                    ],
                                  ),
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
