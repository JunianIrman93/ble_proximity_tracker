import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:ble_proximity_tracker/core/router/app_router.dart';
import 'package:ble_proximity_tracker/core/widgets/empty_view.dart';
import 'package:ble_proximity_tracker/core/widgets/neu.dart';
import 'package:ble_proximity_tracker/core/widgets/section_label.dart';

import '../bloc/scanner_bloc.dart';
import '../widgets/device_card.dart';
import '../widgets/filter_sheet.dart';
import '../widgets/quick_filters.dart';
import '../widgets/scan_control_card.dart';
import '../widgets/status_banner.dart';

class ScannerPage extends StatefulWidget {
  const ScannerPage({super.key});

  @override
  State<ScannerPage> createState() => _ScannerPageState();
}

class _ScannerPageState extends State<ScannerPage> {
  final _search = TextEditingController();

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ScannerBloc, ScannerState>(
      listenWhen: (prev, curr) =>
          curr.message != null && prev.message != curr.message,
      listener: (context, state) => ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(state.message!.text))),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Nearby devices'),
          actions: [
            BlocSelector<ScannerBloc, ScannerState, bool>(
              selector: (s) => s.filter.hasSignalOrNameFilter,
              builder: (context, active) => NeuIconButton(
                tooltip: 'Filters',
                onPressed: () => showFilterSheet(context),
                icon: Badge(
                  isLabelVisible: active,
                  smallSize: 8,
                  child: const Icon(Icons.tune),
                ),
              ),
            ),
            const SizedBox(width: 16),
          ],
        ),
        body: BlocBuilder<ScannerBloc, ScannerState>(
          builder: (context, state) {
            final devices = state.visibleDevices;
            return CustomScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                  sliver: SliverList.list(
                    children: [
                      ScanControlCard(state: state),
                      StatusBanner(state: state),
                      const SizedBox(height: 20),
                      _SearchField(controller: _search),
                      const SizedBox(height: 6),
                    ],
                  ),
                ),
                SliverToBoxAdapter(child: QuickFilters(filter: state.filter)),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
                  sliver: SliverList.list(
                    children: [
                      SectionLabel(
                        state.filter.isActive
                            ? '${devices.length} of ${state.devices.length} devices'
                            : '${devices.length} '
                                  '${devices.length == 1 ? 'device' : 'devices'}',
                        trailing: Text(
                          'Strongest first',
                          style: Theme.of(context).textTheme.labelSmall,
                        ),
                      ),
                    ],
                  ),
                ),
                if (devices.isEmpty)
                  SliverToBoxAdapter(child: _EmptyDevices(state: state))
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                    sliver: SliverList.separated(
                      itemCount: devices.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 14),
                      itemBuilder: (context, index) {
                        final device = devices[index];
                        return _FadeSlideEntry(
                          key: ValueKey('entry_${device.id}'),
                          index: index,
                          child: DeviceCard(
                            key: ValueKey(device.id),
                            device: device,
                            onTap: () =>
                                context.push(AppRoutes.radar(device.id)),
                          ),
                        );
                      },
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _FadeSlideEntry extends StatelessWidget {
  const _FadeSlideEntry({super.key, required this.child, required this.index});

  final Widget child;
  final int index;

  @override
  Widget build(BuildContext context) {
    final delayMs = (index.clamp(0, 5) * 30);
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 320 + delayMs),
      curve: Curves.easeOutCubic,
      tween: Tween<double>(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 14 * (1 - value)),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<ScannerBloc>();
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: controller,
      builder: (context, value, _) => NeuBox(
        inset: true,
        depth: 4,
        radius: 16,
        child: TextField(
          controller: controller,
          onChanged: (q) => bloc.add(SearchQueryChanged(q)),
          textInputAction: TextInputAction.search,
          decoration: InputDecoration(
            hintText: 'Search name or MAC address',
            prefixIcon: const Icon(Icons.search),
            suffixIcon: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: value.text.isEmpty
                  ? const SizedBox.shrink()
                  : IconButton(
                      key: const ValueKey('clear_btn'),
                      tooltip: 'Clear',
                      icon: const Icon(Icons.close),
                      onPressed: () {
                        controller.clear();
                        bloc.add(const SearchQueryChanged(''));
                      },
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

class _EmptyDevices extends StatelessWidget {
  const _EmptyDevices({required this.state});

  final ScannerState state;

  @override
  Widget build(BuildContext context) {
    if (state.devices.isNotEmpty) {
      return const EmptyView(
        icon: Icons.filter_alt_off_outlined,
        title: 'No matching devices',
        message: 'Try another search or lower the signal threshold.',
      );
    }
    if (state.isScanning) {
      return const EmptyView(
        icon: Icons.bluetooth_searching,
        title: 'Looking for devices',
        message: 'Nearby devices appear here as soon as they advertise.',
      );
    }
    return const EmptyView(
      icon: Icons.bluetooth,
      title: 'Not scanning',
      message: 'Start a scan to see BLE devices around you.',
    );
  }
}
