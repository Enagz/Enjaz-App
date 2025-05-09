import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:socket_io_client/socket_io_client.dart' as IO;


class SupportChatScreen extends StatefulWidget {
  @override
  _SupportChatScreenState createState() => _SupportChatScreenState();
}

class _SupportChatScreenState extends State<SupportChatScreen> {
  List<Map<String, dynamic>> messages = [];
  IO.Socket? socket;
  bool isReady = false;
  TextEditingController messageController = TextEditingController();
  String? userId;
  String? token;

  @override
  void initState() {
    super.initState();
    initializeChat();
  }

  void initializeChat() async {
    final prefs = await SharedPreferences.getInstance();
    userId = prefs.getString('userId');
    token = prefs.getString('token');
    if (userId != null && token != null) {
      await fetchChat();
      setupSocket();
      setState(() => isReady = true);
    } else {
      print('❌ userId أو token مفقود');
    }
  }

  Future<void> fetchChat() async {
    final url = Uri.parse('https://wckb4f4m-3000.euw.devtunnels.ms/api/chat/support/clitent');
    final response = await http.get(url, headers: {
      'Authorization': 'Bearer $token',
    });

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      setState(() {
        messages = data.map((msg) => {
          'sender': msg['sender'],
          'message': msg['message'],
          'time': msg['time'],
        }).toList();
      });
    } else {
      print('⚠️ Failed to fetch chat. Status: ${response.statusCode}');
    }
  }

  void setupSocket() {
    socket = IO.io(
      'https://wckb4f4m-3000.euw.devtunnels.ms',
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .build(),
    );

    socket!.connect();

    socket!.onConnect((_) {
      print('🟢 Socket connected');
    });

    socket!.onDisconnect((_) {
      print('🔌 Socket disconnected');
    });

    socket!.onConnectError((error) {
      print('❌ Socket connection error: $error');
    });

    socket!.onError((error) {
      print('🛑 General socket error: $error');
    });

    socket!.onAny((event, data) {
      print('📥 Event: $event -> $data');
    });

    socket!.on("testResponse", (data) {
      print("📥 Received testEvent: $data");
      socket!.emit("testEvent", {
        "message": "Test event received successfully from Flutter!"
      });
    });

    socket!.on("NewEmployeeOrderMessage", (data) {
      print("📥 Received: $data");
      if (data is Map && data.containsKey('message') && data.containsKey('chatId')) {
        final String message = data['message'];
        final String chatId = data['chatId'];
        if (!mounted) return;
        setState(() {
          messages.add({
            "sender": "employee",
            "message": message,
            "chatId": chatId,
            "time": DateTime.now().toIso8601String(),
          });
        });
        print("✅ Message added: $message from employee");
      } else {
        print("⚠️ Unexpected socket data format: $data");
      }
    });
  }

  void sendMessage() {

    print('🔁 Socket status: ${socket?.connected}');

    final message = messageController.text.trim();

    if (!isReady) {
      print('⚠️ لم يكتمل التحميل بعد. userId أو socket غير جاهزين.');
      return;
    }

    if (message.isNotEmpty && userId != null && socket?.connected == true) {
      print('📤 ببعّت للسيرفر: $message');
      print('👤 userId: $userId');

      socket!.emit("OrderCoustmerMessage", {
        "message": message,
        "userId": userId,
      });

      setState(() {
        messages.add({
          "sender": "client",
          "message": message,
          "time": DateTime.now().toIso8601String(),
        });
      });

      messageController.clear();
    } else {
      print('⚠️ لا يمكن الإرسال: message = [$message], userId = [$userId], socket = ${socket?.connected}');
    }
  }

  @override
  Widget build(BuildContext context) {
    final langCode = context.read<LocalizationProvider>().locale.languageCode;
    //final textDirection = langCode == 'ar' ? TextDirection.rtl : TextDirection.ltr;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          langCode == 'ar' ? 'خدمة العملاء' : 'Customer Support',
          style: const TextStyle(color: Colors.black),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              reverse: false,
              padding: const EdgeInsets.all(16),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final msg = messages[index];
                final isClient = msg['sender'] == 'client';
                final time = DateFormat('HH:mm').format(DateTime.parse(msg['time']).toLocal());

                return Align(
                  alignment: isClient ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    padding: const EdgeInsets.all(12),
                    constraints: const BoxConstraints(maxWidth: 280),
                    decoration: BoxDecoration(
                      color: isClient ? const Color(0xFFE6E6E6) : const Color(0xFFD6F0FF),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment:
                      isClient ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                      children: [
                        Text(
                          msg['message'],
                          style: const TextStyle(fontSize: 14, color: Colors.black),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          time,
                          style: const TextStyle(fontSize: 10, color: Color(0xFFB3B3B3)),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFF2F2F2),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: TextField(
                      controller: messageController,
                      decoration: InputDecoration(
                        hintText: langCode == 'ar' ? 'رسالتك...' : 'Your message...',
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  backgroundColor: const Color(0xFF409EDC),
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white),
                    onPressed: () {
                      sendMessage();
                    },
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}