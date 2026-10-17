import 'dart:async';
import 'dart:io';
import 'dart:math' as math;

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:hand_landmarker/hand_landmarker.dart';

import '../utils/hand_gesture.dart';
import '../utils/nv21.dart';
import '../utils/one_euro_filter.dart';
import 'sketch_controller.dart';

class TrackingController extends GetxController {
  CameraController? camera;

  final ready = false.obs;
  final error = RxnString();
  final frameSize = Size.zero.obs;
  final handPoints = <Offset>[].obs;
  final fingertip = Rxn<Offset>();
  final gesture = HandGesture.idle.obs;
  final faceBox = Rxn<Rect>();
  final faceContours = <List<Offset>>[].obs;
  final clearProgress = 0.0.obs;

  final _meshDetector = FaceDetector(
    options: FaceDetectorOptions(
      enableContours: true,
      performanceMode: FaceDetectorMode.fast,
    ),
  );
  final _boxDetector = FaceDetector(
    options: FaceDetectorOptions(performanceMode: FaceDetectorMode.fast),
  );
  final _tipX = OneEuroFilter();
  final _tipY = OneEuroFilter();

  HandLandmarkerPlugin? _hands;
  StreamSubscription<List<Hand>>? _handSub;
  AppLifecycleListener? _lifecycle;

  Size _previewSize = Size.zero;
  int _sensor = 0;
  bool _front = true;
  bool _starting = false;
  bool _faceBusy = false;
  DateTime _lastFace = DateTime(0);
  DateTime _lastHandFrame = DateTime(0);
  DateTime _lastHand = DateTime(0);
  DateTime? _palmSince;
  HandGesture _candidate = HandGesture.idle;
  int _candidateFrames = 0;

  SketchController get _sketch => Get.find<SketchController>();

  @override
  void onInit() {
    super.onInit();
    _lifecycle = AppLifecycleListener(onPause: _stop, onResume: _start);

    if (!Platform.isAndroid) {
      error.value = 'Hand tracking is available on Android for now';
      return;
    }

    try {
      _hands = HandLandmarkerPlugin.create(
        numHands: 1,
        minHandDetectionConfidence: 0.6,
        delegate: HandLandmarkerDelegate.gpu,
      );
      _handSub = _hands!.landmarkStream.listen(_onHands);
    } catch (_) {
      error.value = 'Could not load the hand model';
      return;
    }

    _start();
  }

