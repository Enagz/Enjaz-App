import 'package:flutter/material.dart';
import 'dialog.dart';

class OrdersScreenVistor extends StatelessWidget {
  const OrdersScreenVistor({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
        body: LoginRequiredDialog());
  }
}
