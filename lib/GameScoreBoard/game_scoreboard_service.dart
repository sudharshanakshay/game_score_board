import 'package:flutter/foundation.dart';
import 'package:game_score_board/Helpers/hostid_service.dart';
import 'package:game_score_board/Helpers/session_provider.dart';
import 'package:game_score_board/Socket/socket_service.dart';

class PlayerDetail {
  String id;
  String name;
  int score;

  PlayerDetail({required this.id, required this.name, required this.score});
}

class GameScoreboardService extends ChangeNotifier {
  List<PlayerDetail> gameBoard = [];

  final SessionProvider sessionProvider;

  SocketService socketService = SocketService();


  GameScoreboardService(this.sessionProvider) {
    
    _onSessionChanged();
    listenToScoreUpdates();
  }

  void _onSessionChanged() {
    if (sessionProvider.sessionId == null) {
      if (kDebugMode) {
        print("Session refreshed / cleared");
      }
    } else {
      if (kDebugMode) {
        print("Session updated: ${sessionProvider.sessionId}");
      }
      socketService.socket.emitWithAck(
        'join-session',
        {'sessionId': sessionProvider.sessionId},
        ack: (response) {
          if (kDebugMode) {
            print('Score updated: $response');
          }

          List? scoreBaord = response['scoreBoard'];

          if (scoreBaord != null) {
            for (var playerDetail in scoreBaord) {
             
              gameBoard.add(
                PlayerDetail(
                  id: playerDetail['id'],
                  name: playerDetail['name'],
                  score: playerDetail['score'],
                ),
              );
              notifyListeners();
            }
          }
        },
      );
    }

    notifyListeners(); // if YOUR service UI depends on it
  }

  Future<void> listenToScoreUpdates() async {
    socketService.socket.on('score-update', (response) {
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

    String hostId = await HostIdService.getHostId();


    if (sessionProvider.sessionId == null) {
    } else {
      socketService.socket.emitWithAck(
        'end-session',
        {'sessionId': sessionProvider.sessionId, 'hostId': hostId},
        ack: (response) {
          if (kDebugMode) {
            print(response);
          }
          notifyListeners();
        },
      );
    }
  }
}
