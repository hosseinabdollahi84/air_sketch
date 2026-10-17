import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:gal/gal.dart';
import 'package:get/get.dart';

import '../models/stroke.dart';
import '../views/code_view.dart';
import '../views/settings_view.dart';
import '../widgets/sketch_painter.dart';
import 'settings_controller.dart';
import 'tracking_controller.dart';

class SketchController extends GetxController {
  static const palette = [
    Color(0xFFFF3D8B),
    Color(0xFF22D3EE),
    Color(0xFFA3E635),
    Color(0xFFFBBF24),
    Color(0xFF8B5CF6),
    Color(0xFFFF6B4A),
    Color(0xFF3B82F6),
    Color(0xFFFFFFFF),
  ];

  final strokes = <Stroke>[].obs;
  final color = palette.first.obs;
  final brush = 7.0.obs;
  final glow = true.obs;
  final showMesh = true.obs;
  final saving = false.obs;
  final tick = 0.obs;

  bool touching = false;
  Size canvasSize = Size.zero;
  ui.Image? baked;

  Stroke? _active;
  Stroke? get active => _active;

  void addPoint(Offset point) {
    final stroke = _active;
    if (stroke == null) {
      _active = Stroke(
        points: [point],
        color: color.value,
        width: brush.value,
        glow: glow.value,
      );
    } else {
      if ((stroke.points.last - point).distance < 1.2) return;
      stroke.points.add(point);
    }
    tick.value++;
  }

  void endStroke() {
    final stroke = _active;
    if (stroke == null) return;
    _active = null;
    strokes.add(stroke);
    _bake();
  }

  void undo() {
    if (_active != null) {
      _active = null;
    } else if (strokes.isNotEmpty) {
      strokes.removeLast();
    }
    _bake();
  }

  void clear() {
    _active = null;
    strokes.clear();
    _bake();
  }

  void _bake() {
    if (strokes.isEmpty || canvasSize.isEmpty) {
      baked = null;
    } else {
      const scale = 2.0;
      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder)..scale(scale);
      SketchPainter(strokes, null).paint(canvas, canvasSize);
      baked = recorder.endRecording().toImageSync(
        (canvasSize.width * scale).round(),
        (canvasSize.height * scale).round(),
      );
    }
    tick.value++;
  }

  Future<Uint8List?> renderPng(Size size) async {
    if (size.isEmpty) return null;

    const scale = 2.0;
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder)..scale(scale);
    final area = Offset.zero & size;

    canvas.drawRect(
      area,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0B0B14), Color(0xFF161328)],
        ).createShader(area),
    );
    SketchPainter(strokes, null).paint(canvas, size);

    final image = await recorder.endRecording().toImage(
      (size.width * scale).round(),
      (size.height * scale).round(),
    );
    final data = await image.toByteData(format: ui.ImageByteFormat.png);
    return data?.buffer.asUint8List();
  }

  Future<void> save(Size size) async {
    if (strokes.isEmpty || saving.value) return;
    saving.value = true;

    try {
      if (!await Gal.hasAccess() && !await Gal.requestAccess()) {
        _toast('No access', 'Allow gallery access to save your sketch');
        return;
      }

      final bytes = await renderPng(size);
      if (bytes == null) return;

      await Gal.putImageBytes(
        bytes,
        name: 'airsketch_${DateTime.now().millisecondsSinceEpoch}',
      );
      _toast('Saved', 'Your sketch is in the gallery');
    } catch (_) {
      _toast('Oops', 'Could not save the sketch');
    } finally {
      saving.value = false;
    }
  }

  Future<void> openCode(Size size) async {
    if (!Get.find<SettingsController>().hasKey) {
      _toast('API key needed', 'Add your OpenAI key first');
      await _away(() => const SettingsView());
      return;
    }
    if (strokes.isEmpty) {
      _toast('Nothing to read', 'Draw a screen layout first');
      return;
    }

    final bytes = await renderPng(size);
    if (bytes == null) return;
    await _away(() => CodeView(sketch: bytes));
  }

  Future<void> openSettings() => _away(() => const SettingsView());

  Future<void> _away(Widget Function() page) async {
    final tracking = Get.find<TrackingController>();
    await tracking.pause();
    await Get.to(page, transition: Transition.downToUp);
    await tracking.resume();
  }

  void _toast(String title, String message) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.black.withValues(alpha: 0.6),
      colorText: Colors.white,
      margin: const EdgeInsets.all(16),
      borderRadius: 18,
      duration: const Duration(seconds: 2),
    );
  }
}
