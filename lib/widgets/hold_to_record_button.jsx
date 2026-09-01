import React, { useState, useRef } from 'react';

export const RecordingMode = Object.freeze({
  hold: 'hold',
  tapToToggle: 'tapToToggle',
});

export function HoldToRecordButton({
  isRecording,
  isBusy,
  onRecordStart,
  onRecordStop,
  color = '#E63946',
  mode = RecordingMode.hold,
}) {
  const [isPressed, setIsPressed] = useState(false);
  const isHandlingRef = useRef(false);

  // معالجة بدء التسجيل باللمس أو الماوس
  const handlePointerDown = (e) => {
    if (isBusy) return;
    if (mode === RecordingMode.hold) {
      // منع التمرير وفتح قوائم المتصفح على الموبايل
      if (e.cancelable) e.preventDefault();
      e.stopPropagation();

      isHandlingRef.current = true;
      setIsPressed(true);

      // التقاط حركة الإصبع حتى لو تحرك خارج حدود الزر
      if (e.target && e.target.setPointerCapture && e.pointerId) {
        try {
          e.target.setPointerCapture(e.pointerId);
        } catch (err) {}
      }

      if (onRecordStart) onRecordStart();
    }
  };

  // معالجة إنهاء التسجيل عند رفع الإصبع
  const handlePointerUp = (e) => {
    if (isBusy) return;
    if (mode === RecordingMode.hold && isHandlingRef.current) {
      if (e.cancelable) e.preventDefault();
      e.stopPropagation();

      isHandlingRef.current = false;
      setIsPressed(false);

      if (e.target && e.target.releasePointerCapture && e.pointerId) {
        try {
          e.target.releasePointerCapture(e.pointerId);
        } catch (err) {}
      }

      if (onRecordStop) onRecordStop();
    }
  };

  // معالجة وضع النقر للبدء والنقر للإيقاف
  const handleClick = (e) => {
    if (isBusy) return;
    if (mode === RecordingMode.tapToToggle) {
      e.preventDefault();
      if (isRecording) {
        if (onRecordStop) onRecordStop();
      } else {
        if (onRecordStart) onRecordStart();
      }
    }
  };

  return (
    <div
      style={{
        display: 'flex',
        flexDirection: 'column',
        alignItems: 'center',
        justifyContent: 'center',
        userSelect: 'none',
        WebkitUserSelect: 'none',
        touchAction: 'none', // تعطيل التمرير التلقائي أثناء الضغط
      }}
    >
      <button
        type="button"
        onPointerDown={handlePointerDown}
        onPointerUp={handlePointerUp}
        onPointerCancel={handlePointerUp}
        onClick={handleClick}
        onContextMenu={(e) => e.preventDefault()}
        disabled={isBusy}
        style={{
          width: 86,
          height: 86,
          borderRadius: '50%',
          backgroundColor: isRecording ? '#ef4444' : color,
          border: 'none',
          outline: 'none',
          cursor: isBusy ? 'not-allowed' : 'pointer',
          display: 'flex',
          alignItems: 'center',
          justifyContent: 'center',
          boxShadow: isRecording
            ? '0 0 0 12px rgba(239, 68, 68, 0.25), 0 8px 24px rgba(239, 68, 68, 0.4)'
            : `0 8px 24px ${color}55`,
          transform: isPressed || isRecording ? 'scale(0.92)' : 'scale(1)',
          transition: 'transform 0.15s ease, background-color 0.2s ease, box-shadow 0.2s ease',
          touchAction: 'none',
          WebkitTouchCallout: 'none',
        }}
      >
        <span
          className="material-icons-round"
          style={{
            fontSize: 42,
            color: '#ffffff',
            pointerEvents: 'none',
            transform: isRecording ? 'scale(1.1)' : 'scale(1)',
            transition: 'transform 0.2s ease',
          }}
        >
          {isBusy ? 'hourglass_top' : isRecording ? 'mic' : 'mic_none'}
        </span>
      </button>
    </div>
  );
}

export default HoldToRecordButton;