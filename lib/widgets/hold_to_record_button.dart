import 'package:flutter/material.dart';

/// A big circular mic button that records only while pressed down
/// (press-and-hold gesture), matching the classic voice-memo interaction.
class HoldToRecordButton extends StatefulWidget {
  final VoidCallback onRecordStart;
  final VoidCallback onRecordStop;
  final bool isBusy;
  final Color color;

  const HoldToRecordButton({
    super.key,
    required this.onRecordStart,
    required this.onRecordStop,
    required this.color,
    this.isBusy = false,
  });

  @override
  State<HoldToRecordButton> createState() => _HoldToRecordButtonState();
}

class _HoldToRecordButtonState extends State<HoldToRecordButton>
    with SingleTickerProviderStateMixin {
  bool _pressed = false;

  void _handleDown(TapDownDetails _) {
    if (widget.isBusy) return;
    setState(() => _pressed = true);
    widget.onRecordStart();
  }

  void _handleUp(TapUpDetails _) => _release();

  void _handleCancel() => _release();

  void _release() {
    if (!_pressed) return;
    setState(() => _pressed = false);
    widget.onRecordStop();
  }

  @override
  Widget build(BuildContext context) {
    final size = _pressed ? 150.0 : 130.0;

    return GestureDetector(
      onTapDown: _handleDown,
      onTapUp: _handleUp,
      onTapCancel: _handleCancel,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOut,
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: _pressed ? Colors.redAccent : widget.color,
          boxShadow: [
            BoxShadow(
              color: (_pressed ? Colors.redAccent : widget.color)
                  .withValues(alpha: 0.4),
              blurRadius: _pressed ? 28 : 16,
              spreadRadius: _pressed ? 4 : 0,
            ),
          ],
        ),
        child: Icon(
          _pressed ? Icons.mic_rounded : Icons.mic_none_rounded,
          color: Colors.white,
          size: 56,
        ),
      ),
    );
  }
}
