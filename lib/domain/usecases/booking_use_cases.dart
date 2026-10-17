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
    if (!booking.endDate.isAfter(booking.startDate)) {
      throw ArgumentError('Дата выезда должна быть позже даты заезда.');
    }

    final existingBookings = await _repository.getBookingsForUnit(
      booking.rentalUnitId,
    );
    final hasConflict = existingBookings.any(
      (existing) =>
          existing.id != booking.id &&
          booking.startDate.isBefore(existing.endDate) &&
          existing.startDate.isBefore(booking.endDate),
    );
    if (hasConflict) throw const BookingConflictException();

    return _repository.saveBooking(booking);
  }

  Future<void> deleteBooking(int id) => _repository.deleteBooking(id);
}
