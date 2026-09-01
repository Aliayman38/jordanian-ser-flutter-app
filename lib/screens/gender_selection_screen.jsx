import React, { useState, useEffect, useRef } from 'react';
import { Gender, GenderX } from '../models/speaker.js';
import { useAppState } from '../services/app_state.jsx';
import { AppTheme } from '../theme/app_theme.js';
import { ResponsiveContainer } from '../widgets/responsive_container.jsx';
import { EmotionsMenuScreen } from './emotions_menu_screen.jsx';

function HeaderArt() {
  return (
    <div
      style={{
        width: 84,
        height: 84,
        borderRadius: '50%',
        background: AppTheme.primaryGradient,
        boxShadow: `0 8px 24px ${AppTheme.primary}59`,
        display: 'flex',
        alignItems: 'center',
        justifyContent: 'center',
      }}
    >
      <div
        style={{
          width: 72,
          height: 72,
          borderRadius: '50%',
          backgroundColor: 'rgba(255, 255, 255, 0.18)',
          display: 'flex',
          alignItems: 'center',
          justifyContent: 'center',
        }}
      >
        <span style={{ fontSize: 38 }}>🎙️</span>
      </div>
    </div>
  );
}

function GenderCard({
  icon,
  label,
  sublabel,
  shortcutHint,
  isSelected,
  onTap,
}) {
  const [isHovered, setIsHovered] = useState(false);

  return (
    <div
      onClick={onTap}
      onMouseEnter={() => setIsHovered(true)}
      onMouseLeave={() => setIsHovered(false)}
      style={{
        cursor: 'pointer',
        borderRadius: 22,
        padding: '18px 12px',
        backgroundColor: isSelected ? AppTheme.primary : AppTheme.surface,
        border: `${isSelected ? '2.2px' : isHovered ? '1.8px' : '1.2px'} solid ${
          isSelected
            ? AppTheme.primary
            : isHovered
            ? `${AppTheme.primary}80`
            : AppTheme.borderLight
        }`,
        boxShadow: isSelected
          ? `0 8px 18px ${AppTheme.primary}52`
          : isHovered
          ? `0 6px 16px ${AppTheme.primary}1F`
          : AppTheme.cardShadow,
        transform: isHovered ? 'translateY(-3px)' : 'translateY(0px)',
        transition: 'all 220ms cubic-bezier(0.215, 0.61, 0.355, 1)',
        position: 'relative',
        display: 'flex',
        flexDirection: 'column',
        alignItems: 'center',
        justifyContent: 'center',
        userSelect: 'none',
      }}
    >
      {isSelected && (
        <div
          style={{
            position: 'absolute',
            top: -8,
            left: -2,
            padding: 4,
            backgroundColor: AppTheme.accent,
            borderRadius: '50%',
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'center',
          }}
        >
          <span
            className="material-icons-round"
            style={{ fontSize: 14, color: AppTheme.textDark }}
          >
            check
          </span>
        </div>
      )}

      {shortcutHint && (
        <div
          style={{
            position: 'absolute',
            top: -8,
            right: -2,
            padding: '2px 6px',
            backgroundColor: isSelected
              ? 'rgba(255, 255, 255, 0.2)'
              : AppTheme.borderLight,
            borderRadius: 6,
          }}
        >
          <span
            style={{
              fontSize: 11,
              fontWeight: 'bold',
              color: isSelected ? '#ffffff' : AppTheme.textMuted,
            }}
          >
            {shortcutHint}
          </span>
        </div>
      )}

      <div
        style={{
          display: 'flex',
          flexDirection: 'column',
          alignItems: 'center',
        }}
      >
        <span
          className="material-icons-round"
          style={{
            fontSize: 42,
            color: isSelected ? '#ffffff' : AppTheme.primary,
          }}
        >
          {icon}
        </span>
        <div style={{ height: 8 }} />
        <span
          style={{
            fontSize: 17,
            fontWeight: 900,
            color: isSelected ? '#ffffff' : AppTheme.textDark,
          }}
        >
          {label}
        </span>
        <div style={{ height: 2 }} />
        <span
          style={{
            fontSize: 11.5,
            fontWeight: 600,
            color: isSelected ? 'rgba(255, 255, 255, 0.85)' : AppTheme.textMuted,
          }}
        >
          {sublabel}
        </span>
      </div>
    </div>
  );
}

