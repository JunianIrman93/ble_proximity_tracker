// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $DeviceHistoryTable extends DeviceHistory
    with TableInfo<$DeviceHistoryTable, DeviceHistoryRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DeviceHistoryTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastRssiMeta = const VerificationMeta(
    'lastRssi',
  );
  @override
  late final GeneratedColumn<int> lastRssi = GeneratedColumn<int>(
    'last_rssi',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _bestRssiMeta = const VerificationMeta(
    'bestRssi',
  );
  @override
  late final GeneratedColumn<int> bestRssi = GeneratedColumn<int>(
    'best_rssi',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _firstSeenMeta = const VerificationMeta(
    'firstSeen',
  );
  @override
  late final GeneratedColumn<DateTime> firstSeen = GeneratedColumn<DateTime>(
    'first_seen',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lastSeenMeta = const VerificationMeta(
    'lastSeen',
  );
  @override
  late final GeneratedColumn<DateTime> lastSeen = GeneratedColumn<DateTime>(
    'last_seen',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    lastRssi,
    bestRssi,
    firstSeen,
    lastSeen,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'device_history';
  @override
  VerificationContext validateIntegrity(
    Insertable<DeviceHistoryRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    }
    if (data.containsKey('last_rssi')) {
      context.handle(
        _lastRssiMeta,
        lastRssi.isAcceptableOrUnknown(data['last_rssi']!, _lastRssiMeta),
      );
    } else if (isInserting) {
      context.missing(_lastRssiMeta);
    }
    if (data.containsKey('best_rssi')) {
      context.handle(
        _bestRssiMeta,
        bestRssi.isAcceptableOrUnknown(data['best_rssi']!, _bestRssiMeta),
      );
    } else if (isInserting) {
      context.missing(_bestRssiMeta);
    }
    if (data.containsKey('first_seen')) {
      context.handle(
        _firstSeenMeta,
        firstSeen.isAcceptableOrUnknown(data['first_seen']!, _firstSeenMeta),
      );
    } else if (isInserting) {
      context.missing(_firstSeenMeta);
    }
    if (data.containsKey('last_seen')) {
      context.handle(
        _lastSeenMeta,
        lastSeen.isAcceptableOrUnknown(data['last_seen']!, _lastSeenMeta),
      );
    } else if (isInserting) {
      context.missing(_lastSeenMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DeviceHistoryRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DeviceHistoryRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      ),
      lastRssi: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}last_rssi'],
      )!,
      bestRssi: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}best_rssi'],
      )!,
      firstSeen: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}first_seen'],
      )!,
      lastSeen: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_seen'],
      )!,
    );
  }

  @override
  $DeviceHistoryTable createAlias(String alias) {
    return $DeviceHistoryTable(attachedDatabase, alias);
  }
}

