import 'package:flutter/material.dart';
import 'package:game_score_board/AddNewPlayer/add_player_service.dart';
import 'package:game_score_board/Constants/app_text_styles.dart';
import 'package:game_score_board/Helpers/session_provider.dart';
import 'package:game_score_board/main.dart';
import 'package:provider/provider.dart';

class AddPlayerScreen extends StatefulWidget {
  const AddPlayerScreen({super.key});

  @override
  State<StatefulWidget> createState() => _AddPlayerScreen();
}

class _AddPlayerScreen extends State<AddPlayerScreen> {
  TextEditingController nameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  final List<Color> avatarColors = [
    Color(0xFF0A9396),
    Color(0xFFEE9B00),
    Color(0xFFBB3E03),
    Color(0xFF005F73),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE9D8A6), // Wheat
      appBar: AppBar(
        backgroundColor: const Color(0xFFEE9B00),
        title: const Text("Setup Game"),
      ),
      body: Consumer<AddPlayerService>(
        builder: (context, provider, child) {
          final isDisabled = provider.playerNames.isEmpty;

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [

                /// 🧾 Card Container
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF94D2BD),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      Text("🎲 Players",
                          style: AppTextStyles.titleTextStyle),

                      const SizedBox(height: 10),

                      Text(
                        "${provider.playerNames.length} joined",
                        style: AppTextStyles.labelTextStyle,
                      ),

                      const SizedBox(height: 10),

                      Wrap(
                        spacing: 8,
                        children: List.generate(
                          provider.playerNames.length,
                          (index) {
                            final name = provider.playerNames[index];
                            final color =
                                avatarColors[index % avatarColors.length];

                            return CircleAvatar(
                              radius: 28,
                              backgroundColor: color,
                              child: Text(
                                name[0].toUpperCase(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                ),
                              ),
                            );
                          },
                        ),
                      ),

                      const SizedBox(height: 16),

                      /// 📝 Input
                      Form(
                        key: _formKey,
                        child: TextFormField(
                          controller: nameController,
                          decoration: InputDecoration(
                            labelText: "Enter player name",
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
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

                      /// ➕ Add Player
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0A9396),
                          minimumSize: const Size(double.infinity, 50),
                        ),
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            var isError =
                                provider.addPlayer(nameController.text);

                            if (!isError) {
                              nameController.clear();
                            }
                          }
                        },
                        child: const Text("➕ Add Player"),
                      ),
                    ],
                  ),
                ),

                const Spacer(),

                /// 🎯 Start Game
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFEE9B00),
                    minimumSize: const Size(double.infinity, 55),
                  ),
                  onPressed: isDisabled
                      ? null
                      : () async {
                          String sessionId = await provider.startGame();

                          navigatorKey.currentContext!
                              .read<SessionProvider>()
                              .setSession(sessionId);

                          if (!context.mounted) return;
                          Navigator.pop(context);
                        },
                  child: const Text(
                    "🎯 Start Game",
                    style: TextStyle(fontSize: 18),
                  ),
                ),

                const SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
    );
  }
} 