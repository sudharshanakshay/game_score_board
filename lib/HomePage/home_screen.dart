import 'package:flutter/material.dart';
import 'package:game_score_board/AddNewPlayer/add_player_screen.dart';
import 'package:game_score_board/GameScoreBoard/game_scorebaord_screen.dart';
import 'package:game_score_board/Helpers/session_provider.dart';
import 'package:game_score_board/ScanToConnect/scan_to_connect_screen.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<StatefulWidget> createState() => _HomeScreen();
}

class _HomeScreen extends State<HomeScreen> {
  Widget gameButton({
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.symmetric(vertical: 10),
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              offset: const Offset(0, 4),
              blurRadius: 6,
            ),
          ],
        ),
        child: Center(
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF001219), // Ink Black
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE9D8A6), // Wheat
      body: Consumer<SessionProvider>(
        builder: (context, value, child) {
          if (value.loading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (value.sessionId != null) {
            return const GameScorebaordScreen();
          }

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 🎲 Title
                const Text(
                  "🎮 Game Night",
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF001219),
                  ),
                ),

                const SizedBox(height: 8),

                const Text(
                  "Score Board",
                  style: TextStyle(
                    fontSize: 22,
                    color: Color(0xFF005F73), // Dark Teal
                  ),
                ),

                const SizedBox(height: 40),

                // 🃏 Card Container
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF94D2BD), // Pearl Aqua
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      // 🔶 Host (Primary Action)
                      gameButton(
                        title: "🎯 Host Game",
                        color: const Color(0xFFEE9B00), // Golden Orange
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AddPlayerScreen(),
                            ),
                          );
                        },
                      ),

                      // 🌊 Viewer (Secondary)
                      gameButton(
                        title: "🏁 Join Game",
                        color: const Color(0xFF0A9396), // Dark Cyan
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => QRScanScreen(),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                // 📝 Footer Hint
                const Text(
                  "Start a game or join your friends",
                  style: TextStyle(color: Color(0xFF001219), fontSize: 14),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
