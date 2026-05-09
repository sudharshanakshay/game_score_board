import 'package:flutter/material.dart';

class GameScoreboardLoadingWidget extends StatelessWidget {
  const GameScoreboardLoadingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        child: Column(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                          onPressed: () {},
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
                            "00:00",
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
                      "0 Players",
                      style: const TextStyle(color: Color(0xFF005F73)),
                    ),

                    /// ⚡ Actions cluster
                    TextButton(
                      onPressed: () {},
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

            Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.topRight,
                  colors: [
                    const Color(0xFFEE9B00),
                    const Color.fromARGB(255, 229, 184, 118).withOpacity(0.6),
                  ],
                ),
              ),
              child: SizedBox(height: 40, width: double.infinity, child: Center(child: Text('Loading _'),),),
            ),
          ],
        ),
      ),
    );
  }
}
