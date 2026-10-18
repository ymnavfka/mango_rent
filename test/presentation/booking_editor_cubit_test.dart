import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mango_rent/domain/entities/booking.dart';
import 'package:mango_rent/domain/usecases/booking_use_cases.dart';
import 'package:mango_rent/presentation/calendar/cubit/booking_editor_cubit.dart';

import '../support/in_memory_booking_repository.dart';

void main() {
  late InMemoryBookingRepository repository;
  late BookingEditorCubit cubit;
  late Booking original;

  setUp(() {
    original = Booking(
      id: 12,
      rentalUnitId: 1,
      startDate: DateTime.utc(2026, 10, 10),
      endDate: DateTime.utc(2026, 10, 12),
      clientName: 'Иван',
    );
    repository = InMemoryBookingRepository(bookings: [original]);
    cubit = BookingEditorCubit(
      booking: original,
      useCases: BookingUseCases(repository),
    );
  });

  tearDown(() async {
    await cubit.close();
    await repository.dispose();
  });

  test('updates editor state immediately and queues automatic saves', () async {
    final nameChange = original.copyWith(clientName: 'Анна');
    final phoneChange = nameChange.copyWith(clientPhone: '+79990000000');

    cubit.change(nameChange);
    cubit.change(phoneChange);
    expect(cubit.state.booking.clientName, 'Анна');
    expect(cubit.state.booking.clientPhone, '+79990000000');

    await _flushMicrotasks();
    expect(repository.savedBookings, [nameChange, phoneChange]);
    expect(repository.bookings.single.clientPhone, '+79990000000');
  });

  test('reports save failures and clears the notice', () async {
    repository.saveError = StateError('disk full');
    cubit.change(original.copyWith(comment: 'Обновлено'));
    await _flushMicrotasks();

    expect(cubit.state.notice, contains('Не удалось сохранить'));
    expect(cubit.state.notice, contains('disk full'));
    cubit.clearNotice();
    expect(cubit.state.notice, isNull);
  });

  test('waits for pending automatic saves before deleting a booking', () async {
    final saveGate = Completer<void>();
    repository.beforeSave = (_) => saveGate.future;
    cubit.change(original.copyWith(comment: 'Сначала сохранить'));
    await _flushMicrotasks();

    final deletion = cubit.deleteBooking();
    await _flushMicrotasks();
    expect(repository.deletedBookingIds, isEmpty);

    saveGate.complete();
    await deletion;
    expect(repository.savedBookings, hasLength(1));
    expect(repository.deletedBookingIds, [12]);
  });

  test('deletes only persisted bookings', () async {
    final newBooking = Booking(
      id: null,
      rentalUnitId: original.rentalUnitId,
      startDate: original.startDate,
      endDate: original.endDate,
      clientName: original.clientName,
    );
    final newCubit = BookingEditorCubit(
      booking: newBooking,
      useCases: BookingUseCases(repository),
    );
    await newCubit.deleteBooking();
    expect(repository.deletedBookingIds, isEmpty);
    await newCubit.close();
  });
}

Future<void> _flushMicrotasks() async {
  for (var i = 0; i < 5; i++) {
    await Future<void>.delayed(Duration.zero);
  }
}
