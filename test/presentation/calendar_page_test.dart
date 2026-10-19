import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:mango_rent/domain/entities/booking.dart';
import 'package:mango_rent/domain/entities/rental_unit.dart';
import 'package:mango_rent/domain/repositories/booking_repository.dart';
import 'package:mango_rent/domain/usecases/booking_use_cases.dart';
import 'package:mango_rent/presentation/calendar/calendar_page.dart';
import 'package:mango_rent/presentation/calendar/cubit/calendar_cubit.dart';
import 'package:mango_rent/presentation/theme/app_palette.dart';

void main() {
  group('Calendar month heading', () {
    testWidgets('does not show a separate status legend above the calendar', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(_calendarApp());
      await tester.pumpAndSettle();

      for (final status in BookingStatus.values) {
        expect(find.text(status.label), findsNothing);
      }
    });

    testWidgets('shows a prominent full-width month heading above the dates', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(_calendarApp());
      await tester.pumpAndSettle();

      final monthHeading = _monthLabel(DateTime.now());
      final headingFinder = find.text(monthHeading);
      expect(headingFinder, findsOneWidget);

      final headingBox = tester.renderObject<RenderBox>(
        find.byKey(const ValueKey('calendar-month-header')),
      );
      final datesBox = tester.renderObject<RenderBox>(
        find.byKey(const ValueKey('calendar-corner-cell')),
      );
      expect(headingBox.size.width, greaterThan(350));
      expect(
        headingBox.localToGlobal(Offset.zero).dy,
        lessThan(datesBox.localToGlobal(Offset.zero).dy),
      );
      expect(
        tester.widget<Text>(headingFinder).style?.fontSize,
        greaterThanOrEqualTo(22),
      );
      expect(find.text('ОБЪЕКТ'), findsNothing);
    });

    testWidgets('date headers use larger text in compact date columns', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(_calendarApp());
      await tester.pumpAndSettle();

      expect(dayWidthForScreen(390), lessThan(36));
      final today = DateTime.now();
      final dateHeader = find.byKey(
        ValueKey(
          'calendar-date-header-${today.year}-${today.month}-${today.day}',
        ),
      );
      final headerTexts = find.descendant(
        of: dateHeader,
        matching: find.byType(Text),
      );
      expect(headerTexts, findsNWidgets(2));
      expect(
        tester.widget<Text>(headerTexts.at(0)).style?.fontSize,
        greaterThanOrEqualTo(13),
      );
      expect(
        tester.widget<Text>(headerTexts.at(1)).style?.fontSize,
        greaterThanOrEqualTo(24),
      );

      final dateHeaderBox = tester.renderObject<RenderBox>(dateHeader);
      final cornerCellBox = tester.renderObject<RenderBox>(
        find.byKey(const ValueKey('calendar-corner-cell')),
      );
      expect(
        dateHeaderBox.localToGlobal(Offset.zero).dy,
        closeTo(cornerCellBox.localToGlobal(Offset.zero).dy, 0.1),
      );
    });

    testWidgets('object column uses 15 percent and shows complete wrapped names', (
      tester,
    ) async {
      const unitName =
          'Квартира с экстраординарно длинным названием для проверки переноса';
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(_calendarApp(unitName: unitName));
      await tester.pumpAndSettle();

      final objectColumn = tester.renderObject<RenderBox>(
        find.byKey(const ValueKey('calendar-object-column')),
      );
      expect(objectColumn.size.width, closeTo(390 * 0.15, 0.1));

      final unitLabel = tester.widget<Text>(find.text(unitName));
      expect(unitLabel.maxLines, isNull);
      expect(unitLabel.softWrap, isTrue);
      expect(unitLabel.overflow, TextOverflow.clip);
      expect(unitLabel.style?.fontSize, lessThan(11));
      final labelRect = tester.getRect(find.text(unitName));
      expect(labelRect.left - objectColumn.localToGlobal(Offset.zero).dx, 3.5);
      expect(labelRect.width, lessThanOrEqualTo(objectColumn.size.width - 7));
    });

    testWidgets('tapping an object name does not open a full-name overlay', (
      tester,
    ) async {
      const unitName =
          'Апартаменты у моря с видом на набережную и исторический центр';
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(_calendarApp(unitName: unitName));
      await tester.pumpAndSettle();

      await tester.tap(find.text(unitName));
      await tester.pump();

      expect(
        find.byKey(const ValueKey('calendar-unit-name-island')),
        findsNothing,
      );
      expect(find.text(unitName), findsOneWidget);
    });

    testWidgets('previous and next arrows change the displayed month', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(_calendarApp());
      await tester.pumpAndSettle();

      final currentMonth = DateTime.now();
      await tester.tap(find.byTooltip('Предыдущий месяц'));
      await tester.pumpAndSettle();
      expect(
        find.text(
          _monthLabel(DateTime(currentMonth.year, currentMonth.month - 1)),
        ),
        findsOneWidget,
      );

      await tester.tap(find.byTooltip('Следующий месяц'));
      await tester.pumpAndSettle();
      expect(find.text(_monthLabel(currentMonth)), findsOneWidget);
    });
  });
}

Widget _calendarApp({String unitName = 'Квартира'}) {
  final useCases = BookingUseCases(_TestBookingRepository(unitName: unitName));
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

String _monthLabel(DateTime date) {
  final monthText = DateFormat.yMMMM('ru').format(date);
  return '${monthText[0].toUpperCase()}${monthText.substring(1)}';
}

class _TestBookingRepository implements BookingRepository {
  _TestBookingRepository({required this.unitName});

  final String unitName;

  @override
  Stream<List<RentalUnit>> watchRentalUnits() =>
      Stream.value([RentalUnit(id: 1, name: unitName)]);

  @override
  Stream<List<Booking>> watchBookings() => Stream.value(const []);

  @override
  Future<List<Booking>> getBookingsForUnit(int rentalUnitId) async => const [];

  @override
  Future<void> addRentalUnit(String name) async {}

  @override
  Future<Booking> saveBooking(Booking booking) async => booking;

  @override
  Future<void> deleteBooking(int id) async {}
}
