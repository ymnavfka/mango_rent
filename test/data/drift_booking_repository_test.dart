import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mango_rent/data/local/app_database.dart';
import 'package:mango_rent/data/repositories/drift_booking_repository.dart';
import 'package:mango_rent/domain/entities/booking.dart';
import 'package:mango_rent/domain/repositories/booking_repository.dart';

void main() {
  late AppDatabase database;
  late DriftBookingRepository repository;
  late int unitId;

  setUp(() async {
    database = AppDatabase.forTesting(NativeDatabase.memory());
    repository = DriftBookingRepository(database);
    await repository.addRentalUnit('  Квартира у моря  ');
    await repository.addRentalUnit('Дом');
    unitId = (await repository.watchRentalUnits().first).first.id;
  });

  tearDown(() => database.close());

  test(
    'trims object names, ignores blanks, and preserves their order',
    () async {
      await repository.addRentalUnit('   ');
      final units = await repository.watchRentalUnits().first;

      expect(units.map((unit) => unit.name), ['Квартира у моря', 'Дом']);
    },
  );

  test(
    'persists the full booking record and normalizes date-only values',
    () async {
      final booking = Booking(
        id: null,
        rentalUnitId: unitId,
        startDate: DateTime(2026, 10, 10, 19, 45),
        endDate: DateTime(2026, 10, 13, 8, 15),
        status: BookingStatus.depositPaid,
        clientName: 'Мария',
        clientPhone: '+79990001122',
        amount: 12500.5,
        deposit: '3000',
        guests: 3,
        children: 1,
        hasPets: true,
        source: 'Airbnb',
        comment: 'Поздний заезд',
      );

      final saved = await repository.saveBooking(booking);
      final loaded = (await repository.watchBookings().first).single;

      expect(saved.id, isNotNull);
      expect(loaded.id, saved.id);
      expect(loaded.rentalUnitId, unitId);
      expect(loaded.startDate, DateTime.utc(2026, 10, 10));
      expect(loaded.endDate, DateTime.utc(2026, 10, 13));
      expect(loaded.status, BookingStatus.depositPaid);
      expect(loaded.clientName, 'Мария');
      expect(loaded.clientPhone, '+79990001122');
      expect(loaded.amount, 12500.5);
      expect(loaded.deposit, '3000');
      expect(loaded.guests, 3);
      expect(loaded.children, 1);
      expect(loaded.hasPets, isTrue);
      expect(loaded.source, 'Airbnb');
      expect(loaded.comment, 'Поздний заезд');
    },
  );

  test(
    'rejects overlap on one unit but accepts adjacent dates and other units',
    () async {
      final firstStart = DateTime.utc(2026, 10, 10);
      final first = await repository.saveBooking(
        Booking(
          id: null,
          rentalUnitId: unitId,
          startDate: firstStart,
          endDate: firstStart.add(const Duration(days: 3)),
        ),
      );

      await expectLater(
        repository.saveBooking(
          Booking(
            id: null,
            rentalUnitId: unitId,
            startDate: firstStart.add(const Duration(days: 2)),
            endDate: firstStart.add(const Duration(days: 4)),
          ),
        ),
        throwsA(isA<BookingConflictException>()),
      );

      final adjacent = await repository.saveBooking(
        Booking(
          id: null,
          rentalUnitId: unitId,
          startDate: first.endDate,
          endDate: first.endDate.add(const Duration(days: 1)),
        ),
      );
      final otherUnitId = (await repository.watchRentalUnits().first).last.id;
      final otherUnit = await repository.saveBooking(
        Booking(
          id: null,
          rentalUnitId: otherUnitId,
          startDate: firstStart.add(const Duration(days: 1)),
          endDate: firstStart.add(const Duration(days: 2)),
        ),
      );

      expect(adjacent.id, isNotNull);
      expect(otherUnit.id, isNotNull);
      expect(await repository.getBookingsForUnit(unitId), hasLength(2));
      expect(await repository.getBookingsForUnit(otherUnitId), hasLength(1));
    },
  );

  test(
    'updates a booking without treating its current dates as a conflict',
    () async {
      final start = DateTime.utc(2026, 11, 1);
      final created = await repository.saveBooking(
        Booking(
          id: null,
          rentalUnitId: unitId,
          startDate: start,
          endDate: start.add(const Duration(days: 2)),
        ),
      );
      final updated = await repository.saveBooking(
        created.copyWith(clientName: 'Новое имя'),
      );

      expect(updated.clientName, 'Новое имя');
      expect((await repository.watchBookings().first), hasLength(1));
      expect(
        (await repository.watchBookings().first).single.clientName,
        'Новое имя',
      );
    },
  );

  test('deletes a booking and publishes changes to active watchers', () async {
    final booking = await repository.saveBooking(
      Booking(
        id: null,
        rentalUnitId: unitId,
        startDate: DateTime.utc(2026, 12, 1),
        endDate: DateTime.utc(2026, 12, 2),
      ),
    );
    final snapshots = <List<Booking>>[];
    final subscription = repository.watchBookings().listen(snapshots.add);
    await Future<void>.delayed(Duration.zero);
    await repository.deleteBooking(booking.id!);
    await Future<void>.delayed(Duration.zero);
    await subscription.cancel();

    expect(snapshots.first, hasLength(1));
    expect(snapshots.last, isEmpty);
  });
}
