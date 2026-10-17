import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../utils/hand_gesture.dart';

class TrackingPainter extends CustomPainter {
  TrackingPainter({
    required this.hand,
    required this.tip,
    required this.gesture,
    required this.faceBox,
    required this.faceContours,
    required this.showMesh,
    required this.color,
    required this.brush,
    required this.clearProgress,
  });

  final List<Offset> hand;
  final Offset? tip;
  final HandGesture gesture;
  final Rect? faceBox;
  final List<List<Offset>> faceContours;
  final bool showMesh;
  final Color color;
  final double brush;
  final double clearProgress;

  static const _cyan = Color(0xFF22D3EE);
  static const _violet = Color(0xFF8B5CF6);

  @override
  void paint(Canvas canvas, Size size) {
    if (showMesh) {
      _paintFace(canvas);
      _paintHand(canvas);
    }
    _paintCursor(canvas);
    _paintClearRing(canvas);
  }

  void _paintFace(Canvas canvas) {
    final box = faceBox;
    if (box == null) return;

    final mesh = Paint()
      ..color = _cyan.withValues(alpha: 0.45)
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;
    final dot = Paint()..color = Colors.white.withValues(alpha: 0.7);

    for (final contour in faceContours) {
      if (contour.length < 2) continue;
      canvas.drawPath(Path()..addPolygon(contour, false), mesh);
      for (final p in contour) {
        canvas.drawCircle(p, 1.3, dot);
      }
    }

    final corner = Paint()
      ..color = _cyan
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final len = math.min(box.width, box.height) * 0.18;
    final r = box.inflate(10);

    for (final c in [r.topLeft, r.topRight, r.bottomLeft, r.bottomRight]) {
      final dx = c.dx == r.left ? len : -len;
      final dy = c.dy == r.top ? len : -len;
      canvas.drawLine(c, c.translate(dx, 0), corner);
      canvas.drawLine(c, c.translate(0, dy), corner);
    }
  }

  void _paintHand(Canvas canvas) {
    if (hand.length < 21) return;

    final bone = Paint()
      ..shader = const LinearGradient(
        colors: [_violet, _cyan],
      ).createShader(Rect.fromPoints(hand[0], hand[12]))
      ..strokeWidth = 2.4
      ..strokeCap = StrokeCap.round;
    for (final b in GestureReader.bones) {
      canvas.drawLine(hand[b[0]], hand[b[1]], bone);
    }

    final joint = Paint()..color = Colors.white;
    final ring = Paint()
      ..color = _violet
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6;
    for (final p in hand) {
      canvas.drawCircle(p, 3, joint);
      canvas.drawCircle(p, 5, ring);
    }
  }

  void _paintCursor(Canvas canvas) {
    final p = tip;
    if (p == null) return;

    final drawing = gesture == HandGesture.draw;
    final radius = math.max(brush / 2 + 6, 10.0);

    canvas.drawCircle(
      p,
      radius + 6,
      Paint()
        ..color = color.withValues(alpha: drawing ? 0.35 : 0.15)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10),
    );
    canvas.drawCircle(
      p,
      radius,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.2,
    );
    canvas.drawCircle(
      p,
      drawing ? brush / 2 : 2.5,
      Paint()..color = drawing ? color : Colors.white,
    );
  }

  void _paintClearRing(Canvas canvas) {
    if (clearProgress <= 0 || hand.length < 21) return;

    final center = hand[9];
    final rect = Rect.fromCircle(center: center, radius: 42);
    canvas.drawCircle(
      center,
      42,
      Paint()
        ..color = Colors.white24
        ..style = PaintingStyle.stroke
        ..strokeWidth = 5,
    );
    canvas.drawArc(
      rect,
      -math.pi / 2,
      math.pi * 2 * clearProgress,
      false,
      Paint()
        ..color = const Color(0xFFFF3D8B)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 5
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(covariant TrackingPainter oldDelegate) => true;
}
