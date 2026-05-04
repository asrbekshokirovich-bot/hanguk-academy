import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:dio/dio.dart';
import 'dart:io';
import 'updater_dialog.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const HangukAcademyApp());
}

class HangukAcademyApp extends StatelessWidget {
  const HangukAcademyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hanguk Academy',
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: const Color(0xFF14b8a6),
      ),
      home: const DRMWebContainer(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class DRMWebContainer extends StatefulWidget {
  const DRMWebContainer({super.key});

  @override
  State<DRMWebContainer> createState() => _DRMWebContainerState();
}

class _DRMWebContainerState extends State<DRMWebContainer> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();
    _checkForUpdates();
    
    // The Flutter app now wraps the Hanguk Consulting / Interview Practice
    // site (hanguk-uz) instead of the academy site, so students get the full
    // training experience (Korean voice, AI auto-greet, recorded sessions,
    // etc.) on mobile via the same WebView shell.
    // Route is /auth — hanguk-uz uses react-router with `path="/auth"` for
    // the login/signup screen (not /login).
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0xFF0f172a))
      ..loadRequest(Uri.parse('https://hanguk-uz.vercel.app/auth'));
  }

  Future<void> _checkForUpdates() async {
    // Graceful bypass for non-Android instances since only Android allows direct sideloading via our FileProvider intent natively.
    if (!Platform.isAndroid) return;

    try {
      final packageInfo = await PackageInfo.fromPlatform();
      final currentVersion = packageInfo.version;

      // Make a GET request to the hosting manifest.
      // NOTE: hanguk-uz (Vite/React) does NOT currently expose `/api/version`,
      // so this request will 404 and the catch-block below silently bypasses
      // the update prompt. That's intentional for now — until a proper
      // version endpoint ships for hanguk-uz, the in-app OTA update flow is
      // a no-op (users can still update via Play Store / TestFlight). When
      // we add `/api/version` to hanguk-uz, this URL keeps working unchanged.
      Dio dio = Dio();
      final response = await dio.get('https://hanguk-uz.vercel.app/api/version');
      
      final remoteVersion = response.data['latest_version'] as String?;
      final downloadUrl = response.data['download_url'] as String?;
      final remoteHash = response.data['sha256_checksum'] as String?;

      if (remoteVersion != null && remoteVersion != currentVersion && downloadUrl != null && remoteHash != null) {
        if (mounted) {
          showDialog(
            context: context,
            barrierDismissible: false, // Core constraint enforcing blocking properties.
            builder: (BuildContext context) {
              return OTAUpdaterDialog(
                downloadUrl: downloadUrl,
                latestVersion: remoteVersion,
                expectedSha256: remoteHash,
              );
            },
          );
        }
      }
    } catch (e) {
      debugPrint("Update check failed: $e, continuing cleanly if network is partitioned.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: WebViewWidget(controller: _controller),
      ),
    );
  }
}
