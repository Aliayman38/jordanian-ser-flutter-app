import React, { createContext, useContext, useState, useMemo, useEffect } from 'react';
import { Gender } from '../models/speaker.js';

const AppStateContext = createContext(null);

export function AppStateProvider({ children }) {
  const [gender, setGender] = useState(() => {
    try {
      return localStorage.getItem('ser_gender') || null;
    } catch (e) {
      return null;
    }
  });

  const [score, setScore] = useState(() => {
    try {
      return parseInt(localStorage.getItem('ser_score') || '0', 10) || 0;
    } catch (e) {
      return 0;
    }
  });

  const sessionSuffix = useMemo(() => {
    try {
      const saved = localStorage.getItem('ser_session_suffix');
      if (saved) return saved;
      const gen = String(1000 + Math.floor(Math.random() * 9000));
      localStorage.setItem('ser_session_suffix', gen);
      return gen;
    } catch (e) {
      return String(1000 + Math.floor(Math.random() * 9000));
    }
  }, []);

  const hasSelectedGender = gender !== null;

  const speakerId = useMemo(() => {
    const prefix = gender === Gender.male ? 'M' : 'F';
    return `${prefix}${sessionSuffix}`;
  }, [gender, sessionSuffix]);

  const selectGender = (newGender) => {
    setGender(newGender);
    try {
      if (newGender) {
        localStorage.setItem('ser_gender', newGender);
      } else {
        localStorage.removeItem('ser_gender');
      }
    } catch (e) {}
  };

  const incrementScore = () => {
    setScore((prevScore) => {
      const next = prevScore + 1;
      try {
        localStorage.setItem('ser_score', String(next));
      } catch (e) {}
      return next;
    });
  };

  const reset = () => {
    setGender(null);
    setScore(0);
    try {
      localStorage.removeItem('ser_gender');
      localStorage.removeItem('ser_score');
    } catch (e) {}
  };

  const value = {
    gender,
    score,
    hasSelectedGender,
    speakerId,
    selectGender,
    incrementScore,
    reset,
  };

  return (
    <AppStateContext.Provider value={value}>
      {children}
    </AppStateContext.Provider>
  );
}

export function useAppState() {
  const context = useContext(AppStateContext);
  if (!context) {
    throw new Error('useAppState must be used within an AppStateProvider');
  }
  return context;
}

export default AppStateProvider;

