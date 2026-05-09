import 'package:flutter/material.dart';
import 'package:game_score_board/AddNewPlayer/add_player_service.dart';
import 'package:game_score_board/GameScoreBoard/game_scoreboard_service.dart';
import 'package:game_score_board/Helpers/session_provider.dart';
import 'package:game_score_board/HomePage/home_screen.dart';
import 'package:game_score_board/ScanToConnect/scan_to_connect_service.dart';
import 'package:game_score_board/Socket/socket_service.dart';
import 'package:game_score_board/UpdateScoreBoard/update_scoreboard_service.dart';
import 'package:provider/provider.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  await SocketService().init();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SessionProvider()),
        ChangeNotifierProvider(create: (_) => AddPlayerService()),
        ChangeNotifierProxyProvider<SessionProvider, UpdateScoreboardService>(
          create: (_) => UpdateScoreboardService(SessionProvider()),
          update: (_, sessionProvider, previous) =>
              UpdateScoreboardService(sessionProvider),
        ),
        ChangeNotifierProvider(create: (_) => GameScoreboardService()),
        ChangeNotifierProvider(create: (_) => ScanToConnectService()),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      title: 'Flutter Demo',
      theme: ThemeData(colorScheme: .fromSeed(seedColor: Colors.deepPurple)),
      home: const HomeScreen(),
    );
  }
}
