import React, { useState } from 'react';
import { createRoot } from 'react-dom/client';
import { GenderSelectionScreen } from './screens/gender_selection_screen';
import { AppStateProvider } from './services/app_state';
import { AppTheme } from './theme/app_theme';

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
          fontFamily: AppTheme.theme.fontFamily,
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
