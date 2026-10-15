import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:ble_proximity_tracker/core/bluetooth/domain/entities/scanned_device.dart';
import 'package:ble_proximity_tracker/core/utils/clock.dart';

import '../../domain/entities/proximity_snapshot.dart';
import '../../domain/usecases/track_device_proximity.dart';

part 'radar_event.dart';
part 'radar_state.dart';

class RadarBloc extends Bloc<RadarEvent, RadarState> {
  RadarBloc({
    required String deviceId,
    required TrackDeviceProximity trackProximity,
    required Clock clock,
    ScannedDevice? lastKnown,
    String? knownName,
    this.tickInterval = const Duration(seconds: 1),
  }) : _track = trackProximity,
       _clock = clock,
       super(
         RadarState(
           deviceId: deviceId,
           name: lastKnown?.name ?? knownName,
           snapshot: lastKnown == null
               ? const ProximitySnapshot()
               : trackProximity.addReading(lastKnown),
           now: clock(),
         ),
       ) {
    on<RadarStarted>(_onStarted);
    on<_ReadingReceived>(_onReading);
    on<_Ticked>(_onTicked);
  }

  final TrackDeviceProximity _track;
  final Clock _clock;

  final Duration tickInterval;

  StreamSubscription<ProximityUpdate>? _sub;
  Timer? _ticker;

  @visibleForTesting
  void tick() => add(const _Ticked());

  void _onStarted(RadarStarted event, Emitter<RadarState> emit) {
    _sub ??= _track(state.deviceId).listen((u) => add(_ReadingReceived(u)));
    _ticker ??= Timer.periodic(tickInterval, (_) => add(const _Ticked()));
  }

  void _onReading(_ReadingReceived event, Emitter<RadarState> emit) {
    final device = event.update.device;
    emit(
      state.copyWith(
        name: device.hasName ? device.name : null,
        snapshot: event.update.snapshot,
        now: _clock(),
      ),
    );
  }

  void _onTicked(_Ticked event, Emitter<RadarState> emit) {
    final now = _clock();
    emit(state.copyWith(snapshot: _track.checkLost(now), now: now));
  }

  @override
  Future<void> close() async {
    _ticker?.cancel();
    await _sub?.cancel();
    return super.close();
  }
}
