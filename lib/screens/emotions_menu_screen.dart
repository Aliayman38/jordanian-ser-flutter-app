import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/emotion.dart';
import '../models/speaker.dart';
import '../services/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/emotion_card.dart';
import '../widgets/responsive_container.dart';
import 'recording_screen.dart';

/// Dashboard: live score, contributor level tiers, and responsive grid of emotions.
class EmotionsMenuScreen extends StatelessWidget {
  const EmotionsMenuScreen({super.key});

  void _showChangeGenderDialog(BuildContext context) {
    final appState = context.read<AppState>();

    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Row(
          children: [
            Icon(Icons.tune_rounded, color: AppTheme.primary),
            SizedBox(width: 10),
            Text(
              'تغيير إعدادات الجلسة',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'المعرّف الحالي: ${appState.speakerId} (${appState.gender?.label ?? ""})',
              style: const TextStyle(fontSize: 14, color: AppTheme.textMuted),
            ),
            const SizedBox(height: 16),
            const Text(
              'اختر الصوت المناسب لتسجيلاتك القادمة:',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      backgroundColor: appState.gender == Gender.male
                          ? AppTheme.primary.withOpacity(0.1)
                          : null,
                    ),
                    onPressed: () {
                      appState.selectGender(Gender.male);
                      Navigator.of(dialogCtx).pop();
                    },
                    child: const Text('شاب 👨'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      backgroundColor: appState.gender == Gender.female
                          ? AppTheme.primary.withOpacity(0.1)
                          : null,
                    ),
                    onPressed: () {
                      appState.selectGender(Gender.female);
                      Navigator.of(dialogCtx).pop();
                    },
                    child: const Text('صبية 👩'),
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(),
            child: const Text('إلغاء'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final score = appState.score;

    return Scaffold(
      appBar: AppBar(
        title: const Text('اختر الشعور'),
        actions: [
          IconButton(
            tooltip: 'تغيير المتحدث',
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => _showChangeGenderDialog(context),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: ResponsiveContainer(
        scrollable: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Gamified Score & Level Tier Banner
            _GamifiedTierBanner(score: score, speakerId: appState.speakerId),
            const SizedBox(height: 16),

            // Instruction subtitle
            const Row(
              children: [
                Icon(Icons.mic_external_on_rounded, size: 18, color: AppTheme.primary),
                SizedBox(width: 6),
                Text(
                  'اختر شعوراً لتسجيل عبارة أردنية معبرة:',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textMuted,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Responsive Emotions Grid
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final width = constraints.maxWidth;
                  final crossAxisCount = width > 700
                      ? 4
                      : width > 480
                          ? 3
                          : 2;

                  final childAspectRatio = width > 700
                      ? 1.05
                      : width > 480
                          ? 0.95
                          : 0.85;

                  return GridView.count(
                    crossAxisCount: crossAxisCount,
                    mainAxisSpacing: 14,
                    crossAxisSpacing: 14,
                    childAspectRatio: childAspectRatio,
                    physics: const BouncingScrollPhysics(),
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
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GamifiedTierBanner extends StatelessWidget {
  final int score;
  final String speakerId;

  const _GamifiedTierBanner({required this.score, required this.speakerId});

  ({String title, String badge, int target, double progress}) _getTierInfo(int score) {
    if (score == 0) {
      return (
        title: 'مساهم جديد',
        badge: '🎯',
        target: 1,
        progress: 0.0,
      );
    } else if (score < 4) {
      return (
        title: 'مساهم مبتدئ',
        badge: '🥉',
        target: 4,
        progress: score / 4,
      );
    } else if (score < 10) {
      return (
        title: 'مساهم برونزي',
        badge: '🥈',
        target: 10,
        progress: (score - 3) / 7,
      );
    } else if (score < 20) {
      return (
        title: 'مساهم ذهبي',
        badge: '🥇',
        target: 20,
        progress: (score - 9) / 11,
      );
    } else {
      return (
        title: 'بطل اللهجة الأردنية',
        badge: '🌟',
        target: score,
        progress: 1.0,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final tier = _getTierInfo(score);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: AppTheme.heroGradient,
        borderRadius: BorderRadius.circular(24),
        boxShadow: AppTheme.glowShadow(AppTheme.primaryDark, opacity: 0.3, blur: 20),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Tier Badge & Name
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(tier.badge, style: const TextStyle(fontSize: 22)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tier.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'المعرّف: $speakerId',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.75),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              // Total Score Chip
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: AppTheme.accent,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.accent.withOpacity(0.4),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.graphic_eq_rounded,
                      color: AppTheme.textDark,
                      size: 20,
                    ),
                    const SizedBox(width: 6),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 250),
                      transitionBuilder: (child, anim) =>
                          ScaleTransition(scale: anim, child: child),
                      child: Text(
                        '$score',
                        key: ValueKey(score),
                        style: const TextStyle(
                          color: AppTheme.textDark,
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Tier Progress Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: tier.progress.clamp(0.05, 1.0),
              minHeight: 8,
              backgroundColor: Colors.white.withOpacity(0.15),
              valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.accent),
            ),
          ),

          const SizedBox(height: 6),

          // Next Level hint
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                score >= 20
                    ? 'أعلى رتبة محققة! أسطورة 🌟'
                    : 'سجل ${tier.target - score} مقاطع إضافية للرتبة التالية',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                score >= 20 ? '100%' : '$score / ${tier.target}',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.85),
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
