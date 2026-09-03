import React, { useState, useEffect, useRef } from 'react';
import { ApiService } from '../services/api_service.js';
import { useAppState } from '../services/app_state.jsx';
import { AudioService } from '../services/audio_service.js';
import { AppTheme } from '../theme/app_theme.js';
import { AudioVisualizerWave } from '../widgets/audio_visualizer_wave.jsx';
import { HoldToRecordButton, RecordingMode } from '../widgets/hold_to_record_button.jsx';
import { ResponsiveContainer } from '../widgets/responsive_container.jsx';

const RecordingStage = Object.freeze({
  idle: 'idle',
  recording: 'recording',
  uploading: 'uploading',
});

function SuccessDialog({ isOpen, onClose, onRecordAgain, onGoToMenu, score }) {
  if (!isOpen) return null;

  return (
    <div
      style={{
        position: 'fixed',
        inset: 0,
        backgroundColor: 'rgba(0, 0, 0, 0.6)',
        display: 'flex',
        alignItems: 'center',
        justifyContent: 'center',
        zIndex: 2000,
        padding: 16,
      }}
      onClick={onClose}
    >
      <div
        style={{
          backgroundColor: '#fff',
          borderRadius: 28,
          padding: '28px 24px',
          maxWidth: 460,
          width: '90%',
          boxShadow: '0 8px 30px rgba(0, 0, 0, 0.2)',
          display: 'flex',
          flexDirection: 'column',
          alignItems: 'center',
          boxSizing: 'border-box',
          position: 'relative',
          zIndex: 2001,
        }}
        onClick={(e) => e.stopPropagation()}
      >
        <div
          style={{
            width: 80,
            height: 80,
            borderRadius: '50%',
            background: AppTheme.amberGradient,
            boxShadow: `0 8px 20px ${AppTheme.accentOrange}59`,
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'center',
          }}
        >
          <span style={{ fontSize: 40 }}>🎉</span>
        </div>

        <div style={{ height: 16 }} />

        <h2
          style={{
            fontSize: 22,
            fontWeight: 900,
            color: AppTheme.textDark,
            textAlign: 'center',
            margin: 0,
          }}
        >
          فجرت المايك يا غالي! 🇯🇴
        </h2>

        <div style={{ height: 8 }} />

        <p
          style={{
            fontSize: 14,
            color: AppTheme.textMuted,
            lineHeight: 1.5,
            textAlign: 'center',
            margin: 0,
          }}
        >
          تم رفع تسجيلك بنجاح للمشروع الوطني، شكراً لمساهمتك القيمة!
        </p>

        <div style={{ height: 16 }} />

        <div
          style={{
            padding: '8px 16px',
            backgroundColor: `${AppTheme.primary}1A`,
            borderRadius: 16,
            border: `1px solid ${AppTheme.primary}40`,
            display: 'flex',
            alignItems: 'center',
          }}
        >
          <span
            className="material-icons-round"
            style={{ color: AppTheme.primary, fontSize: 20 }}
          >
            stars
          </span>
          <div style={{ width: 8 }} />
          <span
            style={{
              fontSize: 14,
              fontWeight: 800,
              color: AppTheme.primaryDark,
            }}
          >
            {`مجموع مساهماتك الآن: ${score}`}
          </span>
        </div>

        <div style={{ height: 24 }} />

        <div style={{ width: '100%', display: 'flex', flexDirection: 'column', gap: 10 }}>
          <button
            type="button"
            style={{
              width: '100%',
              height: 50,
              backgroundColor: AppTheme.primary,
              color: '#ffffff',
              border: 'none',
              borderRadius: 12,
              cursor: 'pointer',
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'center',
              gap: 8,
              fontSize: 15.5,
              fontWeight: 'bold',
              touchAction: 'manipulation',
            }}
            onClick={onRecordAgain}
            onTouchEnd={(e) => {
              e.preventDefault();
              onRecordAgain();
            }}
          >
            <span className="material-icons-round" style={{ fontSize: 20 }}>
              refresh
            </span>
            <span>تسجيل جملة ثانية</span>
          </button>

          <button
            type="button"
            style={{
              width: '100%',
              height: 50,
              backgroundColor: 'transparent',
              color: AppTheme.primary,
              border: `1.5px solid ${AppTheme.primary}`,
              borderRadius: 12,
              cursor: 'pointer',
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'center',
              gap: 8,
              fontSize: 15,
              fontWeight: 700,
              touchAction: 'manipulation',
            }}
            onClick={onGoToMenu}
            onTouchEnd={(e) => {
              e.preventDefault();
              onGoToMenu();
            }}
          >
            <span className="material-icons-round" style={{ fontSize: 20 }}>
              grid_view
            </span>
            <span>العودة لقائمة المشاعر</span>
          </button>
        </div>
      </div>
    </div>
  );
}

