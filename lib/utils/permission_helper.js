export class PermissionHelper {
  static isAppleDevice() {
    if (typeof navigator === 'undefined') return false;
    const ua = navigator.userAgent || '';
    const platform = navigator.platform || '';
    const maxTouchPoints = navigator.maxTouchPoints || 0;
    return (
      /iPad|iPhone|iPod/.test(ua) ||
      (platform === 'MacIntel' && maxTouchPoints > 1) ||
      /Macintosh/.test(ua)
    );
  }

  static isSecureOrigin() {
    if (typeof window === 'undefined') return true;
    return (
      window.isSecureContext ??
      (window.location.protocol === 'https:' ||
        window.location.hostname === 'localhost' ||
        window.location.hostname === '127.0.0.1')
    );
  }

  static async checkMicrophoneStatus() {
    const isApple = this.isAppleDevice();

    if (!this.isSecureOrigin()) {
      return {
        status: 'insecure',
        message: 'الاتصال غير آمن (HTTP). يتطلب متصفح Safari وأجهزة آبل رابط HTTPS مشفر لتشغيل المايك.',
        actionHint: 'استخدم رابط https:// أو نفق Cloudflare للوصول.',
      };
    }

    if (!navigator?.mediaDevices?.getUserMedia) {
      return {
        status: 'unsupported',
        message: 'المتصفح لا يدعم الوصول إلى الميكروفون.',
        actionHint: isApple ? 'تأكد من فتح الرابط عبر تطبيق Safari الرسمي.' : 'استخدم متصفحاً حديثاً.',
      };
    }

    try {
      if (navigator?.permissions?.query) {
        const queryStatus = await navigator.permissions.query({ name: 'microphone' });
        if (queryStatus.state === 'granted') {
          return { status: 'granted', message: 'إذن الميكروفون متاح ومفعل.' };
        } else if (queryStatus.state === 'denied') {
          return {
            status: 'denied',
            message: 'تم حظر الميكروفون من إعدادات المتصفح.',
            actionHint: 'اضغط على أيقونة القفل أو المايك في شريط العنوان وفعّل الإذن.',
          };
        }
      }
    } catch (_) {
      // Safari لا يدعم query('microphone')
    }

    return {
      status: 'prompt',
      message: 'يتطلب إذن الميكروفون عند بدء التسجيل.',
      actionHint: 'اضغط سماح (Allow) عند ظهور نافذة الإذن.',
    };
  }

  static async requestMicrophonePermission() {
    try {
      if (!navigator?.mediaDevices?.getUserMedia) return false;
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

export default PermissionHelper;

