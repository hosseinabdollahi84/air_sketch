import 'dart:ui';

enum HandGesture { idle, draw, hover, palm }

class GestureReader {
  static const bones = [
    [0, 1],
    [1, 2],
    [2, 3],
    [3, 4],
    [0, 5],
    [5, 6],
    [6, 7],
    [7, 8],
    [5, 9],
    [9, 10],
    [10, 11],
    [11, 12],
    [9, 13],
    [13, 14],
    [14, 15],
    [15, 16],
    [13, 17],
    [0, 17],
    [17, 18],
    [18, 19],
    [19, 20],
  ];

  static bool _isUp(List<Offset> p, int tip, int joint) {
    final wrist = p[0];
    return (p[tip] - wrist).distance > (p[joint] - wrist).distance * 1.12;
  }

  static HandGesture read(List<Offset> p) {
    if (p.length < 21) return HandGesture.idle;

    final index = _isUp(p, 8, 6);
    final middle = _isUp(p, 12, 10);
    final ring = _isUp(p, 16, 14);
    final pinky = _isUp(p, 20, 18);

    if (index && middle && ring && pinky) return HandGesture.palm;
    if (index && !middle && !ring) return HandGesture.draw;
    if (index && middle) return HandGesture.hover;
    return HandGesture.idle;
  }
}
