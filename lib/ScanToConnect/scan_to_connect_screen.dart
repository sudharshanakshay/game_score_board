import 'package:flutter/material.dart';
import 'package:game_score_board/Helpers/session_provider.dart';
import 'package:game_score_board/main.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';

class QRScanScreen extends StatefulWidget {
  const QRScanScreen({super.key});

  @override
  State<QRScanScreen> createState() => _QRScanScreenState();
}

class _QRScanScreenState extends State<QRScanScreen> {
  String? scannedValue;
  bool isScanned = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Scan QR Code")),
      body: Column(
        children: [
          /// 📷 Scanner
          Expanded(
            flex: 4,
            child: MobileScanner(
              onDetect: (capture) {
                if (isScanned) return;

                final List<Barcode> barcodes = capture.barcodes;

                if (barcodes.isNotEmpty) {
                  final String? rawValue = barcodes.first.rawValue;

                  if (rawValue != null) {
                    setState(() {
                      scannedValue = rawValue;
                      isScanned = true;
                      navigatorKey.currentContext!
                          .read<SessionProvider>()
                          .setSession(scannedValue!);
                    });
                    Navigator.pop(context, scannedValue);
                  }
                }
              },
            ),
          ),

          /// 📦 Result display
          Expanded(
            flex: 2,
            child: Container(
              width: double.infinity,
              color: Colors.black,
              child: Center(
                child: scannedValue == null
                    ? const Text(
                        "Scanning...",
                        style: TextStyle(color: Colors.white),
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            "Scanned Value:",
                            style: TextStyle(color: Colors.white70),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            scannedValue!,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: () {
                              if (scannedValue != null) {
                                navigatorKey.currentContext!
                                    .read<SessionProvider>()
                                    .setSession(scannedValue!);
                              }

                              Navigator.pop(context, scannedValue);
                            },
                            child: const Text("Use This"),
                          ),
                        ],
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
