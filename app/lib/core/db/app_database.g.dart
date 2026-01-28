// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $PersonalBestsTable extends PersonalBests
    with TableInfo<$PersonalBestsTable, PersonalBest> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PersonalBestsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<PbEvent, String> event =
      GeneratedColumn<String>(
        'event',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<PbEvent>($PersonalBestsTable.$converterevent);
  static const VerificationMeta _timeMsMeta = const VerificationMeta('timeMs');
  @override
  late final GeneratedColumn<int> timeMs = GeneratedColumn<int>(
    'time_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
    'date',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [id, event, timeMs, date, note];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'personal_bests';
  @override
  VerificationContext validateIntegrity(
    Insertable<PersonalBest> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('time_ms')) {
      context.handle(
        _timeMsMeta,
        timeMs.isAcceptableOrUnknown(data['time_ms']!, _timeMsMeta),
      );
    } else if (isInserting) {
      context.missing(_timeMsMeta);
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PersonalBest map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PersonalBest(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      event: $PersonalBestsTable.$converterevent.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}event'],
        )!,
      ),
      timeMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}time_ms'],
      )!,
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date'],
      ),
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
    );
  }

  @override
  $PersonalBestsTable createAlias(String alias) {
    return $PersonalBestsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<PbEvent, String, String> $converterevent =
      const EnumNameConverter<PbEvent>(PbEvent.values);
}

