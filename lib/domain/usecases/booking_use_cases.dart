import '../entities/booking.dart';
import '../entities/rental_unit.dart';
import '../errors/booking_exceptions.dart';
import '../repositories/booking_repository.dart';
import '../rules/calendar_day.dart';

/// Application actions used by the presentation layer.
///
/// Coordinates booking rules and persistence through the repository contract.
class BookingUseCases {
  const BookingUseCases(this._repository);

  final BookingRepository _repository;

  Stream<List<RentalUnit>> watchRentalUnits() => _repository.watchRentalUnits();

  Stream<List<Booking>> watchBookings() => _repository.watchBookings();

  Future<void> addRentalUnit(String name) {
    final normalizedName = name.trim();
    if (normalizedName.isEmpty) return Future<void>.value();
    return _repository.addRentalUnit(normalizedName);
  }

  Future<Booking> saveBooking(Booking booking) async {
    final startDate = calendarDay(booking.startDate);
    final endDate = calendarDay(booking.endDate);
    if (!endDate.isAfter(startDate)) {
      throw const InvalidBookingDatesException();
    }

    final existingBookings = await _repository.getBookingsForUnit(
      booking.rentalUnitId,
    );
    final hasConflict = existingBookings.any(
      (existing) {
        final existingStartDate = calendarDay(existing.startDate);
        final existingEndDate = calendarDay(existing.endDate);
        return existing.id != booking.id &&
            startDate.isBefore(existingEndDate) &&
            existingStartDate.isBefore(endDate);
      },
    );
    if (hasConflict) throw const BookingConflictException();

    return _repository.saveBooking(
      booking.copyWith(startDate: startDate, endDate: endDate),
    );
  }

  Future<void> deleteBooking(int id) => _repository.deleteBooking(id);
}
