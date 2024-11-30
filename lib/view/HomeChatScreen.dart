// import 'package:flutter/material.dart';
// import 'ChatScreen.dart';

// class HomeChatScreen extends StatefulWidget {
//   const HomeChatScreen({Key? key}) : super(key: key);

//   @override
//   State<HomeChatScreen> createState() => _HomeChatScreenState();
// }

// class _HomeChatScreenState extends State<HomeChatScreen> {
//   final Map<String, List<String>> chatMessages = {
//     'user1': ['Hello from user1', 'How are you?'],
//     'user2': ['Hi from user2', 'Meeting at 3 PM'],
//     'user3': ['Hey user3 here', 'See you later!'],
//   };

//   void _openChat(String userId, String name) {
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => ChatScreen(
//           name: name,
//           messages: chatMessages[userId]!,
//           onSendMessage: (newMessage) {
//             setState(() {
//               chatMessages[userId]!.add(newMessage);
//             });
//           },
//         ),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text("Chat App"),
//       ),
//       body: ListView(
//         children: [
//           _buildChatItem('user1', 'Nguyễn Văn A'),
//           _buildChatItem('user2', 'Trần Thị B'),
//           _buildChatItem('user3', 'Lê Văn C'),
//         ],
//       ),
//     );
//   }

//   Widget _buildChatItem(String userId, String name) {
//     final lastMessage = chatMessages[userId]?.last ?? 'No messages yet';
//     return ListTile(
//       onTap: () => _openChat(userId, name),
//       leading: CircleAvatar(child: Text(name[0])),
//       title: Text(name),
//       subtitle: Text(
//         lastMessage,
//         maxLines: 1,
//         overflow: TextOverflow.ellipsis,
//       ),
//     );
//   }
// }
