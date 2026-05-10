import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:game_score_board/Helpers/constants.dart';
import 'package:game_score_board/Helpers/session_provider.dart';
import 'package:game_score_board/Helpers/socket_service.dart';
import 'package:game_score_board/main.dart';
import 'package:provider/provider.dart';

class ScanToConnectService extends ChangeNotifier {
  Future<bool> validateSession(String scannedSessionId) async {
    final completer = Completer<bool>();

    SocketService().socket.emitWithAck(
      'validate-session',
      {'sessionId': scannedSessionId},
      ack: (response) {
        bool successStatus = response[Constants.SUCCESSKEY];

        if (successStatus) {
          navigatorKey.currentContext!.read<SessionProvider>().setSession(
            scannedSessionId,
          );
        }

        if (response != null && response['valid']) {
        } else {
          navigatorKey.currentContext!.read<SessionProvider>().setNull();
        }

        completer.complete(response['valid']);
      },
    );

    return completer.future;
  }
}
