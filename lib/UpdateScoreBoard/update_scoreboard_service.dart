import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:game_score_board/Helpers/constants.dart';
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

  Future<Map<String, dynamic>> update({
    required String playerId,
    required int currentPlayerScore,
    required int newPlayerScore,
  }) async {
    String hostId = await HostIdService.getHostId();

    Completer<Map<String, dynamic>> completer = Completer();
    Map<String, dynamic> completerMsg;

    if (currentPlayerScore == newPlayerScore) {
      completerMsg = {Constants.SUCCESSKEY: true};
      completer.complete(completerMsg);
    }

    if (sessionId != null) {
      try {
        SocketService().socket.emitWithAck(
          'update-score',
          {
            'sessionId': sessionId,
            'hostId': hostId,
            'playerId': playerId,
            'playerScore': newPlayerScore,
          },
          ack: (response) {
            bool successStatus = response[Constants.SUCCESSKEY];

            if (successStatus) {
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
