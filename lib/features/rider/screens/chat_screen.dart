import 'package:easy_ride/app/services/get_ride_by_id.dart';
import 'package:easy_ride/app/services/ride_chat.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class ChatScreen extends ConsumerStatefulWidget {
  final String rideId;
  const ChatScreen({super.key, required this.rideId});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(getRideByIdProvider.notifier).fetchRide(widget.rideId);
      ref.read(rideChatProvider.notifier).getRideChat(widget.rideId);
    });
    _textController.addListener(() {
      final hasText = _textController.text.trim().isNotEmpty;
      if (hasText != _hasText) {
        setState(() => _hasText = hasText);
      }
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final content = _textController.text.trim();
    if (content.isEmpty) return;
    ref
        .read(rideChatProvider.notifier)
        .sendMessage(rideId: widget.rideId, content: content);
    _textController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final rideState = ref.watch(getRideByIdProvider);
    final rideDetails = rideState.valueOrNull;
    final driver = rideDetails?.driver;
    final driverUser = driver?.user;
    final chatMessages = ref.watch(rideChatProvider).valueOrNull ?? [];

    ref.listen(rideChatProvider, (previous, next) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent + 40,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeOut,
          );
        }
      });
    });

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF0E0E0E)
          : const Color(0xFFF7F7F8),
      body: SafeArea(
        child: Column(
          children: [
            // ============================================================
            // HEADER
            // ============================================================
            _ChatHeader(
              theme: theme,
              isDark: isDark,
              driverName: driverUser?.fullName,
              driverPhone: driverUser?.phone,
              driverPhotoUrl: driverUser?.profilePhotoUrl,
              isOnline: driver?.isOnline ?? false,
              onBack: () => context.pop(),
              onCall: () {},
            ),

            // ============================================================
            // BODY
            // ============================================================
            Expanded(
              child: rideState.isLoading && rideDetails == null
                  ? Center(
                      child: CircularProgressIndicator(
                        color: colorScheme.primary,
                      ),
                    )
                  : driverUser == null
                  ? _EmptyState(
                      theme: theme,
                      icon: Icons.person_off_outlined,
                      title: 'Driver details unavailable',
                      subtitle: "We couldn't load who you're chatting with.",
                    )
                  : chatMessages.isEmpty
                  ? _EmptyState(
                      theme: theme,
                      icon: Icons.chat_bubble_outline_rounded,
                      title: 'No messages yet',
                      subtitle:
                          'Say hello to ${driverUser.fullName.split(' ').first} about your trip.',
                    )
                  : ListView.separated(
                      controller: _scrollController,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 16,
                      ),
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 10),
                      itemCount: chatMessages.length,
                      itemBuilder: (context, index) {
                        final message = chatMessages[index];
                        return _ChatBubble(
                          theme: theme,
                          isDark: isDark,
                          isMe: message.isMe == true,
                          content: message.content,
                        );
                      },
                    ),
            ),

            // ============================================================
            // INPUT BAR
            // ============================================================
            _ChatInputBar(
              theme: theme,
              isDark: isDark,
              controller: _textController,
              hasText: _hasText,
              onSend: _sendMessage,
            ),
          ],
        ),
      ),
    );
  }
}

// ==================================================================
// HEADER
// ==================================================================

class _ChatHeader extends StatelessWidget {
  final ThemeData theme;
  final bool isDark;
  final String? driverName;
  final String? driverPhone;
  final String? driverPhotoUrl;
  final bool isOnline;
  final VoidCallback onBack;
  final VoidCallback onCall;

