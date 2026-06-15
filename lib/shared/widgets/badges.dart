import 'package:flutter/material.dart';

import '../../domain/models/stay_record.dart';
import '../theme/app_theme.dart';

class SourceBadge extends StatelessWidget {
  const SourceBadge({super.key, required this.source});

  final RecordSource source;

  @override
  Widget build(BuildContext context) {
    return _Badge(
      label: source.label,
      color: source == RecordSource.manual ? Colors.blueGrey : AppColors.teal,
    );
  }
}

class ConfirmationBadge extends StatelessWidget {
  const ConfirmationBadge({super.key, required this.status});

  final ConfirmationStatus status;

  @override
  Widget build(BuildContext context) {
    final color = switch (status) {
      ConfirmationStatus.confirmed => AppColors.teal,
      ConfirmationStatus.needsConfirmation => Colors.orange,
      ConfirmationStatus.rejected => AppColors.muted,
    };
    return _Badge(label: status.label, color: color);
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
