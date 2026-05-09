import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:game_score_board/Constants/app_avatar.dart';
import 'package:game_score_board/Constants/app_colors.dart';
import 'package:game_score_board/UpdateScoreBoard/update_scoreboard_service.dart';
import 'package:provider/provider.dart';

class UpdateScoreboardScreen extends StatefulWidget {
  final String id;
  final String name;
  final int score;
  final ScrollController scrollController;
  final VoidCallback onScoreUpdated;

  const UpdateScoreboardScreen({
    super.key,
    required this.id,
    required this.name,
    required this.score,
    required this.scrollController,
    required this.onScoreUpdated,
  });

  @override
  State<UpdateScoreboardScreen> createState() => _UpdateScoreboardScreenState();
}

class _UpdateScoreboardScreenState extends State<UpdateScoreboardScreen>
    with SingleTickerProviderStateMixin {
  int currentScore = 0;
  int delta = 0;

  late AnimationController _pulseController;

  final List<int> quickValues = [1, 5, 10, 25];

  @override
  void initState() {
    super.initState();

    currentScore = widget.score;

    Future.microtask(() {
      if (!mounted) return;
      context.read<UpdateScoreboardService>().init();
    });

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
      lowerBound: 0.96,
      upperBound: 1.02,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  int get finalScore => currentScore + delta;

  void addPoints(int value) {
    HapticFeedback.lightImpact();

    setState(() {
      delta += value;
    });
  }

  void subtractPoints(int value) {
    HapticFeedback.lightImpact();

    setState(() {
      delta -= value;
    });
  }

  void resetChange() {
    HapticFeedback.mediumImpact();

    setState(() {
      delta = 0;
    });
  }

  Future<void> applyScore() async {
    HapticFeedback.heavyImpact();

    await context.read<UpdateScoreboardService>().update(
      playerId: widget.id,
      newPlayerScore: finalScore,
    );

    widget.onScoreUpdated.call();

    if (!mounted) return;

    Navigator.pop(context);
  }

  Widget scoreButton({
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        height: 62,
        width: 62,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.28),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Center(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 20,
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final avatar = AppAvatar
        .avatars[widget.name.hashCode.abs() % AppAvatar.avatars.length];

    return Material(
      color: const Color(0xFFE9D8A6),
      child: SafeArea(
        child: SingleChildScrollView(
          controller: widget.scrollController,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 20),
            child: Column(
              children: [
                /// TOP BAR
                // Row(
                //   children: [
                //     GestureDetector(
                //       onTap: () => Navigator.pop(context),
                //       child: Container(
                //         padding: const EdgeInsets.all(10),
                //         decoration: BoxDecoration(
                //           color: Colors.white.withOpacity(0.55),
                //           borderRadius: BorderRadius.circular(14),
                //         ),
                //         child: const Icon(
                //           Icons.close,
                //           color: Color(0xFF001219),
                //         ),
                //       ),
                //     ),

                //     const Spacer(),

                //     const Text(
                //       "🎯 Update Score",
                //       style: TextStyle(
                //         fontSize: 22,
                //         fontWeight: FontWeight.w800,
                //         color: Color(0xFF001219),
                //       ),
                //     ),

                //     const Spacer(),

                //     const SizedBox(width: 44),
                //   ],
                // ),
                Center(
                  child: Container(
                    width: 50,
                    height: 5,
                    margin: const EdgeInsets.only(top: 3),
                    decoration: BoxDecoration(
                      color: Colors.black26,
                      borderRadius: BorderRadius.circular(100),
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                /// PLAYER CARD
                ScaleTransition(
                  scale: _pulseController,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      color: const Color(0xFF94D2BD),
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.10),
                          blurRadius: 14,
                          offset: const Offset(0, 7),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        /// AVATAR
                        Container(
                          height: 86,
                          width: 86,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.22),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              avatar,
                              style: const TextStyle(fontSize: 42),
                            ),
                          ),
                        ),

                        const SizedBox(height: 14),

                        Text(
                          widget.name,
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF001219),
                          ),
                        ),

                        const SizedBox(height: 18),

                        /// CURRENT SCORE
                        Text(
                          "$currentScore",
                          style: const TextStyle(
                            fontSize: 56,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF001219),
                          ),
                        ),

                        const SizedBox(height: 8),

                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 220),
                          child: Text(
                            delta == 0
                                ? "No changes"
                                : delta > 0
                                ? "+$delta"
                                : "$delta",
                            key: ValueKey(delta),
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: delta >= 0
                                  ? const Color(0xFF0A9396)
                                  : const Color(0xFFBB3E03),
                            ),
                          ),
                        ),

                        const SizedBox(height: 18),

                        /// FINAL SCORE
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 14,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.25),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Column(
                            children: [
                              const Text(
                                "Final Score",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF005F73),
                                  fontWeight: FontWeight.w700,
                                ),
                              ),

                              const SizedBox(height: 6),

                              Text(
                                "$finalScore",
                                style: const TextStyle(
                                  fontSize: 42,
                                  fontWeight: FontWeight.w900,
                                  color: Color(0xFF001219),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // const Spacer(),

                /// MINUS BUTTONS
                Column(
                  children: [
                    Text(
                      "➖ Remove Points",
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: Color(int.parse(AppColors.substractColor)),
                      ),
                    ),

                    const SizedBox(height: 12),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: quickValues.map((value) {
                        return scoreButton(
                          label: "-$value",
                          color: Color(int.parse(AppColors.substractColor)),
                          onTap: () => subtractPoints(value),
                        );
                      }).toList(),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                /// PLUS BUTTONS
                Column(
                  children: [
                    const Text(
                      "➕ Add Points",
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0A9396),
                      ),
                    ),

                    const SizedBox(height: 12),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: quickValues.map((value) {
                        return scoreButton(
                          label: "+$value",
                          color: const Color(0xFF0A9396),
                          onTap: () => addPoints(value),
                        );
                      }).toList(),
                    ),
                  ],
                ),

                const SizedBox(height: 26),

                /// ACTION BUTTONS
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF005F73),
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                        onPressed: resetChange,
                        child: const Text(
                          "RESET",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 14),

                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFEE9B00),
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                          elevation: 5,
                        ),
                        onPressed: applyScore,
                        child: const Text(
                          "🎮 APPLY SCORE",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
