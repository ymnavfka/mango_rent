import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'app_database.g.dart';

@DataClassName('DbRentalUnit')
class RentalUnits extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
}

@DataClassName('DbBooking')
class Bookings extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get rentalUnitId =>
      integer().references(RentalUnits, #id, onDelete: KeyAction.cascade)();
  IntColumn get startDateMs => integer()();
  IntColumn get endDateMs => integer()();
  TextColumn get status => text().withDefault(const Constant('unpaid'))();
  TextColumn get clientName => text().withDefault(const Constant(''))();
  TextColumn get clientPhone => text().withDefault(const Constant(''))();
  RealColumn get amount => real().nullable()();
  TextColumn get deposit => text().withDefault(const Constant(''))();
  IntColumn get guests => integer().withDefault(const Constant(1))();
  IntColumn get children => integer().withDefault(const Constant(0))();
  BoolColumn get hasPets => boolean().withDefault(const Constant(false))();
  TextColumn get source => text().nullable()();
  TextColumn get comment => text().withDefault(const Constant(''))();
}

@DriftDatabase(tables: [RentalUnits, Bookings])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(driftDatabase(name: 'mango_rent'));

  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 1;
}
