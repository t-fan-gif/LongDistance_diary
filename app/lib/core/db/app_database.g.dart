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
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  late final GeneratedColumnWithTypeConverter<PbEvent, String> event =
      GeneratedColumn<String>('event', aliasedName, false,
              type: DriftSqlType.string, requiredDuringInsert: true)
          .withConverter<PbEvent>($PersonalBestsTable.$converterevent);
  static const VerificationMeta _timeMsMeta = const VerificationMeta('timeMs');
  @override
  late final GeneratedColumn<int> timeMs = GeneratedColumn<int>(
      'time_ms', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
      'date', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
      'note', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  late final GeneratedColumnWithTypeConverter<ActivityType, String>
      activityType = GeneratedColumn<String>(
              'activity_type', aliasedName, false,
              type: DriftSqlType.string,
              requiredDuringInsert: false,
              defaultValue: const Constant('running'))
          .withConverter<ActivityType>(
              $PersonalBestsTable.$converteractivityType);
  @override
  List<GeneratedColumn> get $columns =>
      [id, event, timeMs, date, note, activityType];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'personal_bests';
  @override
  VerificationContext validateIntegrity(Insertable<PersonalBest> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('time_ms')) {
      context.handle(_timeMsMeta,
          timeMs.isAcceptableOrUnknown(data['time_ms']!, _timeMsMeta));
    } else if (isInserting) {
      context.missing(_timeMsMeta);
    }
    if (data.containsKey('date')) {
      context.handle(
          _dateMeta, date.isAcceptableOrUnknown(data['date']!, _dateMeta));
    }
    if (data.containsKey('note')) {
      context.handle(
          _noteMeta, note.isAcceptableOrUnknown(data['note']!, _noteMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PersonalBest map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PersonalBest(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      event: $PersonalBestsTable.$converterevent.fromSql(attachedDatabase
          .typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}event'])!),
      timeMs: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}time_ms'])!,
      date: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}date']),
      note: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}note']),
      activityType: $PersonalBestsTable.$converteractivityType.fromSql(
          attachedDatabase.typeMapping.read(
              DriftSqlType.string, data['${effectivePrefix}activity_type'])!),
    );
  }

  @override
  $PersonalBestsTable createAlias(String alias) {
    return $PersonalBestsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<PbEvent, String, String> $converterevent =
      const EnumNameConverter<PbEvent>(PbEvent.values);
  static JsonTypeConverter2<ActivityType, String, String>
      $converteractivityType =
      const EnumNameConverter<ActivityType>(ActivityType.values);
}

class PersonalBest extends DataClass implements Insertable<PersonalBest> {
  final String id;
  final PbEvent event;
  final int timeMs;
  final DateTime? date;
  final String? note;
  final ActivityType activityType;
  const PersonalBest(
      {required this.id,
      required this.event,
      required this.timeMs,
      this.date,
      this.note,
      required this.activityType});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    {
      map['event'] =
          Variable<String>($PersonalBestsTable.$converterevent.toSql(event));
    }
    map['time_ms'] = Variable<int>(timeMs);
    if (!nullToAbsent || date != null) {
      map['date'] = Variable<DateTime>(date);
    }
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    {
      map['activity_type'] = Variable<String>(
          $PersonalBestsTable.$converteractivityType.toSql(activityType));
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
      activityType: Value(activityType),
    );
  }

  factory PersonalBest.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PersonalBest(
      id: serializer.fromJson<String>(json['id']),
      event: $PersonalBestsTable.$converterevent
          .fromJson(serializer.fromJson<String>(json['event'])),
      timeMs: serializer.fromJson<int>(json['timeMs']),
      date: serializer.fromJson<DateTime?>(json['date']),
      note: serializer.fromJson<String?>(json['note']),
      activityType: $PersonalBestsTable.$converteractivityType
          .fromJson(serializer.fromJson<String>(json['activityType'])),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'event': serializer
          .toJson<String>($PersonalBestsTable.$converterevent.toJson(event)),
      'timeMs': serializer.toJson<int>(timeMs),
      'date': serializer.toJson<DateTime?>(date),
      'note': serializer.toJson<String?>(note),
      'activityType': serializer.toJson<String>(
          $PersonalBestsTable.$converteractivityType.toJson(activityType)),
    };
  }

  PersonalBest copyWith(
          {String? id,
          PbEvent? event,
          int? timeMs,
          Value<DateTime?> date = const Value.absent(),
          Value<String?> note = const Value.absent(),
          ActivityType? activityType}) =>
      PersonalBest(
        id: id ?? this.id,
        event: event ?? this.event,
        timeMs: timeMs ?? this.timeMs,
        date: date.present ? date.value : this.date,
        note: note.present ? note.value : this.note,
        activityType: activityType ?? this.activityType,
      );
  PersonalBest copyWithCompanion(PersonalBestsCompanion data) {
    return PersonalBest(
      id: data.id.present ? data.id.value : this.id,
      event: data.event.present ? data.event.value : this.event,
      timeMs: data.timeMs.present ? data.timeMs.value : this.timeMs,
      date: data.date.present ? data.date.value : this.date,
      note: data.note.present ? data.note.value : this.note,
      activityType: data.activityType.present
          ? data.activityType.value
          : this.activityType,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PersonalBest(')
          ..write('id: $id, ')
          ..write('event: $event, ')
          ..write('timeMs: $timeMs, ')
          ..write('date: $date, ')
          ..write('note: $note, ')
          ..write('activityType: $activityType')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, event, timeMs, date, note, activityType);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PersonalBest &&
          other.id == this.id &&
          other.event == this.event &&
          other.timeMs == this.timeMs &&
          other.date == this.date &&
          other.note == this.note &&
          other.activityType == this.activityType);
}

