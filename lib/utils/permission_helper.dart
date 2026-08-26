import 'package:permission_handler/permission_handler.dart';

/// Helper utility to request and check device permissions
class PermissionHelper {
  PermissionHelper._();

  /// Requests microphone permission and returns true if granted
  static Future<bool> requestMicrophonePermission() async {
    final status = await Permission.microphone.status;
    if (status.isGranted) {
      return true;
    }
    final result = await Permission.microphone.request();
    return result.isGranted;
  }

  /// Checks if microphone permission is granted
  static Future<bool> isMicrophoneGranted() async {
    return Permission.microphone.isGranted;
  }

  /// Opens app settings if permission is permanently denied
  static Future<bool> openSettings() async {
    return openAppSettings();
  }
}
