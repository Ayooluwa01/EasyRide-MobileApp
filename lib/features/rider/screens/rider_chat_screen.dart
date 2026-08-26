import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

class ChatPreview {
  const ChatPreview({
    required this.id,
    required this.driverName,
    required this.avatarUrl,
    required this.lastMessage,
    required this.timeLabel,
    this.unreadCount = 0,
    this.isOnline = false,
    this.isLastMessageMine = false,
  });

  final String id;
  final String driverName;
  final String avatarUrl;
  final String lastMessage;
  final String timeLabel;
  final int unreadCount;
  final bool isOnline;
  final bool isLastMessageMine;
}

class RiderChatListScreen extends StatefulWidget {
  const RiderChatListScreen({super.key});

  @override
  State<RiderChatListScreen> createState() => _RiderChatListScreenState();
}

class _RiderChatListScreenState extends State<RiderChatListScreen> {
  final _searchController = TextEditingController();

  static const _demoChats = [
    ChatPreview(
      id: 'tunde_bakare',
      driverName: 'Tunde Bakare',
      avatarUrl: 'https://i.pravatar.cc/150?img=12',
      lastMessage: 'I am outside at the pickup spot',
      timeLabel: '14:02',
      unreadCount: 1,
      isOnline: true,
    ),
    ChatPreview(
      id: 'kelechi_obi',
      driverName: 'Kelechi Obi',
      avatarUrl: 'https://i.pravatar.cc/150?img=53',
      lastMessage: 'Thanks for the tip! Have a great day.',
      timeLabel: 'Yesterday',
    ),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final syneBaseStyle = GoogleFonts.syne(
      fontSize: 30,
      height: 1.2,
      fontWeight: FontWeight.w700,
    );
    final interBaseStyle = GoogleFonts.inter();

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Messages",
                    style: syneBaseStyle.copyWith(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: colorScheme.onSurface.withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.edit_outlined,
                      size: 18,
                      color: colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Search field
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                decoration: BoxDecoration(
                  color: isDark
                      ? colorScheme.onSurface.withValues(alpha: 0.06)
                      : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: TextField(
                  controller: _searchController,
                  style: TextStyle(fontSize: 14, color: colorScheme.onSurface),
                  decoration: InputDecoration(
                    hintText: "Search drivers or messages...",
                    hintStyle: TextStyle(
                      fontSize: 14,
                      color: colorScheme.onSurface.withValues(alpha: 0.4),
                    ),
                    prefixIcon: Icon(
                      Icons.search,
                      size: 20,
                      color: colorScheme.onSurface.withValues(alpha: 0.4),
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 8),

            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 8,
                ),
                itemCount: _demoChats.length,
                separatorBuilder: (context, index) => Divider(
                  height: 1,
                  color: colorScheme.onSurface.withValues(alpha: 0.06),
                ),
                itemBuilder: (context, index) {
                  final chat = _demoChats[index];
                  return _ChatListTile(
                    chat: chat,
                    interBaseStyle: interBaseStyle,
                    onTap: () {
                      context.push('/rider/chats/${chat.id}', extra: chat);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChatListTile extends StatelessWidget {
  const _ChatListTile({
    required this.chat,
    required this.interBaseStyle,
    required this.onTap,
  });

  final ChatPreview chat;
  final TextStyle interBaseStyle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final hasUnread = chat.unreadCount > 0;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Stack(
              children: [
                CircleAvatar(
                  radius: 26,
                  backgroundImage: NetworkImage(chat.avatarUrl),
                ),
                if (chat.isOnline)
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        color: const Color(0xFF2ED47A),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: colorScheme.surface,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    chat.driverName,
                    style: interBaseStyle.copyWith(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    chat.lastMessage,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: interBaseStyle.copyWith(
                      fontSize: 13,
                      fontStyle: hasUnread
                          ? FontStyle.italic
                          : FontStyle.normal,
                      color: hasUnread
                          ? colorScheme.onSurface.withValues(alpha: 0.75)
                          : colorScheme.onSurface.withValues(alpha: 0.45),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  chat.timeLabel,
                  style: interBaseStyle.copyWith(
                    fontSize: 11,
                    color: colorScheme.onSurface.withValues(alpha: 0.4),
                  ),
                ),
                const SizedBox(height: 6),
                if (hasUnread)
                  Container(
                    width: 20,
                    height: 20,
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                      color: Color(0xFF2ED47A),
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '${chat.unreadCount}',
                      style: interBaseStyle.copyWith(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
