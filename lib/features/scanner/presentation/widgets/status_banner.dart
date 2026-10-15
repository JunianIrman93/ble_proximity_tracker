import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:ble_proximity_tracker/core/bluetooth/domain/entities/bluetooth_status.dart';
import 'package:ble_proximity_tracker/core/widgets/neu.dart';

import '../bloc/scanner_bloc.dart';

class StatusBanner extends StatelessWidget {
  const StatusBanner({super.key, required this.state});

  final ScannerState state;

  @override
  Widget build(BuildContext context) {
    final spec = _specFor(state);
    if (spec == null) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final bloc = context.read<ScannerBloc>();

    return Padding(
      padding: const EdgeInsets.only(top: 18),
      child: NeuBox(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            NeuBox(
              circle: true,
              inset: true,
              depth: 3,
              child: SizedBox.square(
                dimension: 40,
                child: Icon(spec.icon, size: 20, color: scheme.error),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    spec.title,
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: scheme.error,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    spec.message,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            if (spec.action != null) ...[
              const SizedBox(width: 12),
              NeuButton(
                compact: true,
                label: spec.actionLabel!,
                onPressed: () => bloc.add(spec.action!),
              ),
            ],
          ],
        ),
      ),
    );
  }

  static _BannerSpec? _specFor(ScannerState s) {
    if (s.btStatus == BluetoothStatus.unsupported) {
      return const _BannerSpec(
        icon: Icons.bluetooth_disabled,
        title: 'BLE not supported',
        message: 'This device has no Bluetooth Low Energy radio.',
      );
    }
    if (s.permission == ScanPermission.permanentlyDenied) {
      return const _BannerSpec(
        icon: Icons.lock_outline,
        title: 'Permission blocked',
        message: 'Allow "Nearby devices" in app settings to scan.',
        actionLabel: 'Settings',
        action: AppSettingsRequested(),
      );
    }
    if (s.permission == ScanPermission.denied ||
        s.btStatus == BluetoothStatus.unauthorized) {
      return const _BannerSpec(
        icon: Icons.privacy_tip_outlined,
        title: 'Permission needed',
        message: 'Bluetooth access is required to find nearby devices.',
        actionLabel: 'Allow',
        action: ScanStartRequested(),
      );
    }
    if (s.btStatus == BluetoothStatus.off) {
      return const _BannerSpec(
        icon: Icons.bluetooth_disabled,
        title: 'Bluetooth is off',
        message: 'Scanning starts automatically once it is on.',
        actionLabel: 'Turn on',
        action: BluetoothEnableRequested(),
      );
    }
    return null;
  }
}

class _BannerSpec {
  const _BannerSpec({
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.action,
  });

  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final ScannerEvent? action;
}
