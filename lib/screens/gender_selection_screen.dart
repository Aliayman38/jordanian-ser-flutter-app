import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/speaker.dart';
import '../services/app_state.dart';
import '../theme/app_theme.dart';
import 'emotions_menu_screen.dart';

/// First screen: the contributor picks their gender before anything else,
/// since it becomes part of the `speaker_id` sent with every recording.
class GenderSelectionScreen extends StatelessWidget {
  const GenderSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final selected = appState.gender;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const _HeaderArt(),
              const SizedBox(height: 12),
              const Text(
                'مساهمتك الصوتية',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.textDark,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'ساعدنا نبني أول نظام يفهم المشاعر باللهجة الأردنية 🇯🇴\nقبل ما نبلش، اخترلنا جنسك:',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 15, color: AppTheme.textMuted, height: 1.5),
              ),
              const SizedBox(height: 40),
              Row(
                children: [
                  Expanded(
                    child: _GenderCard(
                      icon: Icons.male_rounded,
                      label: Gender.male.label,
                      isSelected: selected == Gender.male,
                      onTap: () => appState.selectGender(Gender.male),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _GenderCard(
                      icon: Icons.female_rounded,
                      label: Gender.female.label,
                      isSelected: selected == Gender.female,
                      onTap: () => appState.selectGender(Gender.female),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 36),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: selected != null
                    ? SizedBox(
                        key: const ValueKey('start-btn'),
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.mic_rounded),
                          label: const Text('ابدأ التحدي'),
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const EmotionsMenuScreen(),
                              ),
                            );
                          },
                        ),
                      )
                    : const SizedBox(key: ValueKey('empty'), height: 56),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeaderArt extends StatelessWidget {
  const _HeaderArt();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 96,
      height: 96,
      decoration: BoxDecoration(
        color: AppTheme.primary.withValues(alpha: 0.1),
        shape: BoxShape.circle,
      ),
      child: const Center(
        child: Text('🎙️', style: TextStyle(fontSize: 44)),
      ),
    );
  }
}

class _GenderCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _GenderCard({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 28),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primary : AppTheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppTheme.primary : Colors.black12,
            width: 2,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppTheme.primary.withValues(alpha: 0.3),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ]
              : null,
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 44,
              color: isSelected ? Colors.white : AppTheme.primary,
            ),
            const SizedBox(height: 10),
            Text(
              label,
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.white : AppTheme.textDark,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
