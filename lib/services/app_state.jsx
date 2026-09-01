import React, { createContext, useContext, useState, useMemo } from 'react';
import { Gender } from '../models/speaker';

const AppStateContext = createContext(null);

export function AppStateProvider({ children }) {
  const [gender, setGender] = useState(null);
  const [score, setScore] = useState(0);

  const sessionSuffix = useMemo(() => {
    return 1000 + Math.floor(Math.random() * 9000);
  }, []);

  const hasSelectedGender = gender !== null;

  const speakerId = useMemo(() => {
    const prefix = gender === Gender.male ? 'M' : 'F';
    return `${prefix}${sessionSuffix}`;
  }, [gender, sessionSuffix]);

  const selectGender = (newGender) => {
    setGender(newGender);
  };

  const incrementScore = () => {
    setScore((prevScore) => prevScore + 1);
  };

  const reset = () => {
    setGender(null);
    setScore(0);
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
