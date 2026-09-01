export class AppTheme {
  static primary = '#006D5B';
  static primaryLight = '#0A8754';
  static primaryDark = '#004D40';
  static primaryContainer = '#E6F4F1';

  static accent = '#FFB703';
  static accentLight = '#FFD166';
  static accentOrange = '#FB8500';

  static coralRed = '#E63946';
  static royalIndigo = '#3F51B5';
  static softSlate = '#607771';

  static background = '#F6FAF8';
  static surface = '#FFFFFF';
  static surfaceElevated = '#FAFCFB';

  static textDark = '#102A24';
  static textMuted = '#536E67';
  static textLight = '#8BA6A0';

  static borderLight = '#E2EBE8';

  static primaryGradient = 'linear-gradient(to bottom right, #006D5B, #0A8754)';
  static heroGradient = 'linear-gradient(to bottom left, #006D5B, #064E41)';
  static amberGradient = 'linear-gradient(to bottom right, #FFB703, #FB8500)';

  static cardShadow = '0 8px 20px -2px rgba(16, 42, 36, 0.06), 0 2px 6px 0 rgba(16, 42, 36, 0.03)';

  static glowShadow(color, opacity = 0.35, blur = 22) {
    const hexOpacity = Math.round(opacity * 255)
      .toString(16)
      .padStart(2, '0');
    return `0 8px ${blur}px ${color.startsWith('#') ? color + hexOpacity : color}`;
  }

  static glassDecoration({ color, borderRadius = 24, borderColor } = {}) {
    return {
      backgroundColor: color || 'rgba(255, 255, 255, 0.85)',
      borderRadius: typeof borderRadius === 'number' ? `${borderRadius}px` : borderRadius,
      border: `1.5px solid ${borderColor || 'rgba(255, 255, 255, 0.4)'}`,
      boxShadow: AppTheme.cardShadow,
    };
  }

  static theme = {
    colorScheme: {
      primary: AppTheme.primary,
      secondary: AppTheme.primaryLight,
      tertiary: AppTheme.accent,
      surface: AppTheme.surface,
      background: AppTheme.background,
    },
    scaffoldBackgroundColor: AppTheme.background,
    fontFamily: ['Cairo', 'Noto Sans Arabic', 'Roboto', 'Arial', 'sans-serif'].join(', '),
    appBar: {
      backgroundColor: 'transparent',
      color: AppTheme.textDark,
      textAlign: 'center',
      fontSize: 20,
      fontWeight: 700,
    },
    card: {
      backgroundColor: AppTheme.surface,
      borderRadius: 24,
      border: `1.2px solid ${AppTheme.borderLight}`,
    },
    dialog: {
      backgroundColor: AppTheme.surface,
      borderRadius: 28,
      boxShadow: '0 12px 24px rgba(0, 0, 0, 0.15)',
    },
    elevatedButton: {
      backgroundColor: AppTheme.primary,
      color: '#FFFFFF',
      boxShadow: `0 3px 8px ${AppTheme.primary}66`,
      padding: '14px 24px',
      fontSize: 16,
      fontWeight: 700,
      borderRadius: 18,
      border: 'none',
      cursor: 'pointer',
    },
    outlinedButton: {
      backgroundColor: 'transparent',
      color: AppTheme.primary,
      border: `1.5px solid ${AppTheme.primary}`,
      padding: '14px 24px',
      fontSize: 15,
      fontWeight: 700,
      borderRadius: 16,
      cursor: 'pointer',
    },
  };
}
