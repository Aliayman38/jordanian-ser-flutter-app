import React, { useState } from 'react';

export function EmotionCard({ data, onTap }) {
  const [isHovered, setIsHovered] = useState(false);
  const [isPressed, setIsPressed] = useState(false);

  const handleMouseDown = () => {
    setIsPressed(true);
  };

  const handleMouseUp = () => {
    setIsPressed(false);
    if (onTap) onTap();
  };

  const handleMouseLeave = () => {
    setIsHovered(false);
    setIsPressed(false);
  };

  return (
    <div
      onMouseEnter={() => setIsHovered(true)}
      onMouseLeave={handleMouseLeave}
      onMouseDown={handleMouseDown}
      onMouseUp={handleMouseUp}
      onTouchStart={handleMouseDown}
      onTouchEnd={handleMouseUp}
      style={{
        cursor: 'pointer',
        userSelect: 'none',
        transform: `scale(${isPressed ? 0.95 : 1.0}) translateY(${isHovered ? -4 : 0}px)`,
        transition: 'transform 200ms cubic-bezier(0.215, 0.61, 0.355, 1)',
        borderRadius: 24,
        background: `linear-gradient(to bottom right, ${data.color}, ${data.darkColor})`,
        border: `${isHovered ? '2px' : '1.5px'} solid ${
          isHovered ? 'rgba(255, 255, 255, 0.45)' : 'rgba(255, 255, 255, 0.2)'
        }`,
        boxShadow: `0 ${isHovered ? 12 : 8}px ${isHovered ? 24 : 16}px ${
          data.darkColor
        }${isHovered ? '80' : '52'}`,
        position: 'relative',
        overflow: 'hidden',
        boxSizing: 'border-box',
        width: '100%',
        aspectRatio: '1 / 1',
      }}
    >
      {/* Subtle decorative background circle */}
      <div
        style={{
          position: 'absolute',
          top: -20,
          right: -20,
          width: 80,
          height: 80,
          borderRadius: '50%',
          backgroundColor: 'rgba(255, 255, 255, 0.08)',
          pointerEvents: 'none',
        }}
      />

      {/* Prompt count badge positioned at top-right */}
      <div
        style={{
          position: 'absolute',
          top: 10,
          right: 10,
          padding: '3px 8px',
          backgroundColor: 'rgba(0, 0, 0, 0.22)',
          borderRadius: 10,
          border: '1px solid rgba(255, 255, 255, 0.25)',
          display: 'flex',
          alignItems: 'center',
          justifyContent: 'center',
        }}
      >
        <span
          style={{
            fontSize: 10.5,
            fontWeight: 700,
            color: 'rgba(255, 255, 255, 0.95)',
          }}
        >
          {`${data.prompts.length} جمل`}
        </span>
      </div>

      {/* Card Main Content (Centered) */}
      <div
        style={{
          display: 'flex',
          flexDirection: 'column',
          alignItems: 'center',
          justifyContent: 'center',
          height: '100%',
          padding: '22px 10px 10px 10px',
          boxSizing: 'border-box',
        }}
      >
        {/* Emoji with slight hover scale */}
        <span
          style={{
            fontSize: 40,
            transform: `scale(${isHovered ? 1.1 : 1.0})`,
            transition: 'transform 200ms ease',
            display: 'inline-block',
          }}
        >
          {data.emoji}
        </span>

        <div style={{ height: 6 }} />

        {/* Arabic label */}
        <span
          style={{
            fontSize: 19,
            fontWeight: 900,
            color: '#FFFFFF',
            letterSpacing: 0.2,
            textAlign: 'center',
            maxWidth: '100%',
            whiteSpace: 'nowrap',
            overflow: 'hidden',
            textOverflow: 'ellipsis',
          }}
        >
          {data.labelArabic}
        </span>

        <div style={{ height: 2 }} />

        {/* Subtitle */}
        <span
          style={{
            fontSize: 11,
            color: 'rgba(255, 255, 255, 0.85)',
            fontWeight: 600,
            textAlign: 'center',
            maxWidth: '100%',
            whiteSpace: 'nowrap',
            overflow: 'hidden',
            textOverflow: 'ellipsis',
          }}
        >
          {data.subtitleArabic}
        </span>
      </div>
    </div>
  );
}
