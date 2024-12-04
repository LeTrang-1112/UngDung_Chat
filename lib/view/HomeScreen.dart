import 'package:demo_database/view/ChatScreen.dart';
import 'package:demo_database/view/LoginScreen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ChatHomeScreen extends StatefulWidget {
  final Map<String, dynamic> user;
  const ChatHomeScreen({Key? key, required this.user}) : super(key: key);
  @override
  _ChatHomeScreenState createState() => _ChatHomeScreenState();
}

class _ChatHomeScreenState extends State<ChatHomeScreen> {
  List<dynamic> conversations = []; // Danh sách cuộc trò chuyện
  dynamic selectedConversation; // Cuộc trò chuyện đã chọn

  // Gọi API để lấy danh sách các cuộc trò chuyện
  Future<void> fetchConversations() async {
    final id = int.parse(widget.user['maNguoidung'].toString());
    final url =
        Uri.parse('http://127.0.0.1:8000/api/tinnhan/conversations/$id');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      setState(() {
        conversations = jsonResponse['data']; // Lưu danh sách cuộc trò chuyện
      });
    } else {
      print('Failed to load conversations: ${response.statusCode}');
    }
  }

  @override
  void initState() {
    super.initState();
    fetchConversations(); // Gọi hàm khi màn hình được khởi tạo
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // Sidebar
          Container(
            width: 80,
            color: Colors.blue,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  children: [
                    const SizedBox(height: 20),
                    CircleAvatar(
                      radius: 30,
                      backgroundImage: AssetImage('images/anhdaidien.jpg'),
                    ),
                    const SizedBox(height: 20),
                    IconButton(
                      icon: const Icon(Icons.chat, color: Colors.white),
                      onPressed: () {},
                    ),
                    IconButton(
                      icon: const Icon(Icons.people, color: Colors.white),
                      onPressed: () {},
                    ),
                    IconButton(
                      icon: const Icon(Icons.settings, color: Colors.white),
                      onPressed: () {},
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.logout, color: Colors.white),
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => LoginScreen(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),

          // Danh sách chat
          Expanded(
            flex: 2,
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  color: Colors.grey[200],
                  child: Row(
                    children: [
                      const Expanded(
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: 'Tìm kiếm',
                            prefixIcon: Icon(Icons.search),
                            border: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(8)),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      IconButton(
                        icon: const Icon(Icons.person_add),
                        onPressed: () {},
                      ),
                      IconButton(
                        icon: const Icon(Icons.group_add),
                        onPressed: () {},
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: conversations.isEmpty
                      ? Center(child: Text('Không có cuộc trò chuyện'))
                      : ListView.builder(
                          itemCount: conversations.length,
                          itemBuilder: (BuildContext context, index) {
                            final conversation = conversations[index];
                            return Card(
                              margin: const EdgeInsets.symmetric(vertical: 8.0),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: Colors.grey[300],
                                  child:
                                      Text('U${conversation['maNguoinhan']}'),
                                ),
                                title:
                                    Text('User ${conversation['maNguoinhan']}'),
                                onTap: () {
                                  setState(() {
                                    selectedConversation = conversation;
                                  });
                                },
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),

          // Phần nội dung chính (sẽ hiển thị chat)
          Expanded(
            flex: 5,
            child: selectedConversation == null
                ? Center(
                    child: Image.asset(
                      'images/hinhnenzalo.jpg', // Hình ảnh thay thế
                      height: 450,
                    ),
                  )
                : ChatScreen(
                    maNguoidung: widget.user['maNguoidung'],
                    maNguoinhan: selectedConversation['maNguoinhan'],
                  ),
          ),
        ],
      ),
    );
  }
}
