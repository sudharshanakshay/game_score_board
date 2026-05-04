import 'package:flutter/material.dart';

class GameNightIcon extends StatelessWidget {
  const GameNightIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 150,
      height: 150,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFFE9D8A6),
            Color(0xFFF3E7C3),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        shape: BoxShape.circle,
        border: Border.all(
          color: const Color(0xFF001219),
          width: 3,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 14,
            offset: const Offset(0, 6),
          )
        ],
      ),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "🎲",
              style: TextStyle(fontSize: 46),
            ),
            SizedBox(height: 6),
            Text(
              "GAME NIGHT",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
                color: Color(0xFF001219),
              ),
            ),
          ],
        ),
      ),
    );
  }
}