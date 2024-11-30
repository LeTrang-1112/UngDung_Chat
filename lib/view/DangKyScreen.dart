import 'package:flutter/material.dart';
import 'package:demo_database/model/ChatModel.dart';
import 'package:demo_database/database/database.dart';

class DangKy_Screen extends StatefulWidget {
  const DangKy_Screen({super.key});

  @override
  State<DangKy_Screen> createState() => _DangKyScreenState();
}

class _DangKyScreenState extends State<DangKy_Screen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text(
            "Đăng ký",
            style: TextStyle(color: Colors.white),
          ),
          centerTitle: true,
          backgroundColor: const Color.fromARGB(255, 25, 1, 237),
        ),
        body: Padding(padding: EdgeInsets.all(8)));
  }
}
