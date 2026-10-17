// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $RentalUnitsTable extends RentalUnits
    with TableInfo<$RentalUnitsTable, DbRentalUnit> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RentalUnitsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [id, name, sortOrder];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'rental_units';
  @override
  VerificationContext validateIntegrity(
    Insertable<DbRentalUnit> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DbRentalUnit map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DbRentalUnit(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
    );
  }

  @override
  $RentalUnitsTable createAlias(String alias) {
    return $RentalUnitsTable(attachedDatabase, alias);
  }
}

class DbRentalUnit extends DataClass implements Insertable<DbRentalUnit> {
  final int id;
  final String name;
  final int sortOrder;
  const DbRentalUnit({
    required this.id,
    required this.name,
    required this.sortOrder,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['sort_order'] = Variable<int>(sortOrder);
    return map;
  }

  RentalUnitsCompanion toCompanion(bool nullToAbsent) {
    return RentalUnitsCompanion(
      id: Value(id),
      name: Value(name),
      sortOrder: Value(sortOrder),
    );
  }

  factory DbRentalUnit.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DbRentalUnit(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'sortOrder': serializer.toJson<int>(sortOrder),
    };
  }

  DbRentalUnit copyWith({int? id, String? name, int? sortOrder}) =>
      DbRentalUnit(
        id: id ?? this.id,
        name: name ?? this.name,
        sortOrder: sortOrder ?? this.sortOrder,
      );
  DbRentalUnit copyWithCompanion(RentalUnitsCompanion data) {
    return DbRentalUnit(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DbRentalUnit(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('sortOrder: $sortOrder')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, sortOrder);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DbRentalUnit &&
          other.id == this.id &&
          other.name == this.name &&
          other.sortOrder == this.sortOrder);
}

class RentalUnitsCompanion extends UpdateCompanion<DbRentalUnit> {
  final Value<int> id;
  final Value<String> name;
  final Value<int> sortOrder;
  const RentalUnitsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.sortOrder = const Value.absent(),
  });
  RentalUnitsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.sortOrder = const Value.absent(),
  }) : name = Value(name);
  static Insertable<DbRentalUnit> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<int>? sortOrder,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (sortOrder != null) 'sort_order': sortOrder,
    });
  }

  RentalUnitsCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<int>? sortOrder,
  }) {
    return RentalUnitsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RentalUnitsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('sortOrder: $sortOrder')
          ..write(')'))
        .toString();
  }
}

