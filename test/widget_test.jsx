import React from 'react';
import { render, screen, fireEvent, act } from '@testing-library/react';
import '@testing-library/jest-dom';
import { JordanianSERApp } from '../main';
import { EmotionData, EmotionType } from '../models/emotion';
import { ResponsiveContainer } from '../widgets/responsive_container';
import { AudioVisualizerWave } from '../widgets/audio_visualizer_wave';
import { HoldToRecordButton, RecordingMode } from '../widgets/hold_to_record_button';
import { EmotionCard } from '../widgets/emotion_card';

describe('JordanianSERApp Widget Tests', () => {
  test('JordanianSERApp builds successfully and shows title & options', () => {
    render(<JordanianSERApp />);

    expect(screen.getByText('المشروع الوطني للذكاء الاصطناعي الأردني')).toBeInTheDocument();
    expect(screen.getByText('تحدي الصوت الأردني')).toBeInTheDocument();
    expect(screen.getByText('شاب')).toBeInTheDocument();
    expect(screen.getByText('صبية')).toBeInTheDocument();
  });

  test('Selecting gender shows contributor ID preview and enables Start button', () => {
    render(<JordanianSERApp />);

    expect(screen.queryByText('ابدأ التحدي 🚀')).not.toBeInTheDocument();

    const maleOption = screen.getByText('شاب');
    fireEvent.click(maleOption);

    expect(screen.getByText(/معرّف المساهم: M/)).toBeInTheDocument();
    const startButton = screen.getByText('ابدأ التحدي 🚀');
    expect(startButton).toBeInTheDocument();

    fireEvent.click(startButton);

    expect(screen.getByText('اختر الشعور')).toBeInTheDocument();
    expect(screen.getByText('معصب')).toBeInTheDocument();
    expect(screen.getByText('فرحان')).toBeInTheDocument();
    expect(screen.getByText('زعلان')).toBeInTheDocument();
    expect(screen.getByText('طبيعي')).toBeInTheDocument();
  });

  test('ResponsiveContainer wraps content cleanly', () => {
    render(
      <ResponsiveContainer>
        <div>محتوى تجريبي</div>
      </ResponsiveContainer>
    );

    expect(screen.getByText('محتوى تجريبي')).toBeInTheDocument();
  });

  test('AudioVisualizerWave renders waveform bars', () => {
    const { container } = render(
      <AudioVisualizerWave isRecording={true} color="#006D5B" barCount={24} />
    );

    expect(container.firstChild).toBeInTheDocument();
  });

  test('HoldToRecordButton supports mode toggling and rendering', () => {
    let started = false;

    const { container } = render(
      <HoldToRecordButton
        color="#E63946"
        mode={RecordingMode.tapToToggle}
        onRecordStart={() => {
          started = true;
        }}
        onRecordStop={() => {}}
      />
    );

    expect(container.firstChild).toBeInTheDocument();

    const micButton = screen.getByText('mic_none');
    fireEvent.click(micButton);

    expect(started).toBe(true);
  });

  test('EmotionCard displays emoji, label, and prompt count', () => {
    const happyData = EmotionData.all[EmotionType.happy];
    let tapped = false;

    render(
      <EmotionCard
        data={happyData}
        onTap={() => {
          tapped = true;
        }}
      />
    );

    expect(screen.getByText('فرحان')).toBeInTheDocument();
    expect(screen.getByText(happyData.emoji)).toBeInTheDocument();
    expect(screen.getByText(`${happyData.prompts.length} جمل`)).toBeInTheDocument();

    const card = screen.getByText('فرحان').closest('div');
    fireEvent.mouseDown(card);
    fireEvent.mouseUp(card);

    expect(tapped).toBe(true);
  });
});