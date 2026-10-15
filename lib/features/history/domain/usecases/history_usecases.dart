import 'package:ble_proximity_tracker/core/bluetooth/domain/entities/scanned_device.dart';
import 'package:ble_proximity_tracker/core/error/failures.dart';
import 'package:ble_proximity_tracker/core/error/result.dart';

import '../entities/history_entry.dart';
import '../repositories/history_repository.dart';

class RecordSightings {
  const RecordSightings(this._repository);

  final HistoryRepository _repository;

  Future<Result<void>> call(List<ScannedDevice> sightings) async {
    if (sightings.isEmpty) return const Ok(null);
    try {
      await _repository.recordSightings(sightings);
      return const Ok(null);
    } catch (e) {
      return Err(UnexpectedFailure('Could not save history: $e'));
    }
  }
}

class WatchHistory {
  const WatchHistory(this._repository);

  final HistoryRepository _repository;

  Stream<List<HistoryEntry>> call() => _repository.watchHistory();
}

class ClearHistory {
  const ClearHistory(this._repository);

  final HistoryRepository _repository;

  Future<Result<void>> call() async {
    try {
      await _repository.clear();
      return const Ok(null);
    } catch (e) {
      return Err(UnexpectedFailure('Could not clear history: $e'));
    }
  }
}
