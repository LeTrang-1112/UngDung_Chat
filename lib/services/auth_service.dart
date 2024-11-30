import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthService {
  static const String baseUrl =
      "http://127.0.0.1:8000/api"; // Thay bằng URL của API của bạn

  // Đăng ký
  Future<Map<String, dynamic>> register(
      String phone, String password, String displayName) async {
    final response = await http.post(
      Uri.parse('$baseUrl/register'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'soDienthoai': phone,
        'matkhau': password,
        'tenHienthi': displayName,
      }),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body); // Nếu thành công, trả về dữ liệu
    } else {
      throw Exception('Failed to register');
    }
  }

  // Đăng nhập
  Future<Map<String, dynamic>> login(String phone, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'soDienthoai': phone,
        'matkhau': password,
      }),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body); // Nếu thành công, trả về dữ liệu
    } else {
      throw Exception('Failed to login');
    }
  }
}
