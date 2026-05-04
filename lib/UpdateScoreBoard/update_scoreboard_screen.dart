import 'package:flutter/material.dart';
import 'package:game_score_board/Constants/app_text_styles.dart';
import 'package:game_score_board/UpdateScoreBoard/update_scoreboard_service.dart';
import 'package:game_score_board/main.dart';
import 'package:provider/provider.dart';

class UpdateScoreboardScreen extends StatefulWidget {
  final String id;
  final String name;
  final int score;

  const UpdateScoreboardScreen({
    super.key,
    required this.id,
    required this.name,
    required this.score,
  });

  @override
  State<StatefulWidget> createState() => _UpdateScoreboardScreen();
}

class _UpdateScoreboardScreen extends State<UpdateScoreboardScreen> {
  String input = "";
  String operator = "+";
  int currentScore = 0;

  @override
  void initState() {
    super.initState();
    currentScore = widget.score;
  }

  int get changeValue => input.isEmpty ? 0 : int.parse(input);

  int get finalScore {
    if (operator == "+") {
      return currentScore + changeValue;
    } else {
      return currentScore - changeValue;
    }
  }

  void onButtonPressed(String value) {
    setState(() {
      if (value == "AC") {
        input = "";
      } else if (value == "+" || value == "-") {
        operator = value;
      } else if (value == "=") {
        currentScore = finalScore;
        input = "";
      } else {
        if (input.length < 3) {
          // limit 0–999 (you can change to 200)
          input += value;
        }
      }
    });
  }

  Widget buildButton(String text) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF94D2BD),
            padding: const EdgeInsets.all(18),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          onPressed: () => onButtonPressed(text),
          child: Text(
            text,
            style: const TextStyle(fontSize: 20, color: Color(0xFF001219)),
          ),
        ),
      ),
    );
  }

  Widget buildActionButton(String text, Color color, {bool isPrimary = false}) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: const EdgeInsets.symmetric(vertical: 18),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      onPressed: () {
        if (text == "AC") {
          onButtonPressed("AC");
        } else {
          onButtonPressed("=");
          navigatorKey.currentContext!.read<UpdateScoreboardService>().update(
            playerId: widget.id,
            newPlayerScore: currentScore,
          );
          Navigator.pop(context); // 👈 return after apply
        }
      },
      child: Text(
        text,
        style: TextStyle(
          fontSize: isPrimary ? 20 : 18,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget buildRow(List<String> buttons) {
    return Row(children: buttons.map((b) => buildButton(b)).toList());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE9D8A6), // Wheat (consistent theme)
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          child: Column(
            children: [
              /// 🔙 HEADER
              Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    "Edit Score",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF001219),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              /// 🧾 SCORE CARD
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF8E7),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.brown, width: 1.2),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.name, style: AppTextStyles.titleTextStyle),

                    const SizedBox(height: 10),

                    /// Current Score
                    Text(
                      "Score: $currentScore",
                      style: const TextStyle(fontSize: 22, color: Colors.brown),
                    ),

                    const SizedBox(height: 8),

                    /// Change
                    Text(
                      "Change: $operator${input.isEmpty ? 0 : input}",
                      style: TextStyle(
                        fontSize: 20,
                        color: operator == "+"
                            ? const Color(0xFF0A9396)
                            : const Color(0xFFBB3E03),
                      ),
                    ),

                    const Divider(height: 20),

                    /// ⭐ FINAL (highlighted)
                    Center(
                      child: Text(
                        "$finalScore",
                        style: const TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF001219),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              /// 🔢 KEYPAD
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    buildRow(["7", "8", "9"]),
                    buildRow(["4", "5", "6"]),
                    buildRow(["1", "2", "3"]),
                    buildRow(["0", "+", "-"]),
                  ],
                ),
              ),

              /// 🎯 ACTION ROW (important change)
              Row(
                children: [
                  Expanded(
                    child: buildActionButton("AC", const Color(0xFF0A9396)),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 2,
                    child: buildActionButton(
                      "APPLY",
                      const Color(0xFFEE9B00),
                      isPrimary: true,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}
