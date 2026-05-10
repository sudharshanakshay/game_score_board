import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:game_score_board/Helpers/constants.dart';
import 'package:game_score_board/Helpers/hostid_service.dart';
import 'package:game_score_board/Helpers/session_provider.dart';
import 'package:game_score_board/Helpers/socket_service.dart';
import 'package:game_score_board/main.dart';
import 'package:provider/provider.dart';

class PlayerDetail {
  String id;
  String name;
  int previousScore;
  int score;

  PlayerDetail({
    required this.id,
    required this.name,
    required this.score,
    this.previousScore = 0,
  });
}

class GameScoreboardService extends ChangeNotifier {
  Map<String, PlayerDetail> gameBoard = {};

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

  Future<Map<String, dynamic>> joinSession() async {
    String? sessionId = navigatorKey.currentContext!
        .read<SessionProvider>()
        .sessionId;

    Completer<Map<String, dynamic>> completer = Completer();
    Map<String, dynamic> completerMsg;

    if (sessionId == null) {
      if (kDebugMode) {
        print("Session refreshed / cleared");
      }

      completerMsg = {
        Constants.SUCCESSKEY: false,
        Constants.MESSAGEKEY: Constants.errorInvalidSessionText,
      };
    } else {
      if (kDebugMode) {
        print("Session updated: $sessionId");
      }
      try {
        SocketService().socket.emitWithAck(
          'join-session',
          {'sessionId': sessionId},
          ack: (response) {
            bool successStatus = response[Constants.SUCCESSKEY];

            if (successStatus) {
              Map<String, dynamic> data = response[Constants.DATAKEY];

              List scoreBoard = data[Constants.SCOREBOARDKEY];

              if (scoreBoard.isNotEmpty) {
                gameBoard = {
                  for (var playerDetail in scoreBoard)
                    playerDetail['id']: PlayerDetail(
                      id: playerDetail['id'],
                      name: playerDetail['name'],
                      score: playerDetail['score'],
                      previousScore: gameBoard[playerDetail['id']] == null
                          ? 0
                          : gameBoard[playerDetail['id']]!.score,
                    ),
                };
                notifyListeners();
              }

              completerMsg = {Constants.SUCCESSKEY: successStatus};
              completer.complete(completerMsg);
            } else {
              completerMsg = {
                Constants.SUCCESSKEY: successStatus,
                Constants.MESSAGEKEY:
                    response[Constants.errorKey][Constants.codeKey],
              };
              completer.complete(completerMsg);
            }
          },
        );
      } catch (err) {
        if (kDebugMode) {
          print(err);
        }

        completerMsg = {
          Constants.SUCCESSKEY: false,
          Constants.MESSAGEKEY: Constants.errorInternalText,
        };
        completer.complete(completerMsg);
      }
    }
    return completer.future;
  }

  Future<void> listenToScoreUpdates() async {
    SocketService().socket.off('score-update');

    SocketService().socket.on('score-update', (response) {
      List? scoreBoard = response;

      if (scoreBoard == null) return;

      gameBoard = {
        for (var playerDetail in scoreBoard)
          playerDetail['id']: PlayerDetail(
            id: playerDetail['id'],
            name: playerDetail['name'],
            score: playerDetail['score'],
            previousScore: gameBoard[playerDetail['id']] == null
                ? 0
                : gameBoard[playerDetail['id']]!.score,
          ),
      };

      notifyListeners();
    });
  }

  Future<Map<String, dynamic>> endGame() async {
    String? sessionId = navigatorKey.currentContext!
        .read<SessionProvider>()
        .sessionId;
    String hostId = await HostIdService.getHostId();

    Completer<Map<String, dynamic>> completer = Completer();
    Map<String, dynamic> completerMsg;

    if (sessionId != null) {
      try {
        SocketService().socket.emitWithAck(
          'end-session',
          {'sessionId': sessionId, 'hostId': hostId},
          ack: (response) {
            bool successStatus = response[Constants.SUCCESSKEY];

            if (successStatus) {
              navigatorKey.currentContext!.read<SessionProvider>().setNull();
              gameBoard.clear();
              notifyListeners();

              completerMsg = {Constants.SUCCESSKEY: successStatus};
              completer.complete(completerMsg);
            } else {
              completerMsg = {
                Constants.SUCCESSKEY: successStatus,
                Constants.MESSAGEKEY:
                    response[Constants.errorKey][Constants.codeKey],
              };
              completer.complete(completerMsg);
            }
          },
        );
      } catch (err) {
        if (kDebugMode) {
          print(err);
        }

        completerMsg = {
          Constants.SUCCESSKEY: false,
          Constants.MESSAGEKEY: Constants.errorInternalText,
        };
        completer.complete(completerMsg);
      }
    } else {
      completerMsg = {
        Constants.SUCCESSKEY: false,
        Constants.MESSAGEKEY: Constants.internalErrorSessionNull,
      };
      completer.complete(completerMsg);
    }

    return completer.future;
  }
}