  const _ChatHeader({
    required this.theme,
    required this.isDark,
    required this.driverName,
    required this.driverPhone,
    required this.driverPhotoUrl,
    required this.isOnline,
    required this.onBack,
    required this.onCall,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 16, 14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF161616) : Colors.white,
        // boxShadow: [
        //   BoxShadow(
        //     color: isDark
        //         ? Colors.black.withValues(alpha: 0.4)
        //         : Colors.black.withValues(alpha: 0.05),
        //     blurRadius: 10,
        //     offset: const Offset(0, 3),
        //   ),
        // ],
      ),
      child: Row(
        children: [
          _RoundIconAction(
            theme: theme,
            icon: Icons.arrow_back,
            onPressed: onBack,
          ),
          const SizedBox(width: 10),

          Stack(
            clipBehavior: Clip.none,
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: colorScheme.primary.withValues(alpha: 0.12),
                backgroundImage: driverPhotoUrl != null
                    ? NetworkImage(driverPhotoUrl!)
                    : null,
                child: driverPhotoUrl == null
                    ? Text(
                        (driverName != null && driverName!.isNotEmpty)
                            ? driverName![0].toUpperCase()
                            : '?',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: colorScheme.primary,
                        ),
                      )
                    : null,
              ),
              Positioned(
                right: -1,
                bottom: -1,
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: isOnline
                        ? const Color(0xFF22C55E)
                        : colorScheme.onSurface.withValues(alpha: 0.3),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isDark ? const Color(0xFF161616) : Colors.white,
                      width: 2,
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  driverName ?? 'Driver',
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  driverPhone ?? (isOnline ? 'Online' : 'Offline'),
                  style: TextStyle(
                    fontSize: 12,
                    color: colorScheme.onSurface.withValues(alpha: 0.55),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),
          _RoundIconAction(
            theme: theme,
            icon: Icons.call,
            onPressed: onCall,
            background: colorScheme.primary.withValues(alpha: 0.12),
          ),
        ],
      ),
    );
  }
}

// ==================================================================
// CHAT BUBBLE
// ==================================================================

class _ChatBubble extends StatelessWidget {
  final ThemeData theme;
  final bool isDark;
  final bool isMe;
  final String content;

  const _ChatBubble({
    required this.theme,
    required this.isDark,
    required this.isMe,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = theme.colorScheme;

    final bubbleColor = isMe
        ? colorScheme.primary
        : (isDark ? const Color(0xFF1E1E1E) : Colors.white);

    final textColor = isMe
        ? colorScheme.onPrimary
        : colorScheme.onSurface.withValues(alpha: 0.9);

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          color: bubbleColor,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isMe ? 16 : 4),
            bottomRight: Radius.circular(isMe ? 4 : 16),
          ),
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? Colors.black.withValues(alpha: 0.3)
                  : Colors.black.withValues(alpha: 0.05),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          content,
          style: TextStyle(fontSize: 15, color: textColor, height: 1.3),
        ),
      ),
    );
  }
}

// ==================================================================
// INPUT BAR
// ==================================================================

class _ChatInputBar extends StatelessWidget {
  final ThemeData theme;
  final bool isDark;
  final TextEditingController controller;
  final bool hasText;
  final VoidCallback onSend;

  const _ChatInputBar({
    required this.theme,
    required this.isDark,
    required this.controller,
    required this.hasText,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = theme.colorScheme;

    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF161616) : Colors.white,
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? Colors.black.withValues(alpha: 0.4)
                  : Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                minLines: 1,
                maxLines: 5,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => onSend(),
                style: TextStyle(fontSize: 15, color: colorScheme.onSurface),
                decoration: InputDecoration(
                  hintText: 'Type a message…',
                  hintStyle: TextStyle(
                    color: colorScheme.onSurface.withValues(alpha: 0.4),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 12,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: colorScheme.onSurface.withValues(alpha: 0.05),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Material(
              color: hasText
                  ? colorScheme.primary
                  : colorScheme.onSurface.withValues(alpha: 0.08),
              shape: const CircleBorder(),
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: hasText ? onSend : null,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Icon(
                    Icons.arrow_upward_rounded,
                    size: 20,
                    color: hasText
                        ? colorScheme.onPrimary
                        : colorScheme.onSurface.withValues(alpha: 0.35),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==================================================================
// EMPTY STATE
// ==================================================================

class _EmptyState extends StatelessWidget {
  final ThemeData theme;
  final IconData icon;
  final String title;
  final String subtitle;

  const _EmptyState({
    required this.theme,
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = theme.colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 40,
              color: colorScheme.onSurface.withValues(alpha: 0.25),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: colorScheme.onSurface.withValues(alpha: 0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==================================================================
// SHARED HELPERS
// ==================================================================

// ignore: non_constant_identifier_names
Widget _RoundIconAction({
  required ThemeData theme,
  required IconData icon,
  required VoidCallback onPressed,
  Color? background,
}) {
  final colorScheme = theme.colorScheme;

  return Material(
    color: background ?? colorScheme.onSurface.withValues(alpha: 0.06),
    shape: const CircleBorder(),
    child: InkWell(
      customBorder: const CircleBorder(),
      onTap: onPressed,
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Icon(icon, size: 20, color: colorScheme.onSurface),
      ),
    ),
  );
}
