import 'package:flutter/foundation.dart';
import 'package:game_score_board/Helpers/hostid_service.dart';
import 'package:game_score_board/Helpers/session_provider.dart';
import 'package:game_score_board/Helpers/socket_service.dart';
import 'package:game_score_board/main.dart';
import 'package:provider/provider.dart';

class PlayerDetail {
  String id;
  String name;
  int score;
  int updateCount = 0;

  PlayerDetail({required this.id, required this.name, required this.score});
}

class GameScoreboardService extends ChangeNotifier {
  List<PlayerDetail> gameBoard = [];

  late VoidCallback _reconnectHandler;

  @override
  void dispose() {
    SocketService().socket.off('score-update');
    super.dispose();
  }

  void init() {
    joinSession();
    listenToScoreUpdates();

    _reconnectHandler = () {
      joinSession();

      listenToScoreUpdates();
    };

    SocketService().addReconnectListerners(_reconnectHandler);
  }

  void joinSession() {
    String? sessionId = navigatorKey.currentContext!
        .read<SessionProvider>()
        .sessionId;
    if (sessionId == null) {
      if (kDebugMode) {
        print("Session refreshed / cleared");
      }
    } else {
      if (kDebugMode) {
        print("Session updated: $sessionId");
      }
      SocketService().socket.emitWithAck(
        'join-session',
        {'sessionId': sessionId},
        ack: (response) {
          if (kDebugMode) {
            print('Score updated: $response');
          }

          List? scoreBoard = response['scoreBoard'];

          if (scoreBoard != null) {
            gameBoard = scoreBoard.map((playerDetail) {
              return PlayerDetail(
                id: playerDetail['id'],
                name: playerDetail['name'],
                score: playerDetail['score'],
              );
            }).toList();
            notifyListeners();
          }
        },
      );
    }
  }

  void listenToScoreUpdates() {
    SocketService().socket.off('score-update');

    SocketService().socket.on('score-update', (response) {
      List? scoreBoard = response;

      if (scoreBoard == null) return;

      gameBoard = scoreBoard.map((playerDetail) {
        return PlayerDetail(
          id: playerDetail['id'],
          name: playerDetail['name'],
          score: playerDetail['score'],
        );
      }).toList();

      notifyListeners();
    });
  }

  Future<void> endGame() async {
    String? sessionId = navigatorKey.currentContext!
        .read<SessionProvider>()
        .sessionId;
    String hostId = await HostIdService.getHostId();

    if (sessionId != null) {
      try {
        SocketService().socket.emitWithAck(
          'end-session',
          {'sessionId': sessionId, 'hostId': hostId},
          ack: (response) {
            navigatorKey.currentContext!.read<SessionProvider>().setNull();
            gameBoard.clear();
            notifyListeners();
          },
        );
      } catch (err) {
        if (kDebugMode) {
          print(err);
        }
      }
    }
  }
}
