import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/sketch_controller.dart';
import '../controllers/tracking_controller.dart';
import '../utils/hand_gesture.dart';

import 'glass_panel.dart';

class TopBar extends StatelessWidget {
  const TopBar({super.key});

  @override
  Widget build(BuildContext context) {
    final tracking = Get.find<TrackingController>();

    return Column(
      children: [
        Row(
          children: [
            ShaderMask(
              shaderCallback: (r) => const LinearGradient(
                colors: [Color(0xFFFF3D8B), Color(0xFF22D3EE)],
              ).createShader(r),
              child: const Text(
                'AirSketch',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.6,
                  color: Colors.white,
                ),
              ),
            ),
            const Spacer(),
            Obx(
              () => _Chip(
                icon: Icons.face_rounded,
                label: 'Face',
                on: tracking.faceBox.value != null,
              ),
            ),
            const SizedBox(width: 8),
            Obx(
              () => _Chip(
                icon: Icons.back_hand_rounded,
                label: 'Hand',
                on: tracking.handPoints.isNotEmpty,
              ),
            ),
            const SizedBox(width: 4),
            IconButton(
              onPressed: Get.find<SketchController>().openSettings,
              icon: const Icon(Icons.tune_rounded, color: Colors.white70),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Obx(() {
          final hasHand = tracking.handPoints.isNotEmpty;
          final (text, color) = switch (tracking.gesture.value) {
            _ when !hasHand => ('Show your hand to the camera', Colors.white70),
            HandGesture.draw => ('Drawing', const Color(0xFFFF3D8B)),
            HandGesture.hover => ('Moving the pen', const Color(0xFF22D3EE)),
            HandGesture.palm => (
              'Hold your palm to clear',
              const Color(0xFFFBBF24),
            ),
            HandGesture.idle => ('Point your index finger', Colors.white70),
          };

          return GlassPanel(
            radius: 30,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    boxShadow: [BoxShadow(color: color, blurRadius: 8)],
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  text,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.icon, required this.label, required this.on});

  final IconData icon;
  final String label;
  final bool on;

  @override
  Widget build(BuildContext context) {
    final color = on ? const Color(0xFFA3E635) : Colors.white38;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: on
            ? const Color(0xFFA3E635).withValues(alpha: 0.14)
            : Colors.black.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.6)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 15, color: color),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
