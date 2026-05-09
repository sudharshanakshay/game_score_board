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

  @override
  void dispose() {
    socketService.socket.off('session-ended');
    super.dispose();
  }

  SessionProvider() {
    fetchLastSession();
    listenForSessionEnd();

    socketService.onReconnect = () {
      fetchLastSession();
      listenForSessionEnd();
    };
  }

  SessionProvider sessionProvider() {
    return navigatorKey.currentContext!.read<SessionProvider>();
  }

  void setNull() {
    _sessionId = null;
    notifyListeners();
  }

  void setSession(String id) {
    _sessionId = id;
    notifyListeners();
  }

  Future<void> fetchLastSession() async {
    if (_sessionId != null) return;
    loading = true;
    String hostId = await HostIdService.getHostId();

    try {
      socketService.socket.emitWithAck(
        'fetch-session',
        {'hostId': hostId},
        ack: (response) {
          if (response["found"] == true) {
            _sessionId = response["sessionId"];
            loading = false;
            notifyListeners();
          } else {
            setNull();
            loading = false;
            notifyListeners();
          }
        },
      );
    } catch (err) {
      if (kDebugMode) {
        print(err);
        loading = false;
        notifyListeners();
      }
    }
  }

  Future<void> listenForSessionEnd() async {
    socketService.socket.off('session-ended');

    socketService.socket.on('session-ended', (response) {
      if (response) {
        setNull();
        notifyListeners();
      }
    });
  }
}
