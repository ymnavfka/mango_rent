import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mango_rent/domain/entities/rental_unit.dart';
import 'package:mango_rent/domain/usecases/booking_use_cases.dart';
import 'package:mango_rent/presentation/calendar/calendar_page.dart';
import 'package:mango_rent/presentation/calendar/cubit/calendar_cubit.dart';

import '../support/in_memory_booking_repository.dart';

void main() {
  group('CalendarPage workflows', () {
    testWidgets('adds an object and validates a blank object name', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final repository = InMemoryBookingRepository();
      addTearDown(repository.dispose);

      await tester.pumpWidget(_calendarApp(repository));
      await tester.pumpAndSettle();
      expect(find.text('Начните с первого объекта'), findsOneWidget);

      await tester.tap(find.text('Добавить объект'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Добавить').last);
      await tester.pumpAndSettle();
      expect(find.text('Введите название объекта.'), findsOneWidget);

      await tester.tap(find.text('Добавить').last);
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'Квартира на Невском');
      await tester.tap(find.text('Добавить').last);
      await tester.pumpAndSettle();

      expect(repository.addedUnitNames, ['Квартира на Невском']);
      expect(find.text('Квартира на Невском'), findsOneWidget);
      expect(find.text('Начните с первого объекта'), findsNothing);
    });

    testWidgets('selects two dates in a unit row and opens the new booking', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final repository = InMemoryBookingRepository(
        units: const [RentalUnit(id: 1, name: 'Квартира')],
      );
      addTearDown(repository.dispose);

      await tester.pumpWidget(_calendarApp(repository));
      await tester.pumpAndSettle();

      final today = DateTime.now();
      final start = DateTime.utc(today.year, today.month, today.day + 2);
      final lastNight = start.add(const Duration(days: 2));
      await _tapCalendarDay(tester, start);
      expect(find.text('Выберите вторую дату в той же строке'), findsOneWidget);
      await _tapCalendarDay(tester, lastNight);
      await tester.pumpAndSettle();

      expect(repository.savedBookings, hasLength(1));
      expect(repository.savedBookings.single.startDate, start);
      expect(
        repository.savedBookings.single.endDate,
        lastNight.add(const Duration(days: 1)),
      );
      expect(find.text('Бронирование'), findsOneWidget);
      expect(find.text('Квартира'), findsWidgets);
    });
  });
}

Widget _calendarApp(InMemoryBookingRepository repository) {
  final useCases = BookingUseCases(repository);
  return MaterialApp(
    locale: const Locale('ru'),
    supportedLocales: const [Locale('ru')],
    localizationsDelegates: const [
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    home: BlocProvider(
      create: (_) => CalendarCubit(useCases),
      child: CalendarPage(useCases: useCases),
    ),
  );
}

Future<void> _tapCalendarDay(WidgetTester tester, DateTime date) async {
  final monthHeader = tester.renderObject<RenderBox>(
    find.byKey(const ValueKey('calendar-month-header')),
  );
  final headerTop =
      monthHeader.localToGlobal(Offset.zero).dy + monthHeader.size.height;
  final screenWidth =
      tester.view.physicalSize.width / tester.view.devicePixelRatio;
  final dayFinder = find.text('${date.day}');
  final candidate = dayFinder.evaluate().firstWhere((element) {
    final box = element.renderObject! as RenderBox;
    final center = box.localToGlobal(box.size.center(Offset.zero));
    return center.dx > 50 &&
        center.dx < screenWidth - 8 &&
        center.dy > headerTop &&
        center.dy < headerTop + 56;
  });
  final dayBox = candidate.renderObject! as RenderBox;
  final dayCenter = dayBox.localToGlobal(dayBox.size.center(Offset.zero));
  final unitFinder = find.text('Квартира');
  final unitBox = tester.renderObject<RenderBox>(unitFinder);
  final unitCenter = unitBox.localToGlobal(unitBox.size.center(Offset.zero));

  await tester.tapAt(Offset(dayCenter.dx, unitCenter.dy));
  await tester.pumpAndSettle();
}
