import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/code_controller.dart';
import '../widgets/code_highlighter.dart';
import '../widgets/glass_panel.dart';

class CodeView extends StatelessWidget {
  const CodeView({super.key, required this.sketch});

  final Uint8List sketch;

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(CodeController(sketch));

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0.8, -1),
            radius: 1.4,
            colors: [Color(0xFF1E1240), Color(0xFF07070C)],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Column(
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
                      'Sketch to Flutter',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const Spacer(),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.memory(
                        sketch,
                        width: 44,
                        height: 66,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: Obx(() {
                    if (controller.loading.value) return const _Thinking();

                    final error = controller.error.value;
                    if (error != null) {
                      return _Problem(
                        message: error,
                        onRetry: controller.generate,
                      );
                    }

                    return GlassPanel(
                      radius: 22,
                      padding: EdgeInsets.zero,
                      child: Column(
                        children: [
                          _CodeHeader(
                            lines:
                                '\n'.allMatches(controller.code.value).length +
                                1,
                          ),
                          Expanded(
                            child: SingleChildScrollView(
                              padding: const EdgeInsets.all(16),
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: SelectableText.rich(
                                  CodeHighlighter.build(controller.code.value),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 14),
                Obx(
                  () => Row(
                    children: [
                      Expanded(
                        child: _ActionButton(
                          icon: Icons.refresh_rounded,
                          label: 'Again',
                          onTap: controller.loading.value
                              ? null
                              : controller.generate,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: _ActionButton(
                          icon: controller.copied.value
                              ? Icons.check_rounded
                              : Icons.copy_rounded,
                          label: controller.copied.value
                              ? 'Copied'
                              : 'Copy code',
                          filled: true,
                          onTap: controller.code.value.isEmpty
                              ? null
                              : controller.copy,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CodeHeader extends StatelessWidget {
  const _CodeHeader({required this.lines});

  final int lines;

  @override
  Widget build(BuildContext context) {
    Widget dot(Color c) => Container(
      width: 11,
      height: 11,
      margin: const EdgeInsets.only(right: 7),
      decoration: BoxDecoration(color: c, shape: BoxShape.circle),
    );

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
        ),
      ),
      child: Row(
        children: [
          dot(const Color(0xFFFF5F57)),
          dot(const Color(0xFFFEBC2E)),
          dot(const Color(0xFF28C840)),
          const SizedBox(width: 8),
          const Text(
            'main.dart',
            style: TextStyle(color: Colors.white70, fontSize: 13),
          ),
          const Spacer(),
          Text(
            '$lines lines',
            style: const TextStyle(color: Colors.white38, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _Thinking extends StatelessWidget {
  const _Thinking();

  @override
  Widget build(BuildContext context) {
    return const Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: 54,
          height: 54,
          child: CircularProgressIndicator(
            strokeWidth: 3,
            color: Color(0xFF22D3EE),
          ),
        ),
        SizedBox(height: 22),
        Text(
          'Reading your sketch...',
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
        ),
        SizedBox(height: 6),
        Text(
          'Turning shapes into widgets',
          style: TextStyle(color: Colors.white54),
        ),
      ],
    );
  }
}

class _Problem extends StatelessWidget {
  const _Problem({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.cloud_off_rounded,
            size: 52,
            color: Color(0xFFFF8FB5),
          ),
          const SizedBox(height: 14),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white70, height: 1.4),
          ),
          const SizedBox(height: 18),
          TextButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Try again'),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.filled = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: onTap == null ? 0.4 : 1,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 54,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            gradient: filled
                ? const LinearGradient(
                    colors: [Color(0xFF8B5CF6), Color(0xFF22D3EE)],
                  )
                : null,
            color: filled ? null : Colors.white.withValues(alpha: 0.08),
            border: filled ? null : Border.all(color: Colors.white12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 20, color: Colors.white),
              const SizedBox(width: 8),
              Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
            ],
          ),
        ),
      ),
    );
  }
}