class PersonalBest extends DataClass implements Insertable<PersonalBest> {
  final String id;
  final PbEvent event;
  final int timeMs;
  final DateTime? date;
  final String? note;
  const PersonalBest({
    required this.id,
    required this.event,
    required this.timeMs,
    this.date,
    this.note,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    {
      map['event'] = Variable<String>(
        $PersonalBestsTable.$converterevent.toSql(event),
      );
    }
    map['time_ms'] = Variable<int>(timeMs);
    if (!nullToAbsent || date != null) {
      map['date'] = Variable<DateTime>(date);
    }
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    return map;
  }

  PersonalBestsCompanion toCompanion(bool nullToAbsent) {
    return PersonalBestsCompanion(
      id: Value(id),
      event: Value(event),
      timeMs: Value(timeMs),
      date: date == null && nullToAbsent ? const Value.absent() : Value(date),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
    );
  }

  factory PersonalBest.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PersonalBest(
      id: serializer.fromJson<String>(json['id']),
      event: $PersonalBestsTable.$converterevent.fromJson(
        serializer.fromJson<String>(json['event']),
      ),
      timeMs: serializer.fromJson<int>(json['timeMs']),
      date: serializer.fromJson<DateTime?>(json['date']),
      note: serializer.fromJson<String?>(json['note']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'event': serializer.toJson<String>(
        $PersonalBestsTable.$converterevent.toJson(event),
      ),
      'timeMs': serializer.toJson<int>(timeMs),
      'date': serializer.toJson<DateTime?>(date),
      'note': serializer.toJson<String?>(note),
    };
  }

  PersonalBest copyWith({
    String? id,
    PbEvent? event,
    int? timeMs,
    Value<DateTime?> date = const Value.absent(),
    Value<String?> note = const Value.absent(),
  }) => PersonalBest(
    id: id ?? this.id,
    event: event ?? this.event,
    timeMs: timeMs ?? this.timeMs,
    date: date.present ? date.value : this.date,
    note: note.present ? note.value : this.note,
  );
  PersonalBest copyWithCompanion(PersonalBestsCompanion data) {
    return PersonalBest(
      id: data.id.present ? data.id.value : this.id,
      event: data.event.present ? data.event.value : this.event,
      timeMs: data.timeMs.present ? data.timeMs.value : this.timeMs,
      date: data.date.present ? data.date.value : this.date,
      note: data.note.present ? data.note.value : this.note,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PersonalBest(')
          ..write('id: $id, ')
          ..write('event: $event, ')
          ..write('timeMs: $timeMs, ')
          ..write('date: $date, ')
          ..write('note: $note')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, event, timeMs, date, note);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PersonalBest &&
          other.id == this.id &&
          other.event == this.event &&
          other.timeMs == this.timeMs &&
          other.date == this.date &&
          other.note == this.note);
}

class PersonalBestsCompanion extends UpdateCompanion<PersonalBest> {
  final Value<String> id;
  final Value<PbEvent> event;
  final Value<int> timeMs;
  final Value<DateTime?> date;
  final Value<String?> note;
  final Value<int> rowid;
  const PersonalBestsCompanion({
    this.id = const Value.absent(),
    this.event = const Value.absent(),
    this.timeMs = const Value.absent(),
    this.date = const Value.absent(),
    this.note = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PersonalBestsCompanion.insert({
    required String id,
    required PbEvent event,
    required int timeMs,
    this.date = const Value.absent(),
    this.note = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       event = Value(event),
       timeMs = Value(timeMs);
  static Insertable<PersonalBest> custom({
    Expression<String>? id,
    Expression<String>? event,
    Expression<int>? timeMs,
    Expression<DateTime>? date,
    Expression<String>? note,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (event != null) 'event': event,
      if (timeMs != null) 'time_ms': timeMs,
      if (date != null) 'date': date,
      if (note != null) 'note': note,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PersonalBestsCompanion copyWith({
    Value<String>? id,
    Value<PbEvent>? event,
    Value<int>? timeMs,
    Value<DateTime?>? date,
    Value<String?>? note,
    Value<int>? rowid,
  }) {
    return PersonalBestsCompanion(
      id: id ?? this.id,
      event: event ?? this.event,
      timeMs: timeMs ?? this.timeMs,
      date: date ?? this.date,
      note: note ?? this.note,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (event.present) {
      map['event'] = Variable<String>(
        $PersonalBestsTable.$converterevent.toSql(event.value),
      );
    }
    if (timeMs.present) {
      map['time_ms'] = Variable<int>(timeMs.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PersonalBestsCompanion(')
          ..write('id: $id, ')
          ..write('event: $event, ')
          ..write('timeMs: $timeMs, ')
          ..write('date: $date, ')
          ..write('note: $note, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PlansTable extends Plans with TableInfo<$PlansTable, Plan> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PlansTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _templateTextMeta = const VerificationMeta(
    'templateText',
  );
  @override
  late final GeneratedColumn<String> templateText = GeneratedColumn<String>(
    'template_text',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [id, date, templateText, note];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'plans';
  @override
  VerificationContext validateIntegrity(
    Insertable<Plan> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('template_text')) {
      context.handle(
        _templateTextMeta,
        templateText.isAcceptableOrUnknown(
          data['template_text']!,
          _templateTextMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_templateTextMeta);
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Plan map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Plan(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date'],
      )!,
      templateText: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}template_text'],
      )!,
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
    );
  }

  @override
  $PlansTable createAlias(String alias) {
    return $PlansTable(attachedDatabase, alias);
  }
}

class Plan extends DataClass implements Insertable<Plan> {
  final String id;
  final DateTime date;
  final String templateText;
  final String? note;
  const Plan({
    required this.id,
    required this.date,
    required this.templateText,
    this.note,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['date'] = Variable<DateTime>(date);
    map['template_text'] = Variable<String>(templateText);
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    return map;
  }

  PlansCompanion toCompanion(bool nullToAbsent) {
    return PlansCompanion(
      id: Value(id),
      date: Value(date),
      templateText: Value(templateText),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
    );
  }

  factory Plan.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Plan(
      id: serializer.fromJson<String>(json['id']),
      date: serializer.fromJson<DateTime>(json['date']),
      templateText: serializer.fromJson<String>(json['templateText']),
      note: serializer.fromJson<String?>(json['note']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'date': serializer.toJson<DateTime>(date),
      'templateText': serializer.toJson<String>(templateText),
      'note': serializer.toJson<String?>(note),
    };
  }

  Plan copyWith({
    String? id,
    DateTime? date,
    String? templateText,
    Value<String?> note = const Value.absent(),
  }) => Plan(
    id: id ?? this.id,
    date: date ?? this.date,
    templateText: templateText ?? this.templateText,
    note: note.present ? note.value : this.note,
  );
  Plan copyWithCompanion(PlansCompanion data) {
    return Plan(
      id: data.id.present ? data.id.value : this.id,
      date: data.date.present ? data.date.value : this.date,
      templateText: data.templateText.present
          ? data.templateText.value
          : this.templateText,
      note: data.note.present ? data.note.value : this.note,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Plan(')
          ..write('id: $id, ')
          ..write('date: $date, ')
          ..write('templateText: $templateText, ')
          ..write('note: $note')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, date, templateText, note);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Plan &&
          other.id == this.id &&
          other.date == this.date &&
          other.templateText == this.templateText &&
          other.note == this.note);
}

class PlansCompanion extends UpdateCompanion<Plan> {
  final Value<String> id;
  final Value<DateTime> date;
  final Value<String> templateText;
  final Value<String?> note;
  final Value<int> rowid;
  const PlansCompanion({
    this.id = const Value.absent(),
    this.date = const Value.absent(),
    this.templateText = const Value.absent(),
    this.note = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PlansCompanion.insert({
    required String id,
    required DateTime date,
    required String templateText,
    this.note = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       date = Value(date),
       templateText = Value(templateText);
  static Insertable<Plan> custom({
    Expression<String>? id,
    Expression<DateTime>? date,
    Expression<String>? templateText,
    Expression<String>? note,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (date != null) 'date': date,
      if (templateText != null) 'template_text': templateText,
      if (note != null) 'note': note,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PlansCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? date,
    Value<String>? templateText,
    Value<String?>? note,
    Value<int>? rowid,
  }) {
    return PlansCompanion(
      id: id ?? this.id,
      date: date ?? this.date,
      templateText: templateText ?? this.templateText,
      note: note ?? this.note,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (templateText.present) {
      map['template_text'] = Variable<String>(templateText.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PlansCompanion(')
          ..write('id: $id, ')
          ..write('date: $date, ')
          ..write('templateText: $templateText, ')
          ..write('note: $note, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SessionsTable extends Sessions with TableInfo<$SessionsTable, Session> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SessionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _startedAtMeta = const VerificationMeta(
    'startedAt',
  );
  @override
  late final GeneratedColumn<DateTime> startedAt = GeneratedColumn<DateTime>(
    'date_time',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _planIdMeta = const VerificationMeta('planId');
  @override
  late final GeneratedColumn<String> planId = GeneratedColumn<String>(
    'plan_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES plans (id)',
    ),
  );
  static const VerificationMeta _templateTextMeta = const VerificationMeta(
    'templateText',
  );
  @override
  late final GeneratedColumn<String> templateText = GeneratedColumn<String>(
    'template_text',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _distanceMainMMeta = const VerificationMeta(
    'distanceMainM',
  );
  @override
  late final GeneratedColumn<int> distanceMainM = GeneratedColumn<int>(
    'distance_main_m',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _durationMainSecMeta = const VerificationMeta(
    'durationMainSec',
  );
  @override
  late final GeneratedColumn<int> durationMainSec = GeneratedColumn<int>(
    'duration_main_sec',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _paceSecPerKmMeta = const VerificationMeta(
    'paceSecPerKm',
  );
  @override
  late final GeneratedColumn<int> paceSecPerKm = GeneratedColumn<int>(
    'pace_sec_per_km',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<Zone?, String> zone =
      GeneratedColumn<String>(
        'zone',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      ).withConverter<Zone?>($SessionsTable.$converterzonen);
  static const VerificationMeta _rpeValueMeta = const VerificationMeta(
    'rpeValue',
  );
  @override
  late final GeneratedColumn<int> rpeValue = GeneratedColumn<int>(
    'rpe_value',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<RestType?, String> restType =
      GeneratedColumn<String>(
        'rest_type',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      ).withConverter<RestType?>($SessionsTable.$converterrestTypen);
  static const VerificationMeta _restDurationSecMeta = const VerificationMeta(
    'restDurationSec',
  );
  @override
  late final GeneratedColumn<int> restDurationSec = GeneratedColumn<int>(
    'rest_duration_sec',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _restDistanceMMeta = const VerificationMeta(
    'restDistanceM',
  );
  @override
  late final GeneratedColumn<int> restDistanceM = GeneratedColumn<int>(
    'rest_distance_m',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _wuDistanceMMeta = const VerificationMeta(
    'wuDistanceM',
  );
  @override
  late final GeneratedColumn<int> wuDistanceM = GeneratedColumn<int>(
    'wu_distance_m',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _wuDurationSecMeta = const VerificationMeta(
    'wuDurationSec',
  );
  @override
  late final GeneratedColumn<int> wuDurationSec = GeneratedColumn<int>(
    'wu_duration_sec',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _cdDistanceMMeta = const VerificationMeta(
    'cdDistanceM',
  );
  @override
  late final GeneratedColumn<int> cdDistanceM = GeneratedColumn<int>(
    'cd_distance_m',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _cdDurationSecMeta = const VerificationMeta(
    'cdDurationSec',
  );
  @override
  late final GeneratedColumn<int> cdDurationSec = GeneratedColumn<int>(
    'cd_duration_sec',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<SessionStatus, String> status =
      GeneratedColumn<String>(
        'status',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<SessionStatus>($SessionsTable.$converterstatus);
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _repLoadMeta = const VerificationMeta(
    'repLoad',
  );
  @override
  late final GeneratedColumn<int> repLoad = GeneratedColumn<int>(
    'rep_load',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    startedAt,
    planId,
    templateText,
    distanceMainM,
    durationMainSec,
    paceSecPerKm,
    zone,
    rpeValue,
    restType,
    restDurationSec,
    restDistanceM,
    wuDistanceM,
    wuDurationSec,
    cdDistanceM,
    cdDurationSec,
    status,
    note,
    repLoad,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sessions';
  @override
  VerificationContext validateIntegrity(
    Insertable<Session> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('date_time')) {
      context.handle(
        _startedAtMeta,
        startedAt.isAcceptableOrUnknown(data['date_time']!, _startedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_startedAtMeta);
    }
    if (data.containsKey('plan_id')) {
      context.handle(
        _planIdMeta,
        planId.isAcceptableOrUnknown(data['plan_id']!, _planIdMeta),
      );
    }
    if (data.containsKey('template_text')) {
      context.handle(
        _templateTextMeta,
        templateText.isAcceptableOrUnknown(
          data['template_text']!,
          _templateTextMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_templateTextMeta);
    }
    if (data.containsKey('distance_main_m')) {
      context.handle(
        _distanceMainMMeta,
        distanceMainM.isAcceptableOrUnknown(
          data['distance_main_m']!,
          _distanceMainMMeta,
        ),
      );
    }
    if (data.containsKey('duration_main_sec')) {
      context.handle(
        _durationMainSecMeta,
        durationMainSec.isAcceptableOrUnknown(
          data['duration_main_sec']!,
          _durationMainSecMeta,
        ),
      );
    }
    if (data.containsKey('pace_sec_per_km')) {
      context.handle(
        _paceSecPerKmMeta,
        paceSecPerKm.isAcceptableOrUnknown(
          data['pace_sec_per_km']!,
          _paceSecPerKmMeta,
        ),
      );
    }
    if (data.containsKey('rpe_value')) {
      context.handle(
        _rpeValueMeta,
        rpeValue.isAcceptableOrUnknown(data['rpe_value']!, _rpeValueMeta),
      );
    }
    if (data.containsKey('rest_duration_sec')) {
      context.handle(
        _restDurationSecMeta,
        restDurationSec.isAcceptableOrUnknown(
          data['rest_duration_sec']!,
          _restDurationSecMeta,
        ),
      );
    }
    if (data.containsKey('rest_distance_m')) {
      context.handle(
        _restDistanceMMeta,
        restDistanceM.isAcceptableOrUnknown(
          data['rest_distance_m']!,
          _restDistanceMMeta,
        ),
      );
    }
    if (data.containsKey('wu_distance_m')) {
      context.handle(
        _wuDistanceMMeta,
        wuDistanceM.isAcceptableOrUnknown(
          data['wu_distance_m']!,
          _wuDistanceMMeta,
        ),
      );
    }
    if (data.containsKey('wu_duration_sec')) {
      context.handle(
        _wuDurationSecMeta,
        wuDurationSec.isAcceptableOrUnknown(
          data['wu_duration_sec']!,
          _wuDurationSecMeta,
        ),
      );
    }
    if (data.containsKey('cd_distance_m')) {
      context.handle(
        _cdDistanceMMeta,
        cdDistanceM.isAcceptableOrUnknown(
          data['cd_distance_m']!,
          _cdDistanceMMeta,
        ),
      );
    }
    if (data.containsKey('cd_duration_sec')) {
      context.handle(
        _cdDurationSecMeta,
        cdDurationSec.isAcceptableOrUnknown(
          data['cd_duration_sec']!,
          _cdDurationSecMeta,
        ),
      );
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    if (data.containsKey('rep_load')) {
      context.handle(
        _repLoadMeta,
        repLoad.isAcceptableOrUnknown(data['rep_load']!, _repLoadMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Session map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Session(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      startedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date_time'],
      )!,
      planId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}plan_id'],
      ),
      templateText: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}template_text'],
      )!,
      distanceMainM: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}distance_main_m'],
      ),
      durationMainSec: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}duration_main_sec'],
      ),
      paceSecPerKm: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}pace_sec_per_km'],
      ),
      zone: $SessionsTable.$converterzonen.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}zone'],
        ),
      ),
      rpeValue: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}rpe_value'],
      ),
      restType: $SessionsTable.$converterrestTypen.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}rest_type'],
        ),
      ),
      restDurationSec: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}rest_duration_sec'],
      ),
      restDistanceM: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}rest_distance_m'],
      ),
      wuDistanceM: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}wu_distance_m'],
      ),
      wuDurationSec: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}wu_duration_sec'],
      ),
      cdDistanceM: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}cd_distance_m'],
      ),
      cdDurationSec: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}cd_duration_sec'],
      ),
      status: $SessionsTable.$converterstatus.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}status'],
        )!,
      ),
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
      repLoad: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}rep_load'],
      ),
    );
  }

  @override
  $SessionsTable createAlias(String alias) {
    return $SessionsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<Zone, String, String> $converterzone =
      const EnumNameConverter<Zone>(Zone.values);
  static JsonTypeConverter2<Zone?, String?, String?> $converterzonen =
      JsonTypeConverter2.asNullable($converterzone);
  static JsonTypeConverter2<RestType, String, String> $converterrestType =
      const EnumNameConverter<RestType>(RestType.values);
  static JsonTypeConverter2<RestType?, String?, String?> $converterrestTypen =
      JsonTypeConverter2.asNullable($converterrestType);
  static JsonTypeConverter2<SessionStatus, String, String> $converterstatus =
      const EnumNameConverter<SessionStatus>(SessionStatus.values);
}

class Session extends DataClass implements Insertable<Session> {
  final String id;
  final DateTime startedAt;
  final String? planId;
  final String templateText;
  final int? distanceMainM;
  final int? durationMainSec;
  final int? paceSecPerKm;
  final Zone? zone;
  final int? rpeValue;
  final RestType? restType;
  final int? restDurationSec;
  final int? restDistanceM;
  final int? wuDistanceM;
  final int? wuDurationSec;
  final int? cdDistanceM;
  final int? cdDurationSec;
  final SessionStatus status;
  final String? note;
  final int? repLoad;
  const Session({
    required this.id,
    required this.startedAt,
    this.planId,
    required this.templateText,
    this.distanceMainM,
    this.durationMainSec,
    this.paceSecPerKm,
    this.zone,
    this.rpeValue,
    this.restType,
    this.restDurationSec,
    this.restDistanceM,
    this.wuDistanceM,
    this.wuDurationSec,
    this.cdDistanceM,
    this.cdDurationSec,
    required this.status,
    this.note,
    this.repLoad,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['date_time'] = Variable<DateTime>(startedAt);
    if (!nullToAbsent || planId != null) {
      map['plan_id'] = Variable<String>(planId);
    }
    map['template_text'] = Variable<String>(templateText);
    if (!nullToAbsent || distanceMainM != null) {
      map['distance_main_m'] = Variable<int>(distanceMainM);
    }
    if (!nullToAbsent || durationMainSec != null) {
      map['duration_main_sec'] = Variable<int>(durationMainSec);
    }
    if (!nullToAbsent || paceSecPerKm != null) {
      map['pace_sec_per_km'] = Variable<int>(paceSecPerKm);
    }
    if (!nullToAbsent || zone != null) {
      map['zone'] = Variable<String>(
        $SessionsTable.$converterzonen.toSql(zone),
      );
    }
    if (!nullToAbsent || rpeValue != null) {
      map['rpe_value'] = Variable<int>(rpeValue);
    }
    if (!nullToAbsent || restType != null) {
      map['rest_type'] = Variable<String>(
        $SessionsTable.$converterrestTypen.toSql(restType),
      );
    }
    if (!nullToAbsent || restDurationSec != null) {
      map['rest_duration_sec'] = Variable<int>(restDurationSec);
    }
    if (!nullToAbsent || restDistanceM != null) {
      map['rest_distance_m'] = Variable<int>(restDistanceM);
    }
    if (!nullToAbsent || wuDistanceM != null) {
      map['wu_distance_m'] = Variable<int>(wuDistanceM);
    }
    if (!nullToAbsent || wuDurationSec != null) {
      map['wu_duration_sec'] = Variable<int>(wuDurationSec);
    }
    if (!nullToAbsent || cdDistanceM != null) {
      map['cd_distance_m'] = Variable<int>(cdDistanceM);
    }
    if (!nullToAbsent || cdDurationSec != null) {
      map['cd_duration_sec'] = Variable<int>(cdDurationSec);
    }
    {
      map['status'] = Variable<String>(
        $SessionsTable.$converterstatus.toSql(status),
      );
    }
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    if (!nullToAbsent || repLoad != null) {
      map['rep_load'] = Variable<int>(repLoad);
    }
    return map;
  }

  SessionsCompanion toCompanion(bool nullToAbsent) {
    return SessionsCompanion(
      id: Value(id),
      startedAt: Value(startedAt),
      planId: planId == null && nullToAbsent
          ? const Value.absent()
          : Value(planId),
      templateText: Value(templateText),
      distanceMainM: distanceMainM == null && nullToAbsent
          ? const Value.absent()
          : Value(distanceMainM),
      durationMainSec: durationMainSec == null && nullToAbsent
          ? const Value.absent()
          : Value(durationMainSec),
      paceSecPerKm: paceSecPerKm == null && nullToAbsent
          ? const Value.absent()
          : Value(paceSecPerKm),
      zone: zone == null && nullToAbsent ? const Value.absent() : Value(zone),
      rpeValue: rpeValue == null && nullToAbsent
          ? const Value.absent()
          : Value(rpeValue),
      restType: restType == null && nullToAbsent
          ? const Value.absent()
          : Value(restType),
      restDurationSec: restDurationSec == null && nullToAbsent
          ? const Value.absent()
          : Value(restDurationSec),
      restDistanceM: restDistanceM == null && nullToAbsent
          ? const Value.absent()
          : Value(restDistanceM),
      wuDistanceM: wuDistanceM == null && nullToAbsent
          ? const Value.absent()
          : Value(wuDistanceM),
      wuDurationSec: wuDurationSec == null && nullToAbsent
          ? const Value.absent()
          : Value(wuDurationSec),
      cdDistanceM: cdDistanceM == null && nullToAbsent
          ? const Value.absent()
          : Value(cdDistanceM),
      cdDurationSec: cdDurationSec == null && nullToAbsent
          ? const Value.absent()
          : Value(cdDurationSec),
      status: Value(status),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      repLoad: repLoad == null && nullToAbsent
          ? const Value.absent()
          : Value(repLoad),
    );
  }

  factory Session.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Session(
      id: serializer.fromJson<String>(json['id']),
      startedAt: serializer.fromJson<DateTime>(json['startedAt']),
      planId: serializer.fromJson<String?>(json['planId']),
      templateText: serializer.fromJson<String>(json['templateText']),
      distanceMainM: serializer.fromJson<int?>(json['distanceMainM']),
      durationMainSec: serializer.fromJson<int?>(json['durationMainSec']),
      paceSecPerKm: serializer.fromJson<int?>(json['paceSecPerKm']),
      zone: $SessionsTable.$converterzonen.fromJson(
        serializer.fromJson<String?>(json['zone']),
      ),
      rpeValue: serializer.fromJson<int?>(json['rpeValue']),
      restType: $SessionsTable.$converterrestTypen.fromJson(
        serializer.fromJson<String?>(json['restType']),
      ),
      restDurationSec: serializer.fromJson<int?>(json['restDurationSec']),
      restDistanceM: serializer.fromJson<int?>(json['restDistanceM']),
      wuDistanceM: serializer.fromJson<int?>(json['wuDistanceM']),
      wuDurationSec: serializer.fromJson<int?>(json['wuDurationSec']),
      cdDistanceM: serializer.fromJson<int?>(json['cdDistanceM']),
      cdDurationSec: serializer.fromJson<int?>(json['cdDurationSec']),
      status: $SessionsTable.$converterstatus.fromJson(
        serializer.fromJson<String>(json['status']),
      ),
      note: serializer.fromJson<String?>(json['note']),
      repLoad: serializer.fromJson<int?>(json['repLoad']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'startedAt': serializer.toJson<DateTime>(startedAt),
      'planId': serializer.toJson<String?>(planId),
      'templateText': serializer.toJson<String>(templateText),
      'distanceMainM': serializer.toJson<int?>(distanceMainM),
      'durationMainSec': serializer.toJson<int?>(durationMainSec),
      'paceSecPerKm': serializer.toJson<int?>(paceSecPerKm),
      'zone': serializer.toJson<String?>(
        $SessionsTable.$converterzonen.toJson(zone),
      ),
      'rpeValue': serializer.toJson<int?>(rpeValue),
      'restType': serializer.toJson<String?>(
        $SessionsTable.$converterrestTypen.toJson(restType),
      ),
      'restDurationSec': serializer.toJson<int?>(restDurationSec),
      'restDistanceM': serializer.toJson<int?>(restDistanceM),
      'wuDistanceM': serializer.toJson<int?>(wuDistanceM),
      'wuDurationSec': serializer.toJson<int?>(wuDurationSec),
      'cdDistanceM': serializer.toJson<int?>(cdDistanceM),
      'cdDurationSec': serializer.toJson<int?>(cdDurationSec),
      'status': serializer.toJson<String>(
        $SessionsTable.$converterstatus.toJson(status),
      ),
      'note': serializer.toJson<String?>(note),
      'repLoad': serializer.toJson<int?>(repLoad),
    };
  }

  Session copyWith({
    String? id,
    DateTime? startedAt,
    Value<String?> planId = const Value.absent(),
    String? templateText,
    Value<int?> distanceMainM = const Value.absent(),
    Value<int?> durationMainSec = const Value.absent(),
    Value<int?> paceSecPerKm = const Value.absent(),
    Value<Zone?> zone = const Value.absent(),
    Value<int?> rpeValue = const Value.absent(),
    Value<RestType?> restType = const Value.absent(),
    Value<int?> restDurationSec = const Value.absent(),
    Value<int?> restDistanceM = const Value.absent(),
    Value<int?> wuDistanceM = const Value.absent(),
    Value<int?> wuDurationSec = const Value.absent(),
    Value<int?> cdDistanceM = const Value.absent(),
    Value<int?> cdDurationSec = const Value.absent(),
    SessionStatus? status,
    Value<String?> note = const Value.absent(),
    Value<int?> repLoad = const Value.absent(),
  }) => Session(
    id: id ?? this.id,
    startedAt: startedAt ?? this.startedAt,
    planId: planId.present ? planId.value : this.planId,
    templateText: templateText ?? this.templateText,
    distanceMainM: distanceMainM.present
        ? distanceMainM.value
        : this.distanceMainM,
    durationMainSec: durationMainSec.present
        ? durationMainSec.value
        : this.durationMainSec,
    paceSecPerKm: paceSecPerKm.present ? paceSecPerKm.value : this.paceSecPerKm,
    zone: zone.present ? zone.value : this.zone,
    rpeValue: rpeValue.present ? rpeValue.value : this.rpeValue,
    restType: restType.present ? restType.value : this.restType,
    restDurationSec: restDurationSec.present
        ? restDurationSec.value
        : this.restDurationSec,
    restDistanceM: restDistanceM.present
        ? restDistanceM.value
        : this.restDistanceM,
    wuDistanceM: wuDistanceM.present ? wuDistanceM.value : this.wuDistanceM,
    wuDurationSec: wuDurationSec.present
        ? wuDurationSec.value
        : this.wuDurationSec,
    cdDistanceM: cdDistanceM.present ? cdDistanceM.value : this.cdDistanceM,
    cdDurationSec: cdDurationSec.present
        ? cdDurationSec.value
        : this.cdDurationSec,
    status: status ?? this.status,
    note: note.present ? note.value : this.note,
    repLoad: repLoad.present ? repLoad.value : this.repLoad,
  );
  Session copyWithCompanion(SessionsCompanion data) {
    return Session(
      id: data.id.present ? data.id.value : this.id,
      startedAt: data.startedAt.present ? data.startedAt.value : this.startedAt,
      planId: data.planId.present ? data.planId.value : this.planId,
      templateText: data.templateText.present
          ? data.templateText.value
          : this.templateText,
      distanceMainM: data.distanceMainM.present
          ? data.distanceMainM.value
          : this.distanceMainM,
      durationMainSec: data.durationMainSec.present
          ? data.durationMainSec.value
          : this.durationMainSec,
      paceSecPerKm: data.paceSecPerKm.present
          ? data.paceSecPerKm.value
          : this.paceSecPerKm,
      zone: data.zone.present ? data.zone.value : this.zone,
      rpeValue: data.rpeValue.present ? data.rpeValue.value : this.rpeValue,
      restType: data.restType.present ? data.restType.value : this.restType,
      restDurationSec: data.restDurationSec.present
          ? data.restDurationSec.value
          : this.restDurationSec,
      restDistanceM: data.restDistanceM.present
          ? data.restDistanceM.value
          : this.restDistanceM,
      wuDistanceM: data.wuDistanceM.present
          ? data.wuDistanceM.value
          : this.wuDistanceM,
      wuDurationSec: data.wuDurationSec.present
          ? data.wuDurationSec.value
          : this.wuDurationSec,
      cdDistanceM: data.cdDistanceM.present
          ? data.cdDistanceM.value
          : this.cdDistanceM,
      cdDurationSec: data.cdDurationSec.present
          ? data.cdDurationSec.value
          : this.cdDurationSec,
      status: data.status.present ? data.status.value : this.status,
      note: data.note.present ? data.note.value : this.note,
      repLoad: data.repLoad.present ? data.repLoad.value : this.repLoad,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Session(')
          ..write('id: $id, ')
          ..write('startedAt: $startedAt, ')
          ..write('planId: $planId, ')
          ..write('templateText: $templateText, ')
          ..write('distanceMainM: $distanceMainM, ')
          ..write('durationMainSec: $durationMainSec, ')
          ..write('paceSecPerKm: $paceSecPerKm, ')
          ..write('zone: $zone, ')
          ..write('rpeValue: $rpeValue, ')
          ..write('restType: $restType, ')
          ..write('restDurationSec: $restDurationSec, ')
          ..write('restDistanceM: $restDistanceM, ')
          ..write('wuDistanceM: $wuDistanceM, ')
          ..write('wuDurationSec: $wuDurationSec, ')
          ..write('cdDistanceM: $cdDistanceM, ')
          ..write('cdDurationSec: $cdDurationSec, ')
          ..write('status: $status, ')
          ..write('note: $note, ')
          ..write('repLoad: $repLoad')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    startedAt,
    planId,
    templateText,
    distanceMainM,
    durationMainSec,
    paceSecPerKm,
    zone,
    rpeValue,
    restType,
    restDurationSec,
    restDistanceM,
    wuDistanceM,
    wuDurationSec,
    cdDistanceM,
    cdDurationSec,
    status,
    note,
    repLoad,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Session &&
          other.id == this.id &&
          other.startedAt == this.startedAt &&
          other.planId == this.planId &&
          other.templateText == this.templateText &&
          other.distanceMainM == this.distanceMainM &&
          other.durationMainSec == this.durationMainSec &&
          other.paceSecPerKm == this.paceSecPerKm &&
          other.zone == this.zone &&
          other.rpeValue == this.rpeValue &&
          other.restType == this.restType &&
          other.restDurationSec == this.restDurationSec &&
          other.restDistanceM == this.restDistanceM &&
          other.wuDistanceM == this.wuDistanceM &&
          other.wuDurationSec == this.wuDurationSec &&
          other.cdDistanceM == this.cdDistanceM &&
          other.cdDurationSec == this.cdDurationSec &&
          other.status == this.status &&
          other.note == this.note &&
          other.repLoad == this.repLoad);
}

class SessionsCompanion extends UpdateCompanion<Session> {
  final Value<String> id;
  final Value<DateTime> startedAt;
  final Value<String?> planId;
  final Value<String> templateText;
  final Value<int?> distanceMainM;
  final Value<int?> durationMainSec;
  final Value<int?> paceSecPerKm;
  final Value<Zone?> zone;
  final Value<int?> rpeValue;
  final Value<RestType?> restType;
  final Value<int?> restDurationSec;
  final Value<int?> restDistanceM;
  final Value<int?> wuDistanceM;
  final Value<int?> wuDurationSec;
  final Value<int?> cdDistanceM;
  final Value<int?> cdDurationSec;
  final Value<SessionStatus> status;
  final Value<String?> note;
  final Value<int?> repLoad;
  final Value<int> rowid;
  const SessionsCompanion({
    this.id = const Value.absent(),
    this.startedAt = const Value.absent(),
    this.planId = const Value.absent(),
    this.templateText = const Value.absent(),
    this.distanceMainM = const Value.absent(),
    this.durationMainSec = const Value.absent(),
    this.paceSecPerKm = const Value.absent(),
    this.zone = const Value.absent(),
    this.rpeValue = const Value.absent(),
    this.restType = const Value.absent(),
    this.restDurationSec = const Value.absent(),
    this.restDistanceM = const Value.absent(),
    this.wuDistanceM = const Value.absent(),
    this.wuDurationSec = const Value.absent(),
    this.cdDistanceM = const Value.absent(),
    this.cdDurationSec = const Value.absent(),
    this.status = const Value.absent(),
    this.note = const Value.absent(),
    this.repLoad = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SessionsCompanion.insert({
    required String id,
    required DateTime startedAt,
    this.planId = const Value.absent(),
    required String templateText,
    this.distanceMainM = const Value.absent(),
    this.durationMainSec = const Value.absent(),
    this.paceSecPerKm = const Value.absent(),
    this.zone = const Value.absent(),
    this.rpeValue = const Value.absent(),
    this.restType = const Value.absent(),
    this.restDurationSec = const Value.absent(),
    this.restDistanceM = const Value.absent(),
    this.wuDistanceM = const Value.absent(),
    this.wuDurationSec = const Value.absent(),
    this.cdDistanceM = const Value.absent(),
    this.cdDurationSec = const Value.absent(),
    required SessionStatus status,
    this.note = const Value.absent(),
    this.repLoad = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       startedAt = Value(startedAt),
       templateText = Value(templateText),
       status = Value(status);
  static Insertable<Session> custom({
    Expression<String>? id,
    Expression<DateTime>? startedAt,
    Expression<String>? planId,
    Expression<String>? templateText,
    Expression<int>? distanceMainM,
    Expression<int>? durationMainSec,
    Expression<int>? paceSecPerKm,
    Expression<String>? zone,
    Expression<int>? rpeValue,
    Expression<String>? restType,
    Expression<int>? restDurationSec,
    Expression<int>? restDistanceM,
    Expression<int>? wuDistanceM,
    Expression<int>? wuDurationSec,
    Expression<int>? cdDistanceM,
    Expression<int>? cdDurationSec,
    Expression<String>? status,
    Expression<String>? note,
    Expression<int>? repLoad,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (startedAt != null) 'date_time': startedAt,
      if (planId != null) 'plan_id': planId,
      if (templateText != null) 'template_text': templateText,
      if (distanceMainM != null) 'distance_main_m': distanceMainM,
      if (durationMainSec != null) 'duration_main_sec': durationMainSec,
      if (paceSecPerKm != null) 'pace_sec_per_km': paceSecPerKm,
      if (zone != null) 'zone': zone,
      if (rpeValue != null) 'rpe_value': rpeValue,
      if (restType != null) 'rest_type': restType,
      if (restDurationSec != null) 'rest_duration_sec': restDurationSec,
      if (restDistanceM != null) 'rest_distance_m': restDistanceM,
      if (wuDistanceM != null) 'wu_distance_m': wuDistanceM,
      if (wuDurationSec != null) 'wu_duration_sec': wuDurationSec,
      if (cdDistanceM != null) 'cd_distance_m': cdDistanceM,
      if (cdDurationSec != null) 'cd_duration_sec': cdDurationSec,
      if (status != null) 'status': status,
      if (note != null) 'note': note,
      if (repLoad != null) 'rep_load': repLoad,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SessionsCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? startedAt,
    Value<String?>? planId,
    Value<String>? templateText,
    Value<int?>? distanceMainM,
    Value<int?>? durationMainSec,
    Value<int?>? paceSecPerKm,
    Value<Zone?>? zone,
    Value<int?>? rpeValue,
    Value<RestType?>? restType,
    Value<int?>? restDurationSec,
    Value<int?>? restDistanceM,
    Value<int?>? wuDistanceM,
    Value<int?>? wuDurationSec,
    Value<int?>? cdDistanceM,
    Value<int?>? cdDurationSec,
    Value<SessionStatus>? status,
    Value<String?>? note,
    Value<int?>? repLoad,
    Value<int>? rowid,
  }) {
    return SessionsCompanion(
      id: id ?? this.id,
      startedAt: startedAt ?? this.startedAt,
      planId: planId ?? this.planId,
      templateText: templateText ?? this.templateText,
      distanceMainM: distanceMainM ?? this.distanceMainM,
      durationMainSec: durationMainSec ?? this.durationMainSec,
      paceSecPerKm: paceSecPerKm ?? this.paceSecPerKm,
      zone: zone ?? this.zone,
      rpeValue: rpeValue ?? this.rpeValue,
      restType: restType ?? this.restType,
      restDurationSec: restDurationSec ?? this.restDurationSec,
      restDistanceM: restDistanceM ?? this.restDistanceM,
      wuDistanceM: wuDistanceM ?? this.wuDistanceM,
      wuDurationSec: wuDurationSec ?? this.wuDurationSec,
      cdDistanceM: cdDistanceM ?? this.cdDistanceM,
      cdDurationSec: cdDurationSec ?? this.cdDurationSec,
      status: status ?? this.status,
      note: note ?? this.note,
      repLoad: repLoad ?? this.repLoad,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (startedAt.present) {
      map['date_time'] = Variable<DateTime>(startedAt.value);
    }
    if (planId.present) {
      map['plan_id'] = Variable<String>(planId.value);
    }
    if (templateText.present) {
      map['template_text'] = Variable<String>(templateText.value);
    }
    if (distanceMainM.present) {
      map['distance_main_m'] = Variable<int>(distanceMainM.value);
    }
    if (durationMainSec.present) {
      map['duration_main_sec'] = Variable<int>(durationMainSec.value);
    }
    if (paceSecPerKm.present) {
      map['pace_sec_per_km'] = Variable<int>(paceSecPerKm.value);
    }
    if (zone.present) {
      map['zone'] = Variable<String>(
        $SessionsTable.$converterzonen.toSql(zone.value),
      );
    }
    if (rpeValue.present) {
      map['rpe_value'] = Variable<int>(rpeValue.value);
    }
    if (restType.present) {
      map['rest_type'] = Variable<String>(
        $SessionsTable.$converterrestTypen.toSql(restType.value),
      );
    }
    if (restDurationSec.present) {
      map['rest_duration_sec'] = Variable<int>(restDurationSec.value);
    }
    if (restDistanceM.present) {
      map['rest_distance_m'] = Variable<int>(restDistanceM.value);
    }
    if (wuDistanceM.present) {
      map['wu_distance_m'] = Variable<int>(wuDistanceM.value);
    }
    if (wuDurationSec.present) {
      map['wu_duration_sec'] = Variable<int>(wuDurationSec.value);
    }
    if (cdDistanceM.present) {
      map['cd_distance_m'] = Variable<int>(cdDistanceM.value);
    }
    if (cdDurationSec.present) {
      map['cd_duration_sec'] = Variable<int>(cdDurationSec.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(
        $SessionsTable.$converterstatus.toSql(status.value),
      );
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (repLoad.present) {
      map['rep_load'] = Variable<int>(repLoad.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SessionsCompanion(')
          ..write('id: $id, ')
          ..write('startedAt: $startedAt, ')
          ..write('planId: $planId, ')
          ..write('templateText: $templateText, ')
          ..write('distanceMainM: $distanceMainM, ')
          ..write('durationMainSec: $durationMainSec, ')
          ..write('paceSecPerKm: $paceSecPerKm, ')
          ..write('zone: $zone, ')
          ..write('rpeValue: $rpeValue, ')
          ..write('restType: $restType, ')
          ..write('restDurationSec: $restDurationSec, ')
          ..write('restDistanceM: $restDistanceM, ')
          ..write('wuDistanceM: $wuDistanceM, ')
          ..write('wuDurationSec: $wuDurationSec, ')
          ..write('cdDistanceM: $cdDistanceM, ')
          ..write('cdDurationSec: $cdDurationSec, ')
          ..write('status: $status, ')
          ..write('note: $note, ')
          ..write('repLoad: $repLoad, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $PersonalBestsTable personalBests = $PersonalBestsTable(this);
  late final $PlansTable plans = $PlansTable(this);
  late final $SessionsTable sessions = $SessionsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    personalBests,
    plans,
    sessions,
  ];
}

typedef $$PersonalBestsTableCreateCompanionBuilder =
    PersonalBestsCompanion Function({
      required String id,
      required PbEvent event,
      required int timeMs,
      Value<DateTime?> date,
      Value<String?> note,
      Value<int> rowid,
    });
typedef $$PersonalBestsTableUpdateCompanionBuilder =
    PersonalBestsCompanion Function({
      Value<String> id,
      Value<PbEvent> event,
      Value<int> timeMs,
      Value<DateTime?> date,
      Value<String?> note,
      Value<int> rowid,
    });

class $$PersonalBestsTableFilterComposer
    extends Composer<_$AppDatabase, $PersonalBestsTable> {
  $$PersonalBestsTableFilterComposer({
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

  ColumnWithTypeConverterFilters<PbEvent, PbEvent, String> get event =>
      $composableBuilder(
        column: $table.event,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<int> get timeMs => $composableBuilder(
    column: $table.timeMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PersonalBestsTableOrderingComposer
    extends Composer<_$AppDatabase, $PersonalBestsTable> {
  $$PersonalBestsTableOrderingComposer({
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

  ColumnOrderings<String> get event => $composableBuilder(
    column: $table.event,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get timeMs => $composableBuilder(
    column: $table.timeMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PersonalBestsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PersonalBestsTable> {
  $$PersonalBestsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumnWithTypeConverter<PbEvent, String> get event =>
      $composableBuilder(column: $table.event, builder: (column) => column);

  GeneratedColumn<int> get timeMs =>
      $composableBuilder(column: $table.timeMs, builder: (column) => column);

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);
}

class $$PersonalBestsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PersonalBestsTable,
          PersonalBest,
          $$PersonalBestsTableFilterComposer,
          $$PersonalBestsTableOrderingComposer,
          $$PersonalBestsTableAnnotationComposer,
          $$PersonalBestsTableCreateCompanionBuilder,
          $$PersonalBestsTableUpdateCompanionBuilder,
          (
            PersonalBest,
            BaseReferences<_$AppDatabase, $PersonalBestsTable, PersonalBest>,
          ),
          PersonalBest,
          PrefetchHooks Function()
        > {
  $$PersonalBestsTableTableManager(_$AppDatabase db, $PersonalBestsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PersonalBestsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PersonalBestsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PersonalBestsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<PbEvent> event = const Value.absent(),
                Value<int> timeMs = const Value.absent(),
                Value<DateTime?> date = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PersonalBestsCompanion(
                id: id,
                event: event,
                timeMs: timeMs,
                date: date,
                note: note,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required PbEvent event,
                required int timeMs,
                Value<DateTime?> date = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PersonalBestsCompanion.insert(
                id: id,
                event: event,
                timeMs: timeMs,
                date: date,
                note: note,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PersonalBestsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PersonalBestsTable,
      PersonalBest,
      $$PersonalBestsTableFilterComposer,
      $$PersonalBestsTableOrderingComposer,
      $$PersonalBestsTableAnnotationComposer,
      $$PersonalBestsTableCreateCompanionBuilder,
      $$PersonalBestsTableUpdateCompanionBuilder,
      (
        PersonalBest,
        BaseReferences<_$AppDatabase, $PersonalBestsTable, PersonalBest>,
      ),
      PersonalBest,
      PrefetchHooks Function()
    >;
typedef $$PlansTableCreateCompanionBuilder =
    PlansCompanion Function({
      required String id,
      required DateTime date,
      required String templateText,
      Value<String?> note,
      Value<int> rowid,
    });
typedef $$PlansTableUpdateCompanionBuilder =
    PlansCompanion Function({
      Value<String> id,
      Value<DateTime> date,
      Value<String> templateText,
      Value<String?> note,
      Value<int> rowid,
    });

final class $$PlansTableReferences
    extends BaseReferences<_$AppDatabase, $PlansTable, Plan> {
  $$PlansTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$SessionsTable, List<Session>> _sessionsRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.sessions,
    aliasName: $_aliasNameGenerator(db.plans.id, db.sessions.planId),
  );

  $$SessionsTableProcessedTableManager get sessionsRefs {
    final manager = $$SessionsTableTableManager(
      $_db,
      $_db.sessions,
    ).filter((f) => f.planId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_sessionsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$PlansTableFilterComposer extends Composer<_$AppDatabase, $PlansTable> {
  $$PlansTableFilterComposer({
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

  ColumnFilters<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get templateText => $composableBuilder(
    column: $table.templateText,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> sessionsRefs(
    Expression<bool> Function($$SessionsTableFilterComposer f) f,
  ) {
    final $$SessionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.sessions,
      getReferencedColumn: (t) => t.planId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SessionsTableFilterComposer(
            $db: $db,
            $table: $db.sessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$PlansTableOrderingComposer
    extends Composer<_$AppDatabase, $PlansTable> {
  $$PlansTableOrderingComposer({
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

  ColumnOrderings<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get templateText => $composableBuilder(
    column: $table.templateText,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PlansTableAnnotationComposer
    extends Composer<_$AppDatabase, $PlansTable> {
  $$PlansTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<String> get templateText => $composableBuilder(
    column: $table.templateText,
    builder: (column) => column,
  );

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  Expression<T> sessionsRefs<T extends Object>(
    Expression<T> Function($$SessionsTableAnnotationComposer a) f,
  ) {
    final $$SessionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.sessions,
      getReferencedColumn: (t) => t.planId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SessionsTableAnnotationComposer(
            $db: $db,
            $table: $db.sessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$PlansTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PlansTable,
          Plan,
          $$PlansTableFilterComposer,
          $$PlansTableOrderingComposer,
          $$PlansTableAnnotationComposer,
          $$PlansTableCreateCompanionBuilder,
          $$PlansTableUpdateCompanionBuilder,
          (Plan, $$PlansTableReferences),
          Plan,
          PrefetchHooks Function({bool sessionsRefs})
        > {
  $$PlansTableTableManager(_$AppDatabase db, $PlansTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PlansTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PlansTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PlansTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> date = const Value.absent(),
                Value<String> templateText = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PlansCompanion(
                id: id,
                date: date,
                templateText: templateText,
                note: note,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required DateTime date,
                required String templateText,
                Value<String?> note = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PlansCompanion.insert(
                id: id,
                date: date,
                templateText: templateText,
                note: note,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $$PlansTableReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback: ({sessionsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (sessionsRefs) db.sessions],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (sessionsRefs)
                    await $_getPrefetchedData<Plan, $PlansTable, Session>(
                      currentTable: table,
                      referencedTable: $$PlansTableReferences
                          ._sessionsRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$PlansTableReferences(db, table, p0).sessionsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.planId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$PlansTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PlansTable,
      Plan,
      $$PlansTableFilterComposer,
      $$PlansTableOrderingComposer,
      $$PlansTableAnnotationComposer,
      $$PlansTableCreateCompanionBuilder,
      $$PlansTableUpdateCompanionBuilder,
      (Plan, $$PlansTableReferences),
      Plan,
      PrefetchHooks Function({bool sessionsRefs})
    >;
typedef $$SessionsTableCreateCompanionBuilder =
    SessionsCompanion Function({
      required String id,
      required DateTime startedAt,
      Value<String?> planId,
      required String templateText,
      Value<int?> distanceMainM,
      Value<int?> durationMainSec,
      Value<int?> paceSecPerKm,
      Value<Zone?> zone,
      Value<int?> rpeValue,
      Value<RestType?> restType,
      Value<int?> restDurationSec,
      Value<int?> restDistanceM,
      Value<int?> wuDistanceM,
      Value<int?> wuDurationSec,
      Value<int?> cdDistanceM,
      Value<int?> cdDurationSec,
      required SessionStatus status,
      Value<String?> note,
      Value<int?> repLoad,
      Value<int> rowid,
    });
typedef $$SessionsTableUpdateCompanionBuilder =
    SessionsCompanion Function({
      Value<String> id,
      Value<DateTime> startedAt,
      Value<String?> planId,
      Value<String> templateText,
      Value<int?> distanceMainM,
      Value<int?> durationMainSec,
      Value<int?> paceSecPerKm,
      Value<Zone?> zone,
      Value<int?> rpeValue,
      Value<RestType?> restType,
      Value<int?> restDurationSec,
      Value<int?> restDistanceM,
      Value<int?> wuDistanceM,
      Value<int?> wuDurationSec,
      Value<int?> cdDistanceM,
      Value<int?> cdDurationSec,
      Value<SessionStatus> status,
      Value<String?> note,
      Value<int?> repLoad,
      Value<int> rowid,
    });

final class $$SessionsTableReferences
    extends BaseReferences<_$AppDatabase, $SessionsTable, Session> {
  $$SessionsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $PlansTable _planIdTable(_$AppDatabase db) => db.plans.createAlias(
    $_aliasNameGenerator(db.sessions.planId, db.plans.id),
  );

  $$PlansTableProcessedTableManager? get planId {
    final $_column = $_itemColumn<String>('plan_id');
    if ($_column == null) return null;
    final manager = $$PlansTableTableManager(
      $_db,
      $_db.plans,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_planIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$SessionsTableFilterComposer
    extends Composer<_$AppDatabase, $SessionsTable> {
  $$SessionsTableFilterComposer({
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

  ColumnFilters<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get templateText => $composableBuilder(
    column: $table.templateText,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get distanceMainM => $composableBuilder(
    column: $table.distanceMainM,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get durationMainSec => $composableBuilder(
    column: $table.durationMainSec,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get paceSecPerKm => $composableBuilder(
    column: $table.paceSecPerKm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<Zone?, Zone, String> get zone =>
      $composableBuilder(
        column: $table.zone,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<int> get rpeValue => $composableBuilder(
    column: $table.rpeValue,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<RestType?, RestType, String> get restType =>
      $composableBuilder(
        column: $table.restType,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<int> get restDurationSec => $composableBuilder(
    column: $table.restDurationSec,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get restDistanceM => $composableBuilder(
    column: $table.restDistanceM,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get wuDistanceM => $composableBuilder(
    column: $table.wuDistanceM,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get wuDurationSec => $composableBuilder(
    column: $table.wuDurationSec,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get cdDistanceM => $composableBuilder(
    column: $table.cdDistanceM,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get cdDurationSec => $composableBuilder(
    column: $table.cdDurationSec,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<SessionStatus, SessionStatus, String>
  get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get repLoad => $composableBuilder(
    column: $table.repLoad,
    builder: (column) => ColumnFilters(column),
  );

  $$PlansTableFilterComposer get planId {
    final $$PlansTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.planId,
      referencedTable: $db.plans,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlansTableFilterComposer(
            $db: $db,
            $table: $db.plans,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SessionsTableOrderingComposer
    extends Composer<_$AppDatabase, $SessionsTable> {
  $$SessionsTableOrderingComposer({
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

  ColumnOrderings<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get templateText => $composableBuilder(
    column: $table.templateText,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get distanceMainM => $composableBuilder(
    column: $table.distanceMainM,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get durationMainSec => $composableBuilder(
    column: $table.durationMainSec,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get paceSecPerKm => $composableBuilder(
    column: $table.paceSecPerKm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get zone => $composableBuilder(
    column: $table.zone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get rpeValue => $composableBuilder(
    column: $table.rpeValue,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get restType => $composableBuilder(
    column: $table.restType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get restDurationSec => $composableBuilder(
    column: $table.restDurationSec,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get restDistanceM => $composableBuilder(
    column: $table.restDistanceM,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get wuDistanceM => $composableBuilder(
    column: $table.wuDistanceM,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get wuDurationSec => $composableBuilder(
    column: $table.wuDurationSec,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get cdDistanceM => $composableBuilder(
    column: $table.cdDistanceM,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get cdDurationSec => $composableBuilder(
    column: $table.cdDurationSec,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get repLoad => $composableBuilder(
    column: $table.repLoad,
    builder: (column) => ColumnOrderings(column),
  );

  $$PlansTableOrderingComposer get planId {
    final $$PlansTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.planId,
      referencedTable: $db.plans,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlansTableOrderingComposer(
            $db: $db,
            $table: $db.plans,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SessionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SessionsTable> {
  $$SessionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get startedAt =>
      $composableBuilder(column: $table.startedAt, builder: (column) => column);

  GeneratedColumn<String> get templateText => $composableBuilder(
    column: $table.templateText,
    builder: (column) => column,
  );

  GeneratedColumn<int> get distanceMainM => $composableBuilder(
    column: $table.distanceMainM,
    builder: (column) => column,
  );

  GeneratedColumn<int> get durationMainSec => $composableBuilder(
    column: $table.durationMainSec,
    builder: (column) => column,
  );

  GeneratedColumn<int> get paceSecPerKm => $composableBuilder(
    column: $table.paceSecPerKm,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<Zone?, String> get zone =>
      $composableBuilder(column: $table.zone, builder: (column) => column);

  GeneratedColumn<int> get rpeValue =>
      $composableBuilder(column: $table.rpeValue, builder: (column) => column);

  GeneratedColumnWithTypeConverter<RestType?, String> get restType =>
      $composableBuilder(column: $table.restType, builder: (column) => column);

  GeneratedColumn<int> get restDurationSec => $composableBuilder(
    column: $table.restDurationSec,
    builder: (column) => column,
  );

  GeneratedColumn<int> get restDistanceM => $composableBuilder(
    column: $table.restDistanceM,
    builder: (column) => column,
  );

  GeneratedColumn<int> get wuDistanceM => $composableBuilder(
    column: $table.wuDistanceM,
    builder: (column) => column,
  );

  GeneratedColumn<int> get wuDurationSec => $composableBuilder(
    column: $table.wuDurationSec,
    builder: (column) => column,
  );

  GeneratedColumn<int> get cdDistanceM => $composableBuilder(
    column: $table.cdDistanceM,
    builder: (column) => column,
  );

  GeneratedColumn<int> get cdDurationSec => $composableBuilder(
    column: $table.cdDurationSec,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<SessionStatus, String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<int> get repLoad =>
      $composableBuilder(column: $table.repLoad, builder: (column) => column);

  $$PlansTableAnnotationComposer get planId {
    final $$PlansTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.planId,
      referencedTable: $db.plans,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlansTableAnnotationComposer(
            $db: $db,
            $table: $db.plans,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SessionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SessionsTable,
          Session,
          $$SessionsTableFilterComposer,
          $$SessionsTableOrderingComposer,
          $$SessionsTableAnnotationComposer,
          $$SessionsTableCreateCompanionBuilder,
          $$SessionsTableUpdateCompanionBuilder,
          (Session, $$SessionsTableReferences),
          Session,
          PrefetchHooks Function({bool planId})
        > {
  $$SessionsTableTableManager(_$AppDatabase db, $SessionsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SessionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SessionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SessionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> startedAt = const Value.absent(),
                Value<String?> planId = const Value.absent(),
                Value<String> templateText = const Value.absent(),
                Value<int?> distanceMainM = const Value.absent(),
                Value<int?> durationMainSec = const Value.absent(),
                Value<int?> paceSecPerKm = const Value.absent(),
                Value<Zone?> zone = const Value.absent(),
                Value<int?> rpeValue = const Value.absent(),
                Value<RestType?> restType = const Value.absent(),
                Value<int?> restDurationSec = const Value.absent(),
                Value<int?> restDistanceM = const Value.absent(),
                Value<int?> wuDistanceM = const Value.absent(),
                Value<int?> wuDurationSec = const Value.absent(),
                Value<int?> cdDistanceM = const Value.absent(),
                Value<int?> cdDurationSec = const Value.absent(),
                Value<SessionStatus> status = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<int?> repLoad = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SessionsCompanion(
                id: id,
                startedAt: startedAt,
                planId: planId,
                templateText: templateText,
                distanceMainM: distanceMainM,
                durationMainSec: durationMainSec,
                paceSecPerKm: paceSecPerKm,
                zone: zone,
                rpeValue: rpeValue,
                restType: restType,
                restDurationSec: restDurationSec,
                restDistanceM: restDistanceM,
                wuDistanceM: wuDistanceM,
                wuDurationSec: wuDurationSec,
                cdDistanceM: cdDistanceM,
                cdDurationSec: cdDurationSec,
                status: status,
                note: note,
                repLoad: repLoad,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required DateTime startedAt,
                Value<String?> planId = const Value.absent(),
                required String templateText,
                Value<int?> distanceMainM = const Value.absent(),
                Value<int?> durationMainSec = const Value.absent(),
                Value<int?> paceSecPerKm = const Value.absent(),
                Value<Zone?> zone = const Value.absent(),
                Value<int?> rpeValue = const Value.absent(),
                Value<RestType?> restType = const Value.absent(),
                Value<int?> restDurationSec = const Value.absent(),
                Value<int?> restDistanceM = const Value.absent(),
                Value<int?> wuDistanceM = const Value.absent(),
                Value<int?> wuDurationSec = const Value.absent(),
                Value<int?> cdDistanceM = const Value.absent(),
                Value<int?> cdDurationSec = const Value.absent(),
                required SessionStatus status,
                Value<String?> note = const Value.absent(),
                Value<int?> repLoad = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SessionsCompanion.insert(
                id: id,
                startedAt: startedAt,
                planId: planId,
                templateText: templateText,
                distanceMainM: distanceMainM,
                durationMainSec: durationMainSec,
                paceSecPerKm: paceSecPerKm,
                zone: zone,
                rpeValue: rpeValue,
                restType: restType,
                restDurationSec: restDurationSec,
                restDistanceM: restDistanceM,
                wuDistanceM: wuDistanceM,
                wuDurationSec: wuDurationSec,
                cdDistanceM: cdDistanceM,
                cdDurationSec: cdDurationSec,
                status: status,
                note: note,
                repLoad: repLoad,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$SessionsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({planId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (planId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.planId,
                                referencedTable: $$SessionsTableReferences
                                    ._planIdTable(db),
                                referencedColumn: $$SessionsTableReferences
                                    ._planIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$SessionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SessionsTable,
      Session,
      $$SessionsTableFilterComposer,
      $$SessionsTableOrderingComposer,
      $$SessionsTableAnnotationComposer,
      $$SessionsTableCreateCompanionBuilder,
      $$SessionsTableUpdateCompanionBuilder,
      (Session, $$SessionsTableReferences),
      Session,
      PrefetchHooks Function({bool planId})
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$PersonalBestsTableTableManager get personalBests =>
      $$PersonalBestsTableTableManager(_db, _db.personalBests);
  $$PlansTableTableManager get plans =>
      $$PlansTableTableManager(_db, _db.plans);
  $$SessionsTableTableManager get sessions =>
      $$SessionsTableTableManager(_db, _db.sessions);
}
