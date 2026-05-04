import 'package:flutter/material.dart';
import 'package:game_score_board/Socket/socket_service.dart';
import 'package:game_score_board/main.dart';
import 'package:provider/provider.dart';

class SessionProvider with ChangeNotifier {
  String? _sessionId;

  String? get sessionId => _sessionId;

  SocketService socketService = SocketService();

  SessionProvider() {
    listenForSessionEnd();
  }

  SessionProvider sessionProvider() {
    return navigatorKey.currentContext!.read<SessionProvider>();
  }

  void _setNull() {
    _sessionId = null;
    notifyListeners();
  }

  void setSession(String id) {
    _sessionId = id;
    notifyListeners();
  }

  Future<void> listenForSessionEnd() async {
    socketService.socket.on('session-ended', (response) {
      if (response) {
        _setNull();
        notifyListeners();
      }
    });
  }
}
