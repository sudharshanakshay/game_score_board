import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:game_score_board/Helpers/constants.dart';
import 'package:game_score_board/Helpers/hostid_service.dart';
import 'package:game_score_board/Helpers/session_provider.dart';
import 'package:game_score_board/Helpers/socket_service.dart';
import 'package:game_score_board/main.dart';
import 'package:provider/provider.dart';

class AddPlayerService extends ChangeNotifier {
  List<String> playerNames = [];

  bool addPlayer(String name) {
    String cleaned = capitalize(name);

    if (!playerNames.any((player) => player == cleaned)) {
      playerNames.add(cleaned);
      notifyListeners();
      return false;
    } else {
      return true;
    }
  }

  void removePlayer(String name) {
    playerNames.remove(name);
    notifyListeners();
  }

  String capitalize(String text) {
    text = text.trim();
    if (text.isEmpty) return text;

    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }

  Future<Map<String, dynamic>> startGame() async {
    String hostId = await HostIdService.getHostId();

    Completer<Map<String, dynamic>> completer = Completer();

    Map<String, dynamic> completerMsg;

    try {
      SocketService().socket.emitWithAck(
        'create-session',
        {'hostId': hostId, 'playerNames': playerNames},
        ack: (response) {
          bool successStatus = response[Constants.SUCCESSKEY];

          if (successStatus) {
            String sessionId =
                response[Constants.DATAKEY][Constants.SESSIONIDKEY];
            navigatorKey.currentContext!.read<SessionProvider>().setSession(
              sessionId,
            );
            notifyListeners();

            completerMsg = {Constants.SUCCESSKEY: successStatus};
          } else {
            if (kDebugMode) {
              print(response[Constants.errorKey]);
            }

            completerMsg = {
              Constants.SUCCESSKEY: successStatus,
              Constants.MESSAGEKEY:
                  response[Constants.errorKey][Constants.MESSAGEKEY],
            };
          }

          completer.complete(completerMsg);
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
}
