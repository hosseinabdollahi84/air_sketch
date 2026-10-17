import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';

import '../views/sketch_view.dart';

class PermissionController extends GetxController {
  final denied = false.obs;
  final blocked = false.obs;

  late final AppLifecycleListener _lifecycle;
  bool _leaving = false;

  @override
  void onInit() {
    super.onInit();
    _lifecycle = AppLifecycleListener(onResume: check);
  }

  @override
  void onReady() {
    super.onReady();
    check();
  }

  Future<void> check() async {
    if (await Permission.camera.isGranted) _openSketch();
  }

  Future<void> ask() async {
    if (blocked.value) {
      await openAppSettings();
      return;
    }

    final status = await Permission.camera.request();
    if (status.isGranted) {
      _openSketch();
      return;
    }

    denied.value = true;
    blocked.value = status.isPermanentlyDenied;
  }

  void _openSketch() {
    if (_leaving) return;
    _leaving = true;
    Get.off(
      () => const SketchView(),
      transition: Transition.fadeIn,
      duration: const Duration(milliseconds: 450),
    );
  }

  @override
  void onClose() {
    _lifecycle.dispose();
    super.onClose();
  }
}
