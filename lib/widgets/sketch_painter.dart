import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../models/stroke.dart';

class SketchPainter extends CustomPainter {
  SketchPainter(this.strokes, this.active, {this.baked});

  final List<Stroke> strokes;
  final Stroke? active;
  final ui.Image? baked;

  @override
  void paint(Canvas canvas, Size size) {
    final image = baked;
    if (image != null) {
      canvas.drawImageRect(
        image,
        Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble()),
        Offset.zero & size,
        Paint()..filterQuality = FilterQuality.medium,
      );
    } else {
      for (final stroke in strokes) {
        _drawStroke(canvas, stroke);
      }
    }
    if (active != null) _drawStroke(canvas, active!);
  }

  void _drawStroke(Canvas canvas, Stroke stroke) {
    final points = stroke.points;
    if (points.isEmpty) return;

    if (points.length == 1) {
      final dot = points.first;
      if (stroke.glow) {
        canvas.drawCircle(
          dot,
          stroke.width,
          Paint()
            ..color = stroke.color.withValues(alpha: 0.55)
            ..maskFilter = MaskFilter.blur(BlurStyle.normal, stroke.width),
        );
      }
      canvas.drawCircle(dot, stroke.width / 2, Paint()..color = stroke.color);
      return;
    }

    final path = Path()..moveTo(points.first.dx, points.first.dy);
    for (var i = 1; i < points.length - 1; i++) {
      final mid = Offset.lerp(points[i], points[i + 1], 0.5)!;
      path.quadraticBezierTo(points[i].dx, points[i].dy, mid.dx, mid.dy);
    }
    path.lineTo(points.last.dx, points.last.dy);

    Paint line(Color color, double width) => Paint()
      ..color = color
      ..strokeWidth = width
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..isAntiAlias = true;

    if (stroke.glow) {
      canvas.drawPath(
        path,
        line(stroke.color.withValues(alpha: 0.6), stroke.width * 2.4)
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, stroke.width),
      );
    }
    canvas.drawPath(path, line(stroke.color, stroke.width));
    if (stroke.glow) {
      canvas.drawPath(
        path,
        line(Colors.white.withValues(alpha: 0.8), stroke.width * 0.35),
      );
    }
  }

  @override
  bool shouldRepaint(covariant SketchPainter oldDelegate) => true;
}
