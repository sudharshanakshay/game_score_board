import 'package:flutter/foundation.dart';
import 'package:game_score_board/Helpers/hostid_service.dart';
import 'package:game_score_board/Helpers/session_provider.dart';
import 'package:game_score_board/Socket/socket_service.dart';

class UpdateScoreboardService extends ChangeNotifier {
  SocketService socketService = SocketService();
  SessionProvider sessionProvider;

  UpdateScoreboardService(this.sessionProvider);

  Future<void> update({
    required String playerId,
    required int newPlayerScore,
  }) async {
    String hostId = await HostIdService.getHostId();

    if (sessionProvider.sessionId != null) {
      socketService.socket.emitWithAck(
        'update-score',
        {
          'sessionId': sessionProvider.sessionId,
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
