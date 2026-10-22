import '../entities/booking.dart';
import '../entities/rental_unit.dart';
import '../repositories/booking_repository.dart';

/// Application actions used by the presentation layer.
///
/// This layer owns booking rules; the repository remains responsible for
/// reading and writing the SQLite representation.
class BookingUseCases {
  const BookingUseCases(this._repository);

  final BookingRepository _repository;

  Stream<List<RentalUnit>> watchRentalUnits() => _repository.watchRentalUnits();

  Stream<List<Booking>> watchBookings() => _repository.watchBookings();

  Future<void> addRentalUnit(String name) => _repository.addRentalUnit(name);

  Future<Booking> saveBooking(Booking booking) async {
    final startDate = _dateOnlyUtc(booking.startDate);
    final endDate = _dateOnlyUtc(booking.endDate);
    if (!endDate.isAfter(startDate)) {
      throw ArgumentError('Дата выезда должна быть позже даты заезда.');
    }

    final existingBookings = await _repository.getBookingsForUnit(
      booking.rentalUnitId,
    );
    final hasConflict = existingBookings.any(
      (existing) {
        final existingStartDate = _dateOnlyUtc(existing.startDate);
        final existingEndDate = _dateOnlyUtc(existing.endDate);
        return existing.id != booking.id &&
            startDate.isBefore(existingEndDate) &&
            existingStartDate.isBefore(endDate);
      },
    );
    if (hasConflict) throw const BookingConflictException();

    return _repository.saveBooking(booking);
  }

  Future<void> deleteBooking(int id) => _repository.deleteBooking(id);
}

DateTime _dateOnlyUtc(DateTime date) =>
    DateTime.utc(date.year, date.month, date.day);
