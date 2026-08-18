import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/emotion.dart';
import '../services/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/emotion_card.dart';
import 'recording_screen.dart';

/// Dashboard: live score + a 2x2 grid of the four emotion categories.
class EmotionsMenuScreen extends StatelessWidget {
  const EmotionsMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final score = context.watch<AppState>().score;

    return Scaffold(
      appBar: AppBar(title: const Text('اختر شعور')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
          child: Column(
            children: [
              _ScoreBanner(score: score),
              const SizedBox(height: 20),
              const Text(
                'اختار الشعور اللي بدك تسجل له مقطع صوتي',
                style: TextStyle(fontSize: 14, color: AppTheme.textMuted),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  children: EmotionData.all.values.map((data) {
                    return EmotionCard(
                      data: data,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => RecordingScreen(emotion: data),
                          ),
                        );
                      },
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ScoreBanner extends StatelessWidget {
  final int score;
  const _ScoreBanner({required this.score});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
      decoration: BoxDecoration(
        color: AppTheme.primary,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withValues(alpha: 0.3),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'مساهماتك الصوتية',
                style: TextStyle(color: Colors.white70, fontSize: 13),
              ),
              SizedBox(height: 4),
              Text(
                'استمر، كل تسجيل بيفرق!',
                style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          Row(
            children: [
              const Icon(Icons.graphic_eq_rounded, color: Colors.white, size: 26),
              const SizedBox(width: 8),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                transitionBuilder: (child, anim) =>
                    ScaleTransition(scale: anim, child: child),
                child: Text(
                  '$score',
                  key: ValueKey(score),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 30,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
