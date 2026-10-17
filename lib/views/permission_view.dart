import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/permission_controller.dart';

class PermissionView extends StatelessWidget {
  const PermissionView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(PermissionController());

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0, -0.35),
            radius: 1.1,
            colors: [Color(0xFF1E1240), Color(0xFF07070C)],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
            child: Column(
              children: [
                const Spacer(),
                const _Orb(),
                const SizedBox(height: 48),
                ShaderMask(
                  shaderCallback: (r) => const LinearGradient(
                    colors: [
                      Color(0xFFFF3D8B),
                      Color(0xFF8B5CF6),
                      Color(0xFF22D3EE),
                    ],
                  ).createShader(r),
                  child: const Text(
                    'AirSketch',
                    style: TextStyle(
                      fontSize: 46,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -1.5,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                const Text(
                  'Raise your finger and draw in the air.\nYour selfie camera turns into a canvas.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    height: 1.5,
                    color: Colors.white70,
                  ),
                ),
                const Spacer(),
                Obx(
                  () => AnimatedOpacity(
                    opacity: controller.denied.value ? 1 : 0,
                    duration: const Duration(milliseconds: 250),
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: Text(
                        controller.blocked.value
                            ? 'Camera is blocked. Turn it on from settings.'
                            : 'AirSketch needs the camera to see your hand.',
                        style: const TextStyle(color: Color(0xFFFF8FB5)),
                      ),
                    ),
                  ),
                ),
                Obx(
                  () => _GlowButton(
                    label: controller.blocked.value
                        ? 'Open settings'
                        : 'Allow camera',
                    icon: controller.blocked.value
                        ? Icons.settings_rounded
                        : Icons.photo_camera_front_rounded,
                    onTap: controller.ask,
                  ),
                ),
                const SizedBox(height: 18),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.lock_outline_rounded,
                      size: 14,
                      color: Colors.white38,
                    ),
                    SizedBox(width: 6),
                    Text(
                      'Everything runs on your phone',
                      style: TextStyle(fontSize: 13, color: Colors.white38),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Orb extends StatefulWidget {
  const _Orb();

  @override
  State<_Orb> createState() => _OrbState();
}

class _OrbState extends State<_Orb> with SingleTickerProviderStateMixin {
  late final AnimationController _spin = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 6),
  )..repeat();

  @override
  void dispose() {
    _spin.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _spin,
      builder: (context, child) {
        final pulse = 1 + math.sin(_spin.value * math.pi * 4) * 0.03;
        return Transform.scale(
          scale: pulse,
          child: Container(
            width: 190,
            height: 190,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: SweepGradient(
                transform: GradientRotation(_spin.value * math.pi * 2),
                colors: const [
                  Color(0xFFFF3D8B),
                  Color(0xFF8B5CF6),
                  Color(0xFF22D3EE),
                  Color(0xFFA3E635),
                  Color(0xFFFF3D8B),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF8B5CF6).withValues(alpha: 0.55),
                  blurRadius: 70,
                  spreadRadius: 6,
                ),
              ],
            ),
            padding: const EdgeInsets.all(4),
            child: child,
          ),
        );
      },
      child: Container(
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Color(0xFF0D0B18),
        ),
        child: const Icon(Icons.draw_rounded, size: 76, color: Colors.white),
      ),
    );
  }
}

class _GlowButton extends StatelessWidget {
  const _GlowButton({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 60,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: const LinearGradient(
            colors: [Color(0xFF8B5CF6), Color(0xFF22D3EE)],
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF8B5CF6).withValues(alpha: 0.5),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 10),
            Text(
              label,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