class $BookingsTable extends Bookings
    with TableInfo<$BookingsTable, DbBooking> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BookingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _rentalUnitIdMeta = const VerificationMeta(
    'rentalUnitId',
  );
  @override
  late final GeneratedColumn<int> rentalUnitId = GeneratedColumn<int>(
    'rental_unit_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES rental_units (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _startDateMsMeta = const VerificationMeta(
    'startDateMs',
  );
  @override
  late final GeneratedColumn<int> startDateMs = GeneratedColumn<int>(
    'start_date_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _endDateMsMeta = const VerificationMeta(
    'endDateMs',
  );
  @override
  late final GeneratedColumn<int> endDateMs = GeneratedColumn<int>(
    'end_date_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('unpaid'),
  );
  static const VerificationMeta _clientNameMeta = const VerificationMeta(
    'clientName',
  );
  @override
  late final GeneratedColumn<String> clientName = GeneratedColumn<String>(
    'client_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _clientPhoneMeta = const VerificationMeta(
    'clientPhone',
  );
  @override
  late final GeneratedColumn<String> clientPhone = GeneratedColumn<String>(
    'client_phone',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<double> amount = GeneratedColumn<double>(
    'amount',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _depositMeta = const VerificationMeta(
    'deposit',
  );
  @override
  late final GeneratedColumn<String> deposit = GeneratedColumn<String>(
    'deposit',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _guestsMeta = const VerificationMeta('guests');
  @override
  late final GeneratedColumn<int> guests = GeneratedColumn<int>(
    'guests',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _childrenMeta = const VerificationMeta(
    'children',
  );
  @override
  late final GeneratedColumn<int> children = GeneratedColumn<int>(
    'children',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _hasPetsMeta = const VerificationMeta(
    'hasPets',
  );
  @override
  late final GeneratedColumn<bool> hasPets = GeneratedColumn<bool>(
    'has_pets',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("has_pets" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _sourceMeta = const VerificationMeta('source');
  @override
  late final GeneratedColumn<String> source = GeneratedColumn<String>(
    'source',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _commentMeta = const VerificationMeta(
    'comment',
  );
  @override
  late final GeneratedColumn<String> comment = GeneratedColumn<String>(
    'comment',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    rentalUnitId,
    startDateMs,
    endDateMs,
    status,
    clientName,
    clientPhone,
    amount,
    deposit,
    guests,
    children,
    hasPets,
    source,
    comment,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'bookings';
  @override
  VerificationContext validateIntegrity(
    Insertable<DbBooking> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('rental_unit_id')) {
      context.handle(
        _rentalUnitIdMeta,
        rentalUnitId.isAcceptableOrUnknown(
          data['rental_unit_id']!,
          _rentalUnitIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_rentalUnitIdMeta);
    }
    if (data.containsKey('start_date_ms')) {
      context.handle(
        _startDateMsMeta,
        startDateMs.isAcceptableOrUnknown(
          data['start_date_ms']!,
          _startDateMsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_startDateMsMeta);
    }
    if (data.containsKey('end_date_ms')) {
      context.handle(
        _endDateMsMeta,
        endDateMs.isAcceptableOrUnknown(data['end_date_ms']!, _endDateMsMeta),
      );
    } else if (isInserting) {
      context.missing(_endDateMsMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('client_name')) {
      context.handle(
        _clientNameMeta,
        clientName.isAcceptableOrUnknown(data['client_name']!, _clientNameMeta),
      );
    }
    if (data.containsKey('client_phone')) {
      context.handle(
        _clientPhoneMeta,
        clientPhone.isAcceptableOrUnknown(
          data['client_phone']!,
          _clientPhoneMeta,
        ),
      );
    }
    if (data.containsKey('amount')) {
      context.handle(
        _amountMeta,
        amount.isAcceptableOrUnknown(data['amount']!, _amountMeta),
      );
    }
    if (data.containsKey('deposit')) {
      context.handle(
        _depositMeta,
        deposit.isAcceptableOrUnknown(data['deposit']!, _depositMeta),
      );
    }
    if (data.containsKey('guests')) {
      context.handle(
        _guestsMeta,
        guests.isAcceptableOrUnknown(data['guests']!, _guestsMeta),
      );
    }
    if (data.containsKey('children')) {
      context.handle(
        _childrenMeta,
        children.isAcceptableOrUnknown(data['children']!, _childrenMeta),
      );
    }
    if (data.containsKey('has_pets')) {
      context.handle(
        _hasPetsMeta,
        hasPets.isAcceptableOrUnknown(data['has_pets']!, _hasPetsMeta),
      );
    }
    if (data.containsKey('source')) {
      context.handle(
        _sourceMeta,
        source.isAcceptableOrUnknown(data['source']!, _sourceMeta),
      );
    }
    if (data.containsKey('comment')) {
      context.handle(
        _commentMeta,
        comment.isAcceptableOrUnknown(data['comment']!, _commentMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DbBooking map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DbBooking(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      rentalUnitId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}rental_unit_id'],
      )!,
      startDateMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}start_date_ms'],
      )!,
      endDateMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}end_date_ms'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      clientName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}client_name'],
      )!,
      clientPhone: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}client_phone'],
      )!,
      amount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}amount'],
      ),
      deposit: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}deposit'],
      )!,
      guests: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}guests'],
      )!,
      children: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}children'],
      )!,
      hasPets: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}has_pets'],
      )!,
      source: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source'],
      ),
      comment: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}comment'],
      )!,
    );
  }

  @override
  $BookingsTable createAlias(String alias) {
    return $BookingsTable(attachedDatabase, alias);
  }
}

