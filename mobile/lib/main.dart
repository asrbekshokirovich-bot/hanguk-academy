import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:dio/dio.dart';
import 'package:pub_semver/pub_semver.dart';
import 'package:url_launcher/url_launcher.dart';
import 'updater_dialog.dart';

/// URL of the live JSON manifest published by the GitHub Actions release
/// workflow. The CI writes a `version.json` and attaches it to every release;
/// `releases/latest/download/...` always resolves to the newest release.
const String _versionManifestUrl =
    'https://github.com/asrbekshokirovich-bot/hanguk-academy/releases/latest/download/version.json';

/// App Store / TestFlight URL shown to iOS users when an update is available.
/// Replace with your real App Store link once the iOS build is published.
const String _appStoreUrl = 'https://apps.apple.com/app/hanguk-consulting/id0';

/// Root URL that the WebView opens. Pointed at hanguk-uz so students get
/// the Interview Practice / Trainer experience.
const String _webAppUrl = 'https://hanguk-uz.vercel.app/auth';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const HangukAcademyApp());
}

class HangukAcademyApp extends StatelessWidget {
  const HangukAcademyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hanguk Consulting',
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
  bool _showIosBanner = false;
  String? _iosLatestVersion;

  @override
  void initState() {
    super.initState();
    // Defer the version check until the first frame is painted so the
    // WebView has a chance to start loading first — better perceived
    // performance, and the dialog doesn't render over a black screen.
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkForUpdates());

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0xFF0f172a))
      ..loadRequest(Uri.parse(_webAppUrl));
  }

  Future<void> _checkForUpdates() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      final currentVersion = packageInfo.version; // e.g. "1.0.3"

      final manifest = await _fetchManifest();
      if (manifest == null) return;

      final latestVersionRaw = manifest['latest_version'] as String?;
      final minRequiredRaw = manifest['min_required_version'] as String?;
      final downloadUrl = manifest['download_url'] as String?;
      final sha256Hash = manifest['sha256_checksum'] as String?;
      final releaseNotes = manifest['release_notes'] as String?;
      final rolloutPercent =
          (manifest['rollout_percent'] as num?)?.toDouble() ?? 100.0;

      if (latestVersionRaw == null) return;

      final current = _tryParseVersion(currentVersion);
      final latest = _tryParseVersion(latestVersionRaw);
      final minRequired = _tryParseVersion(minRequiredRaw);
      if (current == null || latest == null) return;

      final isForcedUpdate =
          minRequired != null && current < minRequired;

      // Already on the latest? Only do the iOS-banner branch if there's an
      // *actual* newer version live.
      if (!isForcedUpdate && current >= latest) return;

      // iOS can't sideload an APK — we direct the user to the store instead.
      if (Platform.isIOS) {
        if (mounted) {
          setState(() {
            _showIosBanner = true;
            _iosLatestVersion = latestVersionRaw;
          });
        }
        return;
      }

      if (!Platform.isAndroid) return;

      // Rollout gate: pseudo-random per-launch sample. A forced update
      // bypasses the gate so security floors always apply universally.
      if (!isForcedUpdate && rolloutPercent < 100) {
        final roll = Random().nextDouble() * 100;
        if (roll > rolloutPercent) return;
      }

      if (downloadUrl == null || sha256Hash == null) return;

      if (!mounted) return;
      showDialog(
        context: context,
        barrierDismissible: !isForcedUpdate,
        builder: (ctx) => OTAUpdaterDialog(
          currentVersion: currentVersion,
          latestVersion: latestVersionRaw,
          downloadUrl: downloadUrl,
          expectedSha256: sha256Hash,
          releaseNotes: releaseNotes,
          force: isForcedUpdate,
        ),
      );
    } catch (e) {
      // Network partition, malformed JSON, etc. — never block app startup
      // on the update flow. Log and continue.
      debugPrint('[updater] check failed: $e');
    }
  }

  /// Fetches the JSON manifest from GitHub Releases. Returns null on any
  /// transport-level failure (offline, 5xx, etc.) so the caller can no-op.
  Future<Map<String, dynamic>?> _fetchManifest() async {
    try {
      final dio = Dio(BaseOptions(
        connectTimeout: const Duration(seconds: 6),
        receiveTimeout: const Duration(seconds: 6),
        responseType: ResponseType.json,
        followRedirects: true,
        validateStatus: (s) => s != null && s >= 200 && s < 400,
      ));
      final response = await dio.get(_versionManifestUrl);
      final data = response.data;
      if (data is Map) return Map<String, dynamic>.from(data);
      return null;
    } catch (_) {
      return null;
    }
  }

  Version? _tryParseVersion(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    // pub_semver tolerates "1.0.3" and "1.0.3+2"; strip a leading "v" if the
    // manifest accidentally uses tag-style "v1.0.3".
    final stripped = raw.startsWith('v') ? raw.substring(1) : raw;
    try {
      return Version.parse(stripped);
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            WebViewWidget(controller: _controller),
            if (_showIosBanner) _buildIosUpdateBanner(),
          ],
        ),
      ),
    );
  }

  Widget _buildIosUpdateBanner() {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: Material(
        color: const Color(0xFF14b8a6),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: [
                const Icon(Icons.system_update, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    "Update available: v${_iosLatestVersion ?? ''}",
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.w600),
                  ),
                ),
                TextButton(
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () async {
                    final uri = Uri.parse(_appStoreUrl);
                    if (await canLaunchUrl(uri)) {
                      await launchUrl(uri,
                          mode: LaunchMode.externalApplication);
                    }
                  },
                  child: const Text("Open App Store"),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () =>
                      setState(() => _showIosBanner = false),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
