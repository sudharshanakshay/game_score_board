import 'package:flutter/foundation.dart';
import 'package:game_score_board/Helpers/hostid_service.dart';
import 'package:game_score_board/Helpers/session_provider.dart';
import 'package:game_score_board/Helpers/socket_service.dart';
import 'package:game_score_board/main.dart';
import 'package:provider/provider.dart';

class UpdateScoreboardService extends ChangeNotifier {
  String? sessionId;

  late VoidCallback _reconnectHadler;

  void init() {
    sessionId = navigatorKey.currentContext!.read<SessionProvider>().sessionId;

    _reconnectHadler = () {
      sessionId = navigatorKey.currentContext!
          .read<SessionProvider>()
          .sessionId;
    };

    SocketService().addReconnectListerners(_reconnectHadler);
  }

  Future<void> update({
    required String playerId,
    required int newPlayerScore,
  }) async {
    String hostId = await HostIdService.getHostId();

    if (sessionId != null) {
      SocketService().socket.emitWithAck(
        'update-score',
        {
          'sessionId': sessionId,
          'hostId': hostId,
          'playerId': playerId,
          'playerScore': newPlayerScore,
        },
        ack: (response) {
          if (kDebugMode) {
            print(response);
          }
        },
      );
    }
  }
}
