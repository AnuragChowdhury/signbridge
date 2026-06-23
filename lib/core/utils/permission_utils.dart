import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

/// Utility for managing app permissions with user-friendly UI.
class PermissionUtils {
  PermissionUtils._();

  /// Requests camera permission.
  ///
  /// Returns `true` if permission is granted, `false` otherwise.
  /// Shows a rationale dialog if the user previously denied permission.
  static Future<bool> requestCameraPermission(BuildContext context) async {
    final status = await Permission.camera.status;

    if (status.isGranted) {
      return true;
    }

    if (status.isDenied) {
      final result = await Permission.camera.request();
      return result.isGranted;
    }

    if (status.isPermanentlyDenied) {
      if (context.mounted) {
        await _showPermissionDeniedDialog(context);
      }
      return false;
    }

    return false;
  }

  /// Checks if camera permission is currently granted.
  static Future<bool> hasCameraPermission() async {
    return await Permission.camera.isGranted;
  }

  /// Shows a dialog informing the user that camera permission was
  /// permanently denied and directing them to app settings.
  static Future<void> _showPermissionDeniedDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          icon: const Icon(Icons.camera_alt_outlined, size: 48),
          title: const Text('Camera Permission Required'),
          content: const Text(
            'SignBridge needs camera access to detect hand gestures '
            'for sign language recognition.\n\n'
            'Please enable camera permission in your device settings.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                openAppSettings();
              },
              child: const Text('Open Settings'),
            ),
          ],
        );
      },
    );
  }
}
