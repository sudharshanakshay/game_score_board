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

  Future<Map<String, dynamic>> addOrRemovePlayers(
    List<String> playerNames,
  ) async {
    String? sessionId = navigatorKey.currentContext!
        .read<SessionProvider>()
        .sessionId;
    String hostId = await HostIdService.getHostId();

    Completer<Map<String, dynamic>> completer = Completer();
    Map<String, dynamic> completerMsg;

    final List<String> removedPlayerIds = gameBoard.entries
        .where((entry) => playerNames.contains(entry.value.name))
        .map((entry) => entry.key)
        .toList();

    final List<String> existingNames = gameBoard.entries
        .map((player) => player.value.name)
        .toList();

    final List<String> newPlayers = playerNames
        .where((playerNames) => !existingNames.contains(playerNames))
        .toList();

    try {
      SocketService().socket.emitWithAck(
        'edit-players',
        ({
          "sessionId": sessionId,
          "hostId": hostId,
          "playerIdsToRemove": removedPlayerIds,
          "playerIdsToAdd": newPlayers,
        }),
        ack: (response) {
          bool successStatus = response[Constants.SUCCESSKEY];
          if (successStatus) {
            completerMsg = {Constants.SUCCESSKEY: successStatus};

            completer.complete(completerMsg);
          } else {
            String errMsg = response[Constants.errorKey][Constants.codeKey];

            if (response[Constants.errorKey][Constants.codeKey] ==
                Constants.codeValueUnauthorised) {
              errMsg = "Only the host may edit players.";
            }

            if (response[Constants.errorKey][Constants.codeKey] ==
                Constants.codeValueSessionNotFound) {
              errMsg =
                  "Game Ended, It may have expired or been ended by the host.";
            }

            completerMsg = {
              Constants.SUCCESSKEY: successStatus,
              Constants.MESSAGEKEY: errMsg,
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

    return completer.future;
  }

  Future<Map<String, dynamic>> resetGame() async {
    bool isJoinedAsHost = navigatorKey.currentContext!
        .read<SessionProvider>()
        .isGameHost;

    Completer<Map<String, dynamic>> completer = Completer();
    Map<String, dynamic> completerMsg;

    if (isJoinedAsHost) {
      String hostId = await HostIdService.getHostId();
      String? sessionId = navigatorKey.currentContext!
          .read<SessionProvider>()
          .sessionId;

      if (sessionId != null) {
        SocketService().socket.emitWithAck(
          'reset-session',
          {'hostId': hostId, 'sessionId': sessionId},
          ack: (response) {
            bool successStatus = response[Constants.SUCCESSKEY];

            if (successStatus) {
              completerMsg = {Constants.SUCCESSKEY: successStatus};
              completer.complete(completerMsg);
            } else {
              String errMsg = response[Constants.errorKey][Constants.codeKey];

              if (response[Constants.errorKey][Constants.codeKey] ==
                  Constants.codeValueUnauthorised) {
                errMsg = "Only the host may Reset Game.";
              }

              if (response[Constants.errorKey][Constants.codeKey] ==
                  Constants.codeValueSessionNotFound) {
                errMsg =
                    "Game Ended, It may have expired or been ended by the host.";
              }

              completerMsg = {
                Constants.SUCCESSKEY: successStatus,
                Constants.MESSAGEKEY: errMsg,
              };
              completer.complete(completerMsg);
            }
          },
        );
      } else {
        completerMsg = {
          Constants.SUCCESSKEY: false,
          Constants.MESSAGEKEY: Constants.internalErrorSessionNull,
        };
        completer.complete(completerMsg);
      }
    } else {
      String errMsg = "Only Host may Reset Game.";

      completerMsg = {
        Constants.SUCCESSKEY: false,
        Constants.MESSAGEKEY: errMsg,
      };
      completer.complete(completerMsg);
    }

    return completer.future;
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
