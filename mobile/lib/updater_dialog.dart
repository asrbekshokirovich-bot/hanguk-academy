import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:crypto/crypto.dart';
import 'dart:io';

/// Dialog that downloads + installs a new APK.
///
/// Two modes, controlled by [force]:
///  - **force=false** → user can dismiss with "Later". The dialog is shown
///    when a newer version is available but the current one is still
///    above `min_required_version`.
///  - **force=true** → no dismiss path. The dialog is shown when the
///    current version is below `min_required_version` (security or
///    compatibility floor).
class OTAUpdaterDialog extends StatefulWidget {
  final String currentVersion;
  final String latestVersion;
  final String downloadUrl;
  final String expectedSha256;
  final String? releaseNotes;
  final bool force;

  const OTAUpdaterDialog({
    super.key,
    required this.currentVersion,
    required this.latestVersion,
    required this.downloadUrl,
    required this.expectedSha256,
    this.releaseNotes,
    this.force = false,
  });

  @override
  State<OTAUpdaterDialog> createState() => _OTAUpdaterDialogState();
}

enum _Phase { idle, downloading, verifying, ready, error }

class _OTAUpdaterDialogState extends State<OTAUpdaterDialog> {
  _Phase _phase = _Phase.idle;
  double _progress = 0.0;
  String? _errorMessage;
  String? _downloadedApkPath;

  String get _statusText {
    switch (_phase) {
      case _Phase.idle:
        return widget.force
            ? "This update is required to keep using Hanguk Consulting."
            : "A new version of Hanguk Consulting is available.";
      case _Phase.downloading:
        return "Downloading update… ${(_progress * 100).toStringAsFixed(0)}%";
      case _Phase.verifying:
        return "Verifying signature…";
      case _Phase.ready:
        return "Download complete. Launching installer…";
      case _Phase.error:
        return _errorMessage ?? "Update failed.";
    }
  }

  Future<void> _ensureInstallPermission() async {
    // Android 8+ requires the user to explicitly allow this app to install
    // unknown APKs. We request once; if denied, the install intent will
    // simply do nothing and the user can retry after granting in Settings.
    if (!Platform.isAndroid) return;
    final status = await Permission.requestInstallPackages.status;
    if (status.isGranted) return;
    final result = await Permission.requestInstallPackages.request();
    if (!result.isGranted) {
      throw Exception(
        "Install permission was denied. Open Settings → Special access → "
        "Install unknown apps → Hanguk Consulting and allow it, then retry.",
      );
    }
  }

  Future<void> _startDownloadAndInstall() async {
    setState(() {
      _phase = _Phase.downloading;
      _progress = 0.0;
      _errorMessage = null;
    });

    try {
      await _ensureInstallPermission();

      final dir = await getExternalStorageDirectory();
      if (dir == null) {
        throw Exception("External storage is unavailable on this device.");
      }
      final savePath = "${dir.path}/hanguk_update_${widget.latestVersion}.apk";

      final dio = Dio();
      await dio.download(
        widget.downloadUrl,
        savePath,
        onReceiveProgress: (received, total) {
          if (total > 0 && mounted) {
            setState(() => _progress = received / total);
          }
        },
      );

      if (!mounted) return;
      setState(() => _phase = _Phase.verifying);

      // Tamper check. We deliberately fail closed: an empty/invalid expected
      // hash aborts the install rather than silently bypassing verification.
      final fileBytes = await File(savePath).readAsBytes();
      final calculated = sha256.convert(fileBytes).toString();

      if (widget.expectedSha256.isEmpty ||
          widget.expectedSha256.length != 64) {
        await File(savePath).delete().catchError((_) => File(savePath));
        throw Exception("Update manifest is missing a valid SHA-256 hash.");
      }
      if (calculated.toLowerCase() != widget.expectedSha256.toLowerCase()) {
        await File(savePath).delete().catchError((_) => File(savePath));
        throw Exception(
          "Downloaded file does not match the expected signature. "
          "Aborting install for your safety.",
        );
      }

      if (!mounted) return;
      setState(() {
        _phase = _Phase.ready;
        _downloadedApkPath = savePath;
      });

      final result = await OpenFilex.open(savePath);
      if (result.type != ResultType.done) {
        throw Exception(
          "Failed to launch installer: ${result.message}. "
          "Try opening Settings → Special access → Install unknown apps.",
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _phase = _Phase.error;
        _errorMessage = e.toString().replaceFirst("Exception: ", "");
      });
    }
  }

  void _retryInstall() {
    final path = _downloadedApkPath;
    if (path != null && File(path).existsSync()) {
      // We already have a verified APK on disk — just relaunch the installer.
      OpenFilex.open(path);
      return;
    }
    _startDownloadAndInstall();
  }

  @override
  Widget build(BuildContext context) {
    // Only block back-button when the update is mandatory.
    return PopScope(
      canPop: !widget.force && _phase != _Phase.downloading,
      child: AlertDialog(
        backgroundColor: const Color(0xFF1e293b),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.system_update,
                color: Color(0xFF14b8a6), size: 28),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                widget.force ? "Update Required" : "Update Available",
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Current: ${widget.currentVersion}  →  New: ${widget.latestVersion}",
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Text(_statusText, style: const TextStyle(color: Colors.white70)),
            if (widget.releaseNotes != null &&
                widget.releaseNotes!.trim().isNotEmpty &&
                _phase == _Phase.idle) ...[
              const SizedBox(height: 12),
              Text(
                "What's new:\n${widget.releaseNotes}",
                style: const TextStyle(color: Colors.white54, fontSize: 12),
              ),
            ],
            if (_phase == _Phase.downloading) ...[
              const SizedBox(height: 16),
              LinearProgressIndicator(
                value: _progress > 0 ? _progress : null,
                backgroundColor: Colors.white10,
                valueColor: const AlwaysStoppedAnimation<Color>(
                    Color(0xFF14b8a6)),
              ),
            ],
          ],
        ),
        actions: _buildActions(context),
      ),
    );
  }

  List<Widget> _buildActions(BuildContext context) {
    final primaryStyle = ElevatedButton.styleFrom(
      backgroundColor: const Color(0xFF14b8a6),
      foregroundColor: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    );
    final secondaryStyle = TextButton.styleFrom(
      foregroundColor: Colors.white70,
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
    );

    switch (_phase) {
      case _Phase.idle:
        return [
          if (!widget.force)
            TextButton(
              style: secondaryStyle,
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Later"),
            ),
          ElevatedButton(
            style: primaryStyle,
            onPressed: _startDownloadAndInstall,
            child: const Text("Download & Install",
                style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ];
      case _Phase.downloading:
      case _Phase.verifying:
      case _Phase.ready:
        // No actions while a network/file operation is in flight.
        return const [];
      case _Phase.error:
        return [
          if (!widget.force)
            TextButton(
              style: secondaryStyle,
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Close"),
            ),
          ElevatedButton(
            style: primaryStyle,
            onPressed: _retryInstall,
            child: const Text("Retry"),
          ),
        ];
    }
  }
}
