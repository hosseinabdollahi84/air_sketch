import 'dart:ui';

class Stroke {
  Stroke({
    required this.points,
    required this.color,
    required this.width,
    required this.glow,
  });

  final List<Offset> points;
  final Color color;
  final double width;
  final bool glow;
}
