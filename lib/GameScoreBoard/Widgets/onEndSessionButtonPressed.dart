import 'package:flutter/material.dart';
import 'package:game_score_board/GameScoreBoard/game_scoreboard_service.dart';
import 'package:game_score_board/Helpers/constants.dart';
import 'package:game_score_board/Helpers/session_provider.dart';
import 'package:game_score_board/main.dart';
import 'package:provider/provider.dart';

Future<bool?> onEndSessionPressed(
  BuildContext context,
  GameScoreboardService gameScoreboardService,
) async {
  bool isLoading = false;
  String? loadingAction;

  return showDialog<bool>(
    context: context,
    barrierDismissible: true,
    builder: (dialogContext) {
      return StatefulBuilder(
        builder: (context, setState) {
          return Center(
            child: Material(
              color: Colors.transparent,
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 24),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF94D2BD),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.25),
                      blurRadius: 18,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),

                /// ✅ Smooth resize transition
                child: AnimatedSize(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeInOut,
                  child: isLoading
                      ? Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: _gameLoading(loadingAction ?? ""),
                        )
                      : Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            /// 🎮 TOP ICON
                            Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.28),
                                shape: BoxShape.circle,
                              ),
                              child: const Text(
                                "🎮",
                                style: TextStyle(fontSize: 34),
                              ),
                            ),

                            const SizedBox(height: 16),

                            /// TITLE
                            const Text(
                              "Game Control",
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFF001219),
                                decoration: TextDecoration.none,
                              ),
                            ),

                            const SizedBox(height: 10),

                            /// SUBTITLE
                            const Text(
                              "Choose what happens next",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 14,
                                height: 1.4,
                                color: Color(0xFF005F73),
                                decoration: TextDecoration.none,
                              ),
                            ),

                            const SizedBox(height: 24),

                            /// 🔄 RESET GAME
                            _gameActionButton(
                              title: "Reset Scores",
                              icon: "🔄",
                              color: const Color(0xFF0A9396),
                              subtitle: "Start a fresh round instantly",
                              onTap: () async {
                                setState(() {
                                  isLoading = true;
                                  loadingAction = "reset";
                                });

                                final res = await gameScoreboardService
                                    .resetGame();

                                setState(() {
                                  isLoading = false;
                                  loadingAction = "reset";
                                });

                                if (res[Constants.SUCCESSKEY] != true) {
                                  final String errorMessage =
                                      res[Constants.MESSAGEKEY];

                                  if (!dialogContext.mounted) return;

                                  final messenger = ScaffoldMessenger.of(
                                    context,
                                  );

                                  messenger.showSnackBar(
                                    SnackBar(
                                      backgroundColor: Colors.redAccent,
                                      behavior: SnackBarBehavior.floating,
                                      content: Text(errorMessage),
                                    ),
                                  );

                                  Future.delayed(
                                    const Duration(seconds: 2),
                                    () {
                                      messenger.hideCurrentSnackBar();
                                    },
                                  );
                                }

                                if (dialogContext.mounted) {
                                  Navigator.pop(dialogContext, false);
                                }
                              },
                            ),

                            const SizedBox(height: 14),

                            /// 🛑 END GAME
                            _gameActionButton(
                              title: "End Game",
                              icon: "🛑",
                              color: const Color(0xFFBB3E03),
                              subtitle: "Disconnect all players",
                              onTap: () async {
                                setState(() {
                                  isLoading = true;
                                  loadingAction = "end";
                                });

                                if (navigatorKey.currentContext!
                                    .read<SessionProvider>()
                                    .isGameHost) {
                                  final res = await gameScoreboardService
                                      .endGame();

                                  if (dialogContext.mounted) {
                                    Navigator.pop(
                                      dialogContext,
                                      res[Constants.SUCCESSKEY] == true,
                                    );
                                  }
                                } else {
                                  Navigator.pop(dialogContext, true);
                                  setState(() {
                                    isLoading = false;
                                  });
                                  navigatorKey.currentContext!
                                      .read<SessionProvider>()
                                      .setNull();
                                }
                              },
                            ),

                            const SizedBox(height: 18),

                            /// CANCEL
                            TextButton(
                              onPressed: () {
                                Navigator.pop(dialogContext);
                              },
                              child: const Text(
                                "Cancel",
                                style: TextStyle(
                                  color: Color(0xFF001219),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ),
          );
        },
      );
    },
  );
}

Widget _gameActionButton({
  required String title,
  required String subtitle,
  required String icon,
  required Color color,
  required VoidCallback onTap,
}) {
  return InkWell(
    borderRadius: BorderRadius.circular(16),
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.22),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.45), width: 1.5),
      ),
      child: Row(
        children: [
          /// ICON
          Container(
            height: 48,
            width: 48,
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(icon, style: const TextStyle(fontSize: 22)),
            ),
          ),

          const SizedBox(width: 14),

          /// TEXTS
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: color,
                    decoration: TextDecoration.none,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF005F73),
                    decoration: TextDecoration.none,
                  ),
                ),
              ],
            ),
          ),

          Icon(Icons.chevron_right_rounded, color: color),
        ],
      ),
    ),
  );
}

Widget _gameLoading(String action) {
  final bool isReset = action == "reset";

  final String emoji = isReset ? "🎲" : "🛑";

  final String title = isReset ? "Resetting Scoreboard" : "Ending Game Session";

  final String subtitle = isReset
      ? "Preparing the next round for everyone..."
      : "Notifying players & closing the room...";

  final Color accent = isReset
      ? const Color(0xFF0A9396)
      : const Color(0xFFBB3E03);

  return Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      /// GLOWING ANIMATED ICON
      TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.92, end: 1.08),
        duration: const Duration(milliseconds: 900),
        curve: Curves.easeInOut,
        builder: (context, scale, child) {
          return Transform.scale(
            scale: scale,
            child: Container(
              height: 90,
              width: 90,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: accent.withOpacity(0.12),
                boxShadow: [
                  BoxShadow(
                    color: accent.withOpacity(0.35),
                    blurRadius: 30,
                    spreadRadius: 4,
                  ),
                ],
              ),
              child: Center(
                child: TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: 1),
                  duration: const Duration(seconds: 2),
                  builder: (context, rotation, child) {
                    return Transform.rotate(
                      angle: rotation * 6.28,
                      child: Text(emoji, style: const TextStyle(fontSize: 42)),
                    );
                  },
                ),
              ),
            ),
          );
        },
      ),

      const SizedBox(height: 22),

      /// TITLE
      Text(
        title,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w900,
          color: Color(0xFF001219),
          decoration: TextDecoration.none,
        ),
      ),

      const SizedBox(height: 10),

      /// SUBTITLE
      Text(
        subtitle,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 14,
          height: 1.4,
          color: Color(0xFF005F73),
          decoration: TextDecoration.none,
        ),
      ),

      const SizedBox(height: 24),

      /// PROGRESS BAR
      ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: LinearProgressIndicator(
          minHeight: 10,
          backgroundColor: Colors.white.withOpacity(0.35),
          valueColor: AlwaysStoppedAnimation(accent),
        ),
      ),

      const SizedBox(height: 14),

      /// FOOTER
      Text(
        isReset
            ? "Syncing player scores..."
            : "Waiting for server acknowledgement...",
        style: TextStyle(
          fontSize: 12,
          color: Colors.black.withOpacity(0.55),
          decoration: TextDecoration.none,
        ),
      ),
    ],
  );
}