  Future<void> _start() async {
    if (_starting || camera != null || _hands == null) return;
    _starting = true;

    try {
      final cameras = await availableCameras();
      final selected = cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.front,
        orElse: () => cameras.first,
      );

      final controller = CameraController(
        selected,
        ResolutionPreset.medium,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.yuv420,
      );
      await controller.initialize();

      _sensor = selected.sensorOrientation;
      _front = selected.lensDirection == CameraLensDirection.front;
      _previewSize = controller.value.previewSize!;
      frameSize.value = Size(_previewSize.height, _previewSize.width);
      _sketch.canvasSize = frameSize.value;

      camera = controller;
      await controller.startImageStream(_onFrame);
      error.value = null;
      ready.value = true;
    } catch (_) {
      error.value = 'Camera is not available';
    } finally {
      _starting = false;
    }
  }

  Future<void> pause() => _stop();

  Future<void> resume() => _start();

  Future<void> _stop() async {
    final controller = camera;
    camera = null;
    ready.value = false;
    _loseHand();
    if (controller == null) return;

    try {
      if (controller.value.isStreamingImages) {
        await controller.stopImageStream();
      }
    } catch (_) {}
    await controller.dispose();
  }

  void _onFrame(CameraImage image) {
    final now = DateTime.now();

    if (now.difference(_lastHandFrame).inMilliseconds >= 33) {
      _lastHandFrame = now;
      try {
        _hands?.processFrame(image, _sensor);
      } catch (_) {}
    }

    if (handPoints.isNotEmpty &&
        now.difference(_lastHand).inMilliseconds > 350) {
      _loseHand();
    }

    if (!_faceBusy && now.difference(_lastFace).inMilliseconds > 250) {
      _lastFace = now;
      _detectFace(image);
    }
  }

  void _onHands(List<Hand> hands) {
    if (hands.isEmpty || frameSize.value.isEmpty) {
      _loseHand();
      return;
    }

    _lastHand = DateTime.now();
    final points = hands.first.landmarks.map(_mapHand).toList();
    handPoints.assignAll(points);

    final raw = GestureReader.read(points);
    if (raw == _candidate) {
      _candidateFrames++;
    } else {
      _candidate = raw;
      _candidateFrames = 1;
    }
    if (_candidateFrames >= 2) gesture.value = raw;

    final t = _lastHand.microsecondsSinceEpoch / 1e6;
    final tip = Offset(
      _tipX.filter(points[8].dx, t),
      _tipY.filter(points[8].dy, t),
    );
    fingertip.value = tip;

    if (!_sketch.touching) {
      if (gesture.value == HandGesture.draw) {
        _sketch.addPoint(tip);
      } else {
        _sketch.endStroke();
      }
    }

    _trackPalm();
  }

  void _trackPalm() {
    if (gesture.value != HandGesture.palm) {
      _palmSince = null;
      clearProgress.value = 0;
      return;
    }

    final now = DateTime.now();
    _palmSince ??= now;
    final held = now.difference(_palmSince!).inMilliseconds / 1500;
    clearProgress.value = held.clamp(0.0, 1.0);

    if (held >= 1) {
      _sketch.clear();
      _palmSince = now.add(const Duration(seconds: 1));
      clearProgress.value = 0;
    }
  }

  void _loseHand() {
    if (handPoints.isNotEmpty) handPoints.clear();
    fingertip.value = null;
    gesture.value = HandGesture.idle;
    clearProgress.value = 0;
    _palmSince = null;
    _candidateFrames = 0;
    _tipX.reset();
    _tipY.reset();
    if (Get.isRegistered<SketchController>() && !_sketch.touching) {
      _sketch.endStroke();
    }
  }

  Offset _mapHand(Landmark l) {
    var x = (l.x - 0.5) * _previewSize.width;
    var y = (l.y - 0.5) * _previewSize.height;
    if (_front) y = -y;

    final angle = _sensor * math.pi / 180;
    final cosA = math.cos(angle);
    final sinA = math.sin(angle);
    final frame = frameSize.value;

    return Offset(
      x * cosA - y * sinA + frame.width / 2,
      x * sinA + y * cosA + frame.height / 2,
    );
  }

  Future<void> _detectFace(CameraImage image) async {
    _faceBusy = true;
    try {
      final withMesh = _sketch.showMesh.value;
      final bytes = await compute(yuvToNv21, YuvFrame(image));
      final input = InputImage.fromBytes(
        bytes: bytes,
        metadata: InputImageMetadata(
          size: Size(image.width.toDouble(), image.height.toDouble()),
          rotation:
              InputImageRotationValue.fromRawValue(_sensor) ??
              InputImageRotation.rotation270deg,
          format: InputImageFormat.nv21,
          bytesPerRow: image.width,
        ),
      );

      final faces = await (withMesh ? _meshDetector : _boxDetector)
          .processImage(input);
      if (faces.isEmpty) {
        faceBox.value = null;
        faceContours.clear();
        return;
      }

      final face = faces.reduce(
        (a, b) => a.boundingBox.width >= b.boundingBox.width ? a : b,
      );
      final frame = frameSize.value;
      final sx = frame.width / image.height;
      final sy = frame.height / image.width;

      Offset map(double x, double y) =>
          Offset(_front ? frame.width - x * sx : x * sx, y * sy);

      final box = face.boundingBox;
      faceBox.value = Rect.fromPoints(
        map(box.left, box.top),
        map(box.right, box.bottom),
      );
      if (!withMesh) {
        faceContours.clear();
        return;
      }
      faceContours.assignAll(
        face.contours.values.whereType<FaceContour>().map(
          (c) =>
              c.points.map((p) => map(p.x.toDouble(), p.y.toDouble())).toList(),
        ),
      );
    } catch (_) {
      faceBox.value = null;
    } finally {
      _faceBusy = false;
    }
  }

  @override
  void onClose() {
    _lifecycle?.dispose();
    _handSub?.cancel();
    final hands = _hands;
    _hands = null;
    _stop().whenComplete(() => hands?.dispose());
    _meshDetector.close();
    _boxDetector.close();
    super.onClose();
  }
}
