import 'package:flutter/material.dart';
import 'package:game_score_board/Helpers/session_provider.dart';
import 'package:game_score_board/ScanToConnect/scan_to_connect_service.dart';
import 'package:game_score_board/main.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';

class QRScanScreen extends StatefulWidget {
  const QRScanScreen({super.key});

  @override
  State<QRScanScreen> createState() => _QRScanScreenState();
}

class _QRScanScreenState extends State<QRScanScreen>
    with SingleTickerProviderStateMixin {
  String? scannedValue;

  bool isSessionValid = true;
  bool isScanned = false;
  bool isJoining = false;

  late AnimationController _scanController;

  final List<String> loadingMessages = [
    "🎲 Looking for game lobby...",
    "🕹 Finding teammates...",
    "🎯 Searching for session...",
    "🏁 Connecting scoreboard...",
    "🎮 Ready to join the fun...",
  ];

  int currentMessageIndex = 0;

  @override
  void initState() {
    super.initState();

    _scanController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _rotateMessages();
  }

  void _rotateMessages() async {
    while (mounted && !isScanned) {
      await Future.delayed(const Duration(seconds: 2));

      if (!mounted) return;

      setState(() {
        currentMessageIndex =
            (currentMessageIndex + 1) % loadingMessages.length;
      });
    }
  }

  @override
  void dispose() {
    _scanController.dispose();
    super.dispose();
  }

  void _handleInvalidSession() {
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.pop(context);
      }
    });
  }

  Future<void> _handleScan(String rawValue) async {
    final scanToConnectService = context.read<ScanToConnectService>();

    final bool valid =
        await scanToConnectService.validateSession(rawValue);

    if (!mounted) return;

    if (!valid) {
      setState(() {
        isSessionValid = false;
      });

      _handleInvalidSession();
      return;
    }

    setState(() {
      scannedValue = rawValue;
      isJoining = true;
    });

    await Future.delayed(const Duration(milliseconds: 800));

    if (!mounted) return;

    navigatorKey.currentContext!
        .read<SessionProvider>()
        .setSession(rawValue);

    Navigator.pop(context, rawValue);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE9D8A6),
      body: SafeArea(
        child: !isSessionValid
            ? _buildInvalidSession()
            : Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    const SizedBox(height: 24),

                    /// HEADER
                    const Icon(
                      Icons.qr_code_scanner_rounded,
                      size: 72,
                      color: Color(0xFF005F73),
                    ),

                    const SizedBox(height: 16),

                    const Text(
                      "Join Game",
                      style: TextStyle(
                        fontSize: 34,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF001219),
                      ),
                    ),

                    const SizedBox(height: 10),

                    const Text(
                      "Scan your friend's QR code\nto join the scoreboard",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: Color(0xFF005F73),
                        height: 1.4,
                      ),
                    ),

                    const SizedBox(height: 40),

                    /// SCANNER CARD
                    Expanded(
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF94D2BD),
                          borderRadius: BorderRadius.circular(28),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.15),
                              blurRadius: 12,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(22),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              /// CAMERA
                              MobileScanner(
                                onDetect: (capture) async {
                                  if (isScanned) return;

                                  isScanned = true;

                                  final List<Barcode> barcodes =
                                      capture.barcodes;

                                  if (barcodes.isEmpty) return;

                                  final rawValue =
                                      barcodes.first.rawValue;

                                  if (rawValue == null) return;

                                  await _handleScan(rawValue);
                                },
                              ),

                              /// DARK OVERLAY
                              Container(
                                color: Colors.black.withOpacity(0.35),
                              ),

                              /// SCANNER FRAME
                              Container(
                                width: 260,
                                height: 260,
                                decoration: BoxDecoration(
                                  borderRadius:
                                      BorderRadius.circular(28),
                                  border: Border.all(
                                    color: const Color(0xFFEE9B00),
                                    width: 4,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFFEE9B00)
                                          .withOpacity(0.4),
                                      blurRadius: 18,
                                      spreadRadius: 2,
                                    ),
                                  ],
                                ),
                              ),

                              /// ANIMATED SCAN LINE
                              AnimatedBuilder(
                                animation: _scanController,
                                builder: (context, child) {
                                  return Positioned(
                                    top:
                                        170 +
                                        (_scanController.value * 220),
                                    child: Container(
                                      width: 220,
                                      height: 4,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFEE9B00),
                                        borderRadius:
                                            BorderRadius.circular(10),
                                        boxShadow: [
                                          BoxShadow(
                                            color:
                                                const Color(0xFFEE9B00)
                                                    .withOpacity(0.8),
                                            blurRadius: 12,
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 28),

                    /// STATUS
                    AnimatedSwitcher(
                      duration:
                          const Duration(milliseconds: 400),
                      child: Text(
                        isJoining
                            ? "🎉 Joining Game..."
                            : loadingMessages[currentMessageIndex],
                        key: ValueKey(
                          isJoining
                              ? "joining"
                              : loadingMessages[currentMessageIndex],
                        ),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF001219),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    /// CANCEL BUTTON
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              const Color(0xFF005F73),
                          foregroundColor: Colors.white,
                          elevation: 4,
                          padding: const EdgeInsets.symmetric(
                            vertical: 16,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(16),
                          ),
                        ),
                        child: const Text(
                          "Cancel",
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
              ),
      ),
    );
  }

  Widget _buildInvalidSession() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: const Color(0xFF94D2BD),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "😵",
                style: TextStyle(fontSize: 56),
              ),

              SizedBox(height: 16),

              Text(
                "Session Expired",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF001219),
                ),
              ),

              SizedBox(height: 16),

              Text(
                "Ask the host to create a new game QR code.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFF005F73),
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}