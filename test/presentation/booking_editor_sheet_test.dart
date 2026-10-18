import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:mango_rent/domain/entities/booking.dart';
import 'package:mango_rent/domain/entities/rental_unit.dart';
import 'package:mango_rent/domain/usecases/booking_use_cases.dart';
import 'package:mango_rent/presentation/calendar/widgets/booking_editor_sheet.dart';

import '../support/in_memory_booking_repository.dart';

void main() {
  group('BookingEditorSheet', () {
    late InMemoryBookingRepository repository;
    late Booking booking;
    late BookingUseCases useCases;

    setUp(() {
      booking = Booking(
        id: 24,
        rentalUnitId: 1,
        startDate: DateTime.utc(2026, 10, 10),
        endDate: DateTime.utc(2026, 10, 12),
        status: BookingStatus.unpaid,
        clientName: 'Иван Петров',
        clientPhone: '+79990000000',
        amount: 1200,
        deposit: '300',
        guests: 2,
        children: 0,
        hasPets: false,
        comment: 'Окно во двор',
      );
      repository = InMemoryBookingRepository(
        units: const [RentalUnit(id: 1, name: 'Апартаменты')],
        bookings: [booking],
      );
      useCases = BookingUseCases(repository);
    });

    tearDown(() => repository.dispose());

    testWidgets('shows saved booking information and all editable fields', (
      tester,
    ) async {
      await _openEditor(tester, booking, useCases);

      expect(find.text('Бронирование'), findsOneWidget);
      expect(find.text('Апартаменты'), findsOneWidget);
      expect(find.text('10 окт. 2026'), findsOneWidget);
      expect(find.text('12 окт. 2026'), findsOneWidget);
      expect(find.text('2 ночи'), findsOneWidget);
      for (final label in [
        'Статус оплаты',
        'Имя клиента',
        'Номер клиента',
        'Сумма',
        'Залог / предоплата',
        'Количество человек',
        'Количество детей',
        'Гости с животными',
        'Откуда бронь',
        'Комментарий',
      ]) {
        expect(find.text(label), findsOneWidget, reason: 'missing $label');
      }
      expect(find.text('Изменения сохраняются автоматически'), findsOneWidget);
    });

    testWidgets('edits every booking detail and saves changes automatically', (
      tester,
    ) async {
      await _openEditor(tester, booking, useCases);

      await _enterField(tester, 'Имя клиента', 'Мария Иванова');
      await _enterField(tester, 'Номер клиента', '+79991112233');
      await _enterField(tester, 'Сумма', '1500,5');
      await _enterField(tester, 'Залог / предоплата', '500');
      await _enterField(tester, 'Количество человек', '4');
      await _enterField(tester, 'Количество детей', '2');
      await _enterField(tester, 'Комментарий', 'Заезд после 18:00');
      final petSwitch = find.byType(SwitchListTile);
      await tester.ensureVisible(petSwitch);
      await tester.tap(petSwitch);
      await tester.pumpAndSettle();
      final statusDropdown = find.byType(
        DropdownButtonFormField<BookingStatus>,
      );
      await tester.ensureVisible(statusDropdown);
      await tester.tap(statusDropdown);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Оплачено').last);
      await tester.pumpAndSettle();
      final sourceDropdown = find.byType(DropdownButtonFormField<String?>);
      await tester.ensureVisible(sourceDropdown);
      await tester.tap(sourceDropdown);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Airbnb').last);
      await tester.pumpAndSettle();
      await _flushMicrotasks(tester);

      final saved = repository.bookings.single;
      expect(saved.clientName, 'Мария Иванова');
      expect(saved.clientPhone, '+79991112233');
      expect(saved.amount, 1500.5);
      expect(saved.deposit, '500');
      expect(saved.guests, 4);
      expect(saved.children, 2);
      expect(saved.hasPets, isTrue);
      expect(saved.status, BookingStatus.paid);
      expect(saved.source, 'Airbnb');
      expect(saved.comment, 'Заезд после 18:00');
    });

    testWidgets('date pickers preserve a valid stay and update night count', (
      tester,
    ) async {
      await _openEditor(tester, booking, useCases);

      await tester.tap(find.text('Заезд'));
      await tester.pumpAndSettle();
      await tester.tap(
        find.descendant(
          of: find.byType(CalendarDatePicker),
          matching: find.text('15'),
        ),
      );
      await tester.tap(find.text('Выбрать').last);
      await tester.pumpAndSettle();

      expect(find.text(_dateLabel(15)), findsOneWidget);
      expect(find.text(_dateLabel(17)), findsOneWidget);
      expect(find.text('2 ночи'), findsOneWidget);

      await tester.tap(find.text('Выезд'));
      await tester.pumpAndSettle();
      await tester.tap(
        find.descendant(
          of: find.byType(CalendarDatePicker),
          matching: find.text('20'),
        ),
      );
      await tester.tap(find.text('Выбрать').last);
      await tester.pumpAndSettle();
      await _flushMicrotasks(tester);

      expect(find.text(_dateLabel(20)), findsOneWidget);
      expect(find.text('5 ночей'), findsOneWidget);
      expect(repository.bookings.single.startDate, DateTime.utc(2026, 10, 15));
      expect(repository.bookings.single.endDate, DateTime.utc(2026, 10, 20));
    });

    testWidgets('asks before deletion and preserves or removes the booking', (
      tester,
    ) async {
      await _openEditor(tester, booking, useCases);
      final deleteButton = find.text('Удалить бронирование');
      await tester.ensureVisible(deleteButton);
      await tester.tap(deleteButton);
      await tester.pumpAndSettle();
      expect(find.text('Удалить бронирование?'), findsOneWidget);
      await tester.tap(find.text('Отмена'));
      await tester.pumpAndSettle();
      expect(repository.deletedBookingIds, isEmpty);
      expect(find.text('Бронирование'), findsOneWidget);

      await tester.ensureVisible(deleteButton);
      await tester.tap(deleteButton);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Удалить').last);
      await tester.pumpAndSettle();

      expect(repository.deletedBookingIds, [24]);
      expect(repository.bookings, isEmpty);
      expect(find.text('Бронирование'), findsNothing);
    });
  });
}

Future<void> _openEditor(
  WidgetTester tester,
  Booking booking,
  BookingUseCases useCases,
) async {
  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(
    MaterialApp(
      locale: const Locale('ru'),
      supportedLocales: const [Locale('ru')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: Builder(
        builder: (context) => Scaffold(
          body: Center(
            child: TextButton(
              onPressed: () => showModalBottomSheet<void>(
                context: context,
                isScrollControlled: true,
                useSafeArea: true,
                builder: (_) => BookingEditorSheet(
                  initialBooking: booking,
                  unitName: 'Апартаменты',
                  useCases: useCases,
                ),
              ),
              child: const Text('Открыть'),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.text('Открыть'));
  await tester.pumpAndSettle();
}

Future<void> _enterField(
  WidgetTester tester,
  String label,
  String value,
) async {
  final field = find.ancestor(
    of: find.text(label),
    matching: find.byType(TextFormField),
  );
  await tester.ensureVisible(field);
  await tester.enterText(field, value);
  await tester.pump();
}

String _dateLabel(int day) =>
    DateFormat('d MMM yyyy', 'ru').format(DateTime(2026, 10, day));

Future<void> _flushMicrotasks(WidgetTester tester) async {
  for (var i = 0; i < 8; i++) {
    await tester.pump();
  }
}
