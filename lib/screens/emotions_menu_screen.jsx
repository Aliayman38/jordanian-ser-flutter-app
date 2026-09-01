import React, { useState, useEffect, useRef } from 'react';
import { EmotionData } from '../models/emotion.js';
import { Gender, GenderX } from '../models/speaker.js';
import { useAppState } from '../services/app_state.jsx';
import { AppTheme } from '../theme/app_theme.js';
import { EmotionCard } from '../widgets/emotion_card.jsx';
import { ResponsiveContainer } from '../widgets/responsive_container.jsx';
import { RecordingScreen } from './recording_screen.jsx';

function ChangeGenderDialog({ isOpen, onClose }) {
  const { speakerId, gender, selectGender } = useAppState();

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
      onClick={onClose}
    >
      <div
        style={{
          backgroundColor: '#fff',
          borderRadius: 24,
          padding: 24,
          maxWidth: 400,
          width: '90%',
          boxShadow: '0 4px 20px rgba(0, 0, 0, 0.15)',
        }}
        onClick={(e) => e.stopPropagation()}
      >
        <div style={{ display: 'flex', alignItems: 'center', marginBottom: 16 }}>
          <span
            className="material-icons-round"
            style={{ color: AppTheme.primary, marginRight: 10, fontSize: 24 }}
          >
            tune
          </span>
          <span style={{ fontSize: 18, fontWeight: 800 }}>تغيير إعدادات الجلسة</span>
        </div>

        <div style={{ display: 'flex', flexDirection: 'column', textAlign: 'start' }}>
          <span style={{ fontSize: 14, color: AppTheme.textMuted }}>
            {`المعرّف الحالي: ${speakerId} (${gender ? GenderX.label(gender) : ''})`}
          </span>
          <div style={{ height: 16 }} />
          <span style={{ fontSize: 14, fontWeight: 700 }}>
            اختر الصوت المناسب لتسجيلاتك القادمة:
          </span>
          <div style={{ height: 12 }} />
          <div style={{ display: 'flex', gap: 10 }}>
            <button
              type="button"
              style={{
                flex: 1,
                padding: '10px 16px',
                borderRadius: 8,
                border: `1px solid ${AppTheme.primary}`,
                backgroundColor:
                  gender === Gender.male
                    ? 'rgba(230, 57, 70, 0.1)'
                    : 'transparent',
                cursor: 'pointer',
                fontSize: 14,
                fontWeight: 600,
                touchAction: 'manipulation',
              }}
              onClick={() => {
                selectGender(Gender.male);
                onClose();
              }}
              onTouchEnd={(e) => {
                e.preventDefault();
                selectGender(Gender.male);
                onClose();
              }}
            >
              شاب 👨
            </button>
            <button
              type="button"
              style={{
                flex: 1,
                padding: '10px 16px',
                borderRadius: 8,
                border: `1px solid ${AppTheme.primary}`,
                backgroundColor:
                  gender === Gender.female
                    ? 'rgba(230, 57, 70, 0.1)'
                    : 'transparent',
                cursor: 'pointer',
                fontSize: 14,
                fontWeight: 600,
                touchAction: 'manipulation',
              }}
              onClick={() => {
                selectGender(Gender.female);
                onClose();
              }}
              onTouchEnd={(e) => {
                e.preventDefault();
                selectGender(Gender.female);
                onClose();
              }}
            >
              صبية 👩
            </button>
          </div>
        </div>

        <div
          style={{
            display: 'flex',
            justifyContent: 'flex-end',
            marginTop: 24,
          }}
        >
          <button
            type="button"
            style={{
              background: 'none',
              border: 'none',
              color: AppTheme.primary,
              cursor: 'pointer',
              fontWeight: 700,
              fontSize: 14,
              padding: 8,
              touchAction: 'manipulation',
            }}
            onClick={onClose}
            onTouchEnd={(e) => {
              e.preventDefault();
              onClose();
            }}
          >
            إلغاء
          </button>
        </div>
      </div>
    </div>
  );
}

