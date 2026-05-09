import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:game_score_board/Helpers/session_provider.dart';
import 'package:game_score_board/Socket/socket_service.dart';
import 'package:game_score_board/main.dart';
import 'package:provider/provider.dart';

class ScanToConnectService extends ChangeNotifier {
  Future<bool> validateSession(String scannedSessionId) async {
    SocketService socketService = SocketService();

    final completer = Completer<bool>();

    socketService.socket.emitWithAck(
      'validate-session',
      {'sessionId' : scannedSessionId},
      ack: (response) {
        if ( response != null && response['valid']) {
          navigatorKey.currentContext!.read<SessionProvider>().setSession(
            scannedSessionId,
          );
        } else {
          navigatorKey.currentContext!.read<SessionProvider>().setNull();
        }

        completer.complete(response['valid']);
      },
    );

    return completer.future;
  }
}
