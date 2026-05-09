import 'package:flutter/foundation.dart';
import 'package:game_score_board/Helpers/config.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketService {
  SocketService._internal();
  static final SocketService _instance = SocketService._internal();

  final List<VoidCallback> _reconnectListerners = [];

  factory SocketService() {
    return _instance;
  }

  late IO.Socket socket;

  bool _isConnected = false;
  bool _isConnecting = false;

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

      _notifyReconnect();
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

      _notifyReconnect();
    });
  }

  void addReconnectListerners(VoidCallback cb) {
    _reconnectListerners.add(cb);
  }

  void removeReconnectListerners(VoidCallback cb) {
    _reconnectListerners.remove(cb);
  }

  void _notifyReconnect() {
    for (final cb in List.from(_reconnectListerners)) {
      cb();
    }
  }
}
