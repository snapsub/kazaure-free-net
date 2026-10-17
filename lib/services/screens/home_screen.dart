import 'dart:async';
import 'package:flutter/material.dart';
import '../services/admob_service.dart';
import '../services/vpn_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AdMobService _adService = AdMobService();
  final VpnConnectionService _vpnService = VpnConnectionService();

  int remainingSeconds = 0;
  Timer? countdownTimer;
  bool isVpnActive = false;

  @override
  void initState() {
    super.initState();
    _adService.loadRewardedAd(() => setState(() {}));
    _vpnService.initializeVpn((status) {
      setState(() => isVpnActive = (status.state == "CONNECTED"));
    });
  }

  void startTimer() {
    countdownTimer?.cancel();
    countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (remainingSeconds > 0) {
        setState(() => remainingSeconds--);
      } else {
        timer.cancel();
        _vpnService.disconnectServer();
        setState(() => isVpnActive = false);
      }
    });
  }

  String formatTime(int seconds) {
    int h = seconds ~/ 3600;
    int m = (seconds % 3600) ~/ 60;
    int s = seconds % 60;
    return "${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Kazaure Free Net")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Time Left: ${formatTime(remainingSeconds)}", style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: isVpnActive ? Colors.red : Colors.green),
              onPressed: () {
                if (remainingSeconds <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Watch an ad to get time first!")));
                  return;
                }
                if (isVpnActive) {
                  _vpnService.disconnectServer();
                  countdownTimer?.cancel();
                } else {
                  _vpnService.connectToServer("YOUR_VPS_JSON_CONFIG_HERE");
                  startTimer();
                }
              },
              child: Text(isVpnActive ? "DISCONNECT" : "CONNECT", style: const TextStyle(color: Colors.white)),
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
              onPressed: () {
                _adService.showRewardedAd(onUserRewarded: (earned) {
                  setState(() => remainingSeconds += earned);
                  startTimer();
                });
              },
              icon: const Icon(Icons.video_collection, color: Colors.white),
              label: const Text("Watch Ad for +2 Hours", style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}
