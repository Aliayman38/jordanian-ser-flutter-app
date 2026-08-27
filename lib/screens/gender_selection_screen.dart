import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/speaker.dart';
import '../services/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/responsive_container.dart';
import 'emotions_menu_screen.dart';

/// First screen: contributor selects gender, previews their anonymous contributor ID,
/// and starts the Jordanian SER voice collection challenge.
/// Fully responsive for Web, Desktop, Tablet, and Mobile.
class GenderSelectionScreen extends StatefulWidget {
  const GenderSelectionScreen({super.key});

  @override
  State<GenderSelectionScreen> createState() => _GenderSelectionScreenState();
}

class _GenderSelectionScreenState extends State<GenderSelectionScreen> {
  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  void _onStart(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const EmotionsMenuScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final selected = appState.gender;
    final isDesktop = ResponsiveBreakpoints.isDesktop(context);

    return Scaffold(
      body: Focus(
        focusNode: _focusNode,
        autofocus: true,
        onKeyEvent: (node, event) {
          if (event is KeyDownEvent) {
            if (event.logicalKey == LogicalKeyboardKey.digit1 ||
                event.logicalKey == LogicalKeyboardKey.numpad1) {
              appState.selectGender(Gender.male);
              return KeyEventResult.handled;
            } else if (event.logicalKey == LogicalKeyboardKey.digit2 ||
                event.logicalKey == LogicalKeyboardKey.numpad2) {
              appState.selectGender(Gender.female);
              return KeyEventResult.handled;
            } else if ((event.logicalKey == LogicalKeyboardKey.enter ||
                    event.logicalKey == LogicalKeyboardKey.space) &&
                selected != null) {
              _onStart(context);
              return KeyEventResult.handled;
            }
          }
          return KeyEventResult.ignored;
        },
        child: ResponsiveContainer(
          maxWidth: isDesktop ? 600 : 520,
          wrapInCardOnDesktop: true,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 8),

              // Jordanian AI Project Pill Badge (Wrap to prevent overflow on small containers)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                    color: AppTheme.primary.withOpacity(0.2),
                  ),
                ),
                child: const Wrap(
                  alignment: WrapAlignment.center,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 6,
                  children: [
                    Text('🇯🇴', style: TextStyle(fontSize: 15)),
                    Text(
                      'المشروع الوطني للذكاء الاصطناعي الأردني',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.primary,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),
              const _HeaderArt(),
              const SizedBox(height: 14),

              // Title
              const Text(
                'تحدي الصوت الأردني',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  color: AppTheme.textDark,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 6),

              // Description
              const Text(
                'ساعدنا في تدريب أول نموذج ذكاء اصطناعي يفهم المشاعر باللهجة الأردنية بدقة عالية ✨\nاختر جنس المتحدث للبدء:',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: AppTheme.textMuted,
                  height: 1.5,
                ),
              ),

              const SizedBox(height: 24),

              // Gender Selection Cards
              Row(
                children: [
                  Expanded(
                    child: _GenderCard(
                      icon: Gender.male.icon,
                      label: Gender.male.label,
                      sublabel: Gender.male.description,
                      shortcutHint: isDesktop ? '1' : null,
                      isSelected: selected == Gender.male,
                      onTap: () => appState.selectGender(Gender.male),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _GenderCard(
                      icon: Gender.female.icon,
                      label: Gender.female.label,
                      sublabel: Gender.female.description,
                      shortcutHint: isDesktop ? '2' : null,
                      isSelected: selected == Gender.female,
                      onTap: () => appState.selectGender(Gender.female),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

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

              const SizedBox(height: 20),

              // Start Challenge Action Button
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: selected != null
                    ? SizedBox(
                        key: const ValueKey('start-btn'),
                        width: double.infinity,
                        height: 54,
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.play_arrow_rounded, size: 24),
                          label: const Text(
                            'ابدأ التحدي 🚀',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          onPressed: () => _onStart(context),
                        ),
                      )
                    : const SizedBox(key: ValueKey('empty'), height: 54),
              ),

              const SizedBox(height: 12),
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
      width: 84,
      height: 84,
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
        shape: BoxShape.circle,
        boxShadow: AppTheme.glowShadow(AppTheme.primary, opacity: 0.35, blur: 24),
      ),
      child: Center(
        child: Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.18),
            shape: BoxShape.circle,
          ),
          child: const Center(
            child: Text('🎙️', style: TextStyle(fontSize: 38)),
          ),
        ),
      ),
    );
  }
}

class _GenderCard extends StatefulWidget {
  final IconData icon;
  final String label;
  final String sublabel;
  final String? shortcutHint;
  final bool isSelected;
  final VoidCallback onTap;

  const _GenderCard({
    required this.icon,
    required this.label,
    required this.sublabel,
    this.shortcutHint,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<_GenderCard> createState() => _GenderCardState();
}

class _GenderCardState extends State<_GenderCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final isSelected = widget.isSelected;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          transform: _isHovered
              ? (Matrix4.identity()..translate(0.0, -3.0, 0.0))
              : Matrix4.identity(),
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
          decoration: BoxDecoration(
            color: isSelected ? AppTheme.primary : AppTheme.surface,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: isSelected
                  ? AppTheme.primary
                  : (_isHovered
                      ? AppTheme.primary.withOpacity(0.5)
                      : AppTheme.borderLight),
              width: isSelected ? 2.2 : (_isHovered ? 1.8 : 1.2),
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: AppTheme.primary.withOpacity(0.32),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                  ]
                : (_isHovered
                    ? [
                        BoxShadow(
                          color: AppTheme.primary.withOpacity(0.12),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ]
                    : AppTheme.cardShadow),
          ),
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              // Selected checkmark indicator
              if (isSelected)
                Positioned(
                  top: -8,
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

              // Keyboard shortcut badge
              if (widget.shortcutHint != null)
                Positioned(
                  top: -8,
                  right: -2,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Colors.white.withOpacity(0.2)
                          : AppTheme.borderLight,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      widget.shortcutHint!,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: isSelected ? Colors.white : AppTheme.textMuted,
                      ),
                    ),
                  ),
                ),

              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    widget.icon,
                    size: 42,
                    color: isSelected ? Colors.white : AppTheme.primary,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.label,
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w900,
                      color: isSelected ? Colors.white : AppTheme.textDark,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    widget.sublabel,
                    style: TextStyle(
                      fontSize: 11.5,
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
      ),
    );
  }
}