class DeviceHistoryRow extends DataClass
    implements Insertable<DeviceHistoryRow> {
  final String id;
  final String? name;
  final int lastRssi;
  final int bestRssi;
  final DateTime firstSeen;
  final DateTime lastSeen;
  const DeviceHistoryRow({
    required this.id,
    this.name,
    required this.lastRssi,
    required this.bestRssi,
    required this.firstSeen,
    required this.lastSeen,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || name != null) {
      map['name'] = Variable<String>(name);
    }
    map['last_rssi'] = Variable<int>(lastRssi);
    map['best_rssi'] = Variable<int>(bestRssi);
    map['first_seen'] = Variable<DateTime>(firstSeen);
    map['last_seen'] = Variable<DateTime>(lastSeen);
    return map;
  }

  DeviceHistoryCompanion toCompanion(bool nullToAbsent) {
    return DeviceHistoryCompanion(
      id: Value(id),
      name: name == null && nullToAbsent ? const Value.absent() : Value(name),
      lastRssi: Value(lastRssi),
      bestRssi: Value(bestRssi),
      firstSeen: Value(firstSeen),
      lastSeen: Value(lastSeen),
    );
  }

  factory DeviceHistoryRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DeviceHistoryRow(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String?>(json['name']),
      lastRssi: serializer.fromJson<int>(json['lastRssi']),
      bestRssi: serializer.fromJson<int>(json['bestRssi']),
      firstSeen: serializer.fromJson<DateTime>(json['firstSeen']),
      lastSeen: serializer.fromJson<DateTime>(json['lastSeen']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String?>(name),
      'lastRssi': serializer.toJson<int>(lastRssi),
      'bestRssi': serializer.toJson<int>(bestRssi),
      'firstSeen': serializer.toJson<DateTime>(firstSeen),
      'lastSeen': serializer.toJson<DateTime>(lastSeen),
    };
  }

  DeviceHistoryRow copyWith({
    String? id,
    Value<String?> name = const Value.absent(),
    int? lastRssi,
    int? bestRssi,
    DateTime? firstSeen,
    DateTime? lastSeen,
  }) => DeviceHistoryRow(
    id: id ?? this.id,
    name: name.present ? name.value : this.name,
    lastRssi: lastRssi ?? this.lastRssi,
    bestRssi: bestRssi ?? this.bestRssi,
    firstSeen: firstSeen ?? this.firstSeen,
    lastSeen: lastSeen ?? this.lastSeen,
  );
  DeviceHistoryRow copyWithCompanion(DeviceHistoryCompanion data) {
    return DeviceHistoryRow(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      lastRssi: data.lastRssi.present ? data.lastRssi.value : this.lastRssi,
      bestRssi: data.bestRssi.present ? data.bestRssi.value : this.bestRssi,
      firstSeen: data.firstSeen.present ? data.firstSeen.value : this.firstSeen,
      lastSeen: data.lastSeen.present ? data.lastSeen.value : this.lastSeen,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DeviceHistoryRow(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('lastRssi: $lastRssi, ')
          ..write('bestRssi: $bestRssi, ')
          ..write('firstSeen: $firstSeen, ')
          ..write('lastSeen: $lastSeen')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, name, lastRssi, bestRssi, firstSeen, lastSeen);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DeviceHistoryRow &&
          other.id == this.id &&
          other.name == this.name &&
          other.lastRssi == this.lastRssi &&
          other.bestRssi == this.bestRssi &&
          other.firstSeen == this.firstSeen &&
          other.lastSeen == this.lastSeen);
}

class DeviceHistoryCompanion extends UpdateCompanion<DeviceHistoryRow> {
  final Value<String> id;
  final Value<String?> name;
  final Value<int> lastRssi;
  final Value<int> bestRssi;
  final Value<DateTime> firstSeen;
  final Value<DateTime> lastSeen;
  final Value<int> rowid;
  const DeviceHistoryCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.lastRssi = const Value.absent(),
    this.bestRssi = const Value.absent(),
    this.firstSeen = const Value.absent(),
    this.lastSeen = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DeviceHistoryCompanion.insert({
    required String id,
    this.name = const Value.absent(),
    required int lastRssi,
    required int bestRssi,
    required DateTime firstSeen,
    required DateTime lastSeen,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       lastRssi = Value(lastRssi),
       bestRssi = Value(bestRssi),
       firstSeen = Value(firstSeen),
       lastSeen = Value(lastSeen);
  static Insertable<DeviceHistoryRow> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<int>? lastRssi,
    Expression<int>? bestRssi,
    Expression<DateTime>? firstSeen,
    Expression<DateTime>? lastSeen,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (lastRssi != null) 'last_rssi': lastRssi,
      if (bestRssi != null) 'best_rssi': bestRssi,
      if (firstSeen != null) 'first_seen': firstSeen,
      if (lastSeen != null) 'last_seen': lastSeen,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DeviceHistoryCompanion copyWith({
    Value<String>? id,
    Value<String?>? name,
    Value<int>? lastRssi,
    Value<int>? bestRssi,
    Value<DateTime>? firstSeen,
    Value<DateTime>? lastSeen,
    Value<int>? rowid,
  }) {
    return DeviceHistoryCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      lastRssi: lastRssi ?? this.lastRssi,
      bestRssi: bestRssi ?? this.bestRssi,
      firstSeen: firstSeen ?? this.firstSeen,
      lastSeen: lastSeen ?? this.lastSeen,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (lastRssi.present) {
      map['last_rssi'] = Variable<int>(lastRssi.value);
    }
    if (bestRssi.present) {
      map['best_rssi'] = Variable<int>(bestRssi.value);
    }
    if (firstSeen.present) {
      map['first_seen'] = Variable<DateTime>(firstSeen.value);
    }
    if (lastSeen.present) {
      map['last_seen'] = Variable<DateTime>(lastSeen.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DeviceHistoryCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('lastRssi: $lastRssi, ')
          ..write('bestRssi: $bestRssi, ')
          ..write('firstSeen: $firstSeen, ')
          ..write('lastSeen: $lastSeen, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $DeviceHistoryTable deviceHistory = $DeviceHistoryTable(this);
  late final DeviceHistoryDao deviceHistoryDao = DeviceHistoryDao(
    this as AppDatabase,
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [deviceHistory];
}

typedef $$DeviceHistoryTableCreateCompanionBuilder =
    DeviceHistoryCompanion Function({
      required String id,
      Value<String?> name,
      required int lastRssi,
      required int bestRssi,
      required DateTime firstSeen,
      required DateTime lastSeen,
      Value<int> rowid,
    });
typedef $$DeviceHistoryTableUpdateCompanionBuilder =
    DeviceHistoryCompanion Function({
      Value<String> id,
      Value<String?> name,
      Value<int> lastRssi,
      Value<int> bestRssi,
      Value<DateTime> firstSeen,
      Value<DateTime> lastSeen,
      Value<int> rowid,
    });

class $$DeviceHistoryTableFilterComposer
    extends Composer<_$AppDatabase, $DeviceHistoryTable> {
  $$DeviceHistoryTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lastRssi => $composableBuilder(
    column: $table.lastRssi,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get bestRssi => $composableBuilder(
    column: $table.bestRssi,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get firstSeen => $composableBuilder(
    column: $table.firstSeen,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastSeen => $composableBuilder(
    column: $table.lastSeen,
    builder: (column) => ColumnFilters(column),
  );
}

class $$DeviceHistoryTableOrderingComposer
    extends Composer<_$AppDatabase, $DeviceHistoryTable> {
  $$DeviceHistoryTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lastRssi => $composableBuilder(
    column: $table.lastRssi,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get bestRssi => $composableBuilder(
    column: $table.bestRssi,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get firstSeen => $composableBuilder(
    column: $table.firstSeen,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastSeen => $composableBuilder(
    column: $table.lastSeen,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$DeviceHistoryTableAnnotationComposer
    extends Composer<_$AppDatabase, $DeviceHistoryTable> {
  $$DeviceHistoryTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get lastRssi =>
      $composableBuilder(column: $table.lastRssi, builder: (column) => column);

  GeneratedColumn<int> get bestRssi =>
      $composableBuilder(column: $table.bestRssi, builder: (column) => column);

  GeneratedColumn<DateTime> get firstSeen =>
      $composableBuilder(column: $table.firstSeen, builder: (column) => column);

  GeneratedColumn<DateTime> get lastSeen =>
      $composableBuilder(column: $table.lastSeen, builder: (column) => column);
}

class $$DeviceHistoryTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DeviceHistoryTable,
          DeviceHistoryRow,
          $$DeviceHistoryTableFilterComposer,
          $$DeviceHistoryTableOrderingComposer,
          $$DeviceHistoryTableAnnotationComposer,
          $$DeviceHistoryTableCreateCompanionBuilder,
          $$DeviceHistoryTableUpdateCompanionBuilder,
          (
            DeviceHistoryRow,
            BaseReferences<
              _$AppDatabase,
              $DeviceHistoryTable,
              DeviceHistoryRow
            >,
          ),
          DeviceHistoryRow,
          PrefetchHooks Function()
        > {
  $$DeviceHistoryTableTableManager(_$AppDatabase db, $DeviceHistoryTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DeviceHistoryTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DeviceHistoryTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DeviceHistoryTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String?> name = const Value.absent(),
                Value<int> lastRssi = const Value.absent(),
                Value<int> bestRssi = const Value.absent(),
                Value<DateTime> firstSeen = const Value.absent(),
                Value<DateTime> lastSeen = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DeviceHistoryCompanion(
                id: id,
                name: name,
                lastRssi: lastRssi,
                bestRssi: bestRssi,
                firstSeen: firstSeen,
                lastSeen: lastSeen,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<String?> name = const Value.absent(),
                required int lastRssi,
                required int bestRssi,
                required DateTime firstSeen,
                required DateTime lastSeen,
                Value<int> rowid = const Value.absent(),
              }) => DeviceHistoryCompanion.insert(
                id: id,
                name: name,
                lastRssi: lastRssi,
                bestRssi: bestRssi,
                firstSeen: firstSeen,
                lastSeen: lastSeen,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$DeviceHistoryTable, DeviceHistoryRow>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $DeviceHistoryTable,
                    DeviceHistoryRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$DeviceHistoryTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DeviceHistoryTable,
      DeviceHistoryRow,
      $$DeviceHistoryTableFilterComposer,
      $$DeviceHistoryTableOrderingComposer,
      $$DeviceHistoryTableAnnotationComposer,
      $$DeviceHistoryTableCreateCompanionBuilder,
      $$DeviceHistoryTableUpdateCompanionBuilder,
      (
        DeviceHistoryRow,
        BaseReferences<_$AppDatabase, $DeviceHistoryTable, DeviceHistoryRow>,
      ),
      DeviceHistoryRow,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$DeviceHistoryTableTableManager get deviceHistory =>
      $$DeviceHistoryTableTableManager(_db, _db.deviceHistory);
}
