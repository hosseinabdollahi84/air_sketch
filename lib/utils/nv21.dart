import 'dart:typed_data';

import 'package:camera/camera.dart';

class YuvFrame {
  YuvFrame(CameraImage image)
    : width = image.width,
      height = image.height,
      y = image.planes[0].bytes,
      yRow = image.planes[0].bytesPerRow,
      u = image.planes[1].bytes,
      uRow = image.planes[1].bytesPerRow,
      v = image.planes[2].bytes,
      vRow = image.planes[2].bytesPerRow,
      pixelStride = image.planes[1].bytesPerPixel ?? 1;

  final int width;
  final int height;
  final Uint8List y;
  final int yRow;
  final Uint8List u;
  final int uRow;
  final Uint8List v;
  final int vRow;
  final int pixelStride;
}

Uint8List yuvToNv21(YuvFrame f) {
  final out = Uint8List(f.width * f.height * 3 ~/ 2);

  for (var row = 0; row < f.height; row++) {
    out.setRange(row * f.width, row * f.width + f.width, f.y, row * f.yRow);
  }

  var i = f.width * f.height;
  for (var row = 0; row < f.height ~/ 2; row++) {
    final uStart = row * f.uRow;
    final vStart = row * f.vRow;
    for (var col = 0; col < f.width ~/ 2; col++) {
      out[i++] = f.v[vStart + col * f.pixelStride];
      out[i++] = f.u[uStart + col * f.pixelStride];
    }
  }
  return out;
}
