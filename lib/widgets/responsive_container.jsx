import React, { useState, useEffect } from 'react';
import { AppTheme } from '../theme/app_theme';

export const ScreenType = Object.freeze({
  mobile: 'mobile',
  tablet: 'tablet',
  desktop: 'desktop',
});

export class ResponsiveBreakpoints {
  static mobileMax = 600;
  static tabletMax = 1024;

  static getScreenType() {
    const width = typeof window !== 'undefined' ? window.innerWidth : 1200;
    if (width < ResponsiveBreakpoints.mobileMax) return ScreenType.mobile;
    if (width < ResponsiveBreakpoints.tabletMax) return ScreenType.tablet;
    return ScreenType.desktop;
  }

  static isMobile() {
    return ResponsiveBreakpoints.getScreenType() === ScreenType.mobile;
  }

  static isTablet() {
    return ResponsiveBreakpoints.getScreenType() === ScreenType.tablet;
  }

  static isDesktop() {
    return ResponsiveBreakpoints.getScreenType() === ScreenType.desktop;
  }
}

export function ResponsiveContainer({
  child,
  children,
  maxWidth = 720,
  padding,
  scrollable = true,
  useSafeArea = true,
  wrapInCardOnDesktop = false,
}) {
  const contentChild = child || children;

  const [windowDimensions, setWindowDimensions] = useState(() => ({
    width: typeof window !== 'undefined' ? window.innerWidth : 1200,
    height: typeof window !== 'undefined' ? window.innerHeight : 800,
  }));

  useEffect(() => {
    const handleResize = () => {
      setWindowDimensions({
        width: window.innerWidth,
        height: window.innerHeight,
      });
    };

    window.addEventListener('resize', handleResize);
    return () => window.removeEventListener('resize', handleResize);
  }, []);

  const screenWidth = windowDimensions.width;
  const isLandscape = windowDimensions.width > windowDimensions.height;
  const isDesktop = screenWidth >= ResponsiveBreakpoints.tabletMax;
  const isTablet =
    screenWidth >= ResponsiveBreakpoints.mobileMax && !isDesktop;

  let defaultPadding;
  if (screenWidth < 380) {
    defaultPadding = { horizontal: 14, vertical: 12 };
  } else if (screenWidth < 600) {
    defaultPadding = {
      horizontal: isLandscape ? 28 : 18,
      vertical: isLandscape ? 12 : 16,
    };
  } else if (isTablet) {
    defaultPadding = { horizontal: 28, vertical: 20 };
  } else {
    defaultPadding = { horizontal: 36, vertical: 24 };
  }

  const effectivePadding =
    padding !== undefined && padding !== null
      ? typeof padding === 'object'
        ? padding
        : { horizontal: padding, vertical: padding }
      : defaultPadding;

  const buildCardWrapped = (inner) => {
    if (isDesktop && wrapInCardOnDesktop) {
      return (
        <div
          style={{
            maxWidth: `${maxWidth}px`,
            width: '100%',
            boxSizing: 'border-box',
            margin: '20px 0',
            padding: '28px',
            backgroundColor: AppTheme.surface,
            borderRadius: '28px',
            border: `1.5px solid ${AppTheme.borderLight}`,
            boxShadow: `0 12px 36px 2px ${AppTheme.primary}0F`,
          }}
        >
          {inner}
        </div>
      );
    }

    return (
      <div
        style={{
          maxWidth: `${maxWidth}px`,
          width: '100%',
          boxSizing: 'border-box',
          padding: `${effectivePadding.vertical || 0}px ${
            effectivePadding.horizontal || 0
          }px`,
        }}
      >
        {inner}
      </div>
    );
  };

  let content;

  if (scrollable) {
    content = (
      <div
        style={{
          width: '100%',
          height: '100%',
          overflowY: 'auto',
          display: 'flex',
          flexDirection: 'column',
        }}
      >
        <div
          style={{
            minHeight: '100%',
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'center',
            width: '100%',
          }}
        >
          {buildCardWrapped(
            <div style={{ width: '100%', height: 'fit-content' }}>
              {contentChild}
            </div>
          )}
        </div>
      </div>
    );
  } else {
    content = (
      <div
        style={{
          width: '100%',
          height: '100%',
          display: 'flex',
          alignItems: 'center',
          justifyContent: 'center',
        }}
      >
        {buildCardWrapped(contentChild)}
      </div>
    );
  }

  if (useSafeArea) {
    content = (
      <div
        style={{
          width: '100%',
          height: '100%',
          boxSizing: 'border-box',
          paddingTop: 'env(safe-area-inset-top, 0px)',
          paddingBottom: 'env(safe-area-inset-bottom, 0px)',
          paddingLeft: 'env(safe-area-inset-left, 0px)',
          paddingRight: 'env(safe-area-inset-right, 0px)',
        }}
      >
        {content}
      </div>
    );
  }

  return content;
}
