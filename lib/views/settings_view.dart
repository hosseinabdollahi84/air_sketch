import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/settings_controller.dart';
import '../widgets/glass_panel.dart';

class SettingsView extends StatefulWidget {
  const SettingsView({super.key});

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  final settings = Get.find<SettingsController>();
  late final keyField = TextEditingController(text: settings.apiKey.value);
  late final modelField = TextEditingController(text: settings.model.value);
  bool hidden = true;

  @override
  void dispose() {
    keyField.dispose();
    modelField.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    await settings.save(keyField.text, modelField.text);
    Get.back();
    Get.snackbar(
      'Saved',
      'OpenAI settings are ready',
      backgroundColor: Colors.black.withValues(alpha: 0.6),
      colorText: Colors.white,
      margin: const EdgeInsets.all(16),
      borderRadius: 18,
      duration: const Duration(seconds: 2),
    );
  }

  InputDecoration _input(String label, IconData icon, {Widget? suffix}) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, size: 20),
      suffixIcon: suffix,
      filled: true,
      fillColor: Colors.black.withValues(alpha: 0.25),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(-0.8, -1),
            radius: 1.4,
            colors: [Color(0xFF1E1240), Color(0xFF07070C)],
          ),
        ),
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: Get.back,
                    icon: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      size: 20,
                    ),
                  ),
                  const Text(
                    'Settings',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              GlassPanel(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'OpenAI',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Used to turn your sketch into Flutter code.',
                      style: TextStyle(color: Colors.white54),
                    ),
                    const SizedBox(height: 18),
                    TextField(
                      controller: keyField,
                      obscureText: hidden,
                      autocorrect: false,
                      enableSuggestions: false,
                      decoration: _input(
                        'API key',
                        Icons.key_rounded,
                        suffix: IconButton(
                          onPressed: () => setState(() => hidden = !hidden),
                          icon: Icon(
                            hidden
                                ? Icons.visibility_rounded
                                : Icons.visibility_off_rounded,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: modelField,
                      autocorrect: false,
                      decoration: _input('Model', Icons.memory_rounded),
                    ),
                    const SizedBox(height: 14),
                    const Row(
                      children: [
                        Icon(
                          Icons.lock_outline_rounded,
                          size: 14,
                          color: Colors.white38,
                        ),
                        SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            'Your key is kept in secure storage on this phone only.',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white38,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                height: 54,
                child: FilledButton(
                  onPressed: _save,
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF8B5CF6),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  child: const Text(
                    'Save',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              Obx(
                () => settings.hasKey
                    ? TextButton(
                        onPressed: () {
                          settings.removeKey();
                          keyField.clear();
                        },
                        child: const Text(
                          'Remove key',
                          style: TextStyle(color: Color(0xFFFF8FB5)),
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
