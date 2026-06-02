import 'package:flutter/material.dart';

import 'manager_ui.dart';

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
      BannerTone.success => (managerGreen, const Color(0xfff0fff4)),
      BannerTone.warning => (managerOrange, const Color(0xfffffbf0)),
      BannerTone.error => (managerRed, const Color(0xfffff1f0)),
      BannerTone.info => (managerBlue, const Color(0xfff2f8ff)),
    };
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: colors.$2,
        border: Border.all(color: colors.$1.withValues(alpha: 0.2)),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 18,
            offset: const Offset(0, 10),
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
              style: TextStyle(color: colors.$1, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}

enum BannerTone { success, warning, error, info }
