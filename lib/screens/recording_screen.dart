import React, { useState, useEffect, useRef } from 'react';
import { ApiService } from '../services/api_service';
import { useAppState } from '../services/app_state';
import { AudioService } from '../services/audio_service';
import { AppTheme } from '../theme/app_theme';
import { AudioVisualizerWave } from '../widgets/audio_visualizer_wave';
import { HoldToRecordButton, RecordingMode } from '../widgets/hold_to_record_button';
import { ResponsiveContainer } from '../widgets/responsive_container';

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
        backgroundColor: 'rgba(0, 0, 0, 0.5)',
        display: 'flex',
        alignItems: 'center',
        justifyContent: 'center',
        zIndex: 1000,
      }}
    >
      <div
        style={{
          backgroundColor: '#fff',
          borderRadius: 28,
          padding: '28px 24px',
          maxWidth: 460,
          width: '90%',
          boxShadow: '0 4px 20px rgba(0, 0, 0, 0.15)',
          display: 'flex',
          flexDirection: 'column',
          alignItems: 'center',
          boxSizing: 'border-box',
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
            }}
            onClick={onRecordAgain}
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
              border: `1px solid ${AppTheme.primary}`,
              borderRadius: 12,
              cursor: 'pointer',
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'center',
              gap: 8,
              fontSize: 15,
              fontWeight: 600,
            }}
            onClick={onGoToMenu}
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
      style={{
        cursor: onTap ? 'pointer' : 'default',
        borderRadius: 12,
        padding: '8px 14px',
        backgroundColor: isSelected ? AppTheme.primary : 'transparent',
        transition: 'background-color 200ms ease',
        userSelect: 'none',
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
              padding: '4px 8px',
              backgroundColor: `${emotion.color}2E`,
              borderRadius: 8,
            }}
          >
            <span
              style={{
                fontSize: 11.5,
                fontWeight: 700,
                color: emotion.darkColor,
              }}
            >
              {`جملة ${promptNumber} من ${totalPrompts}`}
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
            style={{
              background: 'none',
              border: 'none',
              color: emotion.darkColor,
              padding: '4px 10px',
              cursor: 'pointer',
              display: 'flex',
              alignItems: 'center',
              gap: 4,
            }}
          >
            <span className="material-icons-round" style={{ fontSize: 16 }}>
              shuffle
            </span>
            <span style={{ fontSize: 12, fontWeight: 800 }}>
              {isDesktop ? 'جملة ثانية (R)' : 'جملة ثانية'}
            </span>
          </button>
        )}
      </div>

      <div style={{ height: 12 }} />

      <div
        key={prompt}
        style={{
          textAlign: 'right',
          fontSize: 21,
          fontWeight: 800,
          lineHeight: 1.55,
          color: AppTheme.textDark,
          transition: 'opacity 250ms ease-in-out',
        }}
      >
        {prompt}
      </div>
    </div>
  );
}

function ErrorBanner({ message }) {
  return (
    <div
      style={{
        width: '100%',
        boxSizing: 'border-box',
        padding: 12,
        backgroundColor: '#fef2f2',
        borderRadius: 14,
        border: '1px solid #fecaca',
        display: 'flex',
        alignItems: 'center',
      }}
    >
      <span
        className="material-icons-round"
        style={{ color: '#dc2626', fontSize: 20 }}
      >
        error_outline
      </span>
      <div style={{ width: 10 }} />
      <span style={{ color: '#991b1b', fontSize: 13, flex: 1 }}>{message}</span>
    </div>
  );
}