function GamifiedTierBanner({ score, speakerId }) {
  const getTierInfo = (score) => {
    if (score === 0) {
      return {
        title: 'مساهم جديد',
        badge: '🎯',
        target: 1,
        progress: 0.0,
      };
    } else if (score < 4) {
      return {
        title: 'مساهم مبتدئ',
        badge: '🥉',
        target: 4,
        progress: score / 4,
      };
    } else if (score < 10) {
      return {
        title: 'مساهم برونزي',
        badge: '🥈',
        target: 10,
        progress: (score - 3) / 7,
      };
    } else if (score < 20) {
      return {
        title: 'مساهم ذهبي',
        badge: '🥇',
        target: 20,
        progress: (score - 9) / 11,
      };
    } else {
      return {
        title: 'بطل اللهجة الأردنية',
        badge: '🌟',
        target: score,
        progress: 1.0,
      };
    }
  };

  const tier = getTierInfo(score);
  const clampedProgress = Math.min(Math.max(tier.progress, 0.05), 1.0);

  return (
    <div
      style={{
        width: '100%',
        boxSizing: 'border-box',
        padding: 18,
        background: AppTheme.heroGradient,
        borderRadius: 24,
        boxShadow: `0 8px 20px ${AppTheme.primaryDark}4D`,
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
              width: 44,
              height: 44,
              backgroundColor: 'rgba(255, 255, 255, 0.15)',
              borderRadius: '50%',
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'center',
            }}
          >
            <span style={{ fontSize: 22 }}>{tier.badge}</span>
          </div>
          <div style={{ width: 12 }} />
          <div style={{ display: 'flex', flexDirection: 'column', alignItems: 'flex-start' }}>
            <span
              style={{
                color: '#ffffff',
                fontSize: 16,
                fontWeight: 900,
              }}
            >
              {tier.title}
            </span>
            <div style={{ height: 2 }} />
            <span
              style={{
                color: 'rgba(255, 255, 255, 0.75)',
                fontSize: 12,
                fontWeight: 600,
              }}
            >
              {`المعرّف: ${speakerId}`}
            </span>
          </div>
        </div>

        <div
          style={{
            padding: '8px 14px',
            backgroundColor: AppTheme.accent,
            borderRadius: 16,
            boxShadow: `0 4px 10px rgba(255, 227, 168, 0.4)`,
            display: 'flex',
            alignItems: 'center',
          }}
        >
          <span
            className="material-icons-round"
            style={{
              color: AppTheme.textDark,
              fontSize: 20,
            }}
          >
            graphic_eq
          </span>
          <div style={{ width: 6 }} />
          <span
            key={score}
            style={{
              color: AppTheme.textDark,
              fontSize: 20,
              fontWeight: 900,
              transition: 'transform 250ms ease-in-out',
            }}
          >
            {score}
          </span>
        </div>
      </div>

      <div style={{ height: 14 }} />

      <div
        style={{
          borderRadius: 10,
          overflow: 'hidden',
          backgroundColor: 'rgba(255, 255, 255, 0.15)',
          height: 8,
          width: '100%',
        }}
      >
        <div
          style={{
            width: `${clampedProgress * 100}%`,
            height: '100%',
            backgroundColor: AppTheme.accent,
            transition: 'width 300ms ease',
          }}
        />
      </div>

      <div style={{ height: 6 }} />

      <div
        style={{
          display: 'flex',
          justifyContent: 'space-between',
          alignItems: 'center',
        }}
      >
        <span
          style={{
            color: 'rgba(255, 255, 255, 0.8)',
            fontSize: 11.5,
            fontWeight: 600,
          }}
        >
          {score >= 20
            ? 'أعلى رتبة محققة! أسطورة 🌟'
            : `سجل ${tier.target - score} مقاطع إضافية للرتبة التالية`}
        </span>
        <span
          style={{
            color: 'rgba(255, 255, 255, 0.85)',
            fontSize: 11.5,
            fontWeight: 700,
          }}
        >
          {score >= 20 ? '100%' : `${score} / ${tier.target}`}
        </span>
      </div>
    </div>
  );
}

