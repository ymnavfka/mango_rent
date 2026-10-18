import 'package:flutter_test/flutter_test.dart';
import 'package:mango_rent/domain/entities/booking.dart';
import 'package:mango_rent/domain/entities/rental_unit.dart';
import 'package:mango_rent/domain/usecases/booking_use_cases.dart';
import 'package:mango_rent/presentation/calendar/cubit/calendar_cubit.dart';

import '../support/in_memory_booking_repository.dart';

void main() {
  group('CalendarState', () {
    test('creates a six-month date window with every calendar day', () {
      final now = DateTime.now();
      final state = CalendarState.initial();

      expect(state.month, DateTime.utc(now.year, now.month));
      expect(state.rangeStartMonth, DateTime.utc(now.year, now.month - 3));
      expect(state.rangeEnd, DateTime.utc(now.year, now.month + 3));
      expect(state.dates.first, state.rangeStartMonth);
      expect(
        state.dates.last,
        state.rangeEnd.subtract(const Duration(days: 1)),
      );
      expect(
        state.dates.length,
        state.rangeEnd.difference(state.rangeStartMonth).inDays,
      );
    });
  });

  group('CalendarCubit', () {
    late InMemoryBookingRepository repository;
    late CalendarCubit cubit;

    setUp(() {
      repository = InMemoryBookingRepository(
        units: const [
          RentalUnit(id: 1, name: 'Апартаменты'),
          RentalUnit(id: 2, name: 'Дом'),
        ],
      );
      cubit = CalendarCubit(BookingUseCases(repository));
    });

    tearDown(() async {
      await cubit.close();
      await repository.dispose();
    });

    test('loads units and bookings from repository streams', () async {
      final today = DateTime.now();
      final booking = Booking(
        id: 10,
        rentalUnitId: 1,
        startDate: DateTime.utc(today.year, today.month, today.day),
        endDate: DateTime.utc(today.year, today.month, today.day + 2),
      );
      await repository.saveBooking(booking);
      await _flushStreams();

      expect(cubit.state.units, hasLength(2));
      expect(cubit.state.isLoading, isFalse);
      expect(cubit.state.bookings, contains(booking));
      expect(cubit.unitName(1), 'Апартаменты');
      expect(cubit.unitName(999), isEmpty);
    });

    test(
      'changes the visible month and resets the window outside its range',
      () async {
        final initial = cubit.state;
        final next = cubit.changeMonth(1);
        expect(next, DateTime.utc(initial.month.year, initial.month.month + 1));
        expect(cubit.state.rangeStartMonth, initial.rangeStartMonth);

        final outside = cubit.changeMonth(-5);
        expect(
          outside,
          DateTime.utc(initial.month.year, initial.month.month - 4),
        );
        expect(
          cubit.state.rangeStartMonth,
          DateTime.utc(
            outside.year,
            outside.month - CalendarState.monthsInWindow ~/ 2,
          ),
        );
      },
    );

    test('goes to today and changes visible month/range', () async {
      final today = DateTime.now();
      final result = cubit.goToToday();

      expect(result, DateTime.utc(today.year, today.month));
      expect(cubit.state.month, result);
      expect(
        cubit.state.rangeStartMonth,
        DateTime.utc(today.year, today.month - 3),
      );

      cubit.setVisibleMonth(DateTime.utc(2030, 1));
      cubit.setRangeStartMonth(DateTime.utc(2029, 10));
      expect(cubit.state.month, DateTime.utc(2030, 1));
      expect(cubit.state.rangeStartMonth, DateTime.utc(2029, 10));
    });

    test(
      'selects two dates in either order and saves the inclusive stay',
      () async {
        final first = DateTime.utc(2026, 10, 14);
        final last = DateTime.utc(2026, 10, 10);

        expect(await cubit.tapCell(1, first), isNull);
        expect(cubit.state.selection?.date, first);
        final saved = await cubit.tapCell(1, last);

        expect(saved, isNotNull);
        expect(saved!.startDate, last);
        expect(saved.endDate, DateTime.utc(2026, 10, 15));
        expect(saved.nights, 5);
        expect(saved.id, isNotNull);
        expect(cubit.state.selection, isNull);
        expect(repository.savedBookings, hasLength(1));
      },
    );

    test(
      'selecting another unit starts a new range and same-day range is one night',
      () async {
        final date = DateTime.utc(2026, 10, 10);
        await cubit.tapCell(1, date);

        expect(await cubit.tapCell(2, date), isNull);
        expect(cubit.state.selection?.rentalUnitId, 2);
        final saved = await cubit.tapCell(2, date);

        expect(saved?.nights, 1);
        expect(saved?.rentalUnitId, 2);
        expect(cubit.state.selection, isNull);
      },
    );

    test(
      'reports a conflict and clears the attempted date selection',
      () async {
        final date = DateTime.utc(2026, 10, 10);
        repository.bookings.add(
          Booking(
            id: 1,
            rentalUnitId: 1,
            startDate: date,
            endDate: date.add(const Duration(days: 3)),
          ),
        );

        await cubit.tapCell(1, date);
        final result = await cubit.tapCell(
          1,
          date.add(const Duration(days: 1)),
        );

        expect(result, isNull);
        expect(cubit.state.selection, isNull);
        expect(
          cubit.state.notice,
          'В выбранном диапазоне уже есть бронирование.',
        );
        expect(repository.savedBookings, isEmpty);
        cubit.clearNotice();
        expect(cubit.state.notice, isNull);
      },
    );

    test('adds units and exposes repository errors as notices', () async {
      await cubit.addRentalUnit('Коттедж');
      expect(repository.addedUnitNames, ['Коттедж']);

      repository.emitUnitError(StateError('offline'));
      await _flushStreams();
      expect(cubit.state.notice, contains('Не удалось загрузить объекты'));

      repository.emitBookingError(StateError('offline'));
      await _flushStreams();
      expect(cubit.state.notice, contains('Не удалось загрузить бронирования'));
    });
  });
}

Future<void> _flushStreams() async {
  await Future<void>.delayed(Duration.zero);
  await Future<void>.delayed(Duration.zero);
}
