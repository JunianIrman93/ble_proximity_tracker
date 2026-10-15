import 'package:flutter/material.dart';

import 'package:ble_proximity_tracker/core/widgets/neu.dart';

class EmptyView extends StatelessWidget {
  const EmptyView({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
  });

  final IconData icon;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          NeuBox(
            circle: true,
            depth: 8,
            child: SizedBox.square(
              dimension: 84,
              child: Center(
                child: NeuBox(
                  circle: true,
                  inset: true,
                  depth: 4,
                  child: SizedBox.square(
                    dimension: 60,
                    child: Icon(icon, size: 28, color: scheme.onSurfaceVariant),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(title, style: theme.textTheme.titleMedium),
          const SizedBox(height: 6),
          Text(
            message,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
