import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:ble_proximity_tracker/features/history/data/datasources/app_database.dart';
import 'package:ble_proximity_tracker/features/history/domain/entities/history_entry.dart';
import 'package:ble_proximity_tracker/features/history/domain/usecases/history_usecases.dart';
import 'package:ble_proximity_tracker/features/history/presentation/cubit/history_cubit.dart';

import '../../helpers/fakes.dart';

void main() {
  group('DeviceHistoryDao', () {
    late AppDatabase db;

    setUp(() => db = AppDatabase(NativeDatabase.memory()));
    tearDown(() => db.close());

    test('upsert keeps first seen, best RSSI and a known name', () async {
      final t1 = DateTime(2026, 10, 15, 10);
      final t2 = t1.add(const Duration(minutes: 5));
      final dao = db.deviceHistoryDao;

      await dao.upsertSightings([
        (id: 'AA', name: 'Tag', rssi: -50, seenAt: t1),
      ]);
      await dao.upsertSightings([
        (id: 'AA', name: null, rssi: -75, seenAt: t2),
      ]);

      final row = (await dao.watchAll().first).single;
      expect(row.name, 'Tag');
      expect(row.lastRssi, -75);
      expect(row.bestRssi, -50);
      expect(row.firstSeen, t1);
      expect(row.lastSeen, t2);
    });

    test('orders by most recently seen', () async {
      final t = DateTime(2026, 10, 15, 10);
      await db.deviceHistoryDao.upsertSightings([
        (id: 'OLD', name: null, rssi: -60, seenAt: t),
        (
          id: 'NEW',
          name: null,
          rssi: -60,
          seenAt: t.add(const Duration(minutes: 1)),
        ),
      ]);
      final rows = await db.deviceHistoryDao.watchAll().first;
      expect(rows.map((r) => r.id), ['NEW', 'OLD']);
    });
  });

  group('HistoryCubit', () {
    late MockHistoryRepository repo;
    late StreamController<List<HistoryEntry>> stream;
    final t = DateTime(2026, 10, 15, 10);
    final entries = [
      HistoryEntry(
        id: 'AA:BB:01',
        name: 'Tag',
        lastRssi: -60,
        bestRssi: -50,
        firstSeen: t,
        lastSeen: t,
      ),
      HistoryEntry(
        id: 'CC:DD:02',
        lastRssi: -80,
        bestRssi: -70,
        firstSeen: t,
        lastSeen: t,
      ),
    ];

    setUp(() {
      repo = MockHistoryRepository();
      stream = StreamController<List<HistoryEntry>>();
      when(() => repo.watchHistory()).thenAnswer((_) => stream.stream);
      when(() => repo.clear()).thenAnswer((_) async {});
    });

    HistoryCubit build() => HistoryCubit(
      watchHistory: WatchHistory(repo),
      clearHistory: ClearHistory(repo),
    );

    blocTest<HistoryCubit, HistoryState>(
      'emits entries from the database stream',
      build: build,
      act: (cubit) {
        cubit.load();
        stream.add(entries);
      },
      wait: const Duration(milliseconds: 10),
      expect: () => [
        HistoryState(status: HistoryStatus.ready, entries: entries),
      ],
    );

    blocTest<HistoryCubit, HistoryState>(
      'search matches name or MAC without separators',
      build: build,
      seed: () => HistoryState(status: HistoryStatus.ready, entries: entries),
      act: (cubit) => cubit.queryChanged('ccdd'),
      verify: (cubit) =>
          expect(cubit.state.visibleEntries.single.id, 'CC:DD:02'),
    );

    blocTest<HistoryCubit, HistoryState>(
      'clear delegates to the repository',
      build: build,
      act: (cubit) => cubit.clear(),
      verify: (_) => verify(() => repo.clear()).called(1),
    );
  });
}
