import 'package:flutter_test/flutter_test.dart';
import 'package:mango_rent/domain/entities/booking.dart';
import 'package:mango_rent/domain/entities/rental_unit.dart';
import 'package:mango_rent/domain/repositories/booking_repository.dart';
import 'package:mango_rent/domain/usecases/booking_use_cases.dart';

import '../support/in_memory_booking_repository.dart';

void main() {
  group('BookingUseCases.saveBooking', () {
    final checkIn = DateTime.utc(2026, 10, 10);
    final existing = Booking(
      id: 1,
      rentalUnitId: 1,
      startDate: checkIn,
      endDate: checkIn.add(const Duration(days: 3)),
    );

    test(
      'rejects zero-night and reversed bookings before repository writes',
      () async {
        final repository = InMemoryBookingRepository();
        final useCases = BookingUseCases(repository);

        await expectLater(
          useCases.saveBooking(
            Booking(
              id: null,
              rentalUnitId: 1,
              startDate: checkIn,
              endDate: checkIn,
            ),
          ),
          throwsArgumentError,
        );
        await expectLater(
          useCases.saveBooking(
            Booking(
              id: null,
              rentalUnitId: 1,
              startDate: checkIn.add(const Duration(days: 1)),
              endDate: checkIn,
            ),
          ),
          throwsArgumentError,
        );
        expect(repository.savedBookings, isEmpty);
        await repository.dispose();
      },
    );

    test('rejects every overlapping interval for the same unit', () async {
      final repository = InMemoryBookingRepository(bookings: [existing]);
      final useCases = BookingUseCases(repository);
      final intervals = [
        (
          checkIn.subtract(const Duration(days: 1)),
          checkIn.add(const Duration(days: 1)),
        ),
        (
          checkIn.add(const Duration(days: 1)),
          checkIn.add(const Duration(days: 2)),
        ),
        (
          checkIn.add(const Duration(days: 2)),
          checkIn.add(const Duration(days: 4)),
        ),
        (checkIn, checkIn.add(const Duration(days: 3))),
      ];

      for (final (start, end) in intervals) {
        await expectLater(
          useCases.saveBooking(
            Booking(id: null, rentalUnitId: 1, startDate: start, endDate: end),
          ),
          throwsA(isA<BookingConflictException>()),
        );
      }
      expect(repository.savedBookings, isEmpty);
      await repository.dispose();
    });

    test(
      'allows adjacent stays, different units, and updating the same booking',
      () async {
        final repository = InMemoryBookingRepository(
          units: const [
            RentalUnit(id: 1, name: 'Дом'),
            RentalUnit(id: 2, name: 'Студия'),
          ],
          bookings: [existing],
        );
        final useCases = BookingUseCases(repository);

        final checkoutNeighbor = await useCases.saveBooking(
          Booking(
            id: null,
            rentalUnitId: 1,
            startDate: existing.endDate,
            endDate: existing.endDate.add(const Duration(days: 1)),
          ),
        );
        final otherUnit = await useCases.saveBooking(
          Booking(
            id: null,
            rentalUnitId: 2,
            startDate: checkIn.add(const Duration(days: 1)),
            endDate: checkIn.add(const Duration(days: 2)),
          ),
        );
        final updated = await useCases.saveBooking(
          existing.copyWith(clientName: 'Аня'),
        );

        expect(checkoutNeighbor.id, isNotNull);
        expect(otherUnit.id, isNotNull);
        expect(updated.clientName, 'Аня');
        expect(repository.savedBookings, hasLength(3));
        await repository.dispose();
      },
    );

    test('allows checkout on the next booking check-in date', () async {
      final repository = InMemoryBookingRepository(bookings: [existing]);
      final useCases = BookingUseCases(repository);

      final previousStay = await useCases.saveBooking(
        Booking(
          id: null,
          rentalUnitId: 1,
          startDate: DateTime.utc(2026, 10, 8),
          // Booking dates are calendar days; the time component is ignored.
          endDate: DateTime.utc(2026, 10, 10, 12),
        ),
      );

      expect(previousStay.id, isNotNull);
      await repository.dispose();
    });
  });

  test('forwards add and delete operations to the repository', () async {
    final repository = InMemoryBookingRepository();
    final useCases = BookingUseCases(repository);
    await useCases.addRentalUnit('Дом у озера');
    await useCases.deleteBooking(34);

    expect(repository.addedUnitNames, ['Дом у озера']);
    expect(repository.deletedBookingIds, [34]);
    await repository.dispose();
  });
}
