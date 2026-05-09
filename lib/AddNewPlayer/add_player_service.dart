import 'dart:async';

import 'package:flutter/foundation.dart';
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

  Future<void> startGame() async {
    String hostId = await HostIdService.getHostId();

    SocketService().socket.emitWithAck(
      'create-session',
      {'hostId': hostId, 'playerNames': playerNames},
      ack: (response) {
        if (kDebugMode) {
          print('Session created: $response');
        }

        navigatorKey.currentContext!.read<SessionProvider>().setSession(
          response['sessionId'],
        );

        notifyListeners();

        // completer.complete(response['sessionId']);
      },
    );

    // return completer.future;
  }
}
