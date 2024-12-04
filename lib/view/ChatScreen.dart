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
  int? selectedMessageId; // Tin nhắn được chọn để hiện thị nút
  bool isSearching = false;
  TextEditingController _searchController = TextEditingController();
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

  // Hàm xóa tin nhắn
  void deleteMessage(int messageId) async {
    final response = await http.delete(
      Uri.parse('http://127.0.0.1:8000/api/tinnhan/xoa/$messageId'),
    );

    if (response.statusCode == 200) {
      setState(() {
        // Xóa tin nhắn khỏi danh sách nếu xóa thành công
        messages.removeWhere((msg) => msg['id'] == messageId);
        selectedMessageId = null;
        fetchMessages();
      });
    } else {
      print('Failed to delete message: ${response.statusCode}');
    }
  }

  // Hàm thu hồi tin nhắn
  void undoMessage(int messageId) async {
    final response = await http.put(
      Uri.parse('http://127.0.0.1:8000/api/tinnhan/thuhoi/$messageId'),
    );

    if (response.statusCode == 200) {
      setState(() {
        fetchMessages(); // Cập nhật lại danh sách tin nhắn sau khi thu hồi
      });
    } else {
      print('Failed to undo message: ${response.statusCode}');
    }
  }

  void searchMessages(String query) {
    setState(() {
      if (query.isEmpty) {
        fetchMessages();
      } else {
        messages = messages
            .where((message) =>
                message['noiDung'].toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
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
      fetchMessages();
    }
  }

  void _showUserProfileDialog() async {
    // Lấy thông tin người dùng từ API
    final userData = await getUserById(widget.maNguoinhan);

    if (userData['success']) {
      final user = userData['data']; // Dữ liệu người dùng

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Thông tin người dùng'),
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Stack để chồng ảnh đại diện lên hình nền
                Stack(
                  alignment:
                      Alignment.bottomLeft, // Đặt ảnh đại diện ở dưới hình nền
                  children: [
                    Container(
                      width: 270, // Kích thước hình nền
                      height: 150, // Kích thước hình nền
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: NetworkImage(user['avatarUrl'] ??
                              'images/hinhnenzalo.jpg'), // Thay thế với URL hoặc Asset của hình nền
                          fit: BoxFit.cover, // Căng hoặc cắt hình nền để vừa
                        ),
                        borderRadius: BorderRadius.circular(
                            20), // Đặt góc bo tròn cho hình nền
                      ),
                    ),
                    // Ảnh đại diện tròn
                    SizedBox(
                      height: 100,
                    ),
                    Positioned(
                      child: CircleAvatar(
                        backgroundImage: NetworkImage(user['avatarUrl'] ??
                            'images/anhdaidien.jpg'), // URL hoặc Asset ảnh đại diện
                        radius: 30, // Kích thước ảnh đại diện
                        backgroundColor:
                            Colors.white, // Màu nền cho ảnh đại diện
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                // Thông tin người dùng
                Text(
                  'Họ và tên: ${user['tenHienthi']}',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Số điện thoại: ${user['soDienthoai']}',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[700],
                  ),
                ),
                SizedBox(height: 16),
              ],
            ),
            actions: [
              Row(
                mainAxisAlignment:
                    MainAxisAlignment.center, // Đặt các nút ở giữa
                children: [
                  // Nút Hủy Kết Bạn
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8.0), // Tạo khoảng cách giữa các nút
                    child: TextButton(
                      onPressed: () {
                        Navigator.of(context)
                            .pop(); // Đóng hộp thoại khi nhấn "Hủy Kết Bạn"
                      },
                      child: Text(
                        'Hủy Kết Bạn',
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                      style: TextButton.styleFrom(
                        shape: RoundedRectangleBorder(
                            // Bo tròn các góc nút
                            ),
                        backgroundColor: Colors.blue,
                        padding: EdgeInsets.symmetric(
                            vertical: 12,
                            horizontal: 24), // Điều chỉnh khoảng cách trong nút
                      ),
                    ),
                  ),
                  // Nút Đóng
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8.0), // Khoảng cách giữa các nút
                    child: TextButton(
                      onPressed: () {
                        Navigator.of(context)
                            .pop(); // Đóng hộp thoại khi nhấn "Đóng"
                      },
                      child: Text(
                        'Đóng',
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                      style: TextButton.styleFrom(
                        shape: RoundedRectangleBorder(
                            // Bo tròn các góc nút
                            ),
                        backgroundColor: Color.fromARGB(255, 86, 161, 221),
                        padding: EdgeInsets.symmetric(
                            vertical: 12,
                            horizontal: 24), // Điều chỉnh khoảng cách trong nút
                      ),
                    ),
                  ),
                ],
              )
            ],
          );
        },
      );
    } else {
      // Nếu không tìm thấy người dùng, hiển thị thông báo lỗi
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Lỗi'),
            content: Text('Không thể tải thông tin người dùng.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Đóng hộp thoại khi nhấn "Đóng"
                },
                child: Text('Đóng'),
              ),
            ],
          );
        },
      );
    }
  }

  Future<Map<String, dynamic>> getUserById(int id) async {
    final url = Uri.parse(
        'http://127.0.0.1:8000/api/nguoidung/user/$id'); // Địa chỉ API lấy thông tin người dùng

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      if (jsonResponse['success']) {
        return {
          'success': true,
          'data': jsonResponse['data'], // Trả về dữ liệu người dùng
        };
      } else {
        return {
          'success': false,
          'message': jsonResponse['message'] ?? 'User not found',
        };
      }
    } else {
      return {
        'success': false,
        'message': 'Failed to load user data',
      };
    }
  }

  void _onMenuSelected(String value) {
    switch (value) {
      case 'search':
        setState(() {
          isSearching = !isSearching;
        });
        break;
      case 'profile':
        setState(() {
          _showUserProfileDialog();
        });
        break;
      // Có thể thêm các trường hợp khác như logout, thông báo,...
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat with User ${widget.maNguoinhan}'),
        backgroundColor: Colors.blue,
        actions: [
          Row(
            children: [
              IconButton(
                  onPressed: () {
                    print("hihi");
                  },
                  icon: Icon(Icons.camera)),
              IconButton(
                  onPressed: () {
                    print("hihi");
                  },
                  icon: Icon(Icons.phone)),
              PopupMenuButton<String>(
                onSelected: _onMenuSelected,
                itemBuilder: (BuildContext context) {
                  return [
                    PopupMenuItem<String>(
                      value: 'search',
                      child: Text(isSearching ? 'Hủy tìm kiếm' : 'Tìm kiếm'),
                    ),
                    PopupMenuItem<String>(
                      value: 'profile',
                      child: Text('Xem trang cá nhân'),
                    ),
                    // Thêm các mục khác nếu cần
                  ];
                },
              )
            ],
          )
        ],
      ),
      body: Column(
        children: [
          if (isSearching)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Tìm tin nhắn...',
                  border: OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(Icons.clear), // Biểu tượng "hủy"
                    onPressed: () {
                      setState(() {
                        _searchController
                            .clear(); // Xóa nội dung trong ô tìm kiếm
                        searchMessages(
                            ''); // Gọi lại hàm tìm kiếm với chuỗi rỗng
                        isSearching = false; // Tắt chế độ tìm kiếm
                      });
                    },
                  ),
                ),
                onChanged: searchMessages,
              ),
            ),

          // Hiển thị danh sách tin nhắn
          Expanded(
            child: ListView.builder(
                reverse: true,
                itemCount: messages.length,
                // Chỉnh sửa trong ListView.builder
                itemBuilder: (context, index) {
                  final message = messages[messages.length - index - 1];
                  bool isSentByUser =
                      message['maNguoigui'] == widget.maNguoidung;

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedMessageId =
                            message['maTinnhan']; // Lưu ID tin nhắn được chọn
                      });
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Row(
                        mainAxisAlignment: isSentByUser
                            ? MainAxisAlignment.end
                            : MainAxisAlignment.start,
                        children: [
                          if (!isSentByUser)
                            CircleAvatar(
                              backgroundImage:
                                  AssetImage('images/anhdaidien.jpg'),
                            ),
                          SizedBox(width: 10),
                          if (isSentByUser &&
                              selectedMessageId == message['maTinnhan'])
                            Row(
                              children: [
                                IconButton(
                                  icon: Icon(Icons.delete, color: Colors.red),
                                  onPressed: () {
                                    deleteMessage(message[
                                        'maTinnhan']); // Gọi hàm xóa tin nhắn
                                  },
                                ),
                                IconButton(
                                  icon: Icon(Icons.undo, color: Colors.blue),
                                  onPressed: () {
                                    // Gọi hàm thu hồi tin nhắn
                                    undoMessage(message['maTinnhan']);
                                  },
                                ),
                              ],
                            ),
                          Container(
                            decoration: BoxDecoration(
                              color:
                                  isSentByUser ? Colors.blue : Colors.grey[300],
                              borderRadius: BorderRadius.circular(20),
                            ),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16.0, vertical: 10.0),
                            child: Column(
                              crossAxisAlignment: isSentByUser
                                  ? CrossAxisAlignment.end
                                  : CrossAxisAlignment.start,
                              children: [
                                Text(
                                  message['noiDung'],
                                  style: TextStyle(
                                    color: isSentByUser
                                        ? Colors.white
                                        : Colors.black,
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
                          if (isSentByUser)
                            CircleAvatar(
                              backgroundImage:
                                  AssetImage('images/anhdaidien.jpg'),
                            ),
                          if (!isSentByUser &&
                              selectedMessageId == message['maTinnhan'])
                            IconButton(
                              icon: Icon(Icons.delete, color: Colors.red),
                              onPressed: () {
                                deleteMessage(message[
                                    'maTinnhan']); // Gọi hàm xóa tin nhắn
                              },
                            ),
                        ],
                      ),
                    ),
                  );
                }),
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
      headers: <String, String>{'Content-Type': 'application/json'},
      body: jsonEncode(<String, dynamic>{
        'maNguoigui': widget.maNguoidung,
        'maNguoinhan': widget.maNguoinhan,
        'noiDung': content,
        'thoiGianGui': currentTime, // Thêm trường thoiGianGui
      }),
    );

    if (response.statusCode == 200) {
      fetchMessages();
    } else {
      print('Failed to send message');
    }
  }
}