function InfoBanner({ message }) {
  return (
    <div
      style={{
        width: '100%',
        boxSizing: 'border-box',
        padding: 12,
        backgroundColor: '#fffbeb',
        borderRadius: 14,
        border: '1px solid #fcd34d',
        display: 'flex',
        alignItems: 'center',
      }}
    >
      <span
        className="material-icons-round"
        style={{ color: '#92400e', fontSize: 20 }}
      >
        info_outline
      </span>
      <div style={{ width: 10 }} />
      <span
        style={{
          color: '#78350f',
          fontSize: 13,
          fontWeight: 600,
          flex: 1,
        }}
      >
        {message}
      </span>
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
    Math.floor(Math.random() * emotion.prompts.length)
  );
  const [stage, setStage] = useState(RecordingStage.idle);
  const [recordingMode, setRecordingMode] = useState(RecordingMode.hold);
  const [lastError, setLastError] = useState(null);
  const [infoTip, setInfoTip] = useState(null);
  const [elapsedMilliseconds, setElapsedMilliseconds] = useState(0);
  const [successDialogOpen, setSuccessDialogOpen] = useState(false);

  const timerRef = useRef(null);
  const recordStartTimeRef = useRef(null);

  useEffect(() => {
    return () => {
      if (timerRef.current) clearInterval(timerRef.current);
      _audioService.dispose();
    };
  }, [_audioService]);

  const currentPrompt = emotion.promptFor(promptIndex);

  const shufflePrompt = () => {
    if (stage === RecordingStage.recording || stage === RecordingStage.uploading) return;
    setPromptIndex((prev) => (prev + 1) % emotion.prompts.length);
    setLastError(null);
    setInfoTip(null);
  };

  const startTimer = () => {
    setElapsedMilliseconds(0);
    recordStartTimeRef.current = Date.now();
    if (timerRef.current) clearInterval(timerRef.current);
    timerRef.current = setInterval(() => {
      setElapsedMilliseconds(Date.now() - recordStartTimeRef.current);
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
    setLastError(null);
    setInfoTip(null);
    setStage(RecordingStage.recording);
    startTimer();

    try {
      await _audioService.startRecording();
    } catch (e) {
      stopTimer();
      setStage(RecordingStage.idle);
      setLastError(e.toString());
    }
  };

  const stopRecordingAndUpload = async () => {
    if (stage !== RecordingStage.recording) return;
    stopTimer();

    const recordDurationMs = elapsedMilliseconds;

    if (recordDurationMs < 1000) {
      await _audioService.stopRecording();
      setStage(RecordingStage.idle);
      setInfoTip(
        'التسجيل قصير جداً (أقل من ثانية). يرجى التحدث بوضوح وإعادة المحاولة.'
      );
      return;
    }

    setStage(RecordingStage.uploading);

    const audioData = await _audioService.stopRecording();
    if (!audioData || audioData.isEmpty) {
      setStage(RecordingStage.idle);
      setLastError('ما انسجل الصوت، جرب مرة ثانية.');
      return;
    }

    const result = await _apiService.submitAudio({
      audioData,
      speakerId: appState.speakerId,
      emotionTag: emotion.apiTag,
      referenceText: currentPrompt,
    });

    if (result.success) {
      appState.incrementScore();
      setStage(RecordingStage.idle);
      setElapsedMilliseconds(0);
      setSuccessDialogOpen(true);
    } else {
      setStage(RecordingStage.idle);
      setLastError(result.errorMessage || 'صار خطأ غير متوقع في رفع الصوت.');
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
      } else if (event.key === 'r' || event.key === 'R' || event.key === 'n' || event.key === 'N') {
        shufflePrompt();
      } else if (event.key === 'Escape') {
        if (onBack) onBack();
      }
    };

    window.addEventListener('keydown', handleKeyDown);
    return () => window.removeEventListener('keydown', handleKeyDown);
  }, [stage, elapsedMilliseconds, promptIndex, emotion]);

  const getStatusText = () => {
    switch (stage) {
      case RecordingStage.idle:
        return recordingMode === RecordingMode.hold
          ? 'اضغط واستمر بالضغط على المايك للتسجيل'
          : 'اضغط على المايك للبدء، واضغط مرة أخرى للإيقاف';
      case RecordingStage.recording:
        return recordingMode === RecordingMode.hold
          ? '🎙️ جاري التسجيل... ارفع إصبعك للإرسال'
          : '🎙️ جاري التسجيل... اضغط لإيقاف التسجيل والإرسال';
      case RecordingStage.uploading:
        return '🚀 جاري رفع المقطع الصوتي ومعالجته...';
      default:
        return '';
    }
  };

  const isRecording = stage === RecordingStage.recording;
  const isUploading = stage === RecordingStage.uploading;
  const isDesktop = typeof window !== 'undefined' ? window.innerWidth >= 1024 : false;

  const promptSection = (
    <div
      style={{
        display: 'flex',
        flexDirection: 'column',
        width: '100%',
      }}
    >
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
        totalPrompts={emotion.prompts.length}
        isDesktop={isDesktop}
      />

      {lastError && (
        <>
          <div style={{ height: 12 }} />
          <ErrorBanner message={lastError} />
        </>
      )}

      {infoTip && (
        <>
          <div style={{ height: 12 }} />
          <InfoBanner message={infoTip} />
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
    <div
      style={{
        display: 'flex',
        flexDirection: 'column',
        alignItems: 'center',
        justifyContent: 'center',
      }}
    >
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
        color={emotion.color}
        secondaryColor={emotion.darkColor}
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
          color={emotion.color}
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
        }}
      >
        <div style={{ display: 'flex', alignItems: 'center', margin: '0 auto' }}>
          <span style={{ fontSize: 22 }}>{emotion.emoji}</span>
          <div style={{ width: 8 }} />
          <span style={{ fontWeight: 900, fontSize: 18 }}>{emotion.labelArabic}</span>
        </div>
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
          if (onBack) onBack();
        }}
        score={appState.score}
      />
    </div>
  );
}
