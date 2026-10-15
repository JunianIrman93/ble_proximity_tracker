part of 'radar_bloc.dart';

sealed class RadarEvent {
  const RadarEvent();
}

final class RadarStarted extends RadarEvent {
  const RadarStarted();
}

final class _ReadingReceived extends RadarEvent {
  const _ReadingReceived(this.update);

  final ProximityUpdate update;
}

final class _Ticked extends RadarEvent {
  const _Ticked();
}
