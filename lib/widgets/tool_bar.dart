import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/sketch_controller.dart';
import '../controllers/tracking_controller.dart';
import 'glass_panel.dart';

class ToolBar extends StatelessWidget {
  const ToolBar({super.key});

  @override
  Widget build(BuildContext context) {
    final sketch = Get.find<SketchController>();
    final tracking = Get.find<TrackingController>();

    return GlassPanel(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: 38,
            child: Obx(
              () => Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  for (final c in SketchController.palette)
                    _ColorDot(
                      color: c,
                      selected: sketch.color.value == c,
                      onTap: () => sketch.color.value = c,
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Obx(
            () => Row(
              children: [
                const Icon(
                  Icons.brush_rounded,
                  size: 18,
                  color: Colors.white54,
                ),
                Expanded(
                  child: Slider(
                    value: sketch.brush.value,
                    min: 2,
                    max: 24,
                    activeColor: sketch.color.value,
                    inactiveColor: Colors.white12,
                    onChanged: (v) => sketch.brush.value = v,
                  ),
                ),
                SizedBox(
                  width: 28,
                  child: Center(
                    child: Container(
                      width: sketch.brush.value,
                      height: sketch.brush.value,
                      decoration: BoxDecoration(
                        color: sketch.color.value,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Obx(
            () => Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _ToolButton(
                  icon: Icons.undo_rounded,
                  label: 'Undo',
                  onTap: sketch.undo,
                ),
                _ToolButton(
                  icon: Icons.delete_sweep_rounded,
                  label: 'Clear',
                  onTap: sketch.clear,
                ),
                _ToolButton(
                  icon: Icons.auto_awesome_rounded,
                  label: 'Neon',
                  active: sketch.glow.value,
                  onTap: sketch.glow.toggle,
                ),
                _ToolButton(
                  icon: Icons.code_rounded,
                  label: 'Code',
                  active: true,
                  onTap: () => sketch.openCode(tracking.frameSize.value),
                ),
                _ToolButton(
                  icon: Icons.blur_on_rounded,
                  label: 'Mesh',
                  active: sketch.showMesh.value,
                  onTap: sketch.showMesh.toggle,
                ),
                _ToolButton(
                  icon: sketch.saving.value
                      ? Icons.hourglass_top_rounded
                      : Icons.download_rounded,
                  label: 'Save',
                  onTap: () => sketch.save(tracking.frameSize.value),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ColorDot extends StatelessWidget {
  const _ColorDot({
    required this.color,
    required this.selected,
    required this.onTap,
  });

  final Color color;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: selected ? 34 : 26,
        height: selected ? 34 : 26,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color: selected ? Colors.white : Colors.transparent,
            width: 2.5,
          ),
          boxShadow: [
            if (selected)
              BoxShadow(color: color.withValues(alpha: 0.8), blurRadius: 14),
          ],
        ),
      ),
    );
  }
}

class _ToolButton extends StatelessWidget {
  const _ToolButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.active = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final color = active ? const Color(0xFF22D3EE) : Colors.white;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: color.withValues(alpha: 0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
