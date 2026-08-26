import 'dart:math';
import 'package:flutter/material.dart';

/// Animated multi-bar waveform visualizer simulating audio frequencies during recording.
class AudioVisualizerWave extends StatefulWidget {
  final bool isRecording;
  final Color color;
  final Color? secondaryColor;
  final int barCount;
  final double maxHeight;

  const AudioVisualizerWave({
    super.key,
    required this.isRecording,
    required this.color,
    this.secondaryColor,
    this.barCount = 24,
    this.maxHeight = 56,
  });

  @override
  State<AudioVisualizerWave> createState() => _AudioVisualizerWaveState();
}

class _AudioVisualizerWaveState extends State<AudioVisualizerWave>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  final Random _random = Random(42);
  late List<double> _baseHeights;

  @override
  void initState() {
    super.initState();
    _baseHeights = List.generate(widget.barCount, (i) {
      final center = widget.barCount / 2;
      final dist = (i - center).abs() / center;
      return (1.0 - dist * 0.55).clamp(0.25, 1.0);
    });

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..addListener(() {
        if (widget.isRecording && mounted) {
          setState(() {});
        }
      });

    if (widget.isRecording) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(AudioVisualizerWave oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isRecording != oldWidget.isRecording) {
      if (widget.isRecording) {
        _controller.repeat(reverse: true);
      } else {
        _controller.stop();
        _controller.reset();
        setState(() {});
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final secondary = widget.secondaryColor ?? widget.color.withOpacity(0.7);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: widget.color.withOpacity(widget.isRecording ? 0.08 : 0.03),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: widget.color.withOpacity(widget.isRecording ? 0.2 : 0.08),
        ),
      ),
      child: SizedBox(
        height: widget.maxHeight,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: List.generate(widget.barCount, (index) {
            double factor;
            if (widget.isRecording) {
              final wave = sin(_controller.value * 2 * pi + (index * 0.35)).abs();
              final noise = _random.nextDouble() * 0.35;
              factor = ((_baseHeights[index] * 0.55) + (wave * 0.4) + noise)
                  .clamp(0.18, 1.0);
            } else {
              factor = 0.14;
            }

            final barHeight =
                (widget.maxHeight * factor).clamp(5.0, widget.maxHeight);

            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 2.0),
              width: 3.5,
              height: barHeight,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: widget.isRecording
                      ? [widget.color, secondary]
                      : [
                          widget.color.withOpacity(0.2),
                          widget.color.withOpacity(0.1),
                        ],
                ),
                borderRadius: BorderRadius.circular(4),
                boxShadow: widget.isRecording
                    ? [
                        BoxShadow(
                          color: widget.color.withOpacity(0.25),
                          blurRadius: 4,
                          offset: const Offset(0, 1),
                        )
                      ]
                    : null,
              ),
            );
          }),
        ),
      ),
    );
  }
}
