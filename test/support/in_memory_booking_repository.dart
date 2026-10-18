import 'dart:async';

import 'package:mango_rent/domain/entities/booking.dart';
import 'package:mango_rent/domain/entities/rental_unit.dart';
import 'package:mango_rent/domain/repositories/booking_repository.dart';

class InMemoryBookingRepository implements BookingRepository {
  InMemoryBookingRepository({
    List<RentalUnit> units = const [],
    List<Booking> bookings = const [],
  }) : units = List.of(units),
       bookings = List.of(bookings),
       _nextBookingId = _nextIdAfter(bookings);

  final List<RentalUnit> units;
  final List<Booking> bookings;
  final List<String> addedUnitNames = [];
  final List<Booking> savedBookings = [];
  final List<int> deletedBookingIds = [];
  final _unitsController = StreamController<List<RentalUnit>>.broadcast();
  final _bookingsController = StreamController<List<Booking>>.broadcast();

  Object? saveError;
  Object? addUnitError;
  Object? deleteError;
  Future<void> Function(Booking booking)? beforeSave;
  int _nextBookingId;

  static int _nextIdAfter(List<Booking> bookings) =>
      bookings
          .map((booking) => booking.id ?? 0)
          .fold(0, (maxId, id) => id > maxId ? id : maxId) +
      1;

  @override
  Stream<List<RentalUnit>> watchRentalUnits() async* {
    yield List.unmodifiable(units);
    yield* _unitsController.stream;
  }

  @override
  Stream<List<Booking>> watchBookings() async* {
    yield List.unmodifiable(bookings);
    yield* _bookingsController.stream;
  }

  @override
  Future<List<Booking>> getBookingsForUnit(int rentalUnitId) async => bookings
      .where((booking) => booking.rentalUnitId == rentalUnitId)
      .toList();

  @override
  Future<void> addRentalUnit(String name) async {
    if (addUnitError case final error?) throw error;
    addedUnitNames.add(name);
    final trimmedName = name.trim();
    if (trimmedName.isEmpty) return;
    final id = units.isEmpty ? 1 : units.last.id + 1;
    units.add(RentalUnit(id: id, name: trimmedName));
    _unitsController.add(List.unmodifiable(units));
  }

  @override
  Future<Booking> saveBooking(Booking booking) async {
    await beforeSave?.call(booking);
    if (saveError case final error?) throw error;
    savedBookings.add(booking);
    final saved = booking.id == null
        ? booking.copyWith(id: _nextBookingId++)
        : booking;
    final existingIndex = bookings.indexWhere((item) => item.id == saved.id);
    if (existingIndex == -1) {
      bookings.add(saved);
    } else {
      bookings[existingIndex] = saved;
    }
    _bookingsController.add(List.unmodifiable(bookings));
    return saved;
  }

  @override
  Future<void> deleteBooking(int id) async {
    if (deleteError case final error?) throw error;
    deletedBookingIds.add(id);
    bookings.removeWhere((booking) => booking.id == id);
    _bookingsController.add(List.unmodifiable(bookings));
  }

  void emitUnitError(Object error) => _unitsController.addError(error);

  void emitBookingError(Object error) => _bookingsController.addError(error);

  Future<void> dispose() async {
    await _unitsController.close();
    await _bookingsController.close();
  }
}