function ErrorBanner({ error, onDismiss, onRetry }) {
  if (!error) return null;
  const message = typeof error === 'string' ? error : (error.message || 'حدث خطأ غير متوقع');
  const actionHint = typeof error === 'object' ? error.actionHint : null;
  const isAppleIssue = typeof error === 'object' && (error.code === 'PERMISSION_DENIED' || error.code === 'INSECURE_CONTEXT');

  return (
    <div
      style={{
        width: '100%',
        boxSizing: 'border-box',
        padding: '14px 16px',
        backgroundColor: '#fef2f2',
        border: '1.5px solid #f87171',
        borderRadius: 16,
        boxShadow: '0 4px 14px rgba(239, 68, 68, 0.12)',
        display: 'flex',
        flexDirection: 'column',
        gap: 10,
        textAlign: 'right',
        animation: 'fadeIn 0.25s ease-out',
      }}
    >
      <div style={{ display: 'flex', alignItems: 'flex-start', justifyContent: 'space-between', gap: 8 }}>
        <div style={{ display: 'flex', alignItems: 'flex-start', gap: 10 }}>
          <div
            style={{
              width: 32,
              height: 32,
              borderRadius: '50%',
              backgroundColor: '#fee2e2',
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'center',
              flexShrink: 0,
            }}
          >
            <span className="material-icons-round" style={{ fontSize: 20, color: '#dc2626' }}>
              error_outline
            </span>
          </div>
          <div>
            <div style={{ fontSize: 14, fontWeight: 800, color: '#991b1b', lineHeight: 1.4 }}>
              {message}
            </div>
            {actionHint && (
              <div
                style={{
                  fontSize: 12.5,
                  fontWeight: 600,
                  color: '#b91c1c',
                  marginTop: 6,
                  lineHeight: 1.5,
                  backgroundColor: '#ffffff',
                  padding: '8px 12px',
                  borderRadius: 10,
                  border: '1px solid #fecaca',
                }}
              >
                💡 {actionHint}
              </div>
            )}
          </div>
        </div>

        {onDismiss && (
          <button
            type="button"
            onClick={onDismiss}
            style={{
              background: 'none',
              border: 'none',
              cursor: 'pointer',
              padding: 4,
              color: '#991b1b',
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'center',
            }}
            title="إغلاق"
          >
            <span className="material-icons-round" style={{ fontSize: 18 }}>
              close
            </span>
          </button>
        )}
      </div>

      {isAppleIssue && (
        <div
          style={{
            backgroundColor: '#fff1f2',
            padding: '8px 12px',
            borderRadius: 10,
            border: '1px dashed #f43f5e',
            fontSize: 12,
            color: '#881337',
            display: 'flex',
            alignItems: 'center',
            gap: 6,
          }}
        >
          <span style={{ fontSize: 16 }}>🍎</span>
          <span><strong>لمستخدمي أجهزة Apple:</strong> تأكد من فتح الرابط عبر متصفح Safari وليس متصفح مصغر، وتأكد من رابط HTTPS.</span>
        </div>
      )}

      {onRetry && (
        <div style={{ display: 'flex', justifyContent: 'flex-end', marginTop: 2 }}>
          <button
            type="button"
            onClick={onRetry}
            style={{
              padding: '6px 14px',
              backgroundColor: '#dc2626',
              color: '#ffffff',
              border: 'none',
              borderRadius: 8,
              fontSize: 12.5,
              fontWeight: 700,
              cursor: 'pointer',
              display: 'inline-flex',
              alignItems: 'center',
              gap: 4,
            }}
          >
            <span className="material-icons-round" style={{ fontSize: 16 }}>
              refresh
            </span>
            <span>إعادة المحاولة</span>
          </button>
        </div>
      )}
    </div>
  );
}

