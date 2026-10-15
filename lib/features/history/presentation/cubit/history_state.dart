part of 'history_cubit.dart';

enum HistoryStatus { loading, ready, failure }

class HistoryState extends Equatable {
  const HistoryState({
    this.status = HistoryStatus.loading,
    this.entries = const [],
    this.query = '',
    this.error,
  });

  final HistoryStatus status;
  final List<HistoryEntry> entries;
  final String query;
  final String? error;

  List<HistoryEntry> get visibleEntries {
    final q = _normalize(query.trim());
    if (q.isEmpty) return entries;
    return entries
        .where(
          (e) =>
              (e.name?.toLowerCase().contains(q) ?? false) ||
              _normalize(e.id).contains(q),
        )
        .toList();
  }

  static String _normalize(String value) =>
      value.toLowerCase().replaceAll(RegExp('[:-]'), '');

  HistoryState copyWith({
    HistoryStatus? status,
    List<HistoryEntry>? entries,
    String? query,
    String? error,
  }) => HistoryState(
    status: status ?? this.status,
    entries: entries ?? this.entries,
    query: query ?? this.query,
    error: error ?? this.error,
  );

  @override
  List<Object?> get props => [status, entries, query, error];
}
