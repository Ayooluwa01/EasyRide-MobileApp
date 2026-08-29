import 'dart:developer';

import 'package:socket_io_client/socket_io_client.dart' as io;

class Websocket {
  Websocket._internal();
  static final Websocket _instance = Websocket._internal();
  factory Websocket() => _instance;

  io.Socket? _socket;
  String? _accessToken;

  bool get isConnected => _socket?.connected ?? false;
  io.Socket get socket {
    final socket = _socket;
    if (socket == null) {
      throw StateError('Websocket has not been initialized. ');
    }
    return socket;
  }

  void initialize(String accessToken) {
    if (accessToken.isEmpty) {
      throw ArgumentError('Access token cannot be empty');
    }
    // Already initialized with the same token.
    if (_socket != null && _accessToken == accessToken) {
      return;
    }
    // Token changed.
    if (_socket != null && _accessToken != accessToken) {
      updateToken(accessToken);
      return;
    }

    _accessToken = accessToken;

    _socket = io.io(
      'http://127.0.0.1:3000',
      io.OptionBuilder()
          .setTransports(['websocket'])
          .setAuth({'token': accessToken})
          .enableReconnection()
          .setReconnectionAttempts(10)
          .setReconnectionDelay(1000)
          .setReconnectionDelayMax(5000)
          .setTimeout(10000)
          .disableAutoConnect()
          .build(),
    );

    _registerListeners();

    _socket!.connect();
  }

  void _registerListeners() {
    final socket = _socket!;

    socket.onConnect((_) {
      log('🟢 WebSocket connected');
    });

    socket.onDisconnect((reason) {
      log('🔴 WebSocket disconnected: $reason');
    });

    socket.onConnectError((error) {
      log('❌ WebSocket connection error: $error');
    });

    socket.onReconnectAttempt((attempt) {
      log('🔄 WebSocket reconnect attempt: $attempt');
    });

    socket.onReconnect((attempt) {
      log('🟢 WebSocket reconnected after $attempt attempts');
    });

    socket.onReconnectError((error) {
      log('❌ WebSocket reconnect error: $error');
    });

    socket.onReconnectFailed((_) {
      log('❌ WebSocket reconnection failed');
    });
  }

  void updateToken(String accessToken) {
    if (accessToken.isEmpty) {
      return;
    }
    _accessToken = accessToken;
    final socket = _socket;
    if (socket == null) {
      initialize(accessToken);
      return;
    }

    socket.auth = {'token': accessToken};
    if (socket.connected) {
      socket.disconnect();
    }

    socket.connect();
  }

  void emit(String event, [dynamic data]) {
    socket.emit(event, data);
  }

  void on(String event, Function(dynamic) callback) {
    socket.on(event, callback);
  }

  void off(String event, [Function(dynamic)? callback]) {
    socket.off(event, callback);
  }

  void disconnect() {
    _socket?.disconnect();
  }

  void dispose() {
    _socket?.dispose();
    _socket = null;
    _accessToken = null;
  }
}
