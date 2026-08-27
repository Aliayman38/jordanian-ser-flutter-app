import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

enum ScreenType { mobile, tablet, desktop }

class ResponsiveBreakpoints {
  static const double mobileMax = 600;
  static const double tabletMax = 1024;

  static ScreenType getScreenType(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width < mobileMax) return ScreenType.mobile;
    if (width < tabletMax) return ScreenType.tablet;
    return ScreenType.desktop;
  }

  static bool isMobile(BuildContext context) =>
      getScreenType(context) == ScreenType.mobile;

  static bool isTablet(BuildContext context) =>
      getScreenType(context) == ScreenType.tablet;

  static bool isDesktop(BuildContext context) =>
      getScreenType(context) == ScreenType.desktop;
}

/// A wrapper widget that ensures responsive padding, safe scrolling,
/// and maximum content width constraint across mobile, tablet, and website/desktop screens.
class ResponsiveContainer extends StatelessWidget {
  final Widget child;
  final double maxWidth;
  final EdgeInsetsGeometry? padding;
  final bool scrollable;
  final bool useSafeArea;
  final bool wrapInCardOnDesktop;

  const ResponsiveContainer({
    super.key,
    required this.child,
    this.maxWidth = 720,
    this.padding,
    this.scrollable = true,
    this.useSafeArea = true,
    this.wrapInCardOnDesktop = false,
  });

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final isLandscape = mediaQuery.orientation == Orientation.landscape;
    final isDesktop = screenWidth >= ResponsiveBreakpoints.tabletMax;
    final isTablet = screenWidth >= ResponsiveBreakpoints.mobileMax && !isDesktop;

    final defaultPadding = screenWidth < 380
        ? const EdgeInsets.symmetric(horizontal: 14, vertical: 12)
        : screenWidth < 600
            ? EdgeInsets.symmetric(
                horizontal: isLandscape ? 28 : 18,
                vertical: isLandscape ? 12 : 16,
              )
            : isTablet
                ? const EdgeInsets.symmetric(horizontal: 28, vertical: 20)
                : const EdgeInsets.symmetric(horizontal: 36, vertical: 24);

    final effectivePadding = padding ?? defaultPadding;

    Widget buildCardWrapped(Widget inner) {
      if (isDesktop && wrapInCardOnDesktop) {
        return Container(
          constraints: BoxConstraints(maxWidth: maxWidth),
          margin: const EdgeInsets.symmetric(vertical: 20),
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: AppTheme.borderLight, width: 1.5),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primary.withOpacity(0.06),
                blurRadius: 36,
                offset: const Offset(0, 12),
                spreadRadius: 2,
              ),
            ],
          ),
          child: inner,
        );
      }

      return ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Padding(
          padding: effectivePadding,
          child: inner,
        ),
      );
    }

    Widget content;

    if (scrollable) {
      content = LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight,
              ),
              child: Center(
                child: buildCardWrapped(
                  IntrinsicHeight(
                    child: child,
                  ),
                ),
              ),
            ),
          );
        },
      );
    } else {
      content = Center(child: buildCardWrapped(child));
    }

    if (useSafeArea) {
      content = SafeArea(child: content);
    }

    return content;
  }
}