class DbBooking extends DataClass implements Insertable<DbBooking> {
  final int id;
  final int rentalUnitId;
  final int startDateMs;
  final int endDateMs;
  final String status;
  final String clientName;
  final String clientPhone;
  final double? amount;
  final String deposit;
  final int guests;
  final int children;
  final bool hasPets;
  final String? source;
  final String comment;
  const DbBooking({
    required this.id,
    required this.rentalUnitId,
    required this.startDateMs,
    required this.endDateMs,
    required this.status,
    required this.clientName,
    required this.clientPhone,
    this.amount,
    required this.deposit,
    required this.guests,
    required this.children,
    required this.hasPets,
    this.source,
    required this.comment,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['rental_unit_id'] = Variable<int>(rentalUnitId);
    map['start_date_ms'] = Variable<int>(startDateMs);
    map['end_date_ms'] = Variable<int>(endDateMs);
    map['status'] = Variable<String>(status);
    map['client_name'] = Variable<String>(clientName);
    map['client_phone'] = Variable<String>(clientPhone);
    if (!nullToAbsent || amount != null) {
      map['amount'] = Variable<double>(amount);
    }
    map['deposit'] = Variable<String>(deposit);
    map['guests'] = Variable<int>(guests);
    map['children'] = Variable<int>(children);
    map['has_pets'] = Variable<bool>(hasPets);
    if (!nullToAbsent || source != null) {
      map['source'] = Variable<String>(source);
    }
    map['comment'] = Variable<String>(comment);
    return map;
  }

  BookingsCompanion toCompanion(bool nullToAbsent) {
    return BookingsCompanion(
      id: Value(id),
      rentalUnitId: Value(rentalUnitId),
      startDateMs: Value(startDateMs),
      endDateMs: Value(endDateMs),
      status: Value(status),
      clientName: Value(clientName),
      clientPhone: Value(clientPhone),
      amount: amount == null && nullToAbsent
          ? const Value.absent()
          : Value(amount),
      deposit: Value(deposit),
      guests: Value(guests),
      children: Value(children),
      hasPets: Value(hasPets),
      source: source == null && nullToAbsent
          ? const Value.absent()
          : Value(source),
      comment: Value(comment),
    );
  }

  factory DbBooking.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DbBooking(
      id: serializer.fromJson<int>(json['id']),
      rentalUnitId: serializer.fromJson<int>(json['rentalUnitId']),
      startDateMs: serializer.fromJson<int>(json['startDateMs']),
      endDateMs: serializer.fromJson<int>(json['endDateMs']),
      status: serializer.fromJson<String>(json['status']),
      clientName: serializer.fromJson<String>(json['clientName']),
      clientPhone: serializer.fromJson<String>(json['clientPhone']),
      amount: serializer.fromJson<double?>(json['amount']),
      deposit: serializer.fromJson<String>(json['deposit']),
      guests: serializer.fromJson<int>(json['guests']),
      children: serializer.fromJson<int>(json['children']),
      hasPets: serializer.fromJson<bool>(json['hasPets']),
      source: serializer.fromJson<String?>(json['source']),
      comment: serializer.fromJson<String>(json['comment']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'rentalUnitId': serializer.toJson<int>(rentalUnitId),
      'startDateMs': serializer.toJson<int>(startDateMs),
      'endDateMs': serializer.toJson<int>(endDateMs),
      'status': serializer.toJson<String>(status),
      'clientName': serializer.toJson<String>(clientName),
      'clientPhone': serializer.toJson<String>(clientPhone),
      'amount': serializer.toJson<double?>(amount),
      'deposit': serializer.toJson<String>(deposit),
      'guests': serializer.toJson<int>(guests),
      'children': serializer.toJson<int>(children),
      'hasPets': serializer.toJson<bool>(hasPets),
      'source': serializer.toJson<String?>(source),
      'comment': serializer.toJson<String>(comment),
    };
  }

  DbBooking copyWith({
    int? id,
    int? rentalUnitId,
    int? startDateMs,
    int? endDateMs,
    String? status,
    String? clientName,
    String? clientPhone,
    Value<double?> amount = const Value.absent(),
    String? deposit,
    int? guests,
    int? children,
    bool? hasPets,
    Value<String?> source = const Value.absent(),
    String? comment,
  }) => DbBooking(
    id: id ?? this.id,
    rentalUnitId: rentalUnitId ?? this.rentalUnitId,
    startDateMs: startDateMs ?? this.startDateMs,
    endDateMs: endDateMs ?? this.endDateMs,
    status: status ?? this.status,
    clientName: clientName ?? this.clientName,
    clientPhone: clientPhone ?? this.clientPhone,
    amount: amount.present ? amount.value : this.amount,
    deposit: deposit ?? this.deposit,
    guests: guests ?? this.guests,
    children: children ?? this.children,
    hasPets: hasPets ?? this.hasPets,
    source: source.present ? source.value : this.source,
    comment: comment ?? this.comment,
  );
  DbBooking copyWithCompanion(BookingsCompanion data) {
    return DbBooking(
      id: data.id.present ? data.id.value : this.id,
      rentalUnitId: data.rentalUnitId.present
          ? data.rentalUnitId.value
          : this.rentalUnitId,
      startDateMs: data.startDateMs.present
          ? data.startDateMs.value
          : this.startDateMs,
      endDateMs: data.endDateMs.present ? data.endDateMs.value : this.endDateMs,
      status: data.status.present ? data.status.value : this.status,
      clientName: data.clientName.present
          ? data.clientName.value
          : this.clientName,
      clientPhone: data.clientPhone.present
          ? data.clientPhone.value
          : this.clientPhone,
      amount: data.amount.present ? data.amount.value : this.amount,
      deposit: data.deposit.present ? data.deposit.value : this.deposit,
      guests: data.guests.present ? data.guests.value : this.guests,
      children: data.children.present ? data.children.value : this.children,
      hasPets: data.hasPets.present ? data.hasPets.value : this.hasPets,
      source: data.source.present ? data.source.value : this.source,
      comment: data.comment.present ? data.comment.value : this.comment,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DbBooking(')
          ..write('id: $id, ')
          ..write('rentalUnitId: $rentalUnitId, ')
          ..write('startDateMs: $startDateMs, ')
          ..write('endDateMs: $endDateMs, ')
          ..write('status: $status, ')
          ..write('clientName: $clientName, ')
          ..write('clientPhone: $clientPhone, ')
          ..write('amount: $amount, ')
          ..write('deposit: $deposit, ')
          ..write('guests: $guests, ')
          ..write('children: $children, ')
          ..write('hasPets: $hasPets, ')
          ..write('source: $source, ')
          ..write('comment: $comment')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    rentalUnitId,
    startDateMs,
    endDateMs,
    status,
    clientName,
    clientPhone,
    amount,
    deposit,
    guests,
    children,
    hasPets,
    source,
    comment,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DbBooking &&
          other.id == this.id &&
          other.rentalUnitId == this.rentalUnitId &&
          other.startDateMs == this.startDateMs &&
          other.endDateMs == this.endDateMs &&
          other.status == this.status &&
          other.clientName == this.clientName &&
          other.clientPhone == this.clientPhone &&
          other.amount == this.amount &&
          other.deposit == this.deposit &&
          other.guests == this.guests &&
          other.children == this.children &&
          other.hasPets == this.hasPets &&
          other.source == this.source &&
          other.comment == this.comment);
}

class BookingsCompanion extends UpdateCompanion<DbBooking> {
  final Value<int> id;
  final Value<int> rentalUnitId;
  final Value<int> startDateMs;
  final Value<int> endDateMs;
  final Value<String> status;
  final Value<String> clientName;
  final Value<String> clientPhone;
  final Value<double?> amount;
  final Value<String> deposit;
  final Value<int> guests;
  final Value<int> children;
  final Value<bool> hasPets;
  final Value<String?> source;
  final Value<String> comment;
  const BookingsCompanion({
    this.id = const Value.absent(),
    this.rentalUnitId = const Value.absent(),
    this.startDateMs = const Value.absent(),
    this.endDateMs = const Value.absent(),
    this.status = const Value.absent(),
    this.clientName = const Value.absent(),
    this.clientPhone = const Value.absent(),
    this.amount = const Value.absent(),
    this.deposit = const Value.absent(),
    this.guests = const Value.absent(),
    this.children = const Value.absent(),
    this.hasPets = const Value.absent(),
    this.source = const Value.absent(),
    this.comment = const Value.absent(),
  });
  BookingsCompanion.insert({
    this.id = const Value.absent(),
    required int rentalUnitId,
    required int startDateMs,
    required int endDateMs,
    this.status = const Value.absent(),
    this.clientName = const Value.absent(),
    this.clientPhone = const Value.absent(),
    this.amount = const Value.absent(),
    this.deposit = const Value.absent(),
    this.guests = const Value.absent(),
    this.children = const Value.absent(),
    this.hasPets = const Value.absent(),
    this.source = const Value.absent(),
    this.comment = const Value.absent(),
  }) : rentalUnitId = Value(rentalUnitId),
       startDateMs = Value(startDateMs),
       endDateMs = Value(endDateMs);
  static Insertable<DbBooking> custom({
    Expression<int>? id,
    Expression<int>? rentalUnitId,
    Expression<int>? startDateMs,
    Expression<int>? endDateMs,
    Expression<String>? status,
    Expression<String>? clientName,
    Expression<String>? clientPhone,
    Expression<double>? amount,
    Expression<String>? deposit,
    Expression<int>? guests,
    Expression<int>? children,
    Expression<bool>? hasPets,
    Expression<String>? source,
    Expression<String>? comment,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (rentalUnitId != null) 'rental_unit_id': rentalUnitId,
      if (startDateMs != null) 'start_date_ms': startDateMs,
      if (endDateMs != null) 'end_date_ms': endDateMs,
      if (status != null) 'status': status,
      if (clientName != null) 'client_name': clientName,
      if (clientPhone != null) 'client_phone': clientPhone,
      if (amount != null) 'amount': amount,
      if (deposit != null) 'deposit': deposit,
      if (guests != null) 'guests': guests,
      if (children != null) 'children': children,
      if (hasPets != null) 'has_pets': hasPets,
      if (source != null) 'source': source,
      if (comment != null) 'comment': comment,
    });
  }

  BookingsCompanion copyWith({
    Value<int>? id,
    Value<int>? rentalUnitId,
    Value<int>? startDateMs,
    Value<int>? endDateMs,
    Value<String>? status,
    Value<String>? clientName,
    Value<String>? clientPhone,
    Value<double?>? amount,
    Value<String>? deposit,
    Value<int>? guests,
    Value<int>? children,
    Value<bool>? hasPets,
    Value<String?>? source,
    Value<String>? comment,
  }) {
    return BookingsCompanion(
      id: id ?? this.id,
      rentalUnitId: rentalUnitId ?? this.rentalUnitId,
      startDateMs: startDateMs ?? this.startDateMs,
      endDateMs: endDateMs ?? this.endDateMs,
      status: status ?? this.status,
      clientName: clientName ?? this.clientName,
      clientPhone: clientPhone ?? this.clientPhone,
      amount: amount ?? this.amount,
      deposit: deposit ?? this.deposit,
      guests: guests ?? this.guests,
      children: children ?? this.children,
      hasPets: hasPets ?? this.hasPets,
      source: source ?? this.source,
      comment: comment ?? this.comment,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (rentalUnitId.present) {
      map['rental_unit_id'] = Variable<int>(rentalUnitId.value);
    }
    if (startDateMs.present) {
      map['start_date_ms'] = Variable<int>(startDateMs.value);
    }
    if (endDateMs.present) {
      map['end_date_ms'] = Variable<int>(endDateMs.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (clientName.present) {
      map['client_name'] = Variable<String>(clientName.value);
    }
    if (clientPhone.present) {
      map['client_phone'] = Variable<String>(clientPhone.value);
    }
    if (amount.present) {
      map['amount'] = Variable<double>(amount.value);
    }
    if (deposit.present) {
      map['deposit'] = Variable<String>(deposit.value);
    }
    if (guests.present) {
      map['guests'] = Variable<int>(guests.value);
    }
    if (children.present) {
      map['children'] = Variable<int>(children.value);
    }
    if (hasPets.present) {
      map['has_pets'] = Variable<bool>(hasPets.value);
    }
    if (source.present) {
      map['source'] = Variable<String>(source.value);
    }
    if (comment.present) {
      map['comment'] = Variable<String>(comment.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BookingsCompanion(')
          ..write('id: $id, ')
          ..write('rentalUnitId: $rentalUnitId, ')
          ..write('startDateMs: $startDateMs, ')
          ..write('endDateMs: $endDateMs, ')
          ..write('status: $status, ')
          ..write('clientName: $clientName, ')
          ..write('clientPhone: $clientPhone, ')
          ..write('amount: $amount, ')
          ..write('deposit: $deposit, ')
          ..write('guests: $guests, ')
          ..write('children: $children, ')
          ..write('hasPets: $hasPets, ')
          ..write('source: $source, ')
          ..write('comment: $comment')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $RentalUnitsTable rentalUnits = $RentalUnitsTable(this);
  late final $BookingsTable bookings = $BookingsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [rentalUnits, bookings];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'rental_units',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('bookings', kind: UpdateKind.delete)],
    ),
  ]);
}

typedef $$RentalUnitsTableCreateCompanionBuilder =
    RentalUnitsCompanion Function({
      Value<int> id,
      required String name,
      Value<int> sortOrder,
    });
typedef $$RentalUnitsTableUpdateCompanionBuilder =
    RentalUnitsCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<int> sortOrder,
    });

final class $$RentalUnitsTableReferences
    extends BaseReferences<_$AppDatabase, $RentalUnitsTable, DbRentalUnit> {
  $$RentalUnitsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$BookingsTable, List<DbBooking>>
  _bookingsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.bookings,
    aliasName: $_aliasNameGenerator(
      db.rentalUnits.id,
      db.bookings.rentalUnitId,
    ),
  );

  $$BookingsTableProcessedTableManager get bookingsRefs {
    final manager = $$BookingsTableTableManager(
      $_db,
      $_db.bookings,
    ).filter((f) => f.rentalUnitId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_bookingsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$RentalUnitsTableFilterComposer
    extends Composer<_$AppDatabase, $RentalUnitsTable> {
  $$RentalUnitsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> bookingsRefs(
    Expression<bool> Function($$BookingsTableFilterComposer f) f,
  ) {
    final $$BookingsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.bookings,
      getReferencedColumn: (t) => t.rentalUnitId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BookingsTableFilterComposer(
            $db: $db,
            $table: $db.bookings,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$RentalUnitsTableOrderingComposer
    extends Composer<_$AppDatabase, $RentalUnitsTable> {
  $$RentalUnitsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$RentalUnitsTableAnnotationComposer
    extends Composer<_$AppDatabase, $RentalUnitsTable> {
  $$RentalUnitsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  Expression<T> bookingsRefs<T extends Object>(
    Expression<T> Function($$BookingsTableAnnotationComposer a) f,
  ) {
    final $$BookingsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.bookings,
      getReferencedColumn: (t) => t.rentalUnitId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BookingsTableAnnotationComposer(
            $db: $db,
            $table: $db.bookings,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$RentalUnitsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RentalUnitsTable,
          DbRentalUnit,
          $$RentalUnitsTableFilterComposer,
          $$RentalUnitsTableOrderingComposer,
          $$RentalUnitsTableAnnotationComposer,
          $$RentalUnitsTableCreateCompanionBuilder,
          $$RentalUnitsTableUpdateCompanionBuilder,
          (DbRentalUnit, $$RentalUnitsTableReferences),
          DbRentalUnit,
          PrefetchHooks Function({bool bookingsRefs})
        > {
  $$RentalUnitsTableTableManager(_$AppDatabase db, $RentalUnitsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RentalUnitsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RentalUnitsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RentalUnitsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
              }) => RentalUnitsCompanion(
                id: id,
                name: name,
                sortOrder: sortOrder,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                Value<int> sortOrder = const Value.absent(),
              }) => RentalUnitsCompanion.insert(
                id: id,
                name: name,
                sortOrder: sortOrder,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$RentalUnitsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({bookingsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (bookingsRefs) db.bookings],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (bookingsRefs)
                    await $_getPrefetchedData<
                      DbRentalUnit,
                      $RentalUnitsTable,
                      DbBooking
                    >(
                      currentTable: table,
                      referencedTable: $$RentalUnitsTableReferences
                          ._bookingsRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$RentalUnitsTableReferences(
                            db,
                            table,
                            p0,
                          ).bookingsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where(
                            (e) => e.rentalUnitId == item.id,
                          ),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$RentalUnitsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RentalUnitsTable,
      DbRentalUnit,
      $$RentalUnitsTableFilterComposer,
      $$RentalUnitsTableOrderingComposer,
      $$RentalUnitsTableAnnotationComposer,
      $$RentalUnitsTableCreateCompanionBuilder,
      $$RentalUnitsTableUpdateCompanionBuilder,
      (DbRentalUnit, $$RentalUnitsTableReferences),
      DbRentalUnit,
      PrefetchHooks Function({bool bookingsRefs})
    >;
typedef $$BookingsTableCreateCompanionBuilder =
    BookingsCompanion Function({
      Value<int> id,
      required int rentalUnitId,
      required int startDateMs,
      required int endDateMs,
      Value<String> status,
      Value<String> clientName,
      Value<String> clientPhone,
      Value<double?> amount,
      Value<String> deposit,
      Value<int> guests,
      Value<int> children,
      Value<bool> hasPets,
      Value<String?> source,
      Value<String> comment,
    });
typedef $$BookingsTableUpdateCompanionBuilder =
    BookingsCompanion Function({
      Value<int> id,
      Value<int> rentalUnitId,
      Value<int> startDateMs,
      Value<int> endDateMs,
      Value<String> status,
      Value<String> clientName,
      Value<String> clientPhone,
      Value<double?> amount,
      Value<String> deposit,
      Value<int> guests,
      Value<int> children,
      Value<bool> hasPets,
      Value<String?> source,
      Value<String> comment,
    });

final class $$BookingsTableReferences
    extends BaseReferences<_$AppDatabase, $BookingsTable, DbBooking> {
  $$BookingsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $RentalUnitsTable _rentalUnitIdTable(_$AppDatabase db) =>
      db.rentalUnits.createAlias(
        $_aliasNameGenerator(db.bookings.rentalUnitId, db.rentalUnits.id),
      );

  $$RentalUnitsTableProcessedTableManager get rentalUnitId {
    final $_column = $_itemColumn<int>('rental_unit_id')!;

    final manager = $$RentalUnitsTableTableManager(
      $_db,
      $_db.rentalUnits,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_rentalUnitIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$BookingsTableFilterComposer
    extends Composer<_$AppDatabase, $BookingsTable> {
  $$BookingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get startDateMs => $composableBuilder(
    column: $table.startDateMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get endDateMs => $composableBuilder(
    column: $table.endDateMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get clientName => $composableBuilder(
    column: $table.clientName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get clientPhone => $composableBuilder(
    column: $table.clientPhone,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deposit => $composableBuilder(
    column: $table.deposit,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get guests => $composableBuilder(
    column: $table.guests,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get children => $composableBuilder(
    column: $table.children,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get hasPets => $composableBuilder(
    column: $table.hasPets,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get comment => $composableBuilder(
    column: $table.comment,
    builder: (column) => ColumnFilters(column),
  );

  $$RentalUnitsTableFilterComposer get rentalUnitId {
    final $$RentalUnitsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.rentalUnitId,
      referencedTable: $db.rentalUnits,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RentalUnitsTableFilterComposer(
            $db: $db,
            $table: $db.rentalUnits,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$BookingsTableOrderingComposer
    extends Composer<_$AppDatabase, $BookingsTable> {
  $$BookingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get startDateMs => $composableBuilder(
    column: $table.startDateMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get endDateMs => $composableBuilder(
    column: $table.endDateMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get clientName => $composableBuilder(
    column: $table.clientName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get clientPhone => $composableBuilder(
    column: $table.clientPhone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deposit => $composableBuilder(
    column: $table.deposit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get guests => $composableBuilder(
    column: $table.guests,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get children => $composableBuilder(
    column: $table.children,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get hasPets => $composableBuilder(
    column: $table.hasPets,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get comment => $composableBuilder(
    column: $table.comment,
    builder: (column) => ColumnOrderings(column),
  );

  $$RentalUnitsTableOrderingComposer get rentalUnitId {
    final $$RentalUnitsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.rentalUnitId,
      referencedTable: $db.rentalUnits,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RentalUnitsTableOrderingComposer(
            $db: $db,
            $table: $db.rentalUnits,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$BookingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $BookingsTable> {
  $$BookingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get startDateMs => $composableBuilder(
    column: $table.startDateMs,
    builder: (column) => column,
  );

  GeneratedColumn<int> get endDateMs =>
      $composableBuilder(column: $table.endDateMs, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get clientName => $composableBuilder(
    column: $table.clientName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get clientPhone => $composableBuilder(
    column: $table.clientPhone,
    builder: (column) => column,
  );

  GeneratedColumn<double> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumn<String> get deposit =>
      $composableBuilder(column: $table.deposit, builder: (column) => column);

  GeneratedColumn<int> get guests =>
      $composableBuilder(column: $table.guests, builder: (column) => column);

  GeneratedColumn<int> get children =>
      $composableBuilder(column: $table.children, builder: (column) => column);

  GeneratedColumn<bool> get hasPets =>
      $composableBuilder(column: $table.hasPets, builder: (column) => column);

  GeneratedColumn<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  GeneratedColumn<String> get comment =>
      $composableBuilder(column: $table.comment, builder: (column) => column);

  $$RentalUnitsTableAnnotationComposer get rentalUnitId {
    final $$RentalUnitsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.rentalUnitId,
      referencedTable: $db.rentalUnits,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RentalUnitsTableAnnotationComposer(
            $db: $db,
            $table: $db.rentalUnits,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$BookingsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $BookingsTable,
          DbBooking,
          $$BookingsTableFilterComposer,
          $$BookingsTableOrderingComposer,
          $$BookingsTableAnnotationComposer,
          $$BookingsTableCreateCompanionBuilder,
          $$BookingsTableUpdateCompanionBuilder,
          (DbBooking, $$BookingsTableReferences),
          DbBooking,
          PrefetchHooks Function({bool rentalUnitId})
        > {
  $$BookingsTableTableManager(_$AppDatabase db, $BookingsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BookingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BookingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BookingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> rentalUnitId = const Value.absent(),
                Value<int> startDateMs = const Value.absent(),
                Value<int> endDateMs = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String> clientName = const Value.absent(),
                Value<String> clientPhone = const Value.absent(),
                Value<double?> amount = const Value.absent(),
                Value<String> deposit = const Value.absent(),
                Value<int> guests = const Value.absent(),
                Value<int> children = const Value.absent(),
                Value<bool> hasPets = const Value.absent(),
                Value<String?> source = const Value.absent(),
                Value<String> comment = const Value.absent(),
              }) => BookingsCompanion(
                id: id,
                rentalUnitId: rentalUnitId,
                startDateMs: startDateMs,
                endDateMs: endDateMs,
                status: status,
                clientName: clientName,
                clientPhone: clientPhone,
                amount: amount,
                deposit: deposit,
                guests: guests,
                children: children,
                hasPets: hasPets,
                source: source,
                comment: comment,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int rentalUnitId,
                required int startDateMs,
                required int endDateMs,
                Value<String> status = const Value.absent(),
                Value<String> clientName = const Value.absent(),
                Value<String> clientPhone = const Value.absent(),
                Value<double?> amount = const Value.absent(),
                Value<String> deposit = const Value.absent(),
                Value<int> guests = const Value.absent(),
                Value<int> children = const Value.absent(),
                Value<bool> hasPets = const Value.absent(),
                Value<String?> source = const Value.absent(),
                Value<String> comment = const Value.absent(),
              }) => BookingsCompanion.insert(
                id: id,
                rentalUnitId: rentalUnitId,
                startDateMs: startDateMs,
                endDateMs: endDateMs,
                status: status,
                clientName: clientName,
                clientPhone: clientPhone,
                amount: amount,
                deposit: deposit,
                guests: guests,
                children: children,
                hasPets: hasPets,
                source: source,
                comment: comment,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$BookingsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({rentalUnitId = false}) {
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
                    if (rentalUnitId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.rentalUnitId,
                                referencedTable: $$BookingsTableReferences
                                    ._rentalUnitIdTable(db),
                                referencedColumn: $$BookingsTableReferences
                                    ._rentalUnitIdTable(db)
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

typedef $$BookingsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $BookingsTable,
      DbBooking,
      $$BookingsTableFilterComposer,
      $$BookingsTableOrderingComposer,
      $$BookingsTableAnnotationComposer,
      $$BookingsTableCreateCompanionBuilder,
      $$BookingsTableUpdateCompanionBuilder,
      (DbBooking, $$BookingsTableReferences),
      DbBooking,
      PrefetchHooks Function({bool rentalUnitId})
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$RentalUnitsTableTableManager get rentalUnits =>
      $$RentalUnitsTableTableManager(_db, _db.rentalUnits);
  $$BookingsTableTableManager get bookings =>
      $$BookingsTableTableManager(_db, _db.bookings);
}
