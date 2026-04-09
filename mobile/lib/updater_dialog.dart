import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';
import 'dart:io';

class OTAUpdaterDialog extends StatefulWidget {
  final String downloadUrl;
  final String latestVersion;

  const OTAUpdaterDialog({
    super.key, 
    required this.downloadUrl, 
    required this.latestVersion,
  });

  @override
  State<OTAUpdaterDialog> createState() => _OTAUpdaterDialogState();
}

class _OTAUpdaterDialogState extends State<OTAUpdaterDialog> {
  bool _isDownloading = false;
  double _progress = 0.0;
  String _statusText = "A critical system update is required to continue using Hanguk Academy.";

  Future<void> _startDownloadAndInstall() async {
    setState(() {
      _isDownloading = true;
      _statusText = "Downloading update...";
    });

    try {
      final appDocDir = await getExternalStorageDirectory();
      String savePath = "${appDocDir!.path}/hanguk_update_${widget.latestVersion}.apk";

      Dio dio = Dio();
      await dio.download(
        widget.downloadUrl,
        savePath,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            setState(() {
              _progress = received / total;
            });
          }
        },
      );

      setState(() {
        _statusText = "Download complete. Starting installer...";
      });

      // System level call to invoke package installer
      final result = await OpenFilex.open(savePath);
      
      if (result.type != ResultType.done) {
        setState(() {
          _statusText = "Failed to launch installer: ${result.message}";
          _isDownloading = false;
        });
      }
    } catch (e) {
      setState(() {
        _statusText = "Failed to download update: $e";
        _isDownloading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // PopScope rigidly intercepts the physical Android system "Back" button
    // preventing users from arbitrarily dropping the dialog UI.
    return PopScope(
      canPop: false,
      child: AlertDialog(
        backgroundColor: const Color(0xFF1e293b), // Surface color
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.system_update, color: Color(0xFF14b8a6), size: 28),
            SizedBox(width: 12),
            Text(
              "Update Required",
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _statusText,
              style: const TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 24),
            if (_isDownloading)
              Column(
                children: [
                  LinearProgressIndicator(
                    value: _progress,
                    backgroundColor: Colors.white10,
                    valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF14b8a6)),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "${(_progress * 100).toStringAsFixed(1)}%",
                    style: const TextStyle(color: Colors.white54, fontSize: 12),
                  ),
                ],
              ),
          ],
        ),
        actions: [
          if (!_isDownloading)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF14b8a6),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: _startDownloadAndInstall,
                child: const Text("Download & Install", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
        ],
      ),
    );
  }
}
