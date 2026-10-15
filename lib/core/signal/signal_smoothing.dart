import 'signal_zone.dart';

class RssiSmoother {
  RssiSmoother({this.alpha = 0.3}) : assert(alpha > 0 && alpha <= 1);

  final double alpha;
  double? _value;

  double? get value => _value;

  double add(int rssi) {
    final previous = _value;
    final next = previous == null
        ? rssi.toDouble()
        : previous + alpha * (rssi - previous);
    _value = next;
    return next;
  }

  void reset() => _value = null;
}

class ZoneHysteresis {
  ZoneHysteresis({this.marginDb = 3});

  final int marginDb;
  SignalZone? _current;

  SignalZone? get current => _current;

  SignalZone update(double rssi) {
    final rounded = rssi.round();
    final candidate = SignalZone.fromRssi(rounded);
    final current = _current;
    if (current == null) return _current = candidate;

    final strongest = SignalZone.fromRssi(rounded + marginDb).index;
    final weakest = SignalZone.fromRssi(rounded - marginDb).index;
    if (current.index >= strongest && current.index <= weakest) return current;
    return _current = candidate;
  }

  void forceLost() => _current = SignalZone.lost;

  void reset() => _current = null;
}