export function EmotionsMenuScreen({ navigate }) {
  const appState = useAppState();
  const { score, speakerId } = appState;
  const [dialogOpen, setDialogOpen] = useState(false);
  const [containerWidth, setContainerWidth] = useState(0);
  const gridContainerRef = useRef(null);

  useEffect(() => {
    if (!gridContainerRef.current) return;
    const resizeObserver = new ResizeObserver((entries) => {
      for (let entry of entries) {
        setContainerWidth(entry.contentRect.width);
      }
    });
    resizeObserver.observe(gridContainerRef.current);
    return () => resizeObserver.disconnect();
  }, []);

  let crossAxisCount = 2;
  if (containerWidth > 1000) {
    crossAxisCount = 5;
  } else if (containerWidth > 750) {
    crossAxisCount = 4;
  } else if (containerWidth > 500) {
    crossAxisCount = 3;
  } else {
    crossAxisCount = 2;
  }

  const isDesktop = typeof window !== 'undefined' ? window.innerWidth >= 1024 : false;

  const handleSelectEmotion = (data) => {
    if (navigate) {
      navigate(
        <RecordingScreen
          emotion={data}
          navigate={navigate}
          onBack={() => {
            navigate(<EmotionsMenuScreen navigate={navigate} />);
          }}
        />
      );
    }
  };

  return (
    <div
      style={{
        display: 'flex',
        flexDirection: 'column',
        height: '100vh',
        width: '100vw',
        overflow: 'hidden',
        backgroundColor: '#fafafa',
      }}
    >
      <header
        style={{
          display: 'flex',
          alignItems: 'center',
          justifyContent: 'space-between',
          padding: '0 16px',
          height: 56,
          backgroundColor: '#ffffff',
          boxShadow: '0 1px 3px rgba(0,0,0,0.1)',
        }}
      >
        <h1 style={{ fontSize: 20, fontWeight: 700, margin: 0 }}>اختر الشعور</h1>
        <div style={{ display: 'flex', alignItems: 'center' }}>
          <button
            type="button"
            title="تغيير المتحدث"
            onClick={() => setDialogOpen(true)}
            onTouchEnd={(e) => {
              e.preventDefault();
              setDialogOpen(true);
            }}
            style={{
              background: 'none',
              border: 'none',
              cursor: 'pointer',
              padding: 8,
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'center',
              touchAction: 'manipulation',
            }}
          >
            <span className="material-icons-round" style={{ fontSize: 24 }}>
              settings
            </span>
          </button>
          <div style={{ width: 8 }} />
        </div>
      </header>

      <ResponsiveContainer
        maxWidth={isDesktop ? 1080 : 720}
        scrollable={false}
      >
        <div
          style={{
            display: 'flex',
            flexDirection: 'column',
            height: '100%',
            width: '100%',
          }}
        >
          <GamifiedTierBanner score={score} speakerId={speakerId} />
          <div style={{ height: 16 }} />

          <div style={{ display: 'flex', alignItems: 'center' }}>
            <span
              className="material-icons-round"
              style={{ fontSize: 18, color: AppTheme.primary }}
            >
              mic_external_on
            </span>
            <div style={{ width: 6 }} />
            <span
              style={{
                fontSize: 14,
                fontWeight: 700,
                color: AppTheme.textMuted,
              }}
            >
              اختر شعوراً لتسجيل عبارة أردنية معبرة:
            </span>
          </div>
          <div style={{ height: 12 }} />

          <div
            ref={gridContainerRef}
            style={{
              flex: 1,
              overflowY: 'auto',
              minHeight: 0,
            }}
          >
            <div
              style={{
                display: 'grid',
                gridTemplateColumns: `repeat(${crossAxisCount}, 1fr)`,
                gap: 14,
                paddingBottom: 16,
              }}
            >
              {Object.values(EmotionData.all).map((data) => (
                <EmotionCard
                  key={data.type}
                  data={data}
                  onTap={() => handleSelectEmotion(data)}
                />
              ))}
            </div>
          </div>
        </div>
      </ResponsiveContainer>

      <ChangeGenderDialog
        isOpen={dialogOpen}
        onClose={() => setDialogOpen(false)}
      />
    </div>
  );
}

export default EmotionsMenuScreen;