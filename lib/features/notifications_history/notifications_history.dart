import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

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
    print("📲 [NotificationsScreen] opened");
    fetchNotifications();
  }

  Future<void> fetchNotifications() async {
    print("📥 [fetchNotifications] called");
    setState(() => loading = true);

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    print("🔐 [Token]: $token");

    if (token == null) {
      print("❌ [fetchNotifications] No token found.");
      setState(() => loading = false);
      return;
    }

    try {
      final url = Uri.parse("https://wckb4f4m-3000.euw.devtunnels.ms/api/coustmer/notification");
      final response = await http.get(url, headers: {
        'Authorization': 'Bearer $token',
      });

      print("🌐 [Request] URL: $url");
      print("📡 [Response] Status Code: ${response.statusCode}");
      print("📦 [Response] Body: ${response.body}");

      if (response.statusCode == 200) {
        final List decoded = jsonDecode(response.body);
        print("✅ [Success] Notifications count: ${decoded.length}");

        setState(() {
          notifications = decoded;
          loading = false;
        });
      } else {
        print("❌ [Error] Status: ${response.statusCode}, Body: ${response.body}");
        setState(() => loading = false);
      }
    } catch (e) {
      print("❌ [Exception] $e");
      setState(() => loading = false);
    }
  }

  IconData getIcon(String? type) {
    switch (type) {
      case 'Order Message':
        return Icons.message;
      case 'Order Status Changed':
        return Icons.update;
      case 'Support Message':
        return Icons.support_agent;
      default:
        return Icons.notifications;
    }
  }

  Future<void> markNotificationAsRead(String id, int index) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null) return;

    final url = Uri.parse("https://wckb4f4m-3000.euw.devtunnels.ms/api/coustmer/notification/$id");

    try {
      final response = await http.post(url, headers: {
        'Authorization': 'Bearer $token',
      });

      if (response.statusCode == 200) {
        print("✅ Notification $id marked as read");
        setState(() {
          notifications[index]['isRead'] = true;
        });
      } else {
        print("❌ Failed to mark as read: ${response.statusCode}");
      }
    } catch (e) {
      print("❌ Exception while marking as read: $e");
    }
  }


  String formatTime(String isoTime) {
    try {
      final dateTime = DateTime.parse(isoTime).toLocal();
      return "${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}";
    } catch (_) {
      return "";
    }
  }


  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: const Text("الإشعارات"),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: fetchNotifications,
            ),
            SizedBox(
              width: 7,
            ),
          ],
        ),
        body: loading
            ? const Center(child: CircularProgressIndicator())
            : notifications.isEmpty
            ? const Center(child: Text("لا يوجد إشعارات"))
            : ListView.builder(
          itemCount: notifications.length,
          padding: const EdgeInsets.all(16),
            itemBuilder: (context, index) {
              final item = notifications[index];
              final isRead = item['isRead'] == true;

              return GestureDetector(
                onTap:() async {
                  if (!isRead) {
                    await markNotificationAsRead(item['id'], index);
                  }
                  final type = item['type'];
                  final serviceId = item['serviceId'];
                  if (type == 'Order Message' || type == 'Order Status Changed') {
                    Navigator.pushNamed(context, '/order-details', arguments: serviceId);
                  } else if (type == 'Support Message') {
                    Navigator.pushNamed(context, '/support-chat');
                  } else {
                    print("🔔 No action mapped for type: $type");
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