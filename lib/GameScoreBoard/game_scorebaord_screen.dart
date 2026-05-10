import 'dart:async';

import 'package:flutter/material.dart';
import 'package:game_score_board/Constants/app_avatar.dart';
import 'package:game_score_board/Constants/app_colors.dart';
import 'package:game_score_board/GameScoreBoard/game_scoreboard_service.dart';
import 'package:game_score_board/Helpers/constants.dart';
import 'package:game_score_board/Helpers/session_provider.dart';
import 'package:game_score_board/Helpers/socket_service.dart';
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

  SocketService socketService = SocketService();

  final Map<String, Map<String, dynamic>> updatedPlayerColors = {};
  final Map<String, Timer> _resetTimers = {};

  // int colorIndex = 0;

  void markPlayerUpdated(String playerId) {
    setState(() {
      // updatedPlayerColors[playerId] = AppColors.lightColors[colorIndex];

      if (updatedPlayerColors[playerId] == null) {
        updatedPlayerColors[playerId] = {};
        updatedPlayerColors[playerId]![Constants.internalColorIndexKey] = 1;
        updatedPlayerColors[playerId]![Constants.internalShowPreviousScoreKey] =
            true;
      } else {
        updatedPlayerColors[playerId]![Constants.internalColorIndexKey] =
            (updatedPlayerColors[playerId]![Constants.internalColorIndexKey] +
                1) %
            AppColors.lightColors.length;
        updatedPlayerColors[playerId]![Constants.internalShowPreviousScoreKey] =
            true;
      }

      _resetTimers[playerId]?.cancel();

      // ⏱ start new 10s timer
      _resetTimers[playerId] = Timer(const Duration(seconds: 10), () {
        if (!mounted) return;

        setState(() {
          updatedPlayerColors[playerId]?[Constants
                  .internalShowPreviousScoreKey] =
              false;
        });
      });
    });
  }

  @override
  void initState() {
    super.initState();
    startTime = DateTime.now();

    Future.microtask(() {
      if (!mounted) return;
      context.read<GameScoreboardService>().init();
    });

    timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() {
        seconds = DateTime.now().difference(startTime).inSeconds;
      });
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    for (final t in _resetTimers.values) {
      t.cancel();
    }
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
        child: Consumer<GameScoreboardService>(
          builder: (context, service, child) {
            final players = [...service.gameBoard.values];
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
                          previousScore: p.previousScore,
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
    required int previousScore,
    required bool isLeader,
  }) {
    final avatar =
        AppAvatar.avatars[name.hashCode.abs() % AppAvatar.avatars.length];

    final playerState = updatedPlayerColors[id];

    final colorIndex = playerState?[Constants.internalColorIndexKey];
    final showPrevious =
        playerState?[Constants.internalShowPreviousScoreKey] ?? false;

    return InkWell(
      onTap: () {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          enableDrag: true,
          isDismissible: true,
          backgroundColor: Colors.transparent,
          builder: (_) => DraggableScrollableSheet(
            initialChildSize: 0.9,
            minChildSize: 0.6,
            maxChildSize: 0.95,
            expand: false,
            builder: (BuildContext context, ScrollController scrollController) {
              return ClipRRect(
                borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
                child: UpdateScoreboardScreen(
                  id: id,
                  name: name,
                  score: score,
                  scrollController: scrollController,

                  onScoreUpdated: () {
                    markPlayerUpdated(id);
                  },
                ),
              );
            },
          ),
        );
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),

        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),

        decoration: BoxDecoration(
          color: playerState != null
              ? AppColors.lightColors[colorIndex]
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

            Container(
              height: 45,
              width: 45,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.22),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  avatar,
                  style: TextStyle(
                    fontSize: 42,
                    color: AppColors.playerNameTextColor,
                  ),
                ),
              ),
            ),

            const SizedBox(width: 12),

            /// 🧑 Name
            Expanded(
              child: Text(
                name,
                style: const TextStyle(fontSize: 18, color: Color(0xFF001219)),
              ),
            ),

            _previousScoreWidget(previousScore, showPrevious),

            /// 🔢 Score
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              child: Text(
                "$score",
                key: ValueKey(score),
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF001219),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _previousScoreWidget(int previousScore, bool show) {
  if (!show) return const SizedBox();

  return TweenAnimationBuilder<double>(
    tween: Tween(begin: 0.0, end: 1.0),
    duration: const Duration(milliseconds: 250),
    builder: (context, value, child) {
      return Opacity(
        opacity: value,
        child: Transform.translate(
          offset: Offset(10 * (1 - value), 0),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              "$previousScore →",
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Color(0xFFBB3E03),
              ),
            ),
          ),
        ),
      );
    },
  );
}

  Future<bool> onEndSessionPressed(
    BuildContext context,
    GameScoreboardService gameScoreboardService,
  ) async {
    bool isEndConfirmed = false;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (showDialogContext) {
        bool isLoading = false;

        return StatefulBuilder(
          builder: (context, dialogSetState) {
            return AlertDialog(
              backgroundColor: const Color(0xFF1E1E1E),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),

              title: Row(
                children: [
                  const Icon(Icons.warning_amber_rounded, color: Colors.red),

                  const SizedBox(width: 10),

                  Text(
                    isLoading ? "Ending Game..." : "End Game?",
                    style: const TextStyle(color: Colors.white),
                  ),
                ],
              ),

              content: isLoading
                  ? const SizedBox(
                      height: 60,
                      child: Center(child: CircularProgressIndicator()),
                    )
                  : const Text(
                      "This will end the game session.\n\n"
                      "• Players will be disconnected\n"
                      "• This action cannot be undone",
                      style: TextStyle(color: Colors.white70),
                    ),

              actions: [
                TextButton(
                  onPressed: isLoading
                      ? null
                      : () => Navigator.pop(showDialogContext),
                  child: const Text("Cancel"),
                ),

                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),

                  onPressed: isLoading
                      ? null
                      : () async {
                          dialogSetState(() {
                            isLoading = true;
                          });

                          final successMessage = await gameScoreboardService
                              .endGame();

                          if (!mounted) return;

                          dialogSetState(() {
                            isLoading = false;
                          });

                          if (successMessage[Constants.SUCCESSKEY]) {
                            isEndConfirmed = true;
                          }

                          if (showDialogContext.mounted) {
                            Navigator.pop(showDialogContext);
                          }
                        },

                  child: const Text("End Game"),
                ),
              ],
            );
          },
        );
      },
    );

    return isEndConfirmed;
  }
}