class PersonalBestsCompanion extends UpdateCompanion<PersonalBest> {
  final Value<String> id;
  final Value<PbEvent> event;
  final Value<int> timeMs;
  final Value<DateTime?> date;
  final Value<String?> note;
  final Value<ActivityType> activityType;
  final Value<int> rowid;
  const PersonalBestsCompanion({
    this.id = const Value.absent(),
    this.event = const Value.absent(),
    this.timeMs = const Value.absent(),
    this.date = const Value.absent(),
    this.note = const Value.absent(),
    this.activityType = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PersonalBestsCompanion.insert({
    required String id,
    required PbEvent event,
    required int timeMs,
    this.date = const Value.absent(),
    this.note = const Value.absent(),
    this.activityType = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        event = Value(event),
        timeMs = Value(timeMs);
  static Insertable<PersonalBest> custom({
    Expression<String>? id,
    Expression<String>? event,
    Expression<int>? timeMs,
    Expression<DateTime>? date,
    Expression<String>? note,
    Expression<String>? activityType,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (event != null) 'event': event,
      if (timeMs != null) 'time_ms': timeMs,
      if (date != null) 'date': date,
      if (note != null) 'note': note,
      if (activityType != null) 'activity_type': activityType,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PersonalBestsCompanion copyWith(
      {Value<String>? id,
      Value<PbEvent>? event,
      Value<int>? timeMs,
      Value<DateTime?>? date,
      Value<String?>? note,
      Value<ActivityType>? activityType,
      Value<int>? rowid}) {
    return PersonalBestsCompanion(
      id: id ?? this.id,
      event: event ?? this.event,
      timeMs: timeMs ?? this.timeMs,
      date: date ?? this.date,
      note: note ?? this.note,
      activityType: activityType ?? this.activityType,
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
          $PersonalBestsTable.$converterevent.toSql(event.value));
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
    if (activityType.present) {
      map['activity_type'] = Variable<String>(
          $PersonalBestsTable.$converteractivityType.toSql(activityType.value));
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
          ..write('activityType: $activityType, ')
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
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
      'date', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _menuNameMeta =
      const VerificationMeta('menuName');
  @override
  late final GeneratedColumn<String> menuName = GeneratedColumn<String>(
      'menu_name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _distanceMeta =
      const VerificationMeta('distance');
  @override
  late final GeneratedColumn<int> distance = GeneratedColumn<int>(
      'distance', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _paceMeta = const VerificationMeta('pace');
  @override
  late final GeneratedColumn<int> pace = GeneratedColumn<int>(
      'pace', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  @override
  late final GeneratedColumnWithTypeConverter<Zone?, String> zone =
      GeneratedColumn<String>('zone', aliasedName, true,
              type: DriftSqlType.string, requiredDuringInsert: false)
          .withConverter<Zone?>($PlansTable.$converterzonen);
  static const VerificationMeta _repsMeta = const VerificationMeta('reps');
  @override
  late final GeneratedColumn<int> reps = GeneratedColumn<int>(
      'reps', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(1));
  @override
  late final GeneratedColumnWithTypeConverter<ActivityType, String>
      activityType = GeneratedColumn<String>(
              'activity_type', aliasedName, false,
              type: DriftSqlType.string,
              requiredDuringInsert: false,
              defaultValue: const Constant('running'))
          .withConverter<ActivityType>($PlansTable.$converteractivityType);
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
      'note', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _isRaceMeta = const VerificationMeta('isRace');
  @override
  late final GeneratedColumn<bool> isRace = GeneratedColumn<bool>(
      'is_race', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_race" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _durationMeta =
      const VerificationMeta('duration');
  @override
  late final GeneratedColumn<int> duration = GeneratedColumn<int>(
      'duration', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        date,
        menuName,
        distance,
        pace,
        zone,
        reps,
        activityType,
        note,
        isRace,
        duration
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'plans';
  @override
  VerificationContext validateIntegrity(Insertable<Plan> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('date')) {
      context.handle(
          _dateMeta, date.isAcceptableOrUnknown(data['date']!, _dateMeta));
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('menu_name')) {
      context.handle(_menuNameMeta,
          menuName.isAcceptableOrUnknown(data['menu_name']!, _menuNameMeta));
    } else if (isInserting) {
      context.missing(_menuNameMeta);
    }
    if (data.containsKey('distance')) {
      context.handle(_distanceMeta,
          distance.isAcceptableOrUnknown(data['distance']!, _distanceMeta));
    }
    if (data.containsKey('pace')) {
      context.handle(
          _paceMeta, pace.isAcceptableOrUnknown(data['pace']!, _paceMeta));
    }
    if (data.containsKey('reps')) {
      context.handle(
          _repsMeta, reps.isAcceptableOrUnknown(data['reps']!, _repsMeta));
    }
    if (data.containsKey('note')) {
      context.handle(
          _noteMeta, note.isAcceptableOrUnknown(data['note']!, _noteMeta));
    }
    if (data.containsKey('is_race')) {
      context.handle(_isRaceMeta,
          isRace.isAcceptableOrUnknown(data['is_race']!, _isRaceMeta));
    }
    if (data.containsKey('duration')) {
      context.handle(_durationMeta,
          duration.isAcceptableOrUnknown(data['duration']!, _durationMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Plan map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Plan(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      date: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}date'])!,
      menuName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}menu_name'])!,
      distance: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}distance']),
      pace: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}pace']),
      zone: $PlansTable.$converterzonen.fromSql(attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}zone'])),
      reps: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}reps'])!,
      activityType: $PlansTable.$converteractivityType.fromSql(attachedDatabase
          .typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}activity_type'])!),
      note: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}note']),
      isRace: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_race'])!,
      duration: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}duration']),
    );
  }

  @override
  $PlansTable createAlias(String alias) {
    return $PlansTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<Zone, String, String> $converterzone =
      const EnumNameConverter<Zone>(Zone.values);
  static JsonTypeConverter2<Zone?, String?, String?> $converterzonen =
      JsonTypeConverter2.asNullable($converterzone);
  static JsonTypeConverter2<ActivityType, String, String>
      $converteractivityType =
      const EnumNameConverter<ActivityType>(ActivityType.values);
}

class Plan extends DataClass implements Insertable<Plan> {
  final String id;
  final DateTime date;
  final String menuName;
  final int? distance;
  final int? pace;
  final Zone? zone;
  final int reps;
  final ActivityType activityType;
  final String? note;
  final bool isRace;
  final int? duration;
  const Plan(
      {required this.id,
      required this.date,
      required this.menuName,
      this.distance,
      this.pace,
      this.zone,
      required this.reps,
      required this.activityType,
      this.note,
      required this.isRace,
      this.duration});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['date'] = Variable<DateTime>(date);
    map['menu_name'] = Variable<String>(menuName);
    if (!nullToAbsent || distance != null) {
      map['distance'] = Variable<int>(distance);
    }
    if (!nullToAbsent || pace != null) {
      map['pace'] = Variable<int>(pace);
    }
    if (!nullToAbsent || zone != null) {
      map['zone'] = Variable<String>($PlansTable.$converterzonen.toSql(zone));
    }
    map['reps'] = Variable<int>(reps);
    {
      map['activity_type'] = Variable<String>(
          $PlansTable.$converteractivityType.toSql(activityType));
    }
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    map['is_race'] = Variable<bool>(isRace);
    if (!nullToAbsent || duration != null) {
      map['duration'] = Variable<int>(duration);
    }
    return map;
  }

  PlansCompanion toCompanion(bool nullToAbsent) {
    return PlansCompanion(
      id: Value(id),
      date: Value(date),
      menuName: Value(menuName),
      distance: distance == null && nullToAbsent
          ? const Value.absent()
          : Value(distance),
      pace: pace == null && nullToAbsent ? const Value.absent() : Value(pace),
      zone: zone == null && nullToAbsent ? const Value.absent() : Value(zone),
      reps: Value(reps),
      activityType: Value(activityType),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      isRace: Value(isRace),
      duration: duration == null && nullToAbsent
          ? const Value.absent()
          : Value(duration),
    );
  }

  factory Plan.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Plan(
      id: serializer.fromJson<String>(json['id']),
      date: serializer.fromJson<DateTime>(json['date']),
      menuName: serializer.fromJson<String>(json['menuName']),
      distance: serializer.fromJson<int?>(json['distance']),
      pace: serializer.fromJson<int?>(json['pace']),
      zone: $PlansTable.$converterzonen
          .fromJson(serializer.fromJson<String?>(json['zone'])),
      reps: serializer.fromJson<int>(json['reps']),
      activityType: $PlansTable.$converteractivityType
          .fromJson(serializer.fromJson<String>(json['activityType'])),
      note: serializer.fromJson<String?>(json['note']),
      isRace: serializer.fromJson<bool>(json['isRace']),
      duration: serializer.fromJson<int?>(json['duration']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'date': serializer.toJson<DateTime>(date),
      'menuName': serializer.toJson<String>(menuName),
      'distance': serializer.toJson<int?>(distance),
      'pace': serializer.toJson<int?>(pace),
      'zone':
          serializer.toJson<String?>($PlansTable.$converterzonen.toJson(zone)),
      'reps': serializer.toJson<int>(reps),
      'activityType': serializer.toJson<String>(
          $PlansTable.$converteractivityType.toJson(activityType)),
      'note': serializer.toJson<String?>(note),
      'isRace': serializer.toJson<bool>(isRace),
      'duration': serializer.toJson<int?>(duration),
    };
  }

  Plan copyWith(
          {String? id,
          DateTime? date,
          String? menuName,
          Value<int?> distance = const Value.absent(),
          Value<int?> pace = const Value.absent(),
          Value<Zone?> zone = const Value.absent(),
          int? reps,
          ActivityType? activityType,
          Value<String?> note = const Value.absent(),
          bool? isRace,
          Value<int?> duration = const Value.absent()}) =>
      Plan(
        id: id ?? this.id,
        date: date ?? this.date,
        menuName: menuName ?? this.menuName,
        distance: distance.present ? distance.value : this.distance,
        pace: pace.present ? pace.value : this.pace,
        zone: zone.present ? zone.value : this.zone,
        reps: reps ?? this.reps,
        activityType: activityType ?? this.activityType,
        note: note.present ? note.value : this.note,
        isRace: isRace ?? this.isRace,
        duration: duration.present ? duration.value : this.duration,
      );
  Plan copyWithCompanion(PlansCompanion data) {
    return Plan(
      id: data.id.present ? data.id.value : this.id,
      date: data.date.present ? data.date.value : this.date,
      menuName: data.menuName.present ? data.menuName.value : this.menuName,
      distance: data.distance.present ? data.distance.value : this.distance,
      pace: data.pace.present ? data.pace.value : this.pace,
      zone: data.zone.present ? data.zone.value : this.zone,
      reps: data.reps.present ? data.reps.value : this.reps,
      activityType: data.activityType.present
          ? data.activityType.value
          : this.activityType,
      note: data.note.present ? data.note.value : this.note,
      isRace: data.isRace.present ? data.isRace.value : this.isRace,
      duration: data.duration.present ? data.duration.value : this.duration,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Plan(')
          ..write('id: $id, ')
          ..write('date: $date, ')
          ..write('menuName: $menuName, ')
          ..write('distance: $distance, ')
          ..write('pace: $pace, ')
          ..write('zone: $zone, ')
          ..write('reps: $reps, ')
          ..write('activityType: $activityType, ')
          ..write('note: $note, ')
          ..write('isRace: $isRace, ')
          ..write('duration: $duration')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, date, menuName, distance, pace, zone,
      reps, activityType, note, isRace, duration);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Plan &&
          other.id == this.id &&
          other.date == this.date &&
          other.menuName == this.menuName &&
          other.distance == this.distance &&
          other.pace == this.pace &&
          other.zone == this.zone &&
          other.reps == this.reps &&
          other.activityType == this.activityType &&
          other.note == this.note &&
          other.isRace == this.isRace &&
          other.duration == this.duration);
}

class PlansCompanion extends UpdateCompanion<Plan> {
  final Value<String> id;
  final Value<DateTime> date;
  final Value<String> menuName;
  final Value<int?> distance;
  final Value<int?> pace;
  final Value<Zone?> zone;
  final Value<int> reps;
  final Value<ActivityType> activityType;
  final Value<String?> note;
  final Value<bool> isRace;
  final Value<int?> duration;
  final Value<int> rowid;
  const PlansCompanion({
    this.id = const Value.absent(),
    this.date = const Value.absent(),
    this.menuName = const Value.absent(),
    this.distance = const Value.absent(),
    this.pace = const Value.absent(),
    this.zone = const Value.absent(),
    this.reps = const Value.absent(),
    this.activityType = const Value.absent(),
    this.note = const Value.absent(),
    this.isRace = const Value.absent(),
    this.duration = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PlansCompanion.insert({
    required String id,
    required DateTime date,
    required String menuName,
    this.distance = const Value.absent(),
    this.pace = const Value.absent(),
    this.zone = const Value.absent(),
    this.reps = const Value.absent(),
    this.activityType = const Value.absent(),
    this.note = const Value.absent(),
    this.isRace = const Value.absent(),
    this.duration = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        date = Value(date),
        menuName = Value(menuName);
  static Insertable<Plan> custom({
    Expression<String>? id,
    Expression<DateTime>? date,
    Expression<String>? menuName,
    Expression<int>? distance,
    Expression<int>? pace,
    Expression<String>? zone,
    Expression<int>? reps,
    Expression<String>? activityType,
    Expression<String>? note,
    Expression<bool>? isRace,
    Expression<int>? duration,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (date != null) 'date': date,
      if (menuName != null) 'menu_name': menuName,
      if (distance != null) 'distance': distance,
      if (pace != null) 'pace': pace,
      if (zone != null) 'zone': zone,
      if (reps != null) 'reps': reps,
      if (activityType != null) 'activity_type': activityType,
      if (note != null) 'note': note,
      if (isRace != null) 'is_race': isRace,
      if (duration != null) 'duration': duration,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PlansCompanion copyWith(
      {Value<String>? id,
      Value<DateTime>? date,
      Value<String>? menuName,
      Value<int?>? distance,
      Value<int?>? pace,
      Value<Zone?>? zone,
      Value<int>? reps,
      Value<ActivityType>? activityType,
      Value<String?>? note,
      Value<bool>? isRace,
      Value<int?>? duration,
      Value<int>? rowid}) {
    return PlansCompanion(
      id: id ?? this.id,
      date: date ?? this.date,
      menuName: menuName ?? this.menuName,
      distance: distance ?? this.distance,
      pace: pace ?? this.pace,
      zone: zone ?? this.zone,
      reps: reps ?? this.reps,
      activityType: activityType ?? this.activityType,
      note: note ?? this.note,
      isRace: isRace ?? this.isRace,
      duration: duration ?? this.duration,
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
    if (menuName.present) {
      map['menu_name'] = Variable<String>(menuName.value);
    }
    if (distance.present) {
      map['distance'] = Variable<int>(distance.value);
    }
    if (pace.present) {
      map['pace'] = Variable<int>(pace.value);
    }
    if (zone.present) {
      map['zone'] =
          Variable<String>($PlansTable.$converterzonen.toSql(zone.value));
    }
    if (reps.present) {
      map['reps'] = Variable<int>(reps.value);
    }
    if (activityType.present) {
      map['activity_type'] = Variable<String>(
          $PlansTable.$converteractivityType.toSql(activityType.value));
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (isRace.present) {
      map['is_race'] = Variable<bool>(isRace.value);
    }
    if (duration.present) {
      map['duration'] = Variable<int>(duration.value);
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
          ..write('menuName: $menuName, ')
          ..write('distance: $distance, ')
          ..write('pace: $pace, ')
          ..write('zone: $zone, ')
          ..write('reps: $reps, ')
          ..write('activityType: $activityType, ')
          ..write('note: $note, ')
          ..write('isRace: $isRace, ')
          ..write('duration: $duration, ')
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
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _startedAtMeta =
      const VerificationMeta('startedAt');
  @override
  late final GeneratedColumn<DateTime> startedAt = GeneratedColumn<DateTime>(
      'date_time', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _planIdMeta = const VerificationMeta('planId');
  @override
  late final GeneratedColumn<String> planId = GeneratedColumn<String>(
      'plan_id', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES plans (id)'));
  static const VerificationMeta _templateTextMeta =
      const VerificationMeta('templateText');
  @override
  late final GeneratedColumn<String> templateText = GeneratedColumn<String>(
      'template_text', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _repsMeta = const VerificationMeta('reps');
  @override
  late final GeneratedColumn<int> reps = GeneratedColumn<int>(
      'reps', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _distanceMainMMeta =
      const VerificationMeta('distanceMainM');
  @override
  late final GeneratedColumn<int> distanceMainM = GeneratedColumn<int>(
      'distance_main_m', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _durationMainSecMeta =
      const VerificationMeta('durationMainSec');
  @override
  late final GeneratedColumn<int> durationMainSec = GeneratedColumn<int>(
      'duration_main_sec', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _paceSecPerKmMeta =
      const VerificationMeta('paceSecPerKm');
  @override
  late final GeneratedColumn<int> paceSecPerKm = GeneratedColumn<int>(
      'pace_sec_per_km', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  @override
  late final GeneratedColumnWithTypeConverter<Zone?, String> zone =
      GeneratedColumn<String>('zone', aliasedName, true,
              type: DriftSqlType.string, requiredDuringInsert: false)
          .withConverter<Zone?>($SessionsTable.$converterzonen);
  static const VerificationMeta _rpeValueMeta =
      const VerificationMeta('rpeValue');
  @override
  late final GeneratedColumn<int> rpeValue = GeneratedColumn<int>(
      'rpe_value', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  @override
  late final GeneratedColumnWithTypeConverter<RestType?, String> restType =
      GeneratedColumn<String>('rest_type', aliasedName, true,
              type: DriftSqlType.string, requiredDuringInsert: false)
          .withConverter<RestType?>($SessionsTable.$converterrestTypen);
  static const VerificationMeta _restDurationSecMeta =
      const VerificationMeta('restDurationSec');
  @override
  late final GeneratedColumn<int> restDurationSec = GeneratedColumn<int>(
      'rest_duration_sec', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _restDistanceMMeta =
      const VerificationMeta('restDistanceM');
  @override
  late final GeneratedColumn<int> restDistanceM = GeneratedColumn<int>(
      'rest_distance_m', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _wuDistanceMMeta =
      const VerificationMeta('wuDistanceM');
  @override
  late final GeneratedColumn<int> wuDistanceM = GeneratedColumn<int>(
      'wu_distance_m', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _wuDurationSecMeta =
      const VerificationMeta('wuDurationSec');
  @override
  late final GeneratedColumn<int> wuDurationSec = GeneratedColumn<int>(
      'wu_duration_sec', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _cdDistanceMMeta =
      const VerificationMeta('cdDistanceM');
  @override
  late final GeneratedColumn<int> cdDistanceM = GeneratedColumn<int>(
      'cd_distance_m', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _cdDurationSecMeta =
      const VerificationMeta('cdDurationSec');
  @override
  late final GeneratedColumn<int> cdDurationSec = GeneratedColumn<int>(
      'cd_duration_sec', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  @override
  late final GeneratedColumnWithTypeConverter<SessionStatus, String> status =
      GeneratedColumn<String>('status', aliasedName, false,
              type: DriftSqlType.string, requiredDuringInsert: true)
          .withConverter<SessionStatus>($SessionsTable.$converterstatus);
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
      'note', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _loadMeta = const VerificationMeta('load');
  @override
  late final GeneratedColumn<double> load = GeneratedColumn<double>(
      'load', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _repLoadMeta =
      const VerificationMeta('repLoad');
  @override
  late final GeneratedColumn<int> repLoad = GeneratedColumn<int>(
      'rep_load', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  @override
  late final GeneratedColumnWithTypeConverter<ActivityType, String>
      activityType = GeneratedColumn<String>(
              'activity_type', aliasedName, false,
              type: DriftSqlType.string,
              requiredDuringInsert: false,
              defaultValue: const Constant('running'))
          .withConverter<ActivityType>($SessionsTable.$converteractivityType);
  static const VerificationMeta _isRaceMeta = const VerificationMeta('isRace');
  @override
  late final GeneratedColumn<bool> isRace = GeneratedColumn<bool>(
      'is_race', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_race" IN (0, 1))'),
      defaultValue: const Constant(false));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        startedAt,
        planId,
        templateText,
        reps,
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
        load,
        repLoad,
        activityType,
        isRace
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sessions';
  @override
  VerificationContext validateIntegrity(Insertable<Session> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('date_time')) {
      context.handle(_startedAtMeta,
          startedAt.isAcceptableOrUnknown(data['date_time']!, _startedAtMeta));
    } else if (isInserting) {
      context.missing(_startedAtMeta);
    }
    if (data.containsKey('plan_id')) {
      context.handle(_planIdMeta,
          planId.isAcceptableOrUnknown(data['plan_id']!, _planIdMeta));
    }
    if (data.containsKey('template_text')) {
      context.handle(
          _templateTextMeta,
          templateText.isAcceptableOrUnknown(
              data['template_text']!, _templateTextMeta));
    } else if (isInserting) {
      context.missing(_templateTextMeta);
    }
    if (data.containsKey('reps')) {
      context.handle(
          _repsMeta, reps.isAcceptableOrUnknown(data['reps']!, _repsMeta));
    }
    if (data.containsKey('distance_main_m')) {
      context.handle(
          _distanceMainMMeta,
          distanceMainM.isAcceptableOrUnknown(
              data['distance_main_m']!, _distanceMainMMeta));
    }
    if (data.containsKey('duration_main_sec')) {
      context.handle(
          _durationMainSecMeta,
          durationMainSec.isAcceptableOrUnknown(
              data['duration_main_sec']!, _durationMainSecMeta));
    }
    if (data.containsKey('pace_sec_per_km')) {
      context.handle(
          _paceSecPerKmMeta,
          paceSecPerKm.isAcceptableOrUnknown(
              data['pace_sec_per_km']!, _paceSecPerKmMeta));
    }
    if (data.containsKey('rpe_value')) {
      context.handle(_rpeValueMeta,
          rpeValue.isAcceptableOrUnknown(data['rpe_value']!, _rpeValueMeta));
    }
    if (data.containsKey('rest_duration_sec')) {
      context.handle(
          _restDurationSecMeta,
          restDurationSec.isAcceptableOrUnknown(
              data['rest_duration_sec']!, _restDurationSecMeta));
    }
    if (data.containsKey('rest_distance_m')) {
      context.handle(
          _restDistanceMMeta,
          restDistanceM.isAcceptableOrUnknown(
              data['rest_distance_m']!, _restDistanceMMeta));
    }
    if (data.containsKey('wu_distance_m')) {
      context.handle(
          _wuDistanceMMeta,
          wuDistanceM.isAcceptableOrUnknown(
              data['wu_distance_m']!, _wuDistanceMMeta));
    }
    if (data.containsKey('wu_duration_sec')) {
      context.handle(
          _wuDurationSecMeta,
          wuDurationSec.isAcceptableOrUnknown(
              data['wu_duration_sec']!, _wuDurationSecMeta));
    }
    if (data.containsKey('cd_distance_m')) {
      context.handle(
          _cdDistanceMMeta,
          cdDistanceM.isAcceptableOrUnknown(
              data['cd_distance_m']!, _cdDistanceMMeta));
    }
    if (data.containsKey('cd_duration_sec')) {
      context.handle(
          _cdDurationSecMeta,
          cdDurationSec.isAcceptableOrUnknown(
              data['cd_duration_sec']!, _cdDurationSecMeta));
    }
    if (data.containsKey('note')) {
      context.handle(
          _noteMeta, note.isAcceptableOrUnknown(data['note']!, _noteMeta));
    }
    if (data.containsKey('load')) {
      context.handle(
          _loadMeta, load.isAcceptableOrUnknown(data['load']!, _loadMeta));
    }
    if (data.containsKey('rep_load')) {
      context.handle(_repLoadMeta,
          repLoad.isAcceptableOrUnknown(data['rep_load']!, _repLoadMeta));
    }
    if (data.containsKey('is_race')) {
      context.handle(_isRaceMeta,
          isRace.isAcceptableOrUnknown(data['is_race']!, _isRaceMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Session map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Session(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      startedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}date_time'])!,
      planId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}plan_id']),
      templateText: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}template_text'])!,
      reps: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}reps']),
      distanceMainM: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}distance_main_m']),
      durationMainSec: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}duration_main_sec']),
      paceSecPerKm: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}pace_sec_per_km']),
      zone: $SessionsTable.$converterzonen.fromSql(attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}zone'])),
      rpeValue: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}rpe_value']),
      restType: $SessionsTable.$converterrestTypen.fromSql(attachedDatabase
          .typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}rest_type'])),
      restDurationSec: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}rest_duration_sec']),
      restDistanceM: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}rest_distance_m']),
      wuDistanceM: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}wu_distance_m']),
      wuDurationSec: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}wu_duration_sec']),
      cdDistanceM: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}cd_distance_m']),
      cdDurationSec: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}cd_duration_sec']),
      status: $SessionsTable.$converterstatus.fromSql(attachedDatabase
          .typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!),
      note: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}note']),
      load: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}load']),
      repLoad: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}rep_load']),
      activityType: $SessionsTable.$converteractivityType.fromSql(
          attachedDatabase.typeMapping.read(
              DriftSqlType.string, data['${effectivePrefix}activity_type'])!),
      isRace: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_race'])!,
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
  static JsonTypeConverter2<ActivityType, String, String>
      $converteractivityType =
      const EnumNameConverter<ActivityType>(ActivityType.values);
}

class Session extends DataClass implements Insertable<Session> {
  final String id;
  final DateTime startedAt;
  final String? planId;
  final String templateText;
  final int? reps;
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
  final double? load;
  final int? repLoad;
  final ActivityType activityType;
  final bool isRace;
  const Session(
      {required this.id,
      required this.startedAt,
      this.planId,
      required this.templateText,
      this.reps,
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
      this.load,
      this.repLoad,
      required this.activityType,
      required this.isRace});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['date_time'] = Variable<DateTime>(startedAt);
    if (!nullToAbsent || planId != null) {
      map['plan_id'] = Variable<String>(planId);
    }
    map['template_text'] = Variable<String>(templateText);
    if (!nullToAbsent || reps != null) {
      map['reps'] = Variable<int>(reps);
    }
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
      map['zone'] =
          Variable<String>($SessionsTable.$converterzonen.toSql(zone));
    }
    if (!nullToAbsent || rpeValue != null) {
      map['rpe_value'] = Variable<int>(rpeValue);
    }
    if (!nullToAbsent || restType != null) {
      map['rest_type'] =
          Variable<String>($SessionsTable.$converterrestTypen.toSql(restType));
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
      map['status'] =
          Variable<String>($SessionsTable.$converterstatus.toSql(status));
    }
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    if (!nullToAbsent || load != null) {
      map['load'] = Variable<double>(load);
    }
    if (!nullToAbsent || repLoad != null) {
      map['rep_load'] = Variable<int>(repLoad);
    }
    {
      map['activity_type'] = Variable<String>(
          $SessionsTable.$converteractivityType.toSql(activityType));
    }
    map['is_race'] = Variable<bool>(isRace);
    return map;
  }

  SessionsCompanion toCompanion(bool nullToAbsent) {
    return SessionsCompanion(
      id: Value(id),
      startedAt: Value(startedAt),
      planId:
          planId == null && nullToAbsent ? const Value.absent() : Value(planId),
      templateText: Value(templateText),
      reps: reps == null && nullToAbsent ? const Value.absent() : Value(reps),
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
      load: load == null && nullToAbsent ? const Value.absent() : Value(load),
      repLoad: repLoad == null && nullToAbsent
          ? const Value.absent()
          : Value(repLoad),
      activityType: Value(activityType),
      isRace: Value(isRace),
    );
  }

  factory Session.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Session(
      id: serializer.fromJson<String>(json['id']),
      startedAt: serializer.fromJson<DateTime>(json['startedAt']),
      planId: serializer.fromJson<String?>(json['planId']),
      templateText: serializer.fromJson<String>(json['templateText']),
      reps: serializer.fromJson<int?>(json['reps']),
      distanceMainM: serializer.fromJson<int?>(json['distanceMainM']),
      durationMainSec: serializer.fromJson<int?>(json['durationMainSec']),
      paceSecPerKm: serializer.fromJson<int?>(json['paceSecPerKm']),
      zone: $SessionsTable.$converterzonen
          .fromJson(serializer.fromJson<String?>(json['zone'])),
      rpeValue: serializer.fromJson<int?>(json['rpeValue']),
      restType: $SessionsTable.$converterrestTypen
          .fromJson(serializer.fromJson<String?>(json['restType'])),
      restDurationSec: serializer.fromJson<int?>(json['restDurationSec']),
      restDistanceM: serializer.fromJson<int?>(json['restDistanceM']),
      wuDistanceM: serializer.fromJson<int?>(json['wuDistanceM']),
      wuDurationSec: serializer.fromJson<int?>(json['wuDurationSec']),
      cdDistanceM: serializer.fromJson<int?>(json['cdDistanceM']),
      cdDurationSec: serializer.fromJson<int?>(json['cdDurationSec']),
      status: $SessionsTable.$converterstatus
          .fromJson(serializer.fromJson<String>(json['status'])),
      note: serializer.fromJson<String?>(json['note']),
      load: serializer.fromJson<double?>(json['load']),
      repLoad: serializer.fromJson<int?>(json['repLoad']),
      activityType: $SessionsTable.$converteractivityType
          .fromJson(serializer.fromJson<String>(json['activityType'])),
      isRace: serializer.fromJson<bool>(json['isRace']),
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
      'reps': serializer.toJson<int?>(reps),
      'distanceMainM': serializer.toJson<int?>(distanceMainM),
      'durationMainSec': serializer.toJson<int?>(durationMainSec),
      'paceSecPerKm': serializer.toJson<int?>(paceSecPerKm),
      'zone': serializer
          .toJson<String?>($SessionsTable.$converterzonen.toJson(zone)),
      'rpeValue': serializer.toJson<int?>(rpeValue),
      'restType': serializer
          .toJson<String?>($SessionsTable.$converterrestTypen.toJson(restType)),
      'restDurationSec': serializer.toJson<int?>(restDurationSec),
      'restDistanceM': serializer.toJson<int?>(restDistanceM),
      'wuDistanceM': serializer.toJson<int?>(wuDistanceM),
      'wuDurationSec': serializer.toJson<int?>(wuDurationSec),
      'cdDistanceM': serializer.toJson<int?>(cdDistanceM),
      'cdDurationSec': serializer.toJson<int?>(cdDurationSec),
      'status': serializer
          .toJson<String>($SessionsTable.$converterstatus.toJson(status)),
      'note': serializer.toJson<String?>(note),
      'load': serializer.toJson<double?>(load),
      'repLoad': serializer.toJson<int?>(repLoad),
      'activityType': serializer.toJson<String>(
          $SessionsTable.$converteractivityType.toJson(activityType)),
      'isRace': serializer.toJson<bool>(isRace),
    };
  }

  Session copyWith(
          {String? id,
          DateTime? startedAt,
          Value<String?> planId = const Value.absent(),
          String? templateText,
          Value<int?> reps = const Value.absent(),
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
          Value<double?> load = const Value.absent(),
          Value<int?> repLoad = const Value.absent(),
          ActivityType? activityType,
          bool? isRace}) =>
      Session(
        id: id ?? this.id,
        startedAt: startedAt ?? this.startedAt,
        planId: planId.present ? planId.value : this.planId,
        templateText: templateText ?? this.templateText,
        reps: reps.present ? reps.value : this.reps,
        distanceMainM:
            distanceMainM.present ? distanceMainM.value : this.distanceMainM,
        durationMainSec: durationMainSec.present
            ? durationMainSec.value
            : this.durationMainSec,
        paceSecPerKm:
            paceSecPerKm.present ? paceSecPerKm.value : this.paceSecPerKm,
        zone: zone.present ? zone.value : this.zone,
        rpeValue: rpeValue.present ? rpeValue.value : this.rpeValue,
        restType: restType.present ? restType.value : this.restType,
        restDurationSec: restDurationSec.present
            ? restDurationSec.value
            : this.restDurationSec,
        restDistanceM:
            restDistanceM.present ? restDistanceM.value : this.restDistanceM,
        wuDistanceM: wuDistanceM.present ? wuDistanceM.value : this.wuDistanceM,
        wuDurationSec:
            wuDurationSec.present ? wuDurationSec.value : this.wuDurationSec,
        cdDistanceM: cdDistanceM.present ? cdDistanceM.value : this.cdDistanceM,
        cdDurationSec:
            cdDurationSec.present ? cdDurationSec.value : this.cdDurationSec,
        status: status ?? this.status,
        note: note.present ? note.value : this.note,
        load: load.present ? load.value : this.load,
        repLoad: repLoad.present ? repLoad.value : this.repLoad,
        activityType: activityType ?? this.activityType,
        isRace: isRace ?? this.isRace,
      );
  Session copyWithCompanion(SessionsCompanion data) {
    return Session(
      id: data.id.present ? data.id.value : this.id,
      startedAt: data.startedAt.present ? data.startedAt.value : this.startedAt,
      planId: data.planId.present ? data.planId.value : this.planId,
      templateText: data.templateText.present
          ? data.templateText.value
          : this.templateText,
      reps: data.reps.present ? data.reps.value : this.reps,
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
      wuDistanceM:
          data.wuDistanceM.present ? data.wuDistanceM.value : this.wuDistanceM,
      wuDurationSec: data.wuDurationSec.present
          ? data.wuDurationSec.value
          : this.wuDurationSec,
      cdDistanceM:
          data.cdDistanceM.present ? data.cdDistanceM.value : this.cdDistanceM,
      cdDurationSec: data.cdDurationSec.present
          ? data.cdDurationSec.value
          : this.cdDurationSec,
      status: data.status.present ? data.status.value : this.status,
      note: data.note.present ? data.note.value : this.note,
      load: data.load.present ? data.load.value : this.load,
      repLoad: data.repLoad.present ? data.repLoad.value : this.repLoad,
      activityType: data.activityType.present
          ? data.activityType.value
          : this.activityType,
      isRace: data.isRace.present ? data.isRace.value : this.isRace,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Session(')
          ..write('id: $id, ')
          ..write('startedAt: $startedAt, ')
          ..write('planId: $planId, ')
          ..write('templateText: $templateText, ')
          ..write('reps: $reps, ')
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
          ..write('load: $load, ')
          ..write('repLoad: $repLoad, ')
          ..write('activityType: $activityType, ')
          ..write('isRace: $isRace')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
        id,
        startedAt,
        planId,
        templateText,
        reps,
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
        load,
        repLoad,
        activityType,
        isRace
      ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Session &&
          other.id == this.id &&
          other.startedAt == this.startedAt &&
          other.planId == this.planId &&
          other.templateText == this.templateText &&
          other.reps == this.reps &&
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
          other.load == this.load &&
          other.repLoad == this.repLoad &&
          other.activityType == this.activityType &&
          other.isRace == this.isRace);
}

class SessionsCompanion extends UpdateCompanion<Session> {
  final Value<String> id;
  final Value<DateTime> startedAt;
  final Value<String?> planId;
  final Value<String> templateText;
  final Value<int?> reps;
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
  final Value<double?> load;
  final Value<int?> repLoad;
  final Value<ActivityType> activityType;
  final Value<bool> isRace;
  final Value<int> rowid;
  const SessionsCompanion({
    this.id = const Value.absent(),
    this.startedAt = const Value.absent(),
    this.planId = const Value.absent(),
    this.templateText = const Value.absent(),
    this.reps = const Value.absent(),
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
    this.load = const Value.absent(),
    this.repLoad = const Value.absent(),
    this.activityType = const Value.absent(),
    this.isRace = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SessionsCompanion.insert({
    required String id,
    required DateTime startedAt,
    this.planId = const Value.absent(),
    required String templateText,
    this.reps = const Value.absent(),
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
    this.load = const Value.absent(),
    this.repLoad = const Value.absent(),
    this.activityType = const Value.absent(),
    this.isRace = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        startedAt = Value(startedAt),
        templateText = Value(templateText),
        status = Value(status);
  static Insertable<Session> custom({
    Expression<String>? id,
    Expression<DateTime>? startedAt,
    Expression<String>? planId,
    Expression<String>? templateText,
    Expression<int>? reps,
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
    Expression<double>? load,
    Expression<int>? repLoad,
    Expression<String>? activityType,
    Expression<bool>? isRace,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (startedAt != null) 'date_time': startedAt,
      if (planId != null) 'plan_id': planId,
      if (templateText != null) 'template_text': templateText,
      if (reps != null) 'reps': reps,
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
      if (load != null) 'load': load,
      if (repLoad != null) 'rep_load': repLoad,
      if (activityType != null) 'activity_type': activityType,
      if (isRace != null) 'is_race': isRace,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SessionsCompanion copyWith(
      {Value<String>? id,
      Value<DateTime>? startedAt,
      Value<String?>? planId,
      Value<String>? templateText,
      Value<int?>? reps,
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
      Value<double?>? load,
      Value<int?>? repLoad,
      Value<ActivityType>? activityType,
      Value<bool>? isRace,
      Value<int>? rowid}) {
    return SessionsCompanion(
      id: id ?? this.id,
      startedAt: startedAt ?? this.startedAt,
      planId: planId ?? this.planId,
      templateText: templateText ?? this.templateText,
      reps: reps ?? this.reps,
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
      load: load ?? this.load,
      repLoad: repLoad ?? this.repLoad,
      activityType: activityType ?? this.activityType,
      isRace: isRace ?? this.isRace,
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
    if (reps.present) {
      map['reps'] = Variable<int>(reps.value);
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
      map['zone'] =
          Variable<String>($SessionsTable.$converterzonen.toSql(zone.value));
    }
    if (rpeValue.present) {
      map['rpe_value'] = Variable<int>(rpeValue.value);
    }
    if (restType.present) {
      map['rest_type'] = Variable<String>(
          $SessionsTable.$converterrestTypen.toSql(restType.value));
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
      map['status'] =
          Variable<String>($SessionsTable.$converterstatus.toSql(status.value));
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (load.present) {
      map['load'] = Variable<double>(load.value);
    }
    if (repLoad.present) {
      map['rep_load'] = Variable<int>(repLoad.value);
    }
    if (activityType.present) {
      map['activity_type'] = Variable<String>(
          $SessionsTable.$converteractivityType.toSql(activityType.value));
    }
    if (isRace.present) {
      map['is_race'] = Variable<bool>(isRace.value);
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
          ..write('reps: $reps, ')
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
          ..write('load: $load, ')
          ..write('repLoad: $repLoad, ')
          ..write('activityType: $activityType, ')
          ..write('isRace: $isRace, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MenuPresetsTable extends MenuPresets
    with TableInfo<$MenuPresetsTable, MenuPreset> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MenuPresetsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [id, name];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'menu_presets';
  @override
  VerificationContext validateIntegrity(Insertable<MenuPreset> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MenuPreset map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MenuPreset(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
    );
  }

  @override
  $MenuPresetsTable createAlias(String alias) {
    return $MenuPresetsTable(attachedDatabase, alias);
  }
}

class MenuPreset extends DataClass implements Insertable<MenuPreset> {
  final String id;
  final String name;
  const MenuPreset({required this.id, required this.name});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    return map;
  }

  MenuPresetsCompanion toCompanion(bool nullToAbsent) {
    return MenuPresetsCompanion(
      id: Value(id),
      name: Value(name),
    );
  }

  factory MenuPreset.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MenuPreset(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
    };
  }

  MenuPreset copyWith({String? id, String? name}) => MenuPreset(
        id: id ?? this.id,
        name: name ?? this.name,
      );
  MenuPreset copyWithCompanion(MenuPresetsCompanion data) {
    return MenuPreset(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MenuPreset(')
          ..write('id: $id, ')
          ..write('name: $name')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MenuPreset && other.id == this.id && other.name == this.name);
}

class MenuPresetsCompanion extends UpdateCompanion<MenuPreset> {
  final Value<String> id;
  final Value<String> name;
  final Value<int> rowid;
  const MenuPresetsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MenuPresetsCompanion.insert({
    required String id,
    required String name,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        name = Value(name);
  static Insertable<MenuPreset> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MenuPresetsCompanion copyWith(
      {Value<String>? id, Value<String>? name, Value<int>? rowid}) {
    return MenuPresetsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
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
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MenuPresetsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DailyPlanMemosTable extends DailyPlanMemos
    with TableInfo<$DailyPlanMemosTable, DailyPlanMemo> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DailyPlanMemosTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
      'date', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
      'note', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [date, note];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'daily_plan_memos';
  @override
  VerificationContext validateIntegrity(Insertable<DailyPlanMemo> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('date')) {
      context.handle(
          _dateMeta, date.isAcceptableOrUnknown(data['date']!, _dateMeta));
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('note')) {
      context.handle(
          _noteMeta, note.isAcceptableOrUnknown(data['note']!, _noteMeta));
    } else if (isInserting) {
      context.missing(_noteMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {date};
  @override
  DailyPlanMemo map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DailyPlanMemo(
      date: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}date'])!,
      note: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}note'])!,
    );
  }

  @override
  $DailyPlanMemosTable createAlias(String alias) {
    return $DailyPlanMemosTable(attachedDatabase, alias);
  }
}

class DailyPlanMemo extends DataClass implements Insertable<DailyPlanMemo> {
  final DateTime date;
  final String note;
  const DailyPlanMemo({required this.date, required this.note});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['date'] = Variable<DateTime>(date);
    map['note'] = Variable<String>(note);
    return map;
  }

  DailyPlanMemosCompanion toCompanion(bool nullToAbsent) {
    return DailyPlanMemosCompanion(
      date: Value(date),
      note: Value(note),
    );
  }

  factory DailyPlanMemo.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DailyPlanMemo(
      date: serializer.fromJson<DateTime>(json['date']),
      note: serializer.fromJson<String>(json['note']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'date': serializer.toJson<DateTime>(date),
      'note': serializer.toJson<String>(note),
    };
  }

  DailyPlanMemo copyWith({DateTime? date, String? note}) => DailyPlanMemo(
        date: date ?? this.date,
        note: note ?? this.note,
      );
  DailyPlanMemo copyWithCompanion(DailyPlanMemosCompanion data) {
    return DailyPlanMemo(
      date: data.date.present ? data.date.value : this.date,
      note: data.note.present ? data.note.value : this.note,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DailyPlanMemo(')
          ..write('date: $date, ')
          ..write('note: $note')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(date, note);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DailyPlanMemo &&
          other.date == this.date &&
          other.note == this.note);
}

class DailyPlanMemosCompanion extends UpdateCompanion<DailyPlanMemo> {
  final Value<DateTime> date;
  final Value<String> note;
  final Value<int> rowid;
  const DailyPlanMemosCompanion({
    this.date = const Value.absent(),
    this.note = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DailyPlanMemosCompanion.insert({
    required DateTime date,
    required String note,
    this.rowid = const Value.absent(),
  })  : date = Value(date),
        note = Value(note);
  static Insertable<DailyPlanMemo> custom({
    Expression<DateTime>? date,
    Expression<String>? note,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (date != null) 'date': date,
      if (note != null) 'note': note,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DailyPlanMemosCompanion copyWith(
      {Value<DateTime>? date, Value<String>? note, Value<int>? rowid}) {
    return DailyPlanMemosCompanion(
      date: date ?? this.date,
      note: note ?? this.note,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
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
    return (StringBuffer('DailyPlanMemosCompanion(')
          ..write('date: $date, ')
          ..write('note: $note, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TargetRacesTable extends TargetRaces
    with TableInfo<$TargetRacesTable, TargetRace> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TargetRacesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
      'date', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _isMainMeta = const VerificationMeta('isMain');
  @override
  late final GeneratedColumn<bool> isMain = GeneratedColumn<bool>(
      'is_main', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_main" IN (0, 1))'));
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
      'note', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  late final GeneratedColumnWithTypeConverter<PbEvent?, String> raceType =
      GeneratedColumn<String>('race_type', aliasedName, true,
              type: DriftSqlType.string, requiredDuringInsert: false)
          .withConverter<PbEvent?>($TargetRacesTable.$converterraceTypen);
  static const VerificationMeta _distanceMeta =
      const VerificationMeta('distance');
  @override
  late final GeneratedColumn<int> distance = GeneratedColumn<int>(
      'distance', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns =>
      [id, name, date, isMain, note, raceType, distance];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'target_races';
  @override
  VerificationContext validateIntegrity(Insertable<TargetRace> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('date')) {
      context.handle(
          _dateMeta, date.isAcceptableOrUnknown(data['date']!, _dateMeta));
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('is_main')) {
      context.handle(_isMainMeta,
          isMain.isAcceptableOrUnknown(data['is_main']!, _isMainMeta));
    } else if (isInserting) {
      context.missing(_isMainMeta);
    }
    if (data.containsKey('note')) {
      context.handle(
          _noteMeta, note.isAcceptableOrUnknown(data['note']!, _noteMeta));
    }
    if (data.containsKey('distance')) {
      context.handle(_distanceMeta,
          distance.isAcceptableOrUnknown(data['distance']!, _distanceMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TargetRace map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TargetRace(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      date: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}date'])!,
      isMain: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_main'])!,
      note: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}note']),
      raceType: $TargetRacesTable.$converterraceTypen.fromSql(attachedDatabase
          .typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}race_type'])),
      distance: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}distance']),
    );
  }

  @override
  $TargetRacesTable createAlias(String alias) {
    return $TargetRacesTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<PbEvent, String, String> $converterraceType =
      const EnumNameConverter<PbEvent>(PbEvent.values);
  static JsonTypeConverter2<PbEvent?, String?, String?> $converterraceTypen =
      JsonTypeConverter2.asNullable($converterraceType);
}

class TargetRace extends DataClass implements Insertable<TargetRace> {
  final String id;
  final String name;
  final DateTime date;
  final bool isMain;
  final String? note;
  final PbEvent? raceType;
  final int? distance;
  const TargetRace(
      {required this.id,
      required this.name,
      required this.date,
      required this.isMain,
      this.note,
      this.raceType,
      this.distance});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['date'] = Variable<DateTime>(date);
    map['is_main'] = Variable<bool>(isMain);
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    if (!nullToAbsent || raceType != null) {
      map['race_type'] = Variable<String>(
          $TargetRacesTable.$converterraceTypen.toSql(raceType));
    }
    if (!nullToAbsent || distance != null) {
      map['distance'] = Variable<int>(distance);
    }
    return map;
  }

  TargetRacesCompanion toCompanion(bool nullToAbsent) {
    return TargetRacesCompanion(
      id: Value(id),
      name: Value(name),
      date: Value(date),
      isMain: Value(isMain),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      raceType: raceType == null && nullToAbsent
          ? const Value.absent()
          : Value(raceType),
      distance: distance == null && nullToAbsent
          ? const Value.absent()
          : Value(distance),
    );
  }

  factory TargetRace.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TargetRace(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      date: serializer.fromJson<DateTime>(json['date']),
      isMain: serializer.fromJson<bool>(json['isMain']),
      note: serializer.fromJson<String?>(json['note']),
      raceType: $TargetRacesTable.$converterraceTypen
          .fromJson(serializer.fromJson<String?>(json['raceType'])),
      distance: serializer.fromJson<int?>(json['distance']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'date': serializer.toJson<DateTime>(date),
      'isMain': serializer.toJson<bool>(isMain),
      'note': serializer.toJson<String?>(note),
      'raceType': serializer.toJson<String?>(
          $TargetRacesTable.$converterraceTypen.toJson(raceType)),
      'distance': serializer.toJson<int?>(distance),
    };
  }

  TargetRace copyWith(
          {String? id,
          String? name,
          DateTime? date,
          bool? isMain,
          Value<String?> note = const Value.absent(),
          Value<PbEvent?> raceType = const Value.absent(),
          Value<int?> distance = const Value.absent()}) =>
      TargetRace(
        id: id ?? this.id,
        name: name ?? this.name,
        date: date ?? this.date,
        isMain: isMain ?? this.isMain,
        note: note.present ? note.value : this.note,
        raceType: raceType.present ? raceType.value : this.raceType,
        distance: distance.present ? distance.value : this.distance,
      );
  TargetRace copyWithCompanion(TargetRacesCompanion data) {
    return TargetRace(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      date: data.date.present ? data.date.value : this.date,
      isMain: data.isMain.present ? data.isMain.value : this.isMain,
      note: data.note.present ? data.note.value : this.note,
      raceType: data.raceType.present ? data.raceType.value : this.raceType,
      distance: data.distance.present ? data.distance.value : this.distance,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TargetRace(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('date: $date, ')
          ..write('isMain: $isMain, ')
          ..write('note: $note, ')
          ..write('raceType: $raceType, ')
          ..write('distance: $distance')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, name, date, isMain, note, raceType, distance);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TargetRace &&
          other.id == this.id &&
          other.name == this.name &&
          other.date == this.date &&
          other.isMain == this.isMain &&
          other.note == this.note &&
          other.raceType == this.raceType &&
          other.distance == this.distance);
}

class TargetRacesCompanion extends UpdateCompanion<TargetRace> {
  final Value<String> id;
  final Value<String> name;
  final Value<DateTime> date;
  final Value<bool> isMain;
  final Value<String?> note;
  final Value<PbEvent?> raceType;
  final Value<int?> distance;
  final Value<int> rowid;
  const TargetRacesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.date = const Value.absent(),
    this.isMain = const Value.absent(),
    this.note = const Value.absent(),
    this.raceType = const Value.absent(),
    this.distance = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TargetRacesCompanion.insert({
    required String id,
    required String name,
    required DateTime date,
    required bool isMain,
    this.note = const Value.absent(),
    this.raceType = const Value.absent(),
    this.distance = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        name = Value(name),
        date = Value(date),
        isMain = Value(isMain);
  static Insertable<TargetRace> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<DateTime>? date,
    Expression<bool>? isMain,
    Expression<String>? note,
    Expression<String>? raceType,
    Expression<int>? distance,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (date != null) 'date': date,
      if (isMain != null) 'is_main': isMain,
      if (note != null) 'note': note,
      if (raceType != null) 'race_type': raceType,
      if (distance != null) 'distance': distance,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TargetRacesCompanion copyWith(
      {Value<String>? id,
      Value<String>? name,
      Value<DateTime>? date,
      Value<bool>? isMain,
      Value<String?>? note,
      Value<PbEvent?>? raceType,
      Value<int?>? distance,
      Value<int>? rowid}) {
    return TargetRacesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      date: date ?? this.date,
      isMain: isMain ?? this.isMain,
      note: note ?? this.note,
      raceType: raceType ?? this.raceType,
      distance: distance ?? this.distance,
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
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (isMain.present) {
      map['is_main'] = Variable<bool>(isMain.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (raceType.present) {
      map['race_type'] = Variable<String>(
          $TargetRacesTable.$converterraceTypen.toSql(raceType.value));
    }
    if (distance.present) {
      map['distance'] = Variable<int>(distance.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TargetRacesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('date: $date, ')
          ..write('isMain: $isMain, ')
          ..write('note: $note, ')
          ..write('raceType: $raceType, ')
          ..write('distance: $distance, ')
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
  late final $MenuPresetsTable menuPresets = $MenuPresetsTable(this);
  late final $DailyPlanMemosTable dailyPlanMemos = $DailyPlanMemosTable(this);
  late final $TargetRacesTable targetRaces = $TargetRacesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
        personalBests,
        plans,
        sessions,
        menuPresets,
        dailyPlanMemos,
        targetRaces
      ];
}

typedef $$PersonalBestsTableCreateCompanionBuilder = PersonalBestsCompanion
    Function({
  required String id,
  required PbEvent event,
  required int timeMs,
  Value<DateTime?> date,
  Value<String?> note,
  Value<ActivityType> activityType,
  Value<int> rowid,
});
typedef $$PersonalBestsTableUpdateCompanionBuilder = PersonalBestsCompanion
    Function({
  Value<String> id,
  Value<PbEvent> event,
  Value<int> timeMs,
  Value<DateTime?> date,
  Value<String?> note,
  Value<ActivityType> activityType,
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
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<PbEvent, PbEvent, String> get event =>
      $composableBuilder(
          column: $table.event,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnFilters<int> get timeMs => $composableBuilder(
      column: $table.timeMs, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get date => $composableBuilder(
      column: $table.date, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get note => $composableBuilder(
      column: $table.note, builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<ActivityType, ActivityType, String>
      get activityType => $composableBuilder(
          column: $table.activityType,
          builder: (column) => ColumnWithTypeConverterFilters(column));
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
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get event => $composableBuilder(
      column: $table.event, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get timeMs => $composableBuilder(
      column: $table.timeMs, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get date => $composableBuilder(
      column: $table.date, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get note => $composableBuilder(
      column: $table.note, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get activityType => $composableBuilder(
      column: $table.activityType,
      builder: (column) => ColumnOrderings(column));
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

  GeneratedColumnWithTypeConverter<ActivityType, String> get activityType =>
      $composableBuilder(
          column: $table.activityType, builder: (column) => column);
}

class $$PersonalBestsTableTableManager extends RootTableManager<
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
      BaseReferences<_$AppDatabase, $PersonalBestsTable, PersonalBest>
    ),
    PersonalBest,
    PrefetchHooks Function()> {
  $$PersonalBestsTableTableManager(_$AppDatabase db, $PersonalBestsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PersonalBestsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PersonalBestsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PersonalBestsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<PbEvent> event = const Value.absent(),
            Value<int> timeMs = const Value.absent(),
            Value<DateTime?> date = const Value.absent(),
            Value<String?> note = const Value.absent(),
            Value<ActivityType> activityType = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              PersonalBestsCompanion(
            id: id,
            event: event,
            timeMs: timeMs,
            date: date,
            note: note,
            activityType: activityType,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required PbEvent event,
            required int timeMs,
            Value<DateTime?> date = const Value.absent(),
            Value<String?> note = const Value.absent(),
            Value<ActivityType> activityType = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              PersonalBestsCompanion.insert(
            id: id,
            event: event,
            timeMs: timeMs,
            date: date,
            note: note,
            activityType: activityType,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$PersonalBestsTableProcessedTableManager = ProcessedTableManager<
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
      BaseReferences<_$AppDatabase, $PersonalBestsTable, PersonalBest>
    ),
    PersonalBest,
    PrefetchHooks Function()>;
typedef $$PlansTableCreateCompanionBuilder = PlansCompanion Function({
  required String id,
  required DateTime date,
  required String menuName,
  Value<int?> distance,
  Value<int?> pace,
  Value<Zone?> zone,
  Value<int> reps,
  Value<ActivityType> activityType,
  Value<String?> note,
  Value<bool> isRace,
  Value<int?> duration,
  Value<int> rowid,
});
typedef $$PlansTableUpdateCompanionBuilder = PlansCompanion Function({
  Value<String> id,
  Value<DateTime> date,
  Value<String> menuName,
  Value<int?> distance,
  Value<int?> pace,
  Value<Zone?> zone,
  Value<int> reps,
  Value<ActivityType> activityType,
  Value<String?> note,
  Value<bool> isRace,
  Value<int?> duration,
  Value<int> rowid,
});

final class $$PlansTableReferences
    extends BaseReferences<_$AppDatabase, $PlansTable, Plan> {
  $$PlansTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$SessionsTable, List<Session>> _sessionsRefsTable(
          _$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.sessions,
          aliasName: $_aliasNameGenerator(db.plans.id, db.sessions.planId));

  $$SessionsTableProcessedTableManager get sessionsRefs {
    final manager = $$SessionsTableTableManager($_db, $_db.sessions)
        .filter((f) => f.planId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_sessionsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
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
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get date => $composableBuilder(
      column: $table.date, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get menuName => $composableBuilder(
      column: $table.menuName, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get distance => $composableBuilder(
      column: $table.distance, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get pace => $composableBuilder(
      column: $table.pace, builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<Zone?, Zone, String> get zone =>
      $composableBuilder(
          column: $table.zone,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnFilters<int> get reps => $composableBuilder(
      column: $table.reps, builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<ActivityType, ActivityType, String>
      get activityType => $composableBuilder(
          column: $table.activityType,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnFilters<String> get note => $composableBuilder(
      column: $table.note, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isRace => $composableBuilder(
      column: $table.isRace, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get duration => $composableBuilder(
      column: $table.duration, builder: (column) => ColumnFilters(column));

  Expression<bool> sessionsRefs(
      Expression<bool> Function($$SessionsTableFilterComposer f) f) {
    final $$SessionsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.sessions,
        getReferencedColumn: (t) => t.planId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SessionsTableFilterComposer(
              $db: $db,
              $table: $db.sessions,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
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
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get date => $composableBuilder(
      column: $table.date, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get menuName => $composableBuilder(
      column: $table.menuName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get distance => $composableBuilder(
      column: $table.distance, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get pace => $composableBuilder(
      column: $table.pace, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get zone => $composableBuilder(
      column: $table.zone, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get reps => $composableBuilder(
      column: $table.reps, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get activityType => $composableBuilder(
      column: $table.activityType,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get note => $composableBuilder(
      column: $table.note, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isRace => $composableBuilder(
      column: $table.isRace, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get duration => $composableBuilder(
      column: $table.duration, builder: (column) => ColumnOrderings(column));
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

  GeneratedColumn<String> get menuName =>
      $composableBuilder(column: $table.menuName, builder: (column) => column);

  GeneratedColumn<int> get distance =>
      $composableBuilder(column: $table.distance, builder: (column) => column);

  GeneratedColumn<int> get pace =>
      $composableBuilder(column: $table.pace, builder: (column) => column);

  GeneratedColumnWithTypeConverter<Zone?, String> get zone =>
      $composableBuilder(column: $table.zone, builder: (column) => column);

  GeneratedColumn<int> get reps =>
      $composableBuilder(column: $table.reps, builder: (column) => column);

  GeneratedColumnWithTypeConverter<ActivityType, String> get activityType =>
      $composableBuilder(
          column: $table.activityType, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<bool> get isRace =>
      $composableBuilder(column: $table.isRace, builder: (column) => column);

  GeneratedColumn<int> get duration =>
      $composableBuilder(column: $table.duration, builder: (column) => column);

  Expression<T> sessionsRefs<T extends Object>(
      Expression<T> Function($$SessionsTableAnnotationComposer a) f) {
    final $$SessionsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.sessions,
        getReferencedColumn: (t) => t.planId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SessionsTableAnnotationComposer(
              $db: $db,
              $table: $db.sessions,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$PlansTableTableManager extends RootTableManager<
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
    PrefetchHooks Function({bool sessionsRefs})> {
  $$PlansTableTableManager(_$AppDatabase db, $PlansTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PlansTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PlansTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PlansTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<DateTime> date = const Value.absent(),
            Value<String> menuName = const Value.absent(),
            Value<int?> distance = const Value.absent(),
            Value<int?> pace = const Value.absent(),
            Value<Zone?> zone = const Value.absent(),
            Value<int> reps = const Value.absent(),
            Value<ActivityType> activityType = const Value.absent(),
            Value<String?> note = const Value.absent(),
            Value<bool> isRace = const Value.absent(),
            Value<int?> duration = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              PlansCompanion(
            id: id,
            date: date,
            menuName: menuName,
            distance: distance,
            pace: pace,
            zone: zone,
            reps: reps,
            activityType: activityType,
            note: note,
            isRace: isRace,
            duration: duration,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required DateTime date,
            required String menuName,
            Value<int?> distance = const Value.absent(),
            Value<int?> pace = const Value.absent(),
            Value<Zone?> zone = const Value.absent(),
            Value<int> reps = const Value.absent(),
            Value<ActivityType> activityType = const Value.absent(),
            Value<String?> note = const Value.absent(),
            Value<bool> isRace = const Value.absent(),
            Value<int?> duration = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              PlansCompanion.insert(
            id: id,
            date: date,
            menuName: menuName,
            distance: distance,
            pace: pace,
            zone: zone,
            reps: reps,
            activityType: activityType,
            note: note,
            isRace: isRace,
            duration: duration,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) =>
                  (e.readTable(table), $$PlansTableReferences(db, table, e)))
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
                        referencedTable:
                            $$PlansTableReferences._sessionsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$PlansTableReferences(db, table, p0).sessionsRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.planId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$PlansTableProcessedTableManager = ProcessedTableManager<
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
    PrefetchHooks Function({bool sessionsRefs})>;
typedef $$SessionsTableCreateCompanionBuilder = SessionsCompanion Function({
  required String id,
  required DateTime startedAt,
  Value<String?> planId,
  required String templateText,
  Value<int?> reps,
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
  Value<double?> load,
  Value<int?> repLoad,
  Value<ActivityType> activityType,
  Value<bool> isRace,
  Value<int> rowid,
});
typedef $$SessionsTableUpdateCompanionBuilder = SessionsCompanion Function({
  Value<String> id,
  Value<DateTime> startedAt,
  Value<String?> planId,
  Value<String> templateText,
  Value<int?> reps,
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
  Value<double?> load,
  Value<int?> repLoad,
  Value<ActivityType> activityType,
  Value<bool> isRace,
  Value<int> rowid,
});

final class $$SessionsTableReferences
    extends BaseReferences<_$AppDatabase, $SessionsTable, Session> {
  $$SessionsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $PlansTable _planIdTable(_$AppDatabase db) => db.plans
      .createAlias($_aliasNameGenerator(db.sessions.planId, db.plans.id));

  $$PlansTableProcessedTableManager? get planId {
    final $_column = $_itemColumn<String>('plan_id');
    if ($_column == null) return null;
    final manager = $$PlansTableTableManager($_db, $_db.plans)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_planIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
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
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get startedAt => $composableBuilder(
      column: $table.startedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get templateText => $composableBuilder(
      column: $table.templateText, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get reps => $composableBuilder(
      column: $table.reps, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get distanceMainM => $composableBuilder(
      column: $table.distanceMainM, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get durationMainSec => $composableBuilder(
      column: $table.durationMainSec,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get paceSecPerKm => $composableBuilder(
      column: $table.paceSecPerKm, builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<Zone?, Zone, String> get zone =>
      $composableBuilder(
          column: $table.zone,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnFilters<int> get rpeValue => $composableBuilder(
      column: $table.rpeValue, builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<RestType?, RestType, String> get restType =>
      $composableBuilder(
          column: $table.restType,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnFilters<int> get restDurationSec => $composableBuilder(
      column: $table.restDurationSec,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get restDistanceM => $composableBuilder(
      column: $table.restDistanceM, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get wuDistanceM => $composableBuilder(
      column: $table.wuDistanceM, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get wuDurationSec => $composableBuilder(
      column: $table.wuDurationSec, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get cdDistanceM => $composableBuilder(
      column: $table.cdDistanceM, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get cdDurationSec => $composableBuilder(
      column: $table.cdDurationSec, builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<SessionStatus, SessionStatus, String>
      get status => $composableBuilder(
          column: $table.status,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnFilters<String> get note => $composableBuilder(
      column: $table.note, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get load => $composableBuilder(
      column: $table.load, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get repLoad => $composableBuilder(
      column: $table.repLoad, builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<ActivityType, ActivityType, String>
      get activityType => $composableBuilder(
          column: $table.activityType,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnFilters<bool> get isRace => $composableBuilder(
      column: $table.isRace, builder: (column) => ColumnFilters(column));

  $$PlansTableFilterComposer get planId {
    final $$PlansTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.planId,
        referencedTable: $db.plans,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$PlansTableFilterComposer(
              $db: $db,
              $table: $db.plans,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
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
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get startedAt => $composableBuilder(
      column: $table.startedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get templateText => $composableBuilder(
      column: $table.templateText,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get reps => $composableBuilder(
      column: $table.reps, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get distanceMainM => $composableBuilder(
      column: $table.distanceMainM,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get durationMainSec => $composableBuilder(
      column: $table.durationMainSec,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get paceSecPerKm => $composableBuilder(
      column: $table.paceSecPerKm,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get zone => $composableBuilder(
      column: $table.zone, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get rpeValue => $composableBuilder(
      column: $table.rpeValue, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get restType => $composableBuilder(
      column: $table.restType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get restDurationSec => $composableBuilder(
      column: $table.restDurationSec,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get restDistanceM => $composableBuilder(
      column: $table.restDistanceM,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get wuDistanceM => $composableBuilder(
      column: $table.wuDistanceM, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get wuDurationSec => $composableBuilder(
      column: $table.wuDurationSec,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get cdDistanceM => $composableBuilder(
      column: $table.cdDistanceM, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get cdDurationSec => $composableBuilder(
      column: $table.cdDurationSec,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get note => $composableBuilder(
      column: $table.note, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get load => $composableBuilder(
      column: $table.load, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get repLoad => $composableBuilder(
      column: $table.repLoad, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get activityType => $composableBuilder(
      column: $table.activityType,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isRace => $composableBuilder(
      column: $table.isRace, builder: (column) => ColumnOrderings(column));

  $$PlansTableOrderingComposer get planId {
    final $$PlansTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.planId,
        referencedTable: $db.plans,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$PlansTableOrderingComposer(
              $db: $db,
              $table: $db.plans,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
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
      column: $table.templateText, builder: (column) => column);

  GeneratedColumn<int> get reps =>
      $composableBuilder(column: $table.reps, builder: (column) => column);

  GeneratedColumn<int> get distanceMainM => $composableBuilder(
      column: $table.distanceMainM, builder: (column) => column);

  GeneratedColumn<int> get durationMainSec => $composableBuilder(
      column: $table.durationMainSec, builder: (column) => column);

  GeneratedColumn<int> get paceSecPerKm => $composableBuilder(
      column: $table.paceSecPerKm, builder: (column) => column);

  GeneratedColumnWithTypeConverter<Zone?, String> get zone =>
      $composableBuilder(column: $table.zone, builder: (column) => column);

  GeneratedColumn<int> get rpeValue =>
      $composableBuilder(column: $table.rpeValue, builder: (column) => column);

  GeneratedColumnWithTypeConverter<RestType?, String> get restType =>
      $composableBuilder(column: $table.restType, builder: (column) => column);

  GeneratedColumn<int> get restDurationSec => $composableBuilder(
      column: $table.restDurationSec, builder: (column) => column);

  GeneratedColumn<int> get restDistanceM => $composableBuilder(
      column: $table.restDistanceM, builder: (column) => column);

  GeneratedColumn<int> get wuDistanceM => $composableBuilder(
      column: $table.wuDistanceM, builder: (column) => column);

  GeneratedColumn<int> get wuDurationSec => $composableBuilder(
      column: $table.wuDurationSec, builder: (column) => column);

  GeneratedColumn<int> get cdDistanceM => $composableBuilder(
      column: $table.cdDistanceM, builder: (column) => column);

  GeneratedColumn<int> get cdDurationSec => $composableBuilder(
      column: $table.cdDurationSec, builder: (column) => column);

  GeneratedColumnWithTypeConverter<SessionStatus, String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<double> get load =>
      $composableBuilder(column: $table.load, builder: (column) => column);

  GeneratedColumn<int> get repLoad =>
      $composableBuilder(column: $table.repLoad, builder: (column) => column);

  GeneratedColumnWithTypeConverter<ActivityType, String> get activityType =>
      $composableBuilder(
          column: $table.activityType, builder: (column) => column);

  GeneratedColumn<bool> get isRace =>
      $composableBuilder(column: $table.isRace, builder: (column) => column);

  $$PlansTableAnnotationComposer get planId {
    final $$PlansTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.planId,
        referencedTable: $db.plans,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$PlansTableAnnotationComposer(
              $db: $db,
              $table: $db.plans,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$SessionsTableTableManager extends RootTableManager<
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
    PrefetchHooks Function({bool planId})> {
  $$SessionsTableTableManager(_$AppDatabase db, $SessionsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SessionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SessionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SessionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<DateTime> startedAt = const Value.absent(),
            Value<String?> planId = const Value.absent(),
            Value<String> templateText = const Value.absent(),
            Value<int?> reps = const Value.absent(),
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
            Value<double?> load = const Value.absent(),
            Value<int?> repLoad = const Value.absent(),
            Value<ActivityType> activityType = const Value.absent(),
            Value<bool> isRace = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              SessionsCompanion(
            id: id,
            startedAt: startedAt,
            planId: planId,
            templateText: templateText,
            reps: reps,
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
            load: load,
            repLoad: repLoad,
            activityType: activityType,
            isRace: isRace,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required DateTime startedAt,
            Value<String?> planId = const Value.absent(),
            required String templateText,
            Value<int?> reps = const Value.absent(),
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
            Value<double?> load = const Value.absent(),
            Value<int?> repLoad = const Value.absent(),
            Value<ActivityType> activityType = const Value.absent(),
            Value<bool> isRace = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              SessionsCompanion.insert(
            id: id,
            startedAt: startedAt,
            planId: planId,
            templateText: templateText,
            reps: reps,
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
            load: load,
            repLoad: repLoad,
            activityType: activityType,
            isRace: isRace,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) =>
                  (e.readTable(table), $$SessionsTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: ({planId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
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
                      dynamic>>(state) {
                if (planId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.planId,
                    referencedTable: $$SessionsTableReferences._planIdTable(db),
                    referencedColumn:
                        $$SessionsTableReferences._planIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$SessionsTableProcessedTableManager = ProcessedTableManager<
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
    PrefetchHooks Function({bool planId})>;
typedef $$MenuPresetsTableCreateCompanionBuilder = MenuPresetsCompanion
    Function({
  required String id,
  required String name,
  Value<int> rowid,
});
typedef $$MenuPresetsTableUpdateCompanionBuilder = MenuPresetsCompanion
    Function({
  Value<String> id,
  Value<String> name,
  Value<int> rowid,
});

class $$MenuPresetsTableFilterComposer
    extends Composer<_$AppDatabase, $MenuPresetsTable> {
  $$MenuPresetsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));
}

class $$MenuPresetsTableOrderingComposer
    extends Composer<_$AppDatabase, $MenuPresetsTable> {
  $$MenuPresetsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));
}

class $$MenuPresetsTableAnnotationComposer
    extends Composer<_$AppDatabase, $MenuPresetsTable> {
  $$MenuPresetsTableAnnotationComposer({
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
}

class $$MenuPresetsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $MenuPresetsTable,
    MenuPreset,
    $$MenuPresetsTableFilterComposer,
    $$MenuPresetsTableOrderingComposer,
    $$MenuPresetsTableAnnotationComposer,
    $$MenuPresetsTableCreateCompanionBuilder,
    $$MenuPresetsTableUpdateCompanionBuilder,
    (MenuPreset, BaseReferences<_$AppDatabase, $MenuPresetsTable, MenuPreset>),
    MenuPreset,
    PrefetchHooks Function()> {
  $$MenuPresetsTableTableManager(_$AppDatabase db, $MenuPresetsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MenuPresetsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MenuPresetsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MenuPresetsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              MenuPresetsCompanion(
            id: id,
            name: name,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String name,
            Value<int> rowid = const Value.absent(),
          }) =>
              MenuPresetsCompanion.insert(
            id: id,
            name: name,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$MenuPresetsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $MenuPresetsTable,
    MenuPreset,
    $$MenuPresetsTableFilterComposer,
    $$MenuPresetsTableOrderingComposer,
    $$MenuPresetsTableAnnotationComposer,
    $$MenuPresetsTableCreateCompanionBuilder,
    $$MenuPresetsTableUpdateCompanionBuilder,
    (MenuPreset, BaseReferences<_$AppDatabase, $MenuPresetsTable, MenuPreset>),
    MenuPreset,
    PrefetchHooks Function()>;
typedef $$DailyPlanMemosTableCreateCompanionBuilder = DailyPlanMemosCompanion
    Function({
  required DateTime date,
  required String note,
  Value<int> rowid,
});
typedef $$DailyPlanMemosTableUpdateCompanionBuilder = DailyPlanMemosCompanion
    Function({
  Value<DateTime> date,
  Value<String> note,
  Value<int> rowid,
});

class $$DailyPlanMemosTableFilterComposer
    extends Composer<_$AppDatabase, $DailyPlanMemosTable> {
  $$DailyPlanMemosTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<DateTime> get date => $composableBuilder(
      column: $table.date, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get note => $composableBuilder(
      column: $table.note, builder: (column) => ColumnFilters(column));
}

class $$DailyPlanMemosTableOrderingComposer
    extends Composer<_$AppDatabase, $DailyPlanMemosTable> {
  $$DailyPlanMemosTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<DateTime> get date => $composableBuilder(
      column: $table.date, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get note => $composableBuilder(
      column: $table.note, builder: (column) => ColumnOrderings(column));
}

class $$DailyPlanMemosTableAnnotationComposer
    extends Composer<_$AppDatabase, $DailyPlanMemosTable> {
  $$DailyPlanMemosTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);
}

class $$DailyPlanMemosTableTableManager extends RootTableManager<
    _$AppDatabase,
    $DailyPlanMemosTable,
    DailyPlanMemo,
    $$DailyPlanMemosTableFilterComposer,
    $$DailyPlanMemosTableOrderingComposer,
    $$DailyPlanMemosTableAnnotationComposer,
    $$DailyPlanMemosTableCreateCompanionBuilder,
    $$DailyPlanMemosTableUpdateCompanionBuilder,
    (
      DailyPlanMemo,
      BaseReferences<_$AppDatabase, $DailyPlanMemosTable, DailyPlanMemo>
    ),
    DailyPlanMemo,
    PrefetchHooks Function()> {
  $$DailyPlanMemosTableTableManager(
      _$AppDatabase db, $DailyPlanMemosTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DailyPlanMemosTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DailyPlanMemosTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DailyPlanMemosTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<DateTime> date = const Value.absent(),
            Value<String> note = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              DailyPlanMemosCompanion(
            date: date,
            note: note,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required DateTime date,
            required String note,
            Value<int> rowid = const Value.absent(),
          }) =>
              DailyPlanMemosCompanion.insert(
            date: date,
            note: note,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$DailyPlanMemosTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $DailyPlanMemosTable,
    DailyPlanMemo,
    $$DailyPlanMemosTableFilterComposer,
    $$DailyPlanMemosTableOrderingComposer,
    $$DailyPlanMemosTableAnnotationComposer,
    $$DailyPlanMemosTableCreateCompanionBuilder,
    $$DailyPlanMemosTableUpdateCompanionBuilder,
    (
      DailyPlanMemo,
      BaseReferences<_$AppDatabase, $DailyPlanMemosTable, DailyPlanMemo>
    ),
    DailyPlanMemo,
    PrefetchHooks Function()>;
typedef $$TargetRacesTableCreateCompanionBuilder = TargetRacesCompanion
    Function({
  required String id,
  required String name,
  required DateTime date,
  required bool isMain,
  Value<String?> note,
  Value<PbEvent?> raceType,
  Value<int?> distance,
  Value<int> rowid,
});
typedef $$TargetRacesTableUpdateCompanionBuilder = TargetRacesCompanion
    Function({
  Value<String> id,
  Value<String> name,
  Value<DateTime> date,
  Value<bool> isMain,
  Value<String?> note,
  Value<PbEvent?> raceType,
  Value<int?> distance,
  Value<int> rowid,
});

class $$TargetRacesTableFilterComposer
    extends Composer<_$AppDatabase, $TargetRacesTable> {
  $$TargetRacesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get date => $composableBuilder(
      column: $table.date, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isMain => $composableBuilder(
      column: $table.isMain, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get note => $composableBuilder(
      column: $table.note, builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<PbEvent?, PbEvent, String> get raceType =>
      $composableBuilder(
          column: $table.raceType,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnFilters<int> get distance => $composableBuilder(
      column: $table.distance, builder: (column) => ColumnFilters(column));
}

class $$TargetRacesTableOrderingComposer
    extends Composer<_$AppDatabase, $TargetRacesTable> {
  $$TargetRacesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get date => $composableBuilder(
      column: $table.date, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isMain => $composableBuilder(
      column: $table.isMain, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get note => $composableBuilder(
      column: $table.note, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get raceType => $composableBuilder(
      column: $table.raceType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get distance => $composableBuilder(
      column: $table.distance, builder: (column) => ColumnOrderings(column));
}

class $$TargetRacesTableAnnotationComposer
    extends Composer<_$AppDatabase, $TargetRacesTable> {
  $$TargetRacesTableAnnotationComposer({
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

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<bool> get isMain =>
      $composableBuilder(column: $table.isMain, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumnWithTypeConverter<PbEvent?, String> get raceType =>
      $composableBuilder(column: $table.raceType, builder: (column) => column);

  GeneratedColumn<int> get distance =>
      $composableBuilder(column: $table.distance, builder: (column) => column);
}

class $$TargetRacesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $TargetRacesTable,
    TargetRace,
    $$TargetRacesTableFilterComposer,
    $$TargetRacesTableOrderingComposer,
    $$TargetRacesTableAnnotationComposer,
    $$TargetRacesTableCreateCompanionBuilder,
    $$TargetRacesTableUpdateCompanionBuilder,
    (TargetRace, BaseReferences<_$AppDatabase, $TargetRacesTable, TargetRace>),
    TargetRace,
    PrefetchHooks Function()> {
  $$TargetRacesTableTableManager(_$AppDatabase db, $TargetRacesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TargetRacesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TargetRacesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TargetRacesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<DateTime> date = const Value.absent(),
            Value<bool> isMain = const Value.absent(),
            Value<String?> note = const Value.absent(),
            Value<PbEvent?> raceType = const Value.absent(),
            Value<int?> distance = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              TargetRacesCompanion(
            id: id,
            name: name,
            date: date,
            isMain: isMain,
            note: note,
            raceType: raceType,
            distance: distance,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String name,
            required DateTime date,
            required bool isMain,
            Value<String?> note = const Value.absent(),
            Value<PbEvent?> raceType = const Value.absent(),
            Value<int?> distance = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              TargetRacesCompanion.insert(
            id: id,
            name: name,
            date: date,
            isMain: isMain,
            note: note,
            raceType: raceType,
            distance: distance,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$TargetRacesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $TargetRacesTable,
    TargetRace,
    $$TargetRacesTableFilterComposer,
    $$TargetRacesTableOrderingComposer,
    $$TargetRacesTableAnnotationComposer,
    $$TargetRacesTableCreateCompanionBuilder,
    $$TargetRacesTableUpdateCompanionBuilder,
    (TargetRace, BaseReferences<_$AppDatabase, $TargetRacesTable, TargetRace>),
    TargetRace,
    PrefetchHooks Function()>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$PersonalBestsTableTableManager get personalBests =>
      $$PersonalBestsTableTableManager(_db, _db.personalBests);
  $$PlansTableTableManager get plans =>
      $$PlansTableTableManager(_db, _db.plans);
  $$SessionsTableTableManager get sessions =>
      $$SessionsTableTableManager(_db, _db.sessions);
  $$MenuPresetsTableTableManager get menuPresets =>
      $$MenuPresetsTableTableManager(_db, _db.menuPresets);
  $$DailyPlanMemosTableTableManager get dailyPlanMemos =>
      $$DailyPlanMemosTableTableManager(_db, _db.dailyPlanMemos);
  $$TargetRacesTableTableManager get targetRaces =>
      $$TargetRacesTableTableManager(_db, _db.targetRaces);
}
