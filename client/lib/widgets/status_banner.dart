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
      BannerTone.success => (const Color(0xff047857), const Color(0xffecfdf5)),
      BannerTone.warning => (const Color(0xffb45309), const Color(0xfffffbeb)),
      BannerTone.error => (const Color(0xffb91c1c), const Color(0xfffef2f2)),
      BannerTone.info => (const Color(0xff0f172a), const Color(0xfff8fafc)),
    };
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: colors.$2,
        border: Border.all(color: colors.$1.withValues(alpha: 0.35)),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: colors.$1.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon ?? Icons.info_outline, color: colors.$1, size: 20),
          ),
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
