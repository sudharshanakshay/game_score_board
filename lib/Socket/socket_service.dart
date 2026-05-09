import 'package:flutter/foundation.dart';
import 'package:game_score_board/Socket/config.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketService {
  SocketService._internal();
  static final SocketService _instance = SocketService._internal();

  factory SocketService() {
    return _instance;
  }

  late IO.Socket socket;

  bool _isConnected = false;
  bool _isConnecting = false;

  VoidCallback? onReconnect;

  Future<void> init() async {
    if (_isConnected || _isConnecting) return;

    _isConnecting = true;

    socket = IO.io(
      Config.uri,
      IO.OptionBuilder().setTransports(['websocket']).build(),
    );

    socket.connect();

    socket.onConnect((_) {
      _isConnected = true;
      _isConnecting = false;
      if (kDebugMode) {
        print('Connected: ${socket.id}');
      }

      onReconnect?.call();
    });

    socket.onDisconnect((_) {
      _isConnected = false;
      if (kDebugMode) {
        print('Disconnected');
      }
    });

    socket.onReconnect((_) {
      if (kDebugMode) {
        print('Socket reconnected');
      }

      onReconnect?.call();
    });
  }
}
