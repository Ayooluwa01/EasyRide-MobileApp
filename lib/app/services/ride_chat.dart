import 'dart:async';

import 'package:easy_ride/app/api/client.dart';
import 'package:easy_ride/app/models/ride_message_model.dart';
import 'package:easy_ride/app/services/websocket.dart';
import 'package:easy_ride/core/socket/socket_events.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final rideChatProvider =
    AsyncNotifierProvider<RideChat, List<RideMessageModel>>(RideChat.new);

class RideChat extends AsyncNotifier<List<RideMessageModel>> {
  late final Websocket _socket;

  @override
  FutureOr<List<RideMessageModel>> build() {
    _socket = ref.read(websocketProvider);
    _socket.on(SocketEvents.messageNew, _onMessage);
    ref.onDispose(() {
      _socket.off(SocketEvents.messageNew, _onMessage);
    });

    return [];
  }

  // ============================================================
  // GET RIDE CHAT HISTORY
  // ============================================================

  Future<List<RideMessageModel>> getRideChat(String rideId) async {
    final apiClient = ref.read(apiClientProvider);

    try {
      final response = await apiClient.get('/chat/$rideId');
      final responseData = response.data as Map<String, dynamic>;
      final data = responseData['data'] as Map<String, dynamic>;
      final messagesJson = data['messages'] as List<dynamic>;
      final messages = messagesJson
          .map(
            (message) => RideMessageModel.fromJson(
              Map<String, dynamic>.from(message as Map),
            ),
          )
          .toList();

      state = AsyncData(messages);

      return messages;
    } catch (e, stackTrace) {
      state = AsyncError(e, stackTrace);
      rethrow;
    }
  }

  // ============================================================
  // SEND MESSAGE
  // ============================================================

  Future<RideMessageModel> sendMessage({
    required String rideId,
    required String content,
  }) async {
    final apiClient = ref.read(apiClientProvider);
    try {
      final trimmedContent = content.trim();
      if (trimmedContent.isEmpty) {
        throw Exception('Message cannot be empty');
      }
      final response = await apiClient.post(
        '/chat/$rideId',
        data: {'content': trimmedContent},
      );

      final responseData = response.data as Map<String, dynamic>;
      final messageJson = responseData['data'] as Map<String, dynamic>;
      final message = RideMessageModel.fromJson(messageJson);
      final currentMessages = state.valueOrNull ?? [];
      final alreadyExists = currentMessages.any(
        (item) => item.id == message.id,
      );
      if (!alreadyExists) {
        state = AsyncData([...currentMessages, message]);
      }

      return message;
    } catch (e, stackTrace) {
      state = AsyncError(e, stackTrace);
      rethrow;
    }
  }

  // ============================================================
  // WEBSOCKET:
  // ============================================================

  void _onMessage(dynamic payload) {
    try {
      if (payload == null) {
        return;
      }

      final Map<String, dynamic> json;
      if (payload is Map<String, dynamic>) {
        json = payload;
      } else if (payload is Map) {
        json = Map<String, dynamic>.from(payload);
      } else {
        throw Exception(
          'Invalid WebSocket message payload: '
          '${payload.runtimeType}',
        );
      }

      final message = RideMessageModel.fromJson(json);
      final currentMessages = state.valueOrNull ?? [];

      // ----------------------------------------------------------
      // Prevent duplicate message
      // ----------------------------------------------------------

      final alreadyExists = currentMessages.any(
        (item) => item.id == message.id,
      );
      if (alreadyExists) {
        return;
      }

      // ----------------------------------------------------------
      // Add WebSocket message
      // ----------------------------------------------------------

      state = AsyncData([...currentMessages, message]);
    } catch (e) {}
  }

  // ============================================================
  // CLEAR CHAT
  // ============================================================

  void clearMessages() {
    state = const AsyncData([]);
  }
}
