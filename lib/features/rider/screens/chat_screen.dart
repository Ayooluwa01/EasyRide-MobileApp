import 'package:easy_ride/features/rider/screens/rider_chat_screen.dart';
import 'package:flutter/material.dart';

class ChatScreen extends StatefulWidget {
  final String chatId;
  final ChatPreview? chat;

  const ChatScreen({super.key, required this.chatId, this.chat});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.chat?.driverName ?? 'Chat room: ${widget.chatId}'),
      ),
      body: Center(
        child: Text('Viewing chat session ${widget.chat?.isLastMessageMine}'),
      ),
    );
  }
}
