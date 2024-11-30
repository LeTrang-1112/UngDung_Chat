import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ChatScreen extends StatefulWidget {
  final int maNguoidung;
  final int maNguoinhan;

  const ChatScreen({
    Key? key,
    required this.maNguoidung,
    required this.maNguoinhan,
  }) : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  List<dynamic> messages = []; // Danh sách tin nhắn
  TextEditingController _messageController = TextEditingController();

  // Gọi API để lấy tin nhắn
  Future<void> fetchMessages() async {
    final url = Uri.parse(
        'http://127.0.0.1:8000/api/tinnhan/messages/${widget.maNguoidung}/${widget.maNguoinhan}');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      if (jsonResponse['success'] == true) {
        setState(() {
          messages = jsonResponse['data']; // Cập nhật danh sách tin nhắn
        });
      } else {
        print('No messages found');
      }
    } else {
      print('Failed to load messages: ${response.statusCode}');
    }
  }

  @override
  void initState() {
    super.initState();
    fetchMessages(); // Lấy tin nhắn khi khởi tạo
  }

  @override
  void didUpdateWidget(covariant ChatScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.maNguoinhan != widget.maNguoinhan) {
      // Nếu người nhận thay đổi, gọi lại fetchMessages
      fetchMessages();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat with User ${widget.maNguoinhan}'),
        backgroundColor: Colors.blue,
      ),
      body: Column(
        children: [
          // Hiển thị danh sách tin nhắn
          Expanded(
            child: ListView.builder(
              reverse: true, // Đảo ngược để tin nhắn mới sẽ xuất hiện dưới cùng
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final message = messages[
                    messages.length - index - 1]; // Lấy tin nhắn từ cuối
                bool isSentByUser = message['maNguoigui'] ==
                    widget
                        .maNguoidung; // Kiểm tra tin nhắn của người gửi hay người nhận
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Row(
                    mainAxisAlignment: isSentByUser
                        ? MainAxisAlignment.end // Người gửi tin nhắn căn phải
                        : MainAxisAlignment
                            .start, // Người nhận tin nhắn căn trái
                    children: [
                      // Avatar người nhận
                      !isSentByUser
                          ? CircleAvatar(
                              backgroundImage: AssetImage(
                                  'images/anhdaidien.jpg'), // Avatar của người nhận
                            )
                          : SizedBox
                              .shrink(), // Ẩn avatar nếu người gửi là người dùng
                      SizedBox(width: 10),
                      // Tin nhắn của người gửi hoặc người nhận
                      Container(
                        decoration: BoxDecoration(
                          color: isSentByUser ? Colors.blue : Colors.grey[300],
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16.0, vertical: 10.0),
                        child: Column(
                          crossAxisAlignment: isSentByUser
                              ? CrossAxisAlignment
                                  .end // Tin nhắn của người gửi căn phải
                              : CrossAxisAlignment
                                  .start, // Tin nhắn của người nhận căn trái
                          children: [
                            Text(
                              message['noiDung'],
                              style: TextStyle(
                                color:
                                    isSentByUser ? Colors.white : Colors.black,
                                fontSize: 16,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              message['thoiGianGui'],
                              style: TextStyle(
                                color: isSentByUser
                                    ? Colors.white70
                                    : Colors.black54,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 10),
                      // Avatar người gửi
                      isSentByUser
                          ? CircleAvatar(
                              backgroundImage: AssetImage(
                                  'images/anhdaidien.jpg'), // Avatar của người gửi
                            )
                          : SizedBox
                              .shrink(), // Ẩn avatar nếu người nhận là người dùng
                    ],
                  ),
                );
              },
            ),
          ),

          // Nơi để gửi tin nhắn
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Nhập tin nhắn...',
                      border: OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: Icon(Icons.send),
                        onPressed: () {
                          if (_messageController.text.isNotEmpty) {
                            // Gửi tin nhắn khi nhấn nút gửi
                            sendMessage(_messageController.text);
                            _messageController
                                .clear(); // Xóa nội dung sau khi gửi
                          }
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Hàm gửi tin nhắn
  void sendMessage(String content) async {
    final currentTime =
        DateTime.now().toIso8601String(); // Lấy thời gian hiện tại

    final response = await http.post(
      Uri.parse('http://127.0.0.1:8000/api/tinnhan/create'),
      headers: <String, String>{
        'Content-Type': 'application/json',
      },
      body: jsonEncode(<String, dynamic>{
        'maNguoigui': widget.maNguoidung,
        'maNguoinhan': widget.maNguoinhan,
        'noiDung': content,
        'thoiGianGui': currentTime, // Thêm trường thoiGianGui
      }),
    );

    if (response.statusCode == 200) {
      // Sau khi gửi thành công, gọi lại API để lấy danh sách tin nhắn mới
      fetchMessages();
    } else {
      print('Failed to send message');
    }
  }
}
