import 'dart:developer' as developer;

import 'package:easy_ride/app/api/client.dart';
import 'package:easy_ride/app/models/chat_list_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final chatListProvider = AsyncNotifierProvider<ChatList, ChatListModel>(
  ChatList.new,
);

class ChatList extends AsyncNotifier<ChatListModel> {
  @override
  Future<ChatListModel> build() async {
    return getChatHistory();
  }

  Future<ChatListModel> getChatHistory() async {
    final apiClient = ref.read(apiClientProvider);
    state = const AsyncLoading();

    try {
      final response = await apiClient.get('/chat/me');

      developer.log('CHAT LIST ${response.data}', name: 'ChatList');

      final chatList = ChatListModel.fromJson(response.data);

      state = AsyncData(chatList);

      return chatList;
    } catch (e, stackTrace) {
      state = AsyncError(e, stackTrace);
      rethrow;
    }
  }
}
