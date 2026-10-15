import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:ble_proximity_tracker/core/error/result.dart';

import '../../domain/entities/history_entry.dart';
import '../../domain/usecases/history_usecases.dart';

part 'history_state.dart';

class HistoryCubit extends Cubit<HistoryState> {
  HistoryCubit({required this._watchHistory, required this._clearHistory})
    : super(const HistoryState());

  final WatchHistory _watchHistory;
  final ClearHistory _clearHistory;
  StreamSubscription<List<HistoryEntry>>? _sub;

  void load() {
    _sub ??= _watchHistory().listen(
      (entries) =>
          emit(state.copyWith(status: HistoryStatus.ready, entries: entries)),
      onError: (Object e) =>
          emit(state.copyWith(status: HistoryStatus.failure, error: '$e')),
    );
  }

  void queryChanged(String query) => emit(state.copyWith(query: query));

  Future<void> clear() async {
    final result = await _clearHistory();
    if (result case Err(:final failure)) {
      emit(state.copyWith(error: failure.message));
    }
  }

  @override
  Future<void> close() async {
    await _sub?.cancel();
    return super.close();
  }
}