function InfoBanner({ message, onDismiss }) {
  if (!message) return null;
  return (
    <div
      style={{
        width: '100%',
        boxSizing: 'border-box',
        padding: '12px 14px',
        backgroundColor: '#eff6ff',
        border: '1.5px solid #93c5fd',
        borderRadius: 14,
        boxShadow: '0 3px 10px rgba(59, 130, 246, 0.08)',
        display: 'flex',
        alignItems: 'center',
        justifyContent: 'space-between',
        gap: 10,
        textAlign: 'right',
        animation: 'fadeIn 0.25s ease-out',
      }}
    >
      <div style={{ display: 'flex', alignItems: 'center', gap: 8 }}>
        <span className="material-icons-round" style={{ fontSize: 20, color: '#2563eb' }}>
          info
        </span>
        <span style={{ fontSize: 13, fontWeight: 700, color: '#1e40af', lineHeight: 1.4 }}>
          {message}
        </span>
      </div>
      {onDismiss && (
        <button
          type="button"
          onClick={onDismiss}
          style={{
            background: 'none',
            border: 'none',
            cursor: 'pointer',
            padding: 4,
            color: '#2563eb',
            display: 'flex',
            alignItems: 'center',
          }}
          title="إغلاق"
        >
          <span className="material-icons-round" style={{ fontSize: 18 }}>
            close
          </span>
        </button>
      )}
    </div>
  );
}

function Shortcut({ keyLabel, actionLabel }) {
  return (
    <div style={{ display: 'flex', alignItems: 'center' }}>
      <div
        style={{
          padding: '3px 7px',
          backgroundColor: '#ffffff',
          borderRadius: 6,
          border: `1.2px solid ${AppTheme.borderLight}`,
          boxShadow: '0 1px 3px rgba(0,0,0,0.04)',
          fontSize: 11,
          fontWeight: 800,
          color: AppTheme.textDark,
          fontFamily: 'monospace',
        }}
      >
        {keyLabel}
      </div>
      <div style={{ width: 6 }} />
      <span
        style={{
          fontSize: 11.5,
          fontWeight: 600,
          color: AppTheme.textMuted,
        }}
      >
        {actionLabel}
      </span>
    </div>
  );
}

function KeyboardShortcutsCheatSheet({ isRecording, mode }) {
  return (
    <div
      style={{
        padding: '10px 14px',
        backgroundColor: AppTheme.surfaceElevated,
        borderRadius: 14,
        border: `1px solid ${AppTheme.borderLight}`,
        display: 'flex',
        justifyContent: 'space-around',
        alignItems: 'center',
      }}
    >
      <Shortcut keyLabel="Space" actionLabel={isRecording ? 'إيقاف وإرسال' : 'تسجيل'} />
      <Shortcut keyLabel="R" actionLabel="جملة جديدة" />
      <Shortcut keyLabel="Esc" actionLabel="رجوع" />
    </div>
  );
}

