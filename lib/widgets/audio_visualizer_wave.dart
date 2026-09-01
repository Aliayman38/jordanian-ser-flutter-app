import React, { useState, useEffect, useRef, useMemo } from 'react';

export function AudioVisualizerWave({
  isRecording,
  color,
  secondaryColor,
  barCount = 24,
  maxHeight = 56,
}) {
  const [, setTick] = useState(0);
  const animationFrameRef = useRef(null);
  const startTimeRef = useRef(null);

  const baseHeights = useMemo(() => {
    return Array.from({ length: barCount }, (_, i) => {
      const center = barCount / 2;
      const dist = Math.abs(i - center) / center;
      const val = 1.0 - dist * 0.55;
      return Math.min(Math.max(val, 0.25), 1.0);
    });
  }, [barCount]);

  useEffect(() => {
    if (!isRecording) {
      if (animationFrameRef.current) {
        cancelAnimationFrame(animationFrameRef.current);
        animationFrameRef.current = null;
      }
      startTimeRef.current = null;
      setTick((t) => t + 1);
      return;
    }

    startTimeRef.current = performance.now();

    const animate = (time) => {
      setTick((t) => t + 1);
      animationFrameRef.current = requestAnimationFrame(animate);
    };

    animationFrameRef.current = requestAnimationFrame(animate);

    return () => {
      if (animationFrameRef.current) {
        cancelAnimationFrame(animationFrameRef.current);
      }
    };
  }, [isRecording]);

  const getAnimationValue = () => {
    if (!isRecording || !startTimeRef.current) return 0;
    const elapsed = performance.now() - startTimeRef.current;
    const period = 1400;
    const progress = (elapsed % period) / 700;
    return progress > 1 ? 2 - progress : progress;
  };

  const animValue = getAnimationValue();
  const secondary = secondaryColor || `${color}B3`;

  return (
    <div
      style={{
        padding: '8px 16px',
        backgroundColor: isRecording ? `${color}14` : `${color}08`,
        borderRadius: 20,
        border: `1px solid ${isRecording ? `${color}33` : `${color}14`}`,
        display: 'inline-flex',
        alignItems: 'center',
        justifyContent: 'center',
      }}
    >
      <div
        style={{
          height: maxHeight,
          display: 'flex',
          justifyContent: 'center',
          alignItems: 'center',
        }}
      >
        {Array.from({ length: barCount }, (_, index) => {
          let factor;
          if (isRecording) {
            const wave = Math.abs(Math.sin(animValue * 2 * Math.PI + index * 0.35));
            const noise = Math.random() * 0.35;
            factor = Math.min(
              Math.max(baseHeights[index] * 0.55 + wave * 0.4 + noise, 0.18),
              1.0
            );
          } else {
            factor = 0.14;
          }

          const barHeight = Math.min(Math.max(maxHeight * factor, 5.0), maxHeight);

          return (
            <div
              key={index}
              style={{
                margin: '0 2px',
                width: 3.5,
                height: barHeight,
                background: isRecording
                  ? `linear-gradient(to top, ${color}, ${secondary})`
                  : `linear-gradient(to top, ${color}33, ${color}1A)`,
                borderRadius: 4,
                boxShadow: isRecording ? `0 1px 4px ${color}40` : 'none',
              }}
            />
          );
        })}
      </div>
    </div>
  );
}
