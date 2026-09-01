import React, { useState, useEffect, useRef } from 'react';

export const RecordingMode = Object.freeze({
  hold: 'hold',
  tapToToggle: 'tapToToggle',
});

export function HoldToRecordButton({
  onRecordStart,
  onRecordStop,
  color,
  isRecording = false,
  isBusy = false,
  mode = RecordingMode.hold,
}) {
  const [internalPressed, setInternalPressed] = useState(false);
  const [isHovered, setIsHovered] = useState(false);
  const [, setTick] = useState(0);

  const pulseStartTimeRef = useRef(null);
  const animationFrameRef = useRef(null);

  const active = isRecording || internalPressed;
  const activeColor = active ? '#E63946' : color;

  useEffect(() => {
    if (active) {
      if (!pulseStartTimeRef.current) {
        pulseStartTimeRef.current = performance.now();
      }

      const animate = () => {
        setTick((t) => t + 1);
        animationFrameRef.current = requestAnimationFrame(animate);
      };

      animationFrameRef.current = requestAnimationFrame(animate);
    } else {
      if (animationFrameRef.current) {
        cancelAnimationFrame(animationFrameRef.current);
        animationFrameRef.current = null;
      }
      pulseStartTimeRef.current = null;
      setTick((t) => t + 1);
    }

    return () => {
      if (animationFrameRef.current) {
        cancelAnimationFrame(animationFrameRef.current);
      }
    };
  }, [active]);

  const getLinearPulse = () => {
    if (!active || !pulseStartTimeRef.current) return 0;
    const elapsed = performance.now() - pulseStartTimeRef.current;
    return (elapsed % 1400) / 1400;
  };

  const easeOutQuad = (t) => t * (2 - t);
  const pulseVal = easeOutQuad(getLinearPulse());

  const handleHoldDown = (e) => {
    if (e.button !== undefined && e.button !== 0) return;
    if (mode !== RecordingMode.hold || isBusy || isRecording) return;
    setInternalPressed(true);
    onRecordStart();
  };

  const handleHoldUp = () => {
    releaseHold();
  };

  const releaseHold = () => {
    if (mode !== RecordingMode.hold) return;
    if (!internalPressed && !isRecording) return;
    setInternalPressed(false);
    onRecordStop();
  };

  const handleTapToggle = () => {
    if (mode !== RecordingMode.tapToToggle || isBusy) return;
    if (isRecording) {
      onRecordStop();
    } else {
      onRecordStart();
    }
  };

  const ripple2Val = pulseVal;
  const ripple1Val = (pulseVal + 0.5) % 1.0;

  return (
    <div
      style={{
        display: 'flex',
        justifyContent: 'center',
        alignItems: 'center',
      }}
    >
      <div
        onMouseEnter={() => setIsHovered(true)}
        onMouseLeave={() => {
          setIsHovered(false);
          if (internalPressed) releaseHold();
        }}
        style={{
          width: 190,
          height: 190,
          position: 'relative',
          display: 'flex',
          justifyContent: 'center',
          alignItems: 'center',
          cursor: isBusy ? 'not-allowed' : 'pointer',
          userSelect: 'none',
        }}
      >
        {/* Ripple layer 2 (outer) */}
        {active && (
          <div
            style={{
              position: 'absolute',
              width: 130 + 60 * ripple2Val,
              height: 130 + 60 * ripple2Val,
              borderRadius: '50%',
              backgroundColor: `${activeColor}${Math.round(
                (1.0 - ripple2Val) * 0.25 * 255
              )
                .toString(16)
                .padStart(2, '0')}`,
              pointerEvents: 'none',
            }}
          />
        )}

        {/* Ripple layer 1 (inner) */}
        {active && (
          <div
            style={{
              position: 'absolute',
              width: 130 + 40 * ripple1Val,
              height: 130 + 40 * ripple1Val,
              borderRadius: '50%',
              backgroundColor: `${activeColor}${Math.round(
                (1.0 - ripple1Val) * 0.35 * 255
              )
                .toString(16)
                .padStart(2, '0')}`,
              pointerEvents: 'none',
            }}
          />
        )}

        {/* Main Interactive Recording Button */}
        <div
          onMouseDown={mode === RecordingMode.hold ? handleHoldDown : undefined}
          onMouseUp={mode === RecordingMode.hold ? handleHoldUp : undefined}
          onTouchStart={mode === RecordingMode.hold ? handleHoldDown : undefined}
          onTouchEnd={mode === RecordingMode.hold ? handleHoldUp : undefined}
          onTouchCancel={mode === RecordingMode.hold ? releaseHold : undefined}
          onClick={mode === RecordingMode.tapToToggle ? handleTapToggle : undefined}
          style={{
            transform: `scale(${active ? 1.08 : 1.0})`,
            transition:
              'transform 150ms cubic-bezier(0.215, 0.61, 0.355, 1), width 200ms cubic-bezier(0.215, 0.61, 0.355, 1), height 200ms cubic-bezier(0.215, 0.61, 0.355, 1)',
            width: active ? 136 : isHovered ? 130 : 124,
            height: active ? 136 : isHovered ? 130 : 124,
            borderRadius: '50%',
            background: active
              ? 'linear-gradient(to bottom right, #FF4D6D, #C9184A)'
              : `linear-gradient(to bottom right, ${color}, ${color}D9)`,
            boxShadow: `0 ${active ? 10 : isHovered ? 8 : 6}px ${
              active ? 30 : isHovered ? 24 : 16
            }px ${active ? 2 : isHovered ? 1 : 0}px ${activeColor}${Math.round(
              (active ? 0.55 : isHovered ? 0.45 : 0.3) * 255
            )
              .toString(16)
              .padStart(2, '0')}`,
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'center',
            zIndex: 1,
          }}
        >
          <span
            key={`${active}_${mode}`}
            className="material-icons-round"
            style={{
              color: '#FFFFFF',
              fontSize: active ? 58 : 52,
              transition: 'transform 200ms ease, font-size 200ms ease',
            }}
          >
            {active
              ? mode === RecordingMode.tapToToggle
                ? 'stop'
                : 'mic'
              : 'mic_none'}
          </span>
        </div>
      </div>
    </div>
  );
}
