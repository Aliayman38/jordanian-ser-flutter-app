import React, { useState } from 'react';
import { createRoot } from 'react-dom/client';
import { GenderSelectionScreen } from './screens/gender_selection_screen.jsx';
import { AppStateProvider } from './services/app_state.jsx';
import { AppTheme } from './theme/app_theme.js';

export function JordanianSERApp() {
  const [currentScreen, setCurrentScreen] = useState(null);

  const navigate = (screen) => {
    setCurrentScreen(screen);
  };

  return (
    <AppStateProvider>
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
        {currentScreen || <GenderSelectionScreen navigate={navigate} />}
      </div>
    </AppStateProvider>
  );
}

const rootElement = document.getElementById('root');
if (rootElement) {
  const root = createRoot(rootElement);
  root.render(<JordanianSERApp />);
}