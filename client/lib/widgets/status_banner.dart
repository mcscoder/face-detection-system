import 'package:flutter/material.dart';

class StatusBanner extends StatelessWidget {
  const StatusBanner({
    super.key,
    required this.label,
    required this.tone,
    this.icon,
  });

  final String label;
  final BannerTone tone;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final colors = switch (tone) {
      BannerTone.success => (const Color(0xff166534), const Color(0xffdcfce7)),
      BannerTone.warning => (const Color(0xff92400e), const Color(0xfffffbeb)),
      BannerTone.error => (const Color(0xff991b1b), const Color(0xfffee2e2)),
      BannerTone.info => (const Color(0xff1f2937), const Color(0xfff3f4f6)),
    };
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colors.$2,
        border: Border.all(color: colors.$1.withValues(alpha: 0.35)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon ?? Icons.info_outline, color: colors.$1),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: TextStyle(color: colors.$1, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

enum BannerTone { success, warning, error, info }
