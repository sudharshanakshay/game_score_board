import 'package:flutter/material.dart';
import 'package:game_score_board/AddNewPlayer/add_player_service.dart';
import 'package:game_score_board/Constants/app_text_styles.dart';
import 'package:provider/provider.dart';

class AddPlayerScreen extends StatefulWidget {
  const AddPlayerScreen({super.key});

  @override
  State<StatefulWidget> createState() => _AddPlayerScreen();
}

class _AddPlayerScreen extends State<AddPlayerScreen>
    with SingleTickerProviderStateMixin {
  TextEditingController nameController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  bool isStartingGame = false;

  late AnimationController _loadingController;

  final List<Color> avatarColors = [
    Color(0xFF0A9396),
    Color(0xFFEE9B00),
    Color(0xFFBB3E03),
    Color(0xFF005F73),
  ];

  final List<String> loadingMessages = [
    "🎲 Rolling dice...",
    "🃏 Shuffling cards...",
    "🎯 Creating lobby...",
    "🏁 Setting scoreboard...",
    "🎮 Gathering players...",
  ];

  int currentLoadingIndex = 0;

  @override
  void initState() {
    super.initState();

    _loadingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _loadingController.dispose();
    nameController.dispose();
    super.dispose();
  }

  Future<void> _startGame(AddPlayerService provider) async {
    if (isStartingGame) return;

    setState(() {
      isStartingGame = true;
    });

    _rotateLoadingMessages();

    try {
      await provider.startGame();

      await Future.delayed(const Duration(milliseconds: 600));

      if (!mounted) return;

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Failed to start game")));

      setState(() {
        isStartingGame = false;
      });
    }
  }

  void _rotateLoadingMessages() async {
    while (mounted && isStartingGame) {
      await Future.delayed(const Duration(seconds: 1));

      if (!mounted) return;

      setState(() {
        currentLoadingIndex =
            (currentLoadingIndex + 1) % loadingMessages.length;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          backgroundColor: const Color(0xFFE9D8A6),
          appBar: AppBar(
            backgroundColor: const Color(0xFFEE9B00),
            elevation: 0,
            title: const Text("Setup Game"),
          ),
          body: Consumer<AddPlayerService>(
            builder: (context, provider, child) {
              final isDisabled = provider.playerNames.isEmpty || isStartingGame;

              return Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    /// PLAYER CARD
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF94D2BD),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.12),
                            blurRadius: 12,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "🎲 Players",
                            style: AppTextStyles.titleTextStyle,
                          ),
                      
                          const SizedBox(height: 10),
                      
                          Text(
                            "${provider.playerNames.length} joined",
                            style: AppTextStyles.labelTextStyle,
                          ),
                      
                          const SizedBox(height: 16),
                      
                          Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            children: List.generate(
                              provider.playerNames.length,
                              (index) {
                                final name = provider.playerNames[index];
                      
                                final color =
                                    avatarColors[index % avatarColors.length];
                      
                                return Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    CircleAvatar(
                                      radius: 28,
                                      backgroundColor: color,
                                      child: Text(
                                        name[0].toUpperCase(),
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                      
                                    const SizedBox(height: 6),
                      
                                    Text(
                                      name,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Color(0xFF001219),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                          ),
                      
                          const SizedBox(height: 20),
                      
                          /// INPUT
                          Form(
                            key: _formKey,
                            child: TextFormField(
                              controller: nameController,
                              enabled: !isStartingGame,
                              decoration: InputDecoration(
                                labelText: "Enter player name",
                                filled: true,
                                fillColor: Colors.white,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return "Enter a name";
                                }
                      
                                return null;
                              },
                            ),
                          ),
                      
                          const SizedBox(height: 16),
                      
                          /// ADD PLAYER
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF0A9396),
                              minimumSize: const Size(double.infinity, 52),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            onPressed: isStartingGame
                                ? null
                                : () {
                                    if (_formKey.currentState!.validate()) {
                                      var isError = provider.addPlayer(
                                        nameController.text,
                                      );
                      
                                      if (!isError) {
                                        nameController.clear();
                                      }
                                    }
                                  },
                            child: const Text(
                              "➕ Add Player",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                
                    const Spacer(),
                
                    /// START GAME
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFEE9B00),
                        minimumSize: const Size(double.infinity, 58),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 4,
                      ),
                      onPressed: isDisabled ? null : () => _startGame(provider),
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 250),
                        child: isStartingGame
                            ? const Row(
                                key: ValueKey("loading"),
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    height: 22,
                                    width: 22,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 3,
                                      color: Colors.white,
                                    ),
                                  ),
                
                                  SizedBox(width: 14),
                
                                  Text(
                                    "Starting...",
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              )
                            : const Text(
                                "🎯 Start Game",
                                key: ValueKey("start"),
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                
                    const SizedBox(height: 20),
                  ],
                ),
              );
            },
          ),
        ),

        /// FULLSCREEN LOADING OVERLAY
        if (isStartingGame)
          Container(
            color: Colors.black.withOpacity(0.45),
            child: Center(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 32),
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  color: const Color(0xFF94D2BD),
                  borderRadius: BorderRadius.circular(28),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    /// ANIMATED ICON
                    RotationTransition(
                      turns: _loadingController,
                      child: const Text(
                        "🎲",
                        style: TextStyle(
                          fontSize: 60,
                          decoration: TextDecoration.none,
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    const Text(
                      "Starting Game",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF001219),
                        decoration: TextDecoration.none,
                      ),
                    ),

                    const SizedBox(height: 18),

                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: Text(
                        loadingMessages[currentLoadingIndex],
                        key: ValueKey(loadingMessages[currentLoadingIndex]),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 18,
                          color: Color(0xFF005F73),
                          fontWeight: FontWeight.w600,
                          decoration: TextDecoration.none,
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    const SizedBox(
                      width: 34,
                      height: 34,
                      child: CircularProgressIndicator(
                        strokeWidth: 4,
                        color: Color(0xFFEE9B00),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}
