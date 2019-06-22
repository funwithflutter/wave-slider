import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:wave_slider/src/wave_slider.dart';

class WavePainter extends CustomPainter {
  WavePainter({
    @required this.sliderPosition,
    @required this.dragPercentage,
    @required this.animationProgress,
    @required this.sliderState,
    @required this.color,
  })  : assert(sliderPosition != null &&
            dragPercentage != null &&
            animationProgress != null &&
            sliderState != null &&
            color != null),
        wavePainter = Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.5,
        fillPainter = Paint()
          ..color = color
          ..style = PaintingStyle.fill;

  final double sliderPosition;
  final double dragPercentage;
  final double animationProgress;

  final SliderState sliderState;

  final Color color;

  final Paint wavePainter;
  final Paint fillPainter;

  /// Previous slider position initialised at the [anchorRadius], which is the start
  double _previousSliderPosition = anchorRadius;

  static const double anchorRadius = 5;

  @override
  void paint(Canvas canvas, Size size) {
    final Size restrictedSize = Size(size.width - anchorRadius, size.height);
    _paintAnchors(canvas, restrictedSize);

    switch (sliderState) {
      case SliderState.starting:
        _paintStartupWave(canvas, restrictedSize);
        break;
      case SliderState.resting:
        _paintRestingWave(canvas, restrictedSize);
        break;
      case SliderState.sliding:
        _paintSlidingWave(canvas, restrictedSize);
        break;
      case SliderState.stopping:
        _paintStoppingWave(canvas, restrictedSize);
        break;
      default:
        _paintSlidingWave(canvas, restrictedSize);
        break;
    }
  }

  void _paintAnchors(Canvas canvas, Size size) {
    canvas.drawCircle(
        Offset(anchorRadius, size.height), anchorRadius, fillPainter);
    canvas.drawCircle(
        Offset(size.width, size.height), anchorRadius, fillPainter);
  }

  void _paintRestingWave(Canvas canvas, Size size) {
    final Path path = Path();
    path.moveTo(anchorRadius, size.height);
    path.lineTo(size.width, size.height);
    canvas.drawPath(path, wavePainter);
  }

  void _paintStartupWave(Canvas canvas, Size size) {
    final WaveCurveDefinitions line = _calculateWaveLineDefinitions(size);

    final double waveHeight = lerpDouble(size.height, line.controlHeight,
        Curves.elasticOut.transform(animationProgress));
    line.controlHeight = waveHeight;
    _paintWaveLine(canvas, size, line);
  }

  void _paintSlidingWave(Canvas canvas, Size size) {
    final WaveCurveDefinitions line = _calculateWaveLineDefinitions(size);
    _paintWaveLine(canvas, size, line);
  }

  void _paintStoppingWave(Canvas canvas, Size size) {
    final WaveCurveDefinitions line = _calculateWaveLineDefinitions(size);

    final double waveHeight = lerpDouble(line.controlHeight, size.height,
        Curves.elasticOut.transform(animationProgress));

    line.controlHeight = waveHeight;

    _paintWaveLine(canvas, size, line);
  }

  void _paintWaveLine(
      Canvas canvas, Size size, WaveCurveDefinitions waveCurve) {
    final Path path = Path();
    path.moveTo(anchorRadius, size.height);
    path.lineTo(waveCurve.startOfBezier, size.height);
    path.cubicTo(
        waveCurve.leftControlPoint1,
        size.height,
        waveCurve.leftControlPoint2,
        waveCurve.controlHeight,
        waveCurve.centerPoint,
        waveCurve.controlHeight);
    path.cubicTo(
        waveCurve.rightControlPoint1,
        waveCurve.controlHeight,
        waveCurve.rightControlPoint2,
        size.height,
        waveCurve.endOfBezier,
        size.height);
    path.lineTo(size.width, size.height);

    canvas.drawPath(path, wavePainter);
  }

  WaveCurveDefinitions _calculateWaveLineDefinitions(Size size) {
    final double minWaveHeight = size.height * 0.2;
    final double maxWaveHeight = size.height * 0.8;

    final double controlHeight =
        (size.height - minWaveHeight) - (maxWaveHeight * dragPercentage);

    final double bendWidth = 20 + 20 * dragPercentage;
    final double bezierWidth = 20 + 20 * dragPercentage;

    double centerPoint = sliderPosition;
    centerPoint = (centerPoint > size.width) ? size.width : centerPoint;

    double startOfBend = centerPoint - bendWidth / 2;
    double startOfBezier = startOfBend - bezierWidth;
    double endOfBend = sliderPosition + bendWidth / 2;
    double endOfBezier = endOfBend + bezierWidth;

    startOfBend = (startOfBend <= anchorRadius) ? anchorRadius : startOfBend;
    startOfBezier =
        (startOfBezier <= anchorRadius) ? anchorRadius : startOfBezier;
    endOfBend = (endOfBend > size.width) ? size.width : endOfBend;
    endOfBezier = (endOfBezier > size.width) ? size.width : endOfBezier;

    double leftBendControlPoint1 = startOfBend;
    double leftBendControlPoint2 = startOfBend;
    double rightBendControlPoint1 = endOfBend;
    double rightBendControlPoint2 = endOfBend;

    const double bendability = 25.0;
    const double maxSlideDifference = 30.0;
    double slideDifference = (sliderPosition - _previousSliderPosition).abs();

    slideDifference = (slideDifference > maxSlideDifference)
        ? maxSlideDifference
        : slideDifference;

    double bend =
        lerpDouble(0.0, bendability, slideDifference / maxSlideDifference);
    final bool moveLeft = sliderPosition < _previousSliderPosition;
    bend = moveLeft ? -bend : bend;

    leftBendControlPoint1 = leftBendControlPoint1 + bend;
    leftBendControlPoint2 = leftBendControlPoint2 - bend;
    rightBendControlPoint1 = rightBendControlPoint1 - bend;
    rightBendControlPoint2 = rightBendControlPoint2 + bend;

    centerPoint = centerPoint - bend;

    final WaveCurveDefinitions waveCurveDefinitions = WaveCurveDefinitions(
      controlHeight: controlHeight,
      startOfBezier: startOfBezier,
      endOfBezier: endOfBezier,
      leftControlPoint1: leftBendControlPoint1,
      leftControlPoint2: leftBendControlPoint2,
      rightControlPoint1: rightBendControlPoint1,
      rightControlPoint2: rightBendControlPoint2,
      centerPoint: centerPoint,
    );

    return waveCurveDefinitions;
  }

  @override
  bool shouldRepaint(WavePainter oldDelegate) {
    final double diff = _previousSliderPosition - oldDelegate.sliderPosition;
    if (diff.abs() > 20) {
      _previousSliderPosition = sliderPosition;
    } else {
      _previousSliderPosition = oldDelegate.sliderPosition;
    }
    return true;
  }
}

class WaveCurveDefinitions {
  WaveCurveDefinitions({
    @required this.startOfBezier,
    @required this.endOfBezier,
    @required this.leftControlPoint1,
    @required this.leftControlPoint2,
    @required this.rightControlPoint1,
    @required this.rightControlPoint2,
    @required this.controlHeight,
    @required this.centerPoint,
  });

  double startOfBezier;
  double endOfBezier;
  double leftControlPoint1;
  double leftControlPoint2;
  double rightControlPoint1;
  double rightControlPoint2;
  double controlHeight;
  double centerPoint;
}
