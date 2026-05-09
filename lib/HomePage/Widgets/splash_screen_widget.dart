import 'package:flutter/material.dart';

class SplashScreenWidget extends StatefulWidget {
  const SplashScreenWidget({super.key});

  @override
  State<SplashScreenWidget> createState() => _SessionLoadingScreenState();
}

class _SessionLoadingScreenState extends State<SplashScreenWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  final List<String> loadingMessages = [
    "🎲 Rolling the dice...",
    "🃏 Shuffling the cards...",
    "🎮 Restoring game session...",
    "🏁 Loading scoreboard...",
    "👾 Gathering players...",
  ];

  int currentIndex = 0;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);

    _rotateMessages();
  }

  void _rotateMessages() async {
    while (mounted) {
      await Future.delayed(const Duration(seconds: 2));

      if (!mounted) return;

      setState(() {
        currentIndex = (currentIndex + 1) % loadingMessages.length;
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE9D8A6),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 36),
            decoration: BoxDecoration(
              color: const Color(0xFF94D2BD),
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.12),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                /// ANIMATED DICE
                AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(0, -8 * _controller.value),
                      child: const Text("🎲", style: TextStyle(fontSize: 72)),
                    );
                  },
                ),

                const SizedBox(height: 18),

                /// TITLE
                const Text(
                  "Game Night",
                  style: TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF001219),
                  ),
                ),

                const SizedBox(height: 10),

                const Text(
                  "Score Board",
                  style: TextStyle(
                    fontSize: 18,
                    color: Color(0xFF005F73),
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 36),

                /// LOADING MESSAGE
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: Text(
                    loadingMessages[currentIndex],
                    key: ValueKey(loadingMessages[currentIndex]),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 18,
                      color: Color(0xFF001219),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),

                const SizedBox(height: 28),

                /// LOADING INDICATOR
                SizedBox(
                  width: 36,
                  height: 36,
                  child: CircularProgressIndicator(
                    strokeWidth: 4,
                    color: const Color(0xFFEE9B00),
                    backgroundColor: Colors.white.withOpacity(0.4),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