function ModeItem({ label, isSelected, onTap }) {
  return (
    <div
      onClick={onTap}
      onTouchEnd={(e) => {
        if (onTap) {
          e.preventDefault();
          onTap();
        }
      }}
      style={{
        cursor: onTap ? 'pointer' : 'default',
        borderRadius: 12,
        padding: '8px 14px',
        backgroundColor: isSelected ? AppTheme.primary : 'transparent',
        transition: 'background-color 200ms ease',
        userSelect: 'none',
        touchAction: 'manipulation',
      }}
    >
      <span
        style={{
          fontSize: 12.5,
          fontWeight: isSelected ? 800 : 600,
          color: isSelected ? '#ffffff' : AppTheme.textMuted,
        }}
      >
        {label}
      </span>
    </div>
  );
}

function RecordingModeSelector({ currentMode, isBusy, onModeChanged }) {
  return (
    <div
      style={{
        padding: 4,
        backgroundColor: AppTheme.surface,
        borderRadius: 16,
        border: `1px solid ${AppTheme.borderLight}`,
        display: 'inline-flex',
        alignItems: 'center',
      }}
    >
      <ModeItem
        label="اضغط واستمر 👆"
        isSelected={currentMode === RecordingMode.hold}
        onTap={isBusy ? null : () => onModeChanged(RecordingMode.hold)}
      />
      <div style={{ width: 4 }} />
      <ModeItem
        label="ضغطة للبدء والإيقاف ⏯️"
        isSelected={currentMode === RecordingMode.tapToToggle}
        onTap={isBusy ? null : () => onModeChanged(RecordingMode.tapToToggle)}
      />
    </div>
  );
}

function PromptCard({
  prompt,
  emotion,
  onShuffle,
  promptNumber,
  totalPrompts,
  isDesktop = false,
}) {
  return (
    <div
      style={{
        width: '100%',
        boxSizing: 'border-box',
        padding: 20,
        backgroundColor: `${emotion.color}14`,
        borderRadius: 24,
        border: `1.5px solid ${emotion.color}4D`,
        boxShadow: `0 6px 16px ${emotion.color}14`,
        display: 'flex',
        flexDirection: 'column',
      }}
    >
      {/* الرأس: تنبيه أن النص مجرد مثال */}
      <div
        style={{
          display: 'flex',
          justifyContent: 'space-between',
          alignItems: 'center',
        }}
      >
        <div style={{ display: 'flex', alignItems: 'center' }}>
          <div
            style={{
              padding: '4px 10px',
              backgroundColor: `${emotion.color}2E`,
              borderRadius: 10,
            }}
          >
            <span
              style={{
                fontSize: 12,
                fontWeight: 800,
                color: emotion.darkColor,
              }}
            >
              مثال للإلهام فقط 💡
            </span>
          </div>
          <div style={{ width: 8 }} />
          <span
            style={{
              fontSize: 13,
              fontWeight: 700,
              color: AppTheme.textMuted,
            }}
          >
            {`بنبرة ${emotion.labelArabic}:`}
          </span>
        </div>

        {onShuffle && (
          <button
            type="button"
            onClick={onShuffle}
            onTouchEnd={(e) => {
              e.preventDefault();
              onShuffle();
            }}
            style={{
              background: 'none',
              border: 'none',
              color: emotion.darkColor,
              padding: '4px 10px',
              cursor: 'pointer',
              display: 'flex',
              alignItems: 'center',
              gap: 4,
              touchAction: 'manipulation',
            }}
          >
            <span className="material-icons-round" style={{ fontSize: 16 }}>
              shuffle
            </span>
            <span style={{ fontSize: 12, fontWeight: 800 }}>
              {isDesktop ? 'مثال ثاني (R)' : 'مثال ثاني'}
            </span>
          </button>
        )}
      </div>

      <div style={{ height: 12 }} />

      {/* نص المثال المقترح */}
      <div
        key={prompt}
        style={{
          textAlign: 'right',
          fontSize: 20,
          fontWeight: 800,
          lineHeight: 1.55,
          color: AppTheme.textDark,
          opacity: 0.9,
          transition: 'opacity 250ms ease-in-out',
        }}
      >
        "{prompt}"
      </div>

      <div style={{ height: 14 }} />

      {/* صندوق التوضيح لتدريب الـ AI */}
      <div
        style={{
          padding: '10px 14px',
          backgroundColor: '#ffffff',
          borderRadius: 14,
          border: `1.5px dashed ${emotion.color}66`,
          display: 'flex',
          alignItems: 'center',
          gap: 10,
        }}
      >
        <span
          className="material-icons-round"
          style={{ fontSize: 22, color: emotion.darkColor, flexShrink: 0 }}
        >
          record_voice_over
        </span>
        <div style={{ display: 'flex', flexDirection: 'column', textAlign: 'right' }}>
          <span style={{ fontSize: 13, fontWeight: 800, color: AppTheme.textDark }}>
            احكي أي جملة عفوية من عندك! 🇯🇴
          </span>
          <span style={{ fontSize: 11.5, color: AppTheme.textMuted, fontWeight: 600, marginTop: 2 }}>
            المثال اللي فوق مجرد فكرة.. عشان ندرب الذكاء الاصطناعي بدنا كلام عفوي وطبيعي تماماً بنفس الشعور.
          </span>
        </div>
      </div>
    </div>
  );
}

