import 'package:flutter/material.dart';
import 'package:game_score_board/AddNewPlayer/add_player_service.dart';
import 'package:game_score_board/Constants/app_avatar.dart';
import 'package:game_score_board/Constants/app_text_styles.dart';
import 'package:game_score_board/Helpers/constants.dart';
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

  final ScrollController _scrollController = ScrollController();

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

    setState(() => isStartingGame = true);
    _rotateLoadingMessages();

    try {
      Map<String, dynamic> successMessage = await provider.startGame();

      if (successMessage[Constants.SUCCESSKEY]) {
        if (!mounted) return;
        Navigator.pop(context);
      } else {
        setState(() {
          isStartingGame = false;
        });

        final String errorMessage = successMessage[Constants.MESSAGEKEY];

        if (!mounted) return;
        final messenger = ScaffoldMessenger.of(context);

        messenger.showSnackBar(
          SnackBar(
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
            content: Text(errorMessage),
            action: SnackBarAction(
              label: "Retry",
              textColor: Colors.white,
              onPressed: () => _startGame(provider),
            ),
          ),
        );

        Future.delayed(const Duration(seconds: 2), () {
          messenger.hideCurrentSnackBar();
        });
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Failed to start game")));

      setState(() => isStartingGame = false);
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

          // appBar: AppBar(
          //   backgroundColor: const Color(0xFFEE9B00),
          //   elevation: 0,
          //   title: const Text("Setup Game"),
          // ),
          body: Consumer<AddPlayerService>(
            builder: (context, provider, child) {
              final isDisabled = provider.playerNames.isEmpty || isStartingGame;

              return Stack(
                children: [
                  /// 🔵 SCROLLABLE CONTENT
                  SingleChildScrollView(
                    controller: _scrollController,
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
                    child: Column(
                      children: [
                        SizedBox(height: 30),

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
                                spacing: 14,
                                runSpacing: 14,
                                children: List.generate(
                                  provider.playerNames.length,
                                  (index) {
                                    final name = provider.playerNames[index];
                                    final color =
                                        avatarColors[index %
                                            avatarColors.length];
                                    final avatar =
                                        AppAvatar.avatars[name.hashCode.abs() %
                                            AppAvatar.avatars.length];

                                    return Stack(
                                      clipBehavior: Clip.none,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: Colors.white.withOpacity(
                                              0.25,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              18,
                                            ),
                                          ),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              CircleAvatar(
                                                radius: 30,
                                                backgroundColor: color,
                                                child: Text(
                                                  avatar,
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 45,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                // child: Text(
                                                //   name[0].toUpperCase(),
                                                //   style: const TextStyle(
                                                //     color: Colors.white,
                                                //     fontSize: 22,
                                                //     fontWeight: FontWeight.bold,
                                                //   ),
                                                // ),
                                              ),
                                              const SizedBox(height: 8),
                                              SizedBox(
                                                width: 70,
                                                child: Text(
                                                  name,
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  textAlign: TextAlign.center,
                                                  style: const TextStyle(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),

                                        /// REMOVE
                                        Positioned(
                                          top: -6,
                                          right: -6,
                                          child: GestureDetector(
                                            onTap: () =>
                                                provider.removePlayer(name),
                                            child: Container(
                                              padding: const EdgeInsets.all(5),
                                              decoration: BoxDecoration(
                                                color: Colors.redAccent,
                                                shape: BoxShape.circle,
                                                border: Border.all(
                                                  color: Colors.white,
                                                  width: 2,
                                                ),
                                              ),
                                              child: const Icon(
                                                Icons.close,
                                                size: 14,
                                                color: Colors.white,
                                              ),
                                            ),
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
                                  validator: (value) =>
                                      value == null || value.isEmpty
                                      ? "Enter a name"
                                      : null,
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
                                          final isError = provider.addPlayer(
                                            nameController.text,
                                          );

                                          if (!isError) {
                                            nameController.clear();
                                            Future.delayed(
                                              const Duration(milliseconds: 100),
                                              () {
                                                if (!_scrollController
                                                    .hasClients) {
                                                  return;
                                                }

                                                _scrollController.animateTo(
                                                  _scrollController
                                                      .position
                                                      .maxScrollExtent,
                                                  duration: const Duration(
                                                    milliseconds: 300,
                                                  ),
                                                  curve: Curves.easeOut,
                                                );
                                              },
                                            );
                                          }
                                        }
                                      },
                                child: const Text("➕ Add Player"),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  /// 🔥 FIXED START BUTTON
                  Positioned(
                    left: 16,
                    right: 16,
                    bottom: 16,
                    child: SafeArea(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFEE9B00),
                          minimumSize: const Size(double.infinity, 58),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 6,
                        ),
                        onPressed: isDisabled
                            ? null
                            : () => _startGame(provider),
                        child: isStartingGame
                            ? const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 3,
                                      color: Colors.white,
                                    ),
                                  ),
                                  SizedBox(width: 12),
                                  Text("Starting..."),
                                ],
                              )
                            : const Text(
                                "🎯 Start Game",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),

        /// LOADING OVERLAY (unchanged)
        if (isStartingGame)
          Container(
            color: Colors.black.withOpacity(0.45),
            child: Center(
              child: Container(
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  color: const Color(0xFF94D2BD),
                  borderRadius: BorderRadius.circular(28),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
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
                    const SizedBox(height: 20),
                    const Text(
                      "Starting Game",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.none,
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
