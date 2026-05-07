import 'package:flutter/foundation.dart';
import 'package:game_score_board/Helpers/hostid_service.dart';
import 'package:game_score_board/Socket/socket_service.dart';
import 'package:game_score_board/main.dart';
import 'package:provider/provider.dart';

class SessionProvider with ChangeNotifier {
  String? _sessionId;
  bool loading = false;

  String? get sessionId => _sessionId;

  SocketService socketService = SocketService();

  SessionProvider() {
    fetchLastSession();
    listenForSessionEnd();
  }

  SessionProvider sessionProvider() {
    return navigatorKey.currentContext!.read<SessionProvider>();
  }

  // void

  void setNull() {
    _sessionId = null;
    notifyListeners();
  }

  void setSession(String id) {
    _sessionId = id;
    notifyListeners();
  }

  Future<void> fetchLastSession() async {
    loading = true;
    String hostId = await HostIdService.getHostId();

    try {
      socketService.socket.emitWithAck(
        'fetch-session',
        {'hostId': hostId},
        ack: (response) {
          if (response["found"] == true) {
            _sessionId = response["sessionId"];
          }
        },
      );
    } catch (err) {
      if (kDebugMode) {
        print(err);
      }
    }

    loading = false;
    notifyListeners();
  }

  Future<void> listenForSessionEnd() async {
    socketService.socket.on('session-ended', (response) {
      if (response) {
        setNull();
        notifyListeners();
      }
    });
  }
}
