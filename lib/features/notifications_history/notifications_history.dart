import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../localization/change_lang.dart';

class NotificationsHistoryScreen extends StatefulWidget {
  static const String routeName = 'Notifications History';
  const NotificationsHistoryScreen({super.key});

  @override
  State<NotificationsHistoryScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsHistoryScreen> {
  List notifications = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    fetchNotifications();
  }

  Future<void> fetchNotifications() async {
    setState(() => loading = true);
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null) return;

    try {
      final url = Uri.parse("https://backend.enjazkw.com/api/coustmer/notification");
      final response = await http.get(url, headers: {'Authorization': 'Bearer $token'});
      if (response.statusCode == 200) {
        final List decoded = jsonDecode(response.body);
        setState(() {
          notifications = decoded;
          loading = false;
        });
      } else {
        setState(() => loading = false);
      }
    } catch (_) {
      setState(() => loading = false);
    }
  }

  Future<void> markNotificationAsRead(String id, int index) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null) return;
    final url = Uri.parse("https://backend.enjazkw.com/api/coustmer/notification/$id");

    try {
      final response = await http.post(url, headers: {'Authorization': 'Bearer $token'});
      if (response.statusCode == 200) {
        setState(() {
          notifications[index]['isRead'] = true;
        });
      }
    } catch (_) {}
  }

  String formatTime(String isoTime) {
    try {
      final dateTime = DateTime.parse(isoTime).toLocal();
      return "${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}";
    } catch (_) {
      return "";
    }
  }

  @override
  Widget build(BuildContext context) {
    final lang = context.read<LocalizationProvider>().locale.languageCode;
    final textDir = lang == 'ar' ? TextDirection.rtl : TextDirection.ltr;

    return Directionality(
      textDirection: textDir,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: Text(Translations.getText('notifications', lang)),
          actions: [
            IconButton(icon: const Icon(Icons.refresh), onPressed: fetchNotifications),
            const SizedBox(width: 7),
          ],
          automaticallyImplyLeading: false,
        ),
        body: loading
            ? const Center(child: CircularProgressIndicator())
            : notifications.isEmpty
            ? Center(child: Text(Translations.getText('no_notifications', lang)))
            : ListView.builder(
          itemCount: notifications.length,
          padding: const EdgeInsets.all(16),
          itemBuilder: (context, index) {
            final item = notifications[index];
            final isRead = item['isRead'] == true;

            return GestureDetector(
              onTap: () async {
                if (!isRead) await markNotificationAsRead(item['id'], index);
                final type = item['type'];
                final serviceId = item['serviceId'];

                if (type == 'Order Message' || type == 'Order Status Changed') {
                  Navigator.pushNamed(context, '/order-details', arguments: serviceId);
                } else if (type == 'Support Message') {
                  Navigator.pushNamed(context, '/support-chat');
                }
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    "إنجاز",
                    style: const TextStyle(
                      color: Color(0xFF409EDC),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 4),
                    decoration: BoxDecoration(
                      color: isRead ? const Color(0xFFF2F2F2) : const Color(0xFFDCEFFF),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      item['body'] ?? '',
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                  Text(
                    formatTime(item['createdAt']),
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}