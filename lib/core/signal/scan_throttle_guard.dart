class ScanThrottleGuard {
  ScanThrottleGuard({
    this.maxStarts = 5,
    this.window = const Duration(seconds: 30),
  });

  final int maxStarts;
  final Duration window;
  final List<DateTime> _starts = [];

  Duration? waitBeforeNextStart(DateTime now) {
    _starts.removeWhere((t) => now.difference(t) >= window);
    if (_starts.length < maxStarts) return null;
    return window - now.difference(_starts.first);
  }

  void recordStart(DateTime now) => _starts.add(now);
}
