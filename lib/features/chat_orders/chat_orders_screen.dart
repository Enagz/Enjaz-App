import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:http/http.dart' as http;
import '../localization/change_lang.dart';

class OrderChatScreen extends StatefulWidget {
  const OrderChatScreen({Key? key}) : super(key: key);

  @override
  State<OrderChatScreen> createState() => _OrderChatScreenState();
}

class _OrderChatScreenState extends State<OrderChatScreen> {
  List<Map<String, dynamic>> messages = [];
  IO.Socket? socket;
  String? userId;
  String? token;
  bool isReady = false;
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final String orderCode = "8154";

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
    final url = Uri.parse('https://backend.enjazkw.com/api/chat/order/clitent');
    final response = await http.get(url, headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json'
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
      'https://backend.enjazkw.com',
      IO.OptionBuilder().setTransports(['websocket']).disableAutoConnect().build(),
    );

    socket!.connect();

    socket!.onConnect((_) => print('🟢 Socket connected'));
    socket!.onDisconnect((_) => print('🔌 Socket disconnected'));
    socket!.onConnectError((error) => print('❌ Socket connection error: $error'));
    socket!.onError((error) => print('🛑 General socket error: $error'));

    socket!.on("NewEmployeeOrderMessage", (data) {
      if (data is Map && data.containsKey('message')) {
        final String message = data['message'];
        setState(() {
          messages.add({
            "sender": "employee",
            "message": message,
            "time": DateTime.now().toIso8601String(),
          });
        });
        _scrollToBottom();
      }
    });
  }

  void sendMessage() {
    final message = _controller.text.trim();

    if (!isReady) {
      print('⚠️ لم يكتمل التحميل بعد. userId أو socket غير جاهزين.');
      return;
    }

    if (message.isNotEmpty && userId != null && socket?.connected == true) {
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

      _controller.clear();
      _scrollToBottom();
    } else {
      print('⚠️ لا يمكن الإرسال: message = [$message], userId = [$userId], socket = ${socket?.connected}');
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 300), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Widget _buildMessage(Map<String, dynamic> msg) {
    final isMe = msg['sender'] == 'client';
    final time = DateFormat('HH:mm').format(DateTime.parse(msg['time']).toLocal());

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isMe ? const Color(0xFFE6E6E6) : const Color(0xFFD6F0FF),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Text(msg['message'], style: const TextStyle(fontSize: 14)),
            const SizedBox(height: 4),
            Text(time, style: const TextStyle(fontSize: 10, color: Color(0xFFB3B3B3))),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final langCode = Localizations.localeOf(context).languageCode;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        title: Text(
          Translations.getText('chat_title', langCode),
          style: const TextStyle(color: Colors.black),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: messages.length,
              itemBuilder: (context, index) => _buildMessage(messages[index]),
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
                      controller: _controller,
                      decoration: InputDecoration(
                        hintText: Translations.getText('write_message_hint', langCode),
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
                    onPressed: sendMessage,
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