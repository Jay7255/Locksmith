import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'save_inject.dart';
import 'services/ads.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Color(0xFF0E1522),
    systemNavigationBarColor: Color(0xFF0E1522),
    statusBarIconBrightness: Brightness.light,
  ));
  runApp(const LocksmithApp());
}

class LocksmithApp extends StatelessWidget {
  const LocksmithApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Locksmith',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true, brightness: Brightness.dark),
      home: const GamePage(),
    );
  }
}

/// Shows the game (assets/game/index.html) in a web view, with an AdMob
/// banner underneath. The page talks to this code through the "AdBridge"
/// channel: it asks for rewarded and full-screen ads, saves progress and
/// copies share text.
class GamePage extends StatefulWidget {
  const GamePage({super.key});

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  WebViewController? _web;
  SharedPreferences? _prefs;

  @override
  void initState() {
    super.initState();
    AdService.instance.init();
    _load();
  }

  Future<void> _load() async {
    _prefs = await SharedPreferences.getInstance();
    final html = injectSave(
      await rootBundle.loadString('assets/game/index.html'),
      _prefs!.getString('save'),
    );
    final web = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0xFF0E1522))
      ..addJavaScriptChannel('AdBridge', onMessageReceived: _onMessage)
      ..loadHtmlString(html, baseUrl: 'https://locksmith.game/');
    if (mounted) setState(() => _web = web);
  }

  Future<void> _onMessage(JavaScriptMessage message) async {
    final Map<String, dynamic> m;
    try {
      m = jsonDecode(message.message) as Map<String, dynamic>;
    } catch (_) {
      return;
    }
    switch (m['type']) {
      case 'save':
        await _prefs?.setString('save', '${m['data']}');
      case 'rewarded':
        final id = (m['id'] as num?)?.toInt() ?? 0;
        final ok = await AdService.instance.showRewarded();
        await _web?.runJavaScript('window.onAdResult($id, $ok)');
      case 'interstitial':
        await AdService.instance.showInterstitial();
      case 'copy':
        await Clipboard.setData(ClipboardData(text: '${m['text']}'));
      case 'privacy':
        AdService.instance.showPrivacyOptions();
    }
  }

  @override
  Widget build(BuildContext context) {
    final web = _web;
    return Scaffold(
      backgroundColor: const Color(0xFF0E1522),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: web == null
                  ? const Center(child: CircularProgressIndicator())
                  : WebViewWidget(controller: web),
            ),
            const BannerSlot(),
          ],
        ),
      ),
    );
  }
}
