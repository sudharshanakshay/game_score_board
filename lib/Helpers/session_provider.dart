import 'package:flutter/foundation.dart';
import 'package:game_score_board/Helpers/constants.dart';
import 'package:game_score_board/Helpers/hostid_service.dart';
import 'package:game_score_board/Helpers/socket_service.dart';
import 'package:game_score_board/main.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SessionProvider with ChangeNotifier {
  String? _sessionId;
  bool loading = false;
  bool _gameHost = false;

  bool get isGameHost => _gameHost;

  String? get sessionId => _sessionId;

  SocketService socketService = SocketService();

  late VoidCallback _reconnectHandler;

  @override
  void dispose() {
    socketService.socket.off('session-ended');
    super.dispose();
  }

  SessionProvider() {
    _reconnectHandler = () {
      populateIsGameHost();
      fetchLastSession();
      listenForSessionEnd();
    };

    _reconnectHandler();

    SocketService().addReconnectListerners(_reconnectHandler);
  }

  SessionProvider sessionProvider() {
    return navigatorKey.currentContext!.read<SessionProvider>();
  }

  void setNull() {
    _sessionId = null;
    _gameHost = false;
    notifyListeners();
  }

  Future<void> setSession(String id) async {
    _sessionId = id;
    _gameHost = false;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('_gameHost', false);
  }

  Future<void> setSessionCreatedByHost(String id) async {
    _sessionId = id;
    _gameHost = true;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('_gameHost', true);
  }

  Future<void> populateIsGameHost() async {
    final prefs = await SharedPreferences.getInstance();
    _gameHost = prefs.getBool('_gameHost') ?? false;
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
          bool successStatus = response[Constants.SUCCESSKEY];

          if (successStatus) {
            Map<String, String> data = Map.from(response[Constants.DATAKEY]);
            _sessionId = data[Constants.SESSIONIDKEY];
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