export function RecordingScreen({ emotion, onBack }) {
  const appState = useAppState();
  const audioServiceRef = useRef(null);
  const apiServiceRef = useRef(null);

  if (!audioServiceRef.current) {
    audioServiceRef.current = new AudioService();
  }
  if (!apiServiceRef.current) {
    apiServiceRef.current = new ApiService();
  }

  const _audioService = audioServiceRef.current;
  const _apiService = apiServiceRef.current;

  const [promptIndex, setPromptIndex] = useState(() =>
    Math.floor(Math.random() * (emotion?.prompts?.length || 1))
  );
  const [stage, setStage] = useState(RecordingStage.idle);
  const [recordingMode, setRecordingMode] = useState(RecordingMode.hold);
  const [lastError, setLastError] = useState(null);
  const [infoTip, setInfoTip] = useState(null);
  const [elapsedMilliseconds, setElapsedMilliseconds] = useState(0);
  const [successDialogOpen, setSuccessDialogOpen] = useState(false);

  const timerRef = useRef(null);
  const recordStartTimeRef = useRef(null);
  const isRecordingRef = useRef(false);
  const wakeLockRef = useRef(null);

  const MAX_RECORDING_MS = 25000; // حد أقصى للأمان: 25 ثانية

  const acquireWakeLock = async () => {
    try {
      if (typeof navigator !== 'undefined' && 'wakeLock' in navigator) {
        wakeLockRef.current = await navigator.wakeLock.request('screen');
      }
    } catch (e) {}
  };

  const releaseWakeLock = async () => {
    try {
      if (wakeLockRef.current) {
        await wakeLockRef.current.release();
        wakeLockRef.current = null;
      }
    } catch (e) {}
  };

  useEffect(() => {
    return () => {
      if (timerRef.current) clearInterval(timerRef.current);
      releaseWakeLock();
      _audioService.dispose();
    };
  }, [_audioService]);

  const currentPrompt = emotion?.promptFor ? emotion.promptFor(promptIndex) : (emotion?.prompts?.[promptIndex] || '');

  const shufflePrompt = () => {
    if (stage === RecordingStage.recording || stage === RecordingStage.uploading) return;
    setPromptIndex((prev) => (prev + 1) % (emotion?.prompts?.length || 1));
    setLastError(null);
    setInfoTip(null);
  };

  const startTimer = () => {
    setElapsedMilliseconds(0);
    recordStartTimeRef.current = Date.now();
    if (timerRef.current) clearInterval(timerRef.current);
    timerRef.current = setInterval(() => {
      const elapsed = Date.now() - recordStartTimeRef.current;
      setElapsedMilliseconds(elapsed);
      if (elapsed >= MAX_RECORDING_MS) {
        stopRecordingAndUpload();
      }
    }, 100);
  };

  const stopTimer = () => {
    if (timerRef.current) {
      clearInterval(timerRef.current);
      timerRef.current = null;
    }
  };

  const formattedTimer = (() => {
    const totalSeconds = Math.floor(elapsedMilliseconds / 1000);
    const minutes = String(Math.floor(totalSeconds / 60)).padStart(2, '0');
    const seconds = String(totalSeconds % 60).padStart(2, '0');
    return `${minutes}:${seconds}`;
  })();

  const startRecording = async () => {
    if (isRecordingRef.current || stage === RecordingStage.recording || stage === RecordingStage.uploading) return;
    
    // تنشيط AudioContext مباشرة على حركة اللمس لدعم قيود Safari التلقائية
    _audioService.unlockAudioContext();

    setLastError(null);
    setInfoTip(null);
    isRecordingRef.current = true;
    setStage(RecordingStage.recording);
    startTimer();

    try {
      if (typeof navigator !== 'undefined' && navigator.vibrate) {
        try { navigator.vibrate(35); } catch (e) {}
      }
      acquireWakeLock();
      await _audioService.startRecording();
    } catch (e) {
      console.error('startRecording failed:', e);
      releaseWakeLock();
      isRecordingRef.current = false;
      stopTimer();
      setStage(RecordingStage.idle);
      setLastError({
        message: e.message || 'تعذر تشغيل الميكروفون',
        actionHint: e.actionHint || '',
        code: e.code || '',
      });
    }
  };

  const stopRecordingAndUpload = async () => {
    if (!isRecordingRef.current && stage !== RecordingStage.recording) return;
    isRecordingRef.current = false;
    stopTimer();
    releaseWakeLock();

    const recordDurationMs = Date.now() - (recordStartTimeRef.current || Date.now());

    if (recordDurationMs < 800) {
      await _audioService.stopRecording().catch(() => {});
      setStage(RecordingStage.idle);
      setInfoTip('التسجيل قصير جداً (أقل من ثانية). يرجى الاستمرار بالضغط والتحدث بوضوح.');
      return;
    }

    setStage(RecordingStage.uploading);

    try {
      const audioData = await _audioService.stopRecording();
      if (!audioData || audioData.isEmpty) {
        setStage(RecordingStage.idle);
        setLastError({
          message: 'لم يتم التقاط أي صوت، تأكد من أن الميكروفون يعمل وحاول مجدداً.',
          actionHint: 'تأكد من عدم كتم الصوت وتحدث بوضوح قرب المايك.',
          code: 'EMPTY_AUDIO',
        });
        return;
      }

      const promptText = (typeof currentPrompt === 'string' && currentPrompt.trim().length > 0)
        ? currentPrompt.trim()
        : (emotion?.labelArabic || 'تسجيل صوتي');

      const result = await _apiService.submitAudio({
        audioData,
        speakerId: appState.speakerId,
        emotionTag: emotion.apiTag,
        referenceText: promptText,
      });

      if (result.success) {
        if (typeof navigator !== 'undefined' && navigator.vibrate) {
          try { navigator.vibrate([40, 60, 40]); } catch (e) {}
        }
        appState.incrementScore();
        setStage(RecordingStage.idle);
        setElapsedMilliseconds(0);
        setSuccessDialogOpen(true);
      } else {
        setStage(RecordingStage.idle);
        setLastError({
          message: result.errorMessage || 'صار خطأ غير متوقع في رفع الصوت.',
          actionHint: 'تأكد من اتصال الإنترنت وعمل السيرفر.',
          code: 'UPLOAD_FAILED',
        });
      }
    } catch (err) {
      console.error('Upload error:', err);
      setStage(RecordingStage.idle);
      setLastError({
        message: err.message || 'حدث خطأ أثناء معالجة ورفع الصوت.',
        actionHint: err.actionHint || 'حاول تسجيل المقطع مرة أخرى.',
        code: err.code || 'PROCESS_ERROR',
      });
    }
  };

  const handleBack = () => {
    if (onBack) {
      onBack();
    }
  };

  useEffect(() => {
    const handleKeyDown = (event) => {
      if (event.code === 'Space') {
        event.preventDefault();
        if (stage === RecordingStage.idle) {
          startRecording();
        } else if (stage === RecordingStage.recording) {
          stopRecordingAndUpload();
        }
      } else if (event.key === 'r' || event.key === 'R') {
        shufflePrompt();
      } else if (event.key === 'Escape') {
        handleBack();
      }
    };

    window.addEventListener('keydown', handleKeyDown);
    return () => window.removeEventListener('keydown', handleKeyDown);
  }, [stage, emotion]);

  const getStatusText = () => {
    switch (stage) {
      case RecordingStage.recording:
        return '🎙️ جاري التسجيل... ارفع يدك للإرسال أو اضغط زر المسافة (Space)';
      case RecordingStage.uploading:
        return '🚀 جاري رفع المقطع الصوتي ومعالجته...';
      default:
        return recordingMode === RecordingMode.hold
          ? 'اضغط واستمر بالضغط على المايك للتسجيل'
          : 'اضغط على المايك للبدء، واضغط مرة أخرى للإيقاف';
    }
  };

  const isRecording = stage === RecordingStage.recording;
  const isUploading = stage === RecordingStage.uploading;
  const isDesktop = typeof window !== 'undefined' ? window.innerWidth >= 1024 : false;

  const promptSection = (
    <div style={{ display: 'flex', flexDirection: 'column', width: '100%' }}>
      <RecordingModeSelector
        currentMode={recordingMode}
        isBusy={isRecording || isUploading}
        onModeChanged={(mode) => setRecordingMode(mode)}
      />

      <div style={{ height: 14 }} />

      <PromptCard
        prompt={currentPrompt}
        emotion={emotion}
        onShuffle={isRecording || isUploading ? null : shufflePrompt}
        promptNumber={promptIndex + 1}
        totalPrompts={emotion?.prompts?.length || 1}
        isDesktop={isDesktop}
      />

      {lastError && (
        <>
          <div style={{ height: 12 }} />
          <ErrorBanner
            error={lastError}
            onDismiss={() => setLastError(null)}
            onRetry={startRecording}
          />
        </>
      )}

      {infoTip && (
        <>
          <div style={{ height: 12 }} />
          <InfoBanner
            message={infoTip}
            onDismiss={() => setInfoTip(null)}
          />
        </>
      )}

      {isDesktop && (
        <>
          <div style={{ height: 14 }} />
          <KeyboardShortcutsCheatSheet
            isRecording={isRecording}
            mode={recordingMode}
          />
        </>
      )}
    </div>
  );

  const recordingControlsSection = (
    <div style={{ display: 'flex', flexDirection: 'column', alignItems: 'center', justifyContent: 'center' }}>
      {isRecording && (
        <>
          <div
            style={{
              padding: '6px 16px',
              backgroundColor: '#fef2f2',
              borderRadius: 20,
              border: '1px solid #fecaca',
              display: 'inline-flex',
              alignItems: 'center',
            }}
          >
            <div
              style={{
                width: 10,
                height: 10,
                backgroundColor: '#ef4444',
                borderRadius: '50%',
              }}
            />
            <div style={{ width: 8 }} />
            <span
              style={{
                fontSize: 16,
                fontWeight: 900,
                color: '#991b1b',
                fontVariantNumeric: 'tabular-nums',
              }}
            >
              {formattedTimer}
            </span>
          </div>
          <div style={{ height: 12 }} />
        </>
      )}

      <AudioVisualizerWave
        isRecording={isRecording}
        color={emotion?.color || '#E63946'}
        secondaryColor={emotion?.darkColor || '#991B1B'}
      />

      <div style={{ height: 18 }} />

      {isUploading ? (
        <div style={{ display: 'flex', flexDirection: 'column', alignItems: 'center' }}>
          <div
            style={{
              width: 60,
              height: 60,
              borderRadius: '50%',
              border: `3.5px solid ${AppTheme.borderLight}`,
              borderTopColor: AppTheme.primary,
              animation: 'spin 1s linear infinite',
            }}
          />
          <div style={{ height: 16 }} />
        </div>
      ) : (
        <HoldToRecordButton
          color={emotion?.color || '#E63946'}
          isRecording={isRecording}
          isBusy={isUploading}
          mode={recordingMode}
          onRecordStart={startRecording}
          onRecordStop={stopRecordingAndUpload}
        />
      )}

      <div style={{ height: 16 }} />

      <div
        style={{
          textAlign: 'center',
          fontSize: 13.5,
          fontWeight: isRecording ? 700 : 500,
          color: isRecording ? AppTheme.textDark : AppTheme.textMuted,
          transition: 'all 200ms ease',
        }}
      >
        {getStatusText()}
      </div>
    </div>
  );

  return (
    <div
      style={{
        display: 'flex',
        flexDirection: 'column',
        minHeight: '100vh',
        width: '100vw',
      }}
    >
      <header
        style={{
          display: 'flex',
          alignItems: 'center',
          padding: '0 16px',
          height: 56,
          backgroundColor: '#ffffff',
          boxShadow: '0 1px 3px rgba(0,0,0,0.1)',
          position: 'relative',
          zIndex: 100,
        }}
      >
        <button
          type="button"
          onClick={handleBack}
          onTouchEnd={(e) => {
            e.preventDefault();
            handleBack();
          }}
          style={{
            background: 'none',
            border: 'none',
            cursor: 'pointer',
            padding: '12px 16px',
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'center',
            touchAction: 'manipulation',
            WebkitTapHighlightColor: 'transparent',
          }}
          title="رجوع"
        >
          <span className="material-icons-round" style={{ fontSize: 26, color: AppTheme.textDark }}>
            arrow_forward
          </span>
        </button>

        <div style={{ display: 'flex', alignItems: 'center', margin: '0 auto' }}>
          <span style={{ fontSize: 22 }}>{emotion?.emoji}</span>
          <div style={{ width: 8 }} />
          <span style={{ fontWeight: 900, fontSize: 18 }}>{emotion?.labelArabic}</span>
        </div>

        <div style={{ width: 48 }} />
      </header>

      <ResponsiveContainer
        maxWidth={isDesktop ? 960 : 640}
        wrapInCardOnDesktop={true}
      >
        {isDesktop ? (
          <div
            style={{
              display: 'flex',
              alignItems: 'center',
              width: '100%',
            }}
          >
            <div style={{ flex: 5 }}>{promptSection}</div>
            <div style={{ width: 32 }} />
            <div style={{ flex: 5 }}>{recordingControlsSection}</div>
          </div>
        ) : (
          <div
            style={{
              display: 'flex',
              flexDirection: 'column',
              width: '100%',
            }}
          >
            {promptSection}
            <div style={{ height: 20 }} />
            {recordingControlsSection}
            <div style={{ height: 16 }} />
          </div>
        )}
      </ResponsiveContainer>

      <SuccessDialog
        isOpen={successDialogOpen}
        onClose={() => setSuccessDialogOpen(false)}
        onRecordAgain={() => {
          setSuccessDialogOpen(false);
          shufflePrompt();
        }}
        onGoToMenu={() => {
          setSuccessDialogOpen(false);
          handleBack();
        }}
        score={appState.score}
      />
    </div>
  );
}

export default RecordingScreen;