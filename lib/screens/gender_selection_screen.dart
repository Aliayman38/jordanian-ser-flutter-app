import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/speaker.dart';
import '../services/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/responsive_container.dart';
import 'emotions_menu_screen.dart';

/// First screen: contributor selects gender, previews their anonymous contributor ID,
/// and starts the Jordanian SER voice collection challenge.
class GenderSelectionScreen extends StatelessWidget {
  const GenderSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final selected = appState.gender;

    return Scaffold(
      body: ResponsiveContainer(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 12),

            // Jordanian AI Project Pill Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: AppTheme.primary.withOpacity(0.08),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(
                  color: AppTheme.primary.withOpacity(0.2),
                ),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('🇯🇴', style: TextStyle(fontSize: 15)),
                  SizedBox(width: 6),
                  Text(
                    'المشروع الوطني للذكاء الاصطناعي الأردني',
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.primary,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),
            const _HeaderArt(),
            const SizedBox(height: 16),

            // Title
            const Text(
              'تحدي الصوت الأردني',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w900,
                color: AppTheme.textDark,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 8),

            // Description
            const Text(
              'ساعدنا في تدريب أول نموذج ذكاء اصطناعي يفهم المشاعر باللهجة الأردنية بدقة عالية ✨\nاختر جنس المتحدث للبدء:',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14.5,
                color: AppTheme.textMuted,
                height: 1.55,
              ),
            ),

            const SizedBox(height: 28),

            // Gender Selection Cards
            Row(
              children: [
                Expanded(
                  child: _GenderCard(
                    icon: Gender.male.icon,
                    label: Gender.male.label,
                    sublabel: Gender.male.description,
                    isSelected: selected == Gender.male,
                    onTap: () => appState.selectGender(Gender.male),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: _GenderCard(
                    icon: Gender.female.icon,
                    label: Gender.female.label,
                    sublabel: Gender.female.description,
                    isSelected: selected == Gender.female,
                    onTap: () => appState.selectGender(Gender.female),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Live Contributor ID Preview Badge
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              child: selected != null
                  ? Container(
                      key: ValueKey(appState.speakerId),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppTheme.borderLight),
                        boxShadow: AppTheme.cardShadow,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.fingerprint_rounded,
                            size: 18,
                            color: AppTheme.primary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'معرّف المساهم: ${appState.speakerId}',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.textDark,
                            ),
                          ),
                        ],
                      ),
                    )
                  : const SizedBox(height: 38),
            ),

            const SizedBox(height: 24),

            // Start Challenge Action Button
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: selected != null
                  ? SizedBox(
                      key: const ValueKey('start-btn'),
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.play_arrow_rounded, size: 24),
                        label: const Text(
                          'ابدأ التحدي 🚀',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
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

            const SizedBox(height: 16),
          ],
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
      width: 92,
      height: 92,
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
        shape: BoxShape.circle,
        boxShadow: AppTheme.glowShadow(AppTheme.primary, opacity: 0.35, blur: 24),
      ),
      child: Center(
        child: Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.18),
            shape: BoxShape.circle,
          ),
          child: const Center(
            child: Text('🎙️', style: TextStyle(fontSize: 42)),
          ),
        ),
      ),
    );
  }
}

class _GenderCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String sublabel;
  final bool isSelected;
  final VoidCallback onTap;

  const _GenderCard({
    required this.icon,
    required this.label,
    required this.sublabel,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(22),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primary : AppTheme.surface,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: isSelected ? AppTheme.primary : AppTheme.borderLight,
            width: isSelected ? 2.2 : 1.2,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppTheme.primary.withOpacity(0.32),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ]
              : AppTheme.cardShadow,
        ),
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            // Selected checkmark indicator
            if (isSelected)
              Positioned(
                top: -10,
                left: -2,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: AppTheme.accent,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_rounded,
                    size: 14,
                    color: AppTheme.textDark,
                  ),
                ),
              ),

            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  size: 46,
                  color: isSelected ? Colors.white : AppTheme.primary,
                ),
                const SizedBox(height: 10),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: isSelected ? Colors.white : AppTheme.textDark,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  sublabel,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isSelected
                        ? Colors.white.withOpacity(0.85)
                        : AppTheme.textMuted,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
