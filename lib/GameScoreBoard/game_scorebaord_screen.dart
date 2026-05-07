import 'dart:async';

import 'package:flutter/material.dart';
import 'package:game_score_board/GameScoreBoard/game_scoreboard_service.dart';
import 'package:game_score_board/Helpers/session_provider.dart';
import 'package:game_score_board/UpdateScoreBoard/update_scoreboard_screen.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';

class GameScorebaordScreen extends StatefulWidget {
  const GameScorebaordScreen({super.key});

  @override
  State<StatefulWidget> createState() => _GameScorebaordScreen();
}

class _GameScorebaordScreen extends State<GameScorebaordScreen> {
  int seconds = 0;

  Timer? timer;

  late DateTime startTime;

  @override
  void initState() {
    super.initState();
    startTime = DateTime.now();
    timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() {
        seconds = DateTime.now().difference(startTime).inSeconds;
      });
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  String formatTime(int totalSeconds) {
    final m = (totalSeconds % 3600) ~/ 60;
    final s = totalSeconds % 60;
    return "${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE9D8A6),
      body: SafeArea(
        // ✅ FIX 1
        child: Consumer<GameScoreboardService>(
          builder: (context, service, child) {
            final players = [...service.gameBoard];
            players.sort((a, b) => a.score.compareTo(b.score));

            return Padding(
              padding: const EdgeInsets.fromLTRB(
                16,
                12,
                16,
                16,
              ), // ✅ better top spacing
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// 🎮 HEADER (structured)
                  /// 🎮 HEADER
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      /// Row 1: Title + Timer
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "🎲 Scoreboard",
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF001219),
                            ),
                          ),

                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.qr_code_2),
                                color: const Color(0xFF0A9396),
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (_) => qrDialog(context),
                                  );
                                },
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF0A9396),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  formatTime(seconds),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),

                      const SizedBox(height: 10),

                      /// Row 2: Players + Actions
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          /// 👥 Players count
                          Text(
                            "${players.length} Players",
                            style: const TextStyle(color: Color(0xFF005F73)),
                          ),

                          /// ⚡ Actions cluster
                          TextButton(
                            onPressed: () {
                              onEndSessionPressed(context, service);
                            },
                            child: const Text(
                              "End Game",
                              style: TextStyle(
                                color: Color(0xFFBB3E03),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  /// 🏆 LIST
                  Expanded(
                    child: ListView.builder(
                      physics: const BouncingScrollPhysics(), // feels better
                      itemCount: players.length,
                      itemBuilder: (context, index) {
                        final p = players[index];
                        return playerCard(
                          id: p.id,
                          name: p.name,
                          score: p.score,
                          isLeader: index == 0,
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget qrDialog(BuildContext context) {
    final sessionId = context.read<SessionProvider>().sessionId ?? "unknown";
    // final sessionId = context.select<SessionProvider, String>().sessionId ?? "unknown";

    return AlertDialog(
      backgroundColor: const Color(0xFFFFF8E7),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text(
        "Share Game",
        style: TextStyle(color: Color(0xFF001219), fontWeight: FontWeight.bold),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          /// 📦 REAL QR CODE
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: SizedBox(
              width: 180,
              height: 180,
              child: QrImageView(
                data: sessionId, // 👈 THIS is your QR content
                version: QrVersions.auto,
                size: 180,
                backgroundColor: Colors.white,
              ),
            ),
          ),

          const SizedBox(height: 12),

          /// Session ID text
          Text(
            "Session: $sessionId",
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12, color: Color(0xFF005F73)),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Close"),
        ),
      ],
    );
  }

  Widget playerCard({
    required String id,
    required String name,
    required int score,
    required bool isLeader,
  }) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) =>
                UpdateScoreboardScreen(id: id, name: name, score: score),
          ),
        );
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isLeader
              ? const Color(0xFFEE9B00) // Golden Orange
              : const Color(0xFF94D2BD), // Card color
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            /// 👑 Leader Badge
            if (isLeader)
              const Padding(
                padding: EdgeInsets.only(right: 8),
                child: Text("👑", style: TextStyle(fontSize: 22)),
              ),

            /// 🎭 Avatar
            CircleAvatar(
              backgroundColor: const Color(0xFF0A9396),
              child: Text(name[0].toUpperCase()),
            ),

            const SizedBox(width: 12),

            /// 🧑 Name
            Expanded(
              child: Text(
                name,
                style: const TextStyle(fontSize: 18, color: Color(0xFF001219)),
              ),
            ),

            /// 🔢 Score
            Text(
              "$score",
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Color(0xFF001219),
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool onEndSessionPressed(
    BuildContext context,
    GameScoreboardService gameScoreboardService,
  ) {
    bool isEndConfirmed = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (showDialogContext) {
        // if (sessionId == null) {
        //   Navigator.pop(showDialogContext);
        // }
        return AlertDialog(
          backgroundColor: const Color(0xFF1E1E1E),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: const [
              Icon(Icons.warning_amber_rounded, color: Colors.red),
              SizedBox(width: 10),
              Text("End Game?", style: TextStyle(color: Colors.white)),
            ],
          ),
          content: const Text(
            "This will end the game session.\n\n"
            "• Players will be disconnected\n"
            "• This action cannot be undone",
            style: TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(showDialogContext),
              child: const Text("Cancel"),
            ),

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                gameScoreboardService.endGame();

                isEndConfirmed = true;

                Navigator.pop(showDialogContext);
              },
              child: const Text("End Game"),
            ),
          ],
        );
      },
    );
    return isEndConfirmed;
  }
}
