import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import 'HomeScreen.dart'; // Đảm bảo đường dẫn đúng

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool isPasswordHidden = true;
  String selectedCountryCode = "+84";
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool isLoading = false; // Hiển thị trạng thái tải

  Future<void> login(
      BuildContext context, String soDienThoai, String matKhau) async {
    final url = Uri.parse('http://127.0.0.1:8000/api/nguoidung/login');
    setState(() {
      isLoading = true;
    });

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'soDienthoai': soDienThoai, 'matkhauMahoa': matKhau}),
      );

      setState(() {
        isLoading = false;
      });

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        if (responseData['success']) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => ChatHomeScreen(user: responseData['data']),
            ),
          );
        } else {
          _showErrorDialog(context, "Đăng nhập thất bại $matKhau $soDienThoai",
              responseData['message']);
        }
      } else {
        _showErrorDialog(
            context, "Lỗi server", "Mã lỗi: ${response.statusCode}");
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      _showErrorDialog(context, "Lỗi kết nối",
          "Không thể kết nối đến máy chủ. Vui lòng thử lại sau.");
    }
  }

  void _showErrorDialog(BuildContext context, String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Đóng"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: Center(
        child: isLoading
            ? const CircularProgressIndicator() // Hiển thị vòng tròn tải
            : Container(
                width: 350,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      "ZALO",
                      style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "Đăng nhập",
                      style: TextStyle(fontSize: 16, color: Colors.black54),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        DropdownButton<String>(
                          value: selectedCountryCode,
                          underline: const SizedBox(),
                          items: const [
                            DropdownMenuItem(value: "+84", child: Text("+84")),
                            DropdownMenuItem(value: "+1", child: Text("+1")),
                            DropdownMenuItem(value: "+91", child: Text("+91")),
                          ],
                          onChanged: (value) {
                            setState(() {
                              selectedCountryCode = value!;
                            });
                          },
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            controller: phoneController,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly
                            ],
                            decoration: const InputDecoration(
                              hintText: "Số điện thoại",
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: passwordController,
                      obscureText: isPasswordHidden,
                      decoration: InputDecoration(
                        hintText: "Mật khẩu",
                        border: const OutlineInputBorder(),
                        suffixIcon: IconButton(
                          icon: Icon(
                            isPasswordHidden
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                          onPressed: () {
                            setState(() {
                              isPasswordHidden = !isPasswordHidden;
                            });
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                        ),
                        onPressed: () {
                          final phone = phoneController.text.trim();
                          final password = passwordController.text.trim();

                          if (phone.isEmpty || password.isEmpty) {
                            _showErrorDialog(context, "Lỗi",
                                "Vui lòng nhập đầy đủ thông tin.");
                            return;
                          }

                          login(context, "$phone", password);
                        },
                        child: const Text(
                          "Đăng Nhập",
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