export function GenderSelectionScreen({ navigate }) {
  const appState = useAppState();
  const selected = appState.gender;
  const containerRef = useRef(null);

  const isDesktop =
    typeof window !== 'undefined' ? window.innerWidth >= 1024 : false;

  const onStart = () => {
    if (navigate) {
      navigate(<EmotionsMenuScreen navigate={navigate} />);
    }
  };

  useEffect(() => {
    const handleKeyDown = (event) => {
      if (event.key === '1') {
        appState.selectGender(Gender.male);
      } else if (event.key === '2') {
        appState.selectGender(Gender.female);
      } else if (
        (event.key === 'Enter' || event.key === ' ') &&
        selected !== null &&
        selected !== undefined
      ) {
        onStart();
      }
    };

    window.addEventListener('keydown', handleKeyDown);
    return () => window.removeEventListener('keydown', handleKeyDown);
  }, [selected, appState]);

  return (
    <div
      ref={containerRef}
      tabIndex={0}
      style={{
        display: 'flex',
        flexDirection: 'column',
        minHeight: '100vh',
        width: '100vw',
        outline: 'none',
      }}
    >
      <ResponsiveContainer
        maxWidth={isDesktop ? 600 : 520}
        wrapInCardOnDesktop={true}
      >
        <div
          style={{
            display: 'flex',
            flexDirection: 'column',
            alignItems: 'center',
            justifyContent: 'center',
            width: '100%',
          }}
        >
          <div style={{ height: 8 }} />

          <div
            style={{
              padding: '6px 14px',
              backgroundColor: `${AppTheme.primary}14`,
              borderRadius: 30,
              border: `1px solid ${AppTheme.primary}33`,
              display: 'flex',
              flexWrap: 'wrap',
              justifyContent: 'center',
              alignItems: 'center',
              gap: 6,
            }}
          >
            <span style={{ fontSize: 15 }}>🇯🇴</span>
            <span
              style={{
                fontSize: 12,
                fontWeight: 700,
                color: AppTheme.primary,
              }}
            >
              المشروع الوطني للذكاء الاصطناعي الأردني
            </span>
          </div>

          <div style={{ height: 16 }} />
          <HeaderArt />
          <div style={{ height: 14 }} />

          <h1
            style={{
              fontSize: 26,
              fontWeight: 900,
              color: AppTheme.textDark,
              letterSpacing: -0.3,
              textAlign: 'center',
              margin: 0,
            }}
          >
            تحدي الصوت الأردني
          </h1>
          <div style={{ height: 6 }} />

          <p
            style={{
              fontSize: 14,
              color: AppTheme.textMuted,
              lineHeight: 1.5,
              textAlign: 'center',
              margin: 0,
              whiteSpace: 'pre-line',
            }}
          >
            {'ساعدنا في تدريب أول نموذج ذكاء اصطناعي يفهم المشاعر باللهجة الأردنية بدقة عالية ✨\nاختر جنس المتحدث للبدء:'}
          </p>

          <div style={{ height: 24 }} />

          <div
            style={{
              display: 'flex',
              width: '100%',
              gap: 12,
            }}
          >
            <div style={{ flex: 1 }}>
              <GenderCard
                icon={GenderX.icon(Gender.male)}
                label={GenderX.label(Gender.male)}
                sublabel={GenderX.description(Gender.male)}
                shortcutHint={isDesktop ? '1' : null}
                isSelected={selected === Gender.male}
                onTap={() => appState.selectGender(Gender.male)}
              />
            </div>
            <div style={{ flex: 1 }}>
              <GenderCard
                icon={GenderX.icon(Gender.female)}
                label={GenderX.label(Gender.female)}
                sublabel={GenderX.description(Gender.female)}
                shortcutHint={isDesktop ? '2' : null}
                isSelected={selected === Gender.female}
                onTap={() => appState.selectGender(Gender.female)}
              />
            </div>
          </div>

          <div style={{ height: 16 }} />

          <div
            style={{
              minHeight: 38,
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'center',
              transition: 'opacity 250ms ease-in-out',
            }}
          >
            {selected != null ? (
              <div
                key={appState.speakerId}
                style={{
                  padding: '8px 16px',
                  backgroundColor: AppTheme.surface,
                  borderRadius: 16,
                  border: `1px solid ${AppTheme.borderLight}`,
                  boxShadow: AppTheme.cardShadow,
                  display: 'flex',
                  alignItems: 'center',
                }}
              >
                <span
                  className="material-icons-round"
                  style={{
                    fontSize: 18,
                    color: AppTheme.primary,
                  }}
                >
                  fingerprint
                </span>
                <div style={{ width: 8 }} />
                <span
                  style={{
                    fontSize: 13,
                    fontWeight: 700,
                    color: AppTheme.textDark,
                  }}
                >
                  {`معرّف المساهم: ${appState.speakerId}`}
                </span>
              </div>
            ) : (
              <div style={{ height: 38 }} />
            )}
          </div>

          <div style={{ height: 20 }} />

          <div
            style={{
              width: '100%',
              minHeight: 54,
              transition: 'opacity 300ms ease-in-out',
            }}
          >
            {selected != null ? (
              <button
                type="button"
                onClick={onStart}
                style={{
                  width: '100%',
                  height: 54,
                  backgroundColor: AppTheme.primary,
                  color: '#ffffff',
                  border: 'none',
                  borderRadius: 14,
                  cursor: 'pointer',
                  display: 'flex',
                  alignItems: 'center',
                  justifyContent: 'center',
                  gap: 8,
                  fontSize: 17,
                  fontWeight: 900,
                  boxShadow: `0 4px 14px ${AppTheme.primary}4D`,
                }}
              >
                <span className="material-icons-round" style={{ fontSize: 24 }}>
                  play_arrow
                </span>
                <span>ابدأ التحدي 🚀</span>
              </button>
            ) : (
              <div style={{ height: 54 }} />
            )}
          </div>

          <div style={{ height: 12 }} />
        </div>
      </ResponsiveContainer>
    </div>
  );
}

export default GenderSelectionScreen;