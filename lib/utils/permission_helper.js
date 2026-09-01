export class PermissionHelper {
  static async requestMicrophonePermission() {
    try {
      if (navigator?.permissions?.query) {
        const status = await navigator.permissions.query({ name: 'microphone' });
        if (status.state === 'granted') {
          return true;
        }
      }
      const stream = await navigator.mediaDevices.getUserMedia({ audio: true });
      stream.getTracks().forEach((track) => track.stop());
      return true;
    } catch (_) {
      return false;
    }
  }

  static async isMicrophoneGranted() {
    try {
      if (navigator?.permissions?.query) {
        const status = await navigator.permissions.query({ name: 'microphone' });
        return status.state === 'granted';
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  static async openSettings() {
    return false;
  }
}
