import 'package:flutter/material.dart';
import 'package:demo_database/model/ChatModel.dart';
import 'package:demo_database/database/database.dart';

class DangNhap_Screen extends StatefulWidget {
  const DangNhap_Screen({super.key});

  @override
  State<DangNhap_Screen> createState() => _DangNhap_ScreenState();
}

class _DangNhap_ScreenState extends State<DangNhap_Screen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Thêm chó mới"),
        backgroundColor: Colors.teal,
        centerTitle: true,
      ),
      body: Padding(padding: const EdgeInsets.all(16.0)),
    );
  }
}
