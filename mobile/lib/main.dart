import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter_windowmanager/flutter_windowmanager.dart';
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
    _secureScreen();
    _checkForUpdates();
    
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0xFF0f172a))
      ..loadRequest(Uri.parse('https://hanguk-academy.vercel.app'));
  }

  Future<void> _checkForUpdates() async {
    // Graceful bypass for non-Android instances since only Android allows direct sideloading via our FileProvider intent natively.
    if (!Platform.isAndroid) return;

    try {
      final packageInfo = await PackageInfo.fromPlatform();
      final currentVersion = packageInfo.version;

      // Make a GET request to the hosting manifest.
      // (Placeholder endpoint linked to Vercel deployment structure).
      Dio dio = Dio();
      final response = await dio.get('https://hanguk-academy.vercel.app/api/version');
      
      final remoteVersion = response.data['latest_version'] as String?;
      final downloadUrl = response.data['download_url'] as String?;

      if (remoteVersion != null && remoteVersion != currentVersion && downloadUrl != null) {
        if (mounted) {
          showDialog(
            context: context,
            barrierDismissible: false, // Core constraint enforcing blocking properties.
            builder: (BuildContext context) {
              return OTAUpdaterDialog(
                downloadUrl: downloadUrl,
                latestVersion: remoteVersion,
              );
            },
          );
        }
      }
    } catch (e) {
      debugPrint("Update check failed: $e, continuing cleanly if network is partitioned.");
    }
  }

  Future<void> _secureScreen() async {
    // Dynamic fallback: Request FLAG_SECURE on Android explicitly.
    if (Platform.isAndroid) {
      await FlutterWindowManager.addFlags(FlutterWindowManager.FLAG_SECURE);
    }
    // iOS is handled via AppDelegate.swift natively.
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
