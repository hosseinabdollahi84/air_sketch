import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/sketch_controller.dart';
import '../controllers/tracking_controller.dart';
import '../widgets/sketch_painter.dart';
import '../widgets/tool_bar.dart';
import '../widgets/top_bar.dart';
import '../widgets/tracking_painter.dart';

class SketchView extends StatelessWidget {
  const SketchView({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(SketchController());
    Get.put(TrackingController());

    return Scaffold(
      body: Stack(
        children: [
          const Positioned.fill(child: _CameraLayer()),
          const Positioned.fill(
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: [0, 0.2, 0.7, 1],
                    colors: [
                      Color(0xAA000000),
                      Colors.transparent,
                      Colors.transparent,
                      Color(0xCC000000),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: EdgeInsets.fromLTRB(20, 12, 20, 0),
                child: TopBar(),
              ),
            ),
          ),
          const Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: SafeArea(
              child: Padding(
                padding: EdgeInsets.fromLTRB(14, 0, 14, 12),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [_Hints(), SizedBox(height: 12), ToolBar()],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CameraLayer extends StatelessWidget {
  const _CameraLayer();

  @override
  Widget build(BuildContext context) {
    final tracking = Get.find<TrackingController>();
    final sketch = Get.find<SketchController>();

    return Obx(() {
      final error = tracking.error.value;
      if (error != null) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Text(
              error,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white70, fontSize: 16),
            ),
          ),
        );
      }

      final camera = tracking.camera;
      if (!tracking.ready.value || camera == null) {
        return const Center(
          child: CircularProgressIndicator(color: Color(0xFF8B5CF6)),
        );
      }

      return FittedBox(
        fit: BoxFit.cover,
        clipBehavior: Clip.hardEdge,
        child: SizedBox.fromSize(
          size: tracking.frameSize.value,
          child: GestureDetector(
            onPanStart: (d) {
              sketch.endStroke();
              sketch.touching = true;
              sketch.addPoint(d.localPosition);
            },
            onPanUpdate: (d) => sketch.addPoint(d.localPosition),
            onPanEnd: (_) => _liftFinger(sketch),
            onPanCancel: () => _liftFinger(sketch),
            child: Stack(
              fit: StackFit.expand,
              children: [
                CameraPreview(camera),
                RepaintBoundary(
                  child: Obx(
                    () => CustomPaint(
                      painter: TrackingPainter(
                        hand: tracking.handPoints.toList(),
                        tip: tracking.fingertip.value,
                        gesture: tracking.gesture.value,
                        faceBox: tracking.faceBox.value,
                        faceContours: tracking.faceContours.toList(),
                        showMesh: sketch.showMesh.value,
                        color: sketch.color.value,
                        brush: sketch.brush.value,
                        clearProgress: tracking.clearProgress.value,
                      ),
                    ),
                  ),
                ),
                RepaintBoundary(
                  child: Obx(() {
                    sketch.tick.value;
                    return CustomPaint(
                      painter: SketchPainter(
                        sketch.strokes.toList(),
                        sketch.active,
                        baked: sketch.baked,
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

  void _liftFinger(SketchController sketch) {
    sketch.endStroke();
    sketch.touching = false;
  }
}

class _Hints extends StatelessWidget {
  const _Hints();

  @override
  Widget build(BuildContext context) {
    const style = TextStyle(fontSize: 12, color: Colors.white60);

    return const Wrap(
      alignment: WrapAlignment.center,
      spacing: 16,
      runSpacing: 4,
      children: [
        Text('☝️  draw', style: style),
        Text('✌️  move', style: style),
        Text('🖐  hold to clear', style: style),
        Text('👆  touch works too', style: style),
      ],
    );
  }
}
