import 'dart:math' as math;

class OneEuroFilter {
  OneEuroFilter({this.minCutoff = 1.0, this.beta = 0.012, this.dCutoff = 1.0});

  final double minCutoff;
  final double beta;
  final double dCutoff;

  double? _x;
  double _dx = 0;
  double? _t;

  double _alpha(double cutoff, double dt) {
    final tau = 1 / (2 * math.pi * cutoff);
    return 1 / (1 + tau / dt);
  }

  double filter(double value, double time) {
    final prevX = _x;
    final prevT = _t;
    if (prevX == null || prevT == null) {
      _x = value;
      _t = time;
      return value;
    }

    final dt = math.max(time - prevT, 1e-3);
    final speed = (value - prevX) / dt;
    _dx += _alpha(dCutoff, dt) * (speed - _dx);

    final cutoff = minCutoff + beta * _dx.abs();
    final x = prevX + _alpha(cutoff, dt) * (value - prevX);

    _x = x;
    _t = time;
    return x;
  }

  void reset() {
    _x = null;
    _t = null;
    _dx = 0;
  }
}
