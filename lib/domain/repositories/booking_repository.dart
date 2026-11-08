import '../entities/booking.dart';
import '../entities/rental_unit.dart';

abstract interface class BookingRepository {
  Stream<List<RentalUnit>> watchRentalUnits();
  Stream<List<Booking>> watchBookings();
  Future<List<Booking>> getBookingsForUnit(int rentalUnitId);

  Future<void> addRentalUnit(String name);
  Future<Booking> saveBooking(Booking booking);
  Future<void> deleteBooking(int id);
}
