import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter_windowmanager/flutter_windowmanager.dart';
import 'dart:io';

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
    
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0xFF0f172a))
      ..loadRequest(Uri.parse('https://hanguk-academy.vercel.app'));
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
