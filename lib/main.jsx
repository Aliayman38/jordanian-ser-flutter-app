import React, { useState } from 'react';
import { createRoot } from 'react-dom/client';
import { GenderSelectionScreen } from './screens/gender_selection_screen.jsx';
import { EmotionsMenuScreen } from './screens/emotions_menu_screen.jsx';
import { AppStateProvider, useAppState } from './services/app_state.jsx';
import { AppTheme } from './theme/app_theme.js';

function AppContent() {
  const appState = useAppState();
  const [currentScreen, setCurrentScreen] = useState(null);

  const navigate = (screen) => {
    setCurrentScreen(screen);
  };

  // إذا اختار المستخدم جنسه مسبقاً (مخزن في المتصفح)، ينتقل مباشرة لقائمة المشاعر
  const defaultScreen = appState.hasSelectedGender ? (
    <EmotionsMenuScreen navigate={navigate} />
  ) : (
    <GenderSelectionScreen navigate={navigate} />
  );

  return (
    <div
      dir="rtl"
      style={{
        minHeight: '100vh',
        backgroundColor: AppTheme.background,
        fontFamily: AppTheme.theme?.fontFamily || 'Cairo, Tajawal, sans-serif',
        color: AppTheme.textDark,
        margin: 0,
        padding: 0,
        boxSizing: 'border-box',
      }}
    >
      {currentScreen || defaultScreen}
    </div>
  );
}

export function JordanianSERApp() {
  return (
    <AppStateProvider>
      <AppContent />
    </AppStateProvider>
  );
}

const rootElement = document.getElementById('root');
if (rootElement) {
  const root = createRoot(rootElement);
  root.render(<JordanianSERApp />);
}