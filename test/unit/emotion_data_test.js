import { EmotionType, EmotionData } from '../models/emotion';

describe('EmotionData Tests', () => {
  test('All 4 core emotion categories are configured', () => {
    const keys = Object.keys(EmotionData.all);
    expect(keys.length).toBe(4);
    expect(EmotionData.all).toHaveProperty(EmotionType.angry);
    expect(EmotionData.all).toHaveProperty(EmotionType.happy);
    expect(EmotionData.all).toHaveProperty(EmotionType.sad);
    expect(EmotionData.all).toHaveProperty(EmotionType.neutral);
  });

  test('Each emotion has at least 4 authentic prompts', () => {
    Object.values(EmotionData.all).forEach((data) => {
      expect(data.prompts.length).toBeGreaterThanOrEqual(4);
      expect(data.labelArabic.length).toBeGreaterThan(0);
      expect(data.subtitleArabic.length).toBeGreaterThan(0);
      expect(data.emoji.length).toBeGreaterThan(0);
      expect(data.apiTag.length).toBeGreaterThan(0);
    });
  });

  test('promptFor rotates and cycles within bounds', () => {
    const happy = EmotionData.all[EmotionType.happy];
    const count = happy.prompts.length;
    expect(happy.promptFor(0)).toBe(happy.prompts[0]);
    expect(happy.promptFor(count)).toBe(happy.prompts[0]);
    expect(happy.promptFor(count + 1)).toBe(happy.prompts[1]);
  });
});