import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';

class SettingsController extends GetxController {
  static const defaultModel = 'gpt-5-mini';

  final _storage = const FlutterSecureStorage();

  final apiKey = ''.obs;
  final model = defaultModel.obs;

  bool get hasKey => apiKey.value.trim().isNotEmpty;

  @override
  void onInit() {
    super.onInit();
    _load();
  }

  Future<void> _load() async {
    apiKey.value = await _storage.read(key: 'openai_key') ?? '';
    model.value = await _storage.read(key: 'openai_model') ?? defaultModel;
  }

  Future<void> save(String key, String newModel) async {
    apiKey.value = key.trim();
    model.value = newModel.trim().isEmpty ? defaultModel : newModel.trim();
    await _storage.write(key: 'openai_key', value: apiKey.value);
    await _storage.write(key: 'openai_model', value: model.value);
  }

  Future<void> removeKey() async {
    apiKey.value = '';
    await _storage.delete(key: 'openai_key');
  }
}
