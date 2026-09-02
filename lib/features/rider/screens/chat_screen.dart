import 'package:easy_ride/features/rider/screens/rider_chat_screen.dart';
import 'package:flutter/material.dart';

class ChatScreen extends StatefulWidget {
  final String rideId;

  const ChatScreen({super.key, required this.rideId});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: Text('Chat room: ${widget.rideId}')));
  }
}
