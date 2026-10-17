import 'package:drift/drift.dart';

import '../../domain/entities/booking.dart';
import '../../domain/entities/rental_unit.dart';
import '../../domain/repositories/booking_repository.dart';
import '../local/app_database.dart';

class DriftBookingRepository implements BookingRepository {
  DriftBookingRepository(this._database);

  final AppDatabase _database;

  @override
  Stream<List<RentalUnit>> watchRentalUnits() {
    final query = _database.select(_database.rentalUnits)
      ..orderBy([
        (unit) => OrderingTerm.asc(unit.sortOrder),
        (unit) => OrderingTerm.asc(unit.id),
      ]);
    return query.watch().map(
      (rows) => rows
          .map((row) => RentalUnit(id: row.id, name: row.name))
          .toList(growable: false),
    );
  }

  @override
  Stream<List<Booking>> watchBookings() {
    return _database
        .select(_database.bookings)
        .watch()
        .map((rows) => rows.map(_toDomain).toList(growable: false));
  }

  @override
  Future<List<Booking>> getBookingsForUnit(int rentalUnitId) async {
    final rows = await (_database.select(
      _database.bookings,
    )..where((row) => row.rentalUnitId.equals(rentalUnitId))).get();
    return rows.map(_toDomain).toList(growable: false);
  }

  @override
  Future<void> addRentalUnit(String name) async {
    final trimmedName = name.trim();
    if (trimmedName.isEmpty) return;
    final current = await _database.select(_database.rentalUnits).get();
    await _database
        .into(_database.rentalUnits)
        .insert(
          RentalUnitsCompanion.insert(
            name: trimmedName,
            sortOrder: Value(current.length),
          ),
        );
  }

  @override
  Future<Booking> saveBooking(Booking booking) async {
    if (!booking.endDate.isAfter(booking.startDate)) {
      throw ArgumentError('Дата выезда должна быть позже даты заезда.');
    }

    final sameUnit = await (_database.select(
      _database.bookings,
    )..where((row) => row.rentalUnitId.equals(booking.rentalUnitId))).get();
    final start = _encodeDate(booking.startDate);
    final end = _encodeDate(booking.endDate);
    final hasConflict = sameUnit.any(
      (existing) =>
          existing.id != booking.id &&
          start < existing.endDateMs &&
          existing.startDateMs < end,
    );
    if (hasConflict) throw const BookingConflictException();

    final companion = BookingsCompanion(
      rentalUnitId: Value(booking.rentalUnitId),
      startDateMs: Value(start),
      endDateMs: Value(end),
      status: Value(booking.status.storageValue),
      clientName: Value(booking.clientName),
      clientPhone: Value(booking.clientPhone),
      amount: Value(booking.amount),
      deposit: Value(booking.deposit),
      guests: Value(booking.guests),
      children: Value(booking.children),
      hasPets: Value(booking.hasPets),
      source: Value(booking.source),
      comment: Value(booking.comment),
    );

    final id = booking.id;
    if (id == null) {
      final createdId = await _database
          .into(_database.bookings)
          .insert(companion);
      return booking.copyWith(id: createdId);
    } else {
      await (_database.update(
        _database.bookings,
      )..where((row) => row.id.equals(id))).write(companion);
      return booking;
    }
  }

  @override
  Future<void> deleteBooking(int id) async {
    await (_database.delete(
      _database.bookings,
    )..where((row) => row.id.equals(id))).go();
  }

  Booking _toDomain(DbBooking row) {
    return Booking(
      id: row.id,
      rentalUnitId: row.rentalUnitId,
      startDate: _decodeDate(row.startDateMs),
      endDate: _decodeDate(row.endDateMs),
      status: BookingStatus.fromStorage(row.status),
      clientName: row.clientName,
      clientPhone: row.clientPhone,
      amount: row.amount,
      deposit: row.deposit,
      guests: row.guests,
      children: row.children,
      hasPets: row.hasPets,
      source: row.source,
      comment: row.comment,
    );
  }

  int _encodeDate(DateTime date) =>
      DateTime.utc(date.year, date.month, date.day).millisecondsSinceEpoch;

  DateTime _decodeDate(int milliseconds) {
    final date = DateTime.fromMillisecondsSinceEpoch(milliseconds, isUtc: true);
    return DateTime.utc(date.year, date.month, date.day);
  }
}
