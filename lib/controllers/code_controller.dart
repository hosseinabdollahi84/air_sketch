import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../services/openai_service.dart';
import 'settings_controller.dart';

class CodeController extends GetxController {
  CodeController(this.sketch);

  final Uint8List sketch;
  final _service = OpenAiService();

  final loading = false.obs;
  final code = ''.obs;
  final error = RxnString();
  final copied = false.obs;

  @override
  void onReady() {
    super.onReady();
    generate();
  }

  Future<void> generate() async {
    if (loading.value) return;
    final settings = Get.find<SettingsController>();

    loading.value = true;
    error.value = null;
    try {
      code.value = await _service.sketchToFlutter(
        apiKey: settings.apiKey.value,
        model: settings.model.value,
        image: sketch,
      );
      if (code.value.isEmpty) {
        error.value = 'The model sent back an empty answer';
      }
    } catch (e) {
      error.value = e.toString().replaceFirst('Exception: ', '');
    } finally {
      loading.value = false;
    }
  }

  Future<void> copy() async {
    if (code.value.isEmpty) return;
    await Clipboard.setData(ClipboardData(text: code.value));
    copied.value = true;
    await Future.delayed(const Duration(seconds: 2));
    copied.value = false;
  }
}
