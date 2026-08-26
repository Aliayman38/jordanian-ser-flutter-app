import 'package:flutter/material.dart';

/// A wrapper widget that ensures responsive padding, safe scrolling,
/// and maximum content width constraint across mobile, tablet, and landscape screens.
class ResponsiveContainer extends StatelessWidget {
  final Widget child;
  final double maxWidth;
  final EdgeInsetsGeometry? padding;
  final bool scrollable;
  final bool useSafeArea;

  const ResponsiveContainer({
    super.key,
    required this.child,
    this.maxWidth = 650,
    this.padding,
    this.scrollable = true,
    this.useSafeArea = true,
  });

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final isLandscape = mediaQuery.orientation == Orientation.landscape;

    final defaultPadding = screenWidth < 380
        ? const EdgeInsets.symmetric(horizontal: 16, vertical: 12)
        : screenWidth < 600
            ? EdgeInsets.symmetric(
                horizontal: isLandscape ? 32 : 20,
                vertical: isLandscape ? 12 : 18,
              )
            : const EdgeInsets.symmetric(horizontal: 36, vertical: 24);

    final effectivePadding = padding ?? defaultPadding;

    Widget content = Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Padding(
          padding: effectivePadding,
          child: child,
        ),
      ),
    );

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
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: maxWidth),
                  child: Padding(
                    padding: effectivePadding,
                    child: IntrinsicHeight(
                      child: child,
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      );
    }

    if (useSafeArea) {
      return SafeArea(child: content);
    }
    return content;
  }
}
