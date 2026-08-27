import 'package:flutter/material.dart';

enum RecordingMode {
  hold,
  tapToToggle,
}

/// Dynamic microphone recording button supporting both "Hold to record"
/// and "Tap to toggle" modes with multi-layer pulsating ripple rings,
/// mouse hover states, and responsive styling.
class HoldToRecordButton extends StatefulWidget {
  final VoidCallback onRecordStart;
  final VoidCallback onRecordStop;
  final bool isRecording;
  final bool isBusy;
  final Color color;
  final RecordingMode mode;

  const HoldToRecordButton({
    super.key,
    required this.onRecordStart,
    required this.onRecordStop,
    required this.color,
    this.isRecording = false,
    this.isBusy = false,
    this.mode = RecordingMode.hold,
  });

  @override
  State<HoldToRecordButton> createState() => _HoldToRecordButtonState();
}

class _HoldToRecordButtonState extends State<HoldToRecordButton>
    with TickerProviderStateMixin {
  late final AnimationController _pulseController;
  late final AnimationController _scaleController;
  late final Animation<double> _pulseAnimation;
  late final Animation<double> _scaleAnimation;
  bool _internalPressed = false;
  bool _isHovered = false;

  bool get _active => widget.isRecording || _internalPressed;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    _pulseAnimation = CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeOutQuad,
    );

    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeOutCubic),
    );

    if (widget.isRecording) {
      _pulseController.repeat();
      _scaleController.forward();
    }
  }

  @override
  void didUpdateWidget(HoldToRecordButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isRecording != oldWidget.isRecording) {
      if (widget.isRecording) {
        _pulseController.repeat();
        _scaleController.forward();
      } else {
        _pulseController.stop();
        _pulseController.reset();
        _scaleController.reverse();
        _internalPressed = false;
      }
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  // --- Hold Mode Handlers ---
  void _handleHoldDown(TapDownDetails _) {
    if (widget.mode != RecordingMode.hold || widget.isBusy || widget.isRecording) return;
    setState(() => _internalPressed = true);
    _scaleController.forward();
    _pulseController.repeat();
    widget.onRecordStart();
  }

  void _handleHoldUp(TapUpDetails _) => _releaseHold();

  void _handleHoldCancel() => _releaseHold();

  void _releaseHold() {
    if (widget.mode != RecordingMode.hold) return;
    if (!_internalPressed && !widget.isRecording) return;
    setState(() => _internalPressed = false);
    _scaleController.reverse();
    _pulseController.stop();
    _pulseController.reset();
    widget.onRecordStop();
  }

  // --- Tap to Toggle Mode Handler ---
  void _handleTapToggle() {
    if (widget.mode != RecordingMode.tapToToggle || widget.isBusy) return;
    if (widget.isRecording) {
      widget.onRecordStop();
    } else {
      widget.onRecordStart();
    }
  }

  @override
  Widget build(BuildContext context) {
    final activeColor = _active ? const Color(0xFFE63946) : widget.color;

    return Center(
      child: MouseRegion(
        cursor: widget.isBusy ? SystemMouseCursors.forbidden : SystemMouseCursors.click,
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: SizedBox(
          width: 190,
          height: 190,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Ripple layer 2 (outer)
              AnimatedBuilder(
                animation: _pulseAnimation,
                builder: (context, _) {
                  if (!_active) return const SizedBox.shrink();
                  final value = _pulseAnimation.value;
                  return Container(
                    width: 130 + (60 * value),
                    height: 130 + (60 * value),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: activeColor.withOpacity((1.0 - value) * 0.25),
                    ),
                  );
                },
              ),

              // Ripple layer 1 (inner)
              AnimatedBuilder(
                animation: _pulseAnimation,
                builder: (context, _) {
                  if (!_active) return const SizedBox.shrink();
                  final value = (_pulseAnimation.value + 0.5) % 1.0;
                  return Container(
                    width: 130 + (40 * value),
                    height: 130 + (40 * value),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: activeColor.withOpacity((1.0 - value) * 0.35),
                    ),
                  );
                },
              ),

              // Main Interactive Recording Button
              GestureDetector(
                onTapDown: widget.mode == RecordingMode.hold ? _handleHoldDown : null,
                onTapUp: widget.mode == RecordingMode.hold ? _handleHoldUp : null,
                onTapCancel: widget.mode == RecordingMode.hold ? _handleHoldCancel : null,
                onTap: widget.mode == RecordingMode.tapToToggle ? _handleTapToggle : null,
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeOutCubic,
                    width: _active ? 136 : (_isHovered ? 130 : 124),
                    height: _active ? 136 : (_isHovered ? 130 : 124),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: _active
                            ? [const Color(0xFFFF4D6D), const Color(0xFFC9184A)]
                            : [widget.color, widget.color.withOpacity(0.85)],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: activeColor.withOpacity(_active ? 0.55 : (_isHovered ? 0.45 : 0.3)),
                          blurRadius: _active ? 30 : (_isHovered ? 24 : 16),
                          offset: Offset(0, _active ? 10 : (_isHovered ? 8 : 6)),
                          spreadRadius: _active ? 2 : (_isHovered ? 1 : 0),
                        ),
                      ],
                    ),
                    child: Center(
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 200),
                        transitionBuilder: (child, anim) =>
                            ScaleTransition(scale: anim, child: child),
                        child: Icon(
                          _active
                              ? (widget.mode == RecordingMode.tapToToggle
                                  ? Icons.stop_rounded
                                  : Icons.mic_rounded)
                              : Icons.mic_none_rounded,
                          key: ValueKey('${_active}_${widget.mode}'),
                          color: Colors.white,
                          size: _active ? 58 : 52,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
