import 'package:air_sketch/widgets/code_highlighter.dart';
import 'package:air_sketch/utils/hand_gesture.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('highlighter keeps the original text', () {
    const code =
        "import 'package:x/x.dart';\n// hi\nclass A extends B { final n = 3.5; }";
    expect(CodeHighlighter.build(code).toPlainText(), code);
  });

  test('pointing finger reads as draw', () {
    final p = List.generate(21, (_) => const Offset(0, 0));
    p[6] = const Offset(0, -50);
    p[8] = const Offset(0, -100);
    for (final j in [10, 14, 18]) {
      p[j] = const Offset(0, -50);
    }
    for (final t in [12, 16, 20]) {
      p[t] = const Offset(0, -30);
    }
    expect(GestureReader.read(p), HandGesture.draw);
    p[12] = const Offset(0, -100);
    expect(GestureReader.read(p), HandGesture.hover);
    p[16] = const Offset(0, -100);
    p[20] = const Offset(0, -100);
    expect(GestureReader.read(p), HandGesture.palm);
  });
}
