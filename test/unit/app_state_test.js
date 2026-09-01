import { renderHook, act } from '@testing-library/react';
import { Gender } from '../models/speaker';
import { useAppState, AppStateProvider } from '../services/app_state';

describe('AppState Tests', () => {
  const wrapper = ({ children }) => <AppStateProvider>{children}</AppStateProvider>;

  test('Initial state should have no gender and score 0', () => {
    const { result } = renderHook(() => useAppState(), { wrapper });

    expect(result.current.hasSelectedGender).toBe(false);
    expect(result.current.gender).toBeNull();
    expect(result.current.score).toBe(0);
  });

  test('Selecting male gender produces speakerId starting with M', () => {
    const { result } = renderHook(() => useAppState(), { wrapper });

    act(() => {
      result.current.selectGender(Gender.male);
    });

    expect(result.current.hasSelectedGender).toBe(true);
    expect(result.current.gender).toBe(Gender.male);
    expect(result.current.speakerId.startsWith('M')).toBe(true);
  });

  test('Selecting female gender produces speakerId starting with F', () => {
    const { result } = renderHook(() => useAppState(), { wrapper });

    act(() => {
      result.current.selectGender(Gender.female);
    });

    expect(result.current.hasSelectedGender).toBe(true);
    expect(result.current.gender).toBe(Gender.female);
    expect(result.current.speakerId.startsWith('F')).toBe(true);
  });

  test('Increment score increments correctly', () => {
    const { result } = renderHook(() => useAppState(), { wrapper });

    act(() => {
      result.current.incrementScore();
      result.current.incrementScore();
    });

    expect(result.current.score).toBe(2);
  });

  test('Reset clears gender and resets score to 0', () => {
    const { result } = renderHook(() => useAppState(), { wrapper });

    act(() => {
      result.current.selectGender(Gender.male);
      result.current.incrementScore();
    });

    act(() => {
      result.current.reset();
    });

    expect(result.current.gender).toBeNull();
    expect(result.current.score).toBe(0);
    expect(result.current.hasSelectedGender).toBe(false);
  });
});