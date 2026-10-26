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

    testWidgets(
      'object column uses 15 percent and shows complete wrapped names',
      (tester) async {
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
        expect(
          labelRect.left - objectColumn.localToGlobal(Offset.zero).dx,
          3.5,
        );
        expect(labelRect.width, lessThanOrEqualTo(objectColumn.size.width - 7));
      },
    );

    testWidgets('tapping an object name opens its full-screen calendar', (
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
      await tester.pumpAndSettle();

      expect(
        find.byKey(const ValueKey('calendar-detail-view')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey('calendar-detail-weekday-1')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey('calendar-detail-weekday-7')),
        findsOneWidget,
      );
      expect(_keyStartingWith('calendar-detail-weekday-'), findsNWidgets(7));
      expect(_keyStartingWith('calendar-date-header-'), findsNothing);
      expect(_keyStartingWith('calendar-detail-day-'), findsNWidgets(42));
      expect(_keyStartingWith('calendar-detail-week-'), findsNWidgets(6));
      expect(
        find.byKey(const ValueKey('calendar-detail-back')),
        findsOneWidget,
      );
      expect(find.text(unitName), findsOneWidget);
    });

    testWidgets('detail calendar filters bookings and can switch objects', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        _calendarApp(
          units: const [
            RentalUnit(id: 1, name: 'Квартира'),
            RentalUnit(id: 2, name: 'Дом'),
          ],
          bookings: [
            _booking(id: 1, rentalUnitId: 1, clientName: 'Анна'),
            _booking(id: 2, rentalUnitId: 2, clientName: 'Борис'),
          ],
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Квартира'));
      await tester.pumpAndSettle();

      expect(_detailBooking(1), findsOneWidget);
      expect(_detailBooking(2), findsNothing);

      await tester.tap(find.byKey(const ValueKey('calendar-unit-selector-2')));
      await tester.pumpAndSettle();

      expect(_detailBooking(1), findsNothing);
      expect(_detailBooking(2), findsOneWidget);
    });

    testWidgets('calendar follows a drag and settles on the nearest month', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final currentMonth = DateTime.now();
      await tester.pumpWidget(_calendarApp());
      await tester.pumpAndSettle();
      await tester.tap(find.text('Квартира'));
      await tester.pumpAndSettle();

      final pager = find.byKey(const ValueKey('calendar-detail-month-pager'));
      final viewport = tester.getRect(pager);
      final nextMonth = DateTime(currentMonth.year, currentMonth.month + 1);
      final drag = await tester.startGesture(viewport.center);
      await drag.moveBy(const Offset(-20, 0));
      await drag.moveBy(Offset(-viewport.width * 0.4, 0));
      await tester.pump(const Duration(milliseconds: 16));

      final currentPage = find.byKey(_detailMonthPageKey(currentMonth));
      final nextPage = find.byKey(_detailMonthPageKey(nextMonth));
      expect(currentPage, findsOneWidget);
      expect(nextPage, findsOneWidget);
      expect(
        tester.getRect(currentPage).left,
        closeTo(viewport.left - viewport.width * 0.4, 1),
      );
      expect(
        tester.getRect(nextPage).left,
        closeTo(viewport.left + viewport.width * 0.6, 1),
      );

      await drag.up();
      await tester.pumpAndSettle();
      expect(find.text(_monthLabel(currentMonth)), findsOneWidget);

      final forwardDrag = await tester.startGesture(viewport.center);
      await forwardDrag.moveBy(const Offset(-20, 0));
      await forwardDrag.moveBy(Offset(-viewport.width * 0.6, 0));
      await tester.pump(const Duration(milliseconds: 16));
      await forwardDrag.up();
      await tester.pumpAndSettle();
      expect(find.text(_monthLabel(nextMonth)), findsOneWidget);

      await tester.fling(pager, Offset(viewport.width * 0.8, 0), 1000);
      await tester.pumpAndSettle();

      expect(find.text(_monthLabel(currentMonth)), findsOneWidget);
    });

    testWidgets('detail bookings occupy half of arrival and checkout days', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(600, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final now = DateTime.now();
      final monthStart = DateTime.utc(now.year, now.month);
      final weekStart = monthStart.subtract(
        Duration(days: monthStart.weekday - DateTime.monday),
      );
      final booking = Booking(
        id: 41,
        rentalUnitId: 1,
        startDate: weekStart.add(const Duration(days: 2)),
        endDate: weekStart.add(const Duration(days: 5)),
        clientName: 'Анна',
      );

      await tester.pumpWidget(_calendarApp(bookings: [booking]));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Квартира'));
      await tester.pumpAndSettle();

      final segment = find.byKey(
        _detailBookingSegmentKey(booking.id!, weekStart),
      );
      final segmentRect = tester.getRect(
        find.descendant(of: segment, matching: find.byType(Material)),
      );
      final arrivalCell = tester.getRect(
        find.byKey(_detailDayKey(booking.startDate)),
      );
      final checkoutCell = tester.getRect(
        find.byKey(_detailDayKey(booking.endDate)),
      );

      expect(segmentRect.left, closeTo(arrivalCell.center.dx + 2, 0.1));
      expect(segmentRect.right, closeTo(checkoutCell.center.dx - 2, 0.1));
    });

    testWidgets('booking ending on a week boundary reaches checkout noon', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(600, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final now = DateTime.now();
      final monthStart = DateTime.utc(now.year, now.month);
      final weekStart = monthStart.subtract(
        Duration(days: monthStart.weekday - DateTime.monday),
      );
      final checkoutDate = weekStart.add(const Duration(days: 7));
      final booking = Booking(
        id: 44,
        rentalUnitId: 1,
        startDate: weekStart.add(const Duration(days: 2)),
        endDate: checkoutDate,
        clientName: 'Анна',
      );

      await tester.pumpWidget(_calendarApp(bookings: [booking]));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Квартира'));
      await tester.pumpAndSettle();

      final checkoutWeekStart = checkoutDate;
      final checkoutSegment = find.byKey(
        _detailBookingSegmentKey(booking.id!, checkoutWeekStart),
      );
      final segmentRect = tester.getRect(
        find.descendant(of: checkoutSegment, matching: find.byType(Material)),
      );
      final checkoutCell = tester.getRect(
        find.byKey(_detailDayKey(checkoutDate)),
      );

      expect(segmentRect.left, closeTo(checkoutCell.left + 2, 0.1));
      expect(segmentRect.right, closeTo(checkoutCell.center.dx - 2, 0.1));
    });

    testWidgets('split booking hides a partial label when it cannot fit', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final now = DateTime.now();
      final monthStart = DateTime.utc(now.year, now.month);
      final weekStart = monthStart.subtract(
        Duration(days: monthStart.weekday - DateTime.monday),
      );
      final booking = Booking(
        id: 42,
        rentalUnitId: 1,
        startDate: weekStart.add(const Duration(days: 1)),
        endDate: weekStart.add(const Duration(days: 8)),
        clientName: 'Аня',
      );

      await tester.pumpWidget(_calendarApp(bookings: [booking]));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Квартира'));
      await tester.pumpAndSettle();

      final firstSegment = find.byKey(
        _detailBookingSegmentKey(booking.id!, weekStart),
      );
      final secondWeekStart = weekStart.add(const Duration(days: 7));
      final secondSegment = find.byKey(
        _detailBookingSegmentKey(booking.id!, secondWeekStart),
      );
      expect(_detailBooking(booking.id!), findsNWidgets(2));
      final summary = '${nightLabel(booking.nights)} · 1 чел.';
      expect(
        find.descendant(
          of: firstSegment,
          matching: find.text(booking.clientName),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(of: secondSegment, matching: find.byType(Text)),
        findsNothing,
      );
      expect(
        find.descendant(of: firstSegment, matching: find.text(summary)),
        findsOneWidget,
      );
      final firstLabel = tester.widget<Text>(
        find.descendant(
          of: firstSegment,
          matching: find.text(booking.clientName),
        ),
      );
      final firstSummary = tester.widget<Text>(
        find.descendant(of: firstSegment, matching: find.text(summary)),
      );
      expect(firstLabel.style?.fontSize, 11);
      expect(firstSummary.style?.fontSize, 9);
      expect(
        tester
            .widget<Material>(
              find.descendant(
                of: firstSegment,
                matching: find.byType(Material),
              ),
            )
            .borderRadius,
        const BorderRadius.only(
          topLeft: Radius.circular(9),
          bottomLeft: Radius.circular(9),
        ),
      );
      expect(
        tester
            .widget<Material>(
              find.descendant(
                of: secondSegment,
                matching: find.byType(Material),
              ),
            )
            .borderRadius,
        const BorderRadius.only(
          topRight: Radius.circular(9),
          bottomRight: Radius.circular(9),
        ),
      );
    });

    testWidgets('wide week segments repeat the exact same booking label', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(600, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final now = DateTime.now();
      final monthStart = DateTime.utc(now.year, now.month);
      final weekStart = monthStart.subtract(
        Duration(days: monthStart.weekday - DateTime.monday),
      );
      final booking = Booking(
        id: 43,
        rentalUnitId: 1,
        startDate: weekStart.add(const Duration(days: 3)),
        endDate: weekStart.add(const Duration(days: 10)),
        clientName: 'Аня',
      );

      await tester.pumpWidget(_calendarApp(bookings: [booking]));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Квартира'));
      await tester.pumpAndSettle();

      final firstSegment = find.byKey(
        _detailBookingSegmentKey(booking.id!, weekStart),
      );
      final secondSegment = find.byKey(
        _detailBookingSegmentKey(
          booking.id!,
          weekStart.add(const Duration(days: 7)),
        ),
      );
      final summary = '${nightLabel(booking.nights)} · 1 чел.';
      final firstTexts = tester
          .widgetList<Text>(
            find.descendant(of: firstSegment, matching: find.byType(Text)),
          )
          .toList();
      final secondTexts = tester
          .widgetList<Text>(
            find.descendant(of: secondSegment, matching: find.byType(Text)),
          )
          .toList();

      expect(firstTexts.map((text) => text.data), [
        booking.clientName,
        summary,
      ]);
      expect(secondTexts.map((text) => text.data), [
        booking.clientName,
        summary,
      ]);
      expect(firstTexts[0].style?.fontSize, secondTexts[0].style?.fontSize);
      expect(firstTexts[1].style?.fontSize, secondTexts[1].style?.fontSize);

      final firstCardRect = tester.getRect(
        find.descendant(of: firstSegment, matching: find.byType(Material)),
      );
      final secondCardRect = tester.getRect(
        find.descendant(of: secondSegment, matching: find.byType(Material)),
      );
      final firstNameRect = tester.getRect(
        find.descendant(
          of: firstSegment,
          matching: find.text(booking.clientName),
        ),
      );
      final secondNameRect = tester.getRect(
        find.descendant(
          of: secondSegment,
          matching: find.text(booking.clientName),
        ),
      );
      expect(
        firstNameRect.top - firstCardRect.top,
        closeTo(secondNameRect.top - secondCardRect.top, 0.1),
      );
      expect(
        firstNameRect.left - firstCardRect.left,
        closeTo(secondNameRect.left - secondCardRect.left, 0.1),
      );
    });

    testWidgets('detail back button returns to the full calendar', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(_calendarApp());
      await tester.pumpAndSettle();
      await tester.tap(find.text('Квартира'));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const ValueKey('calendar-detail-back')));
      await tester.pumpAndSettle();

      expect(find.byKey(const ValueKey('calendar-detail-view')), findsNothing);
      expect(
        find.byKey(const ValueKey('calendar-corner-cell')),
        findsOneWidget,
      );
    });

    testWidgets('system back closes the selected object calendar', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(_calendarApp());
      await tester.pumpAndSettle();
      await tester.tap(find.text('Квартира'));
      await tester.pumpAndSettle();

      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();

      expect(find.byKey(const ValueKey('calendar-detail-view')), findsNothing);
      expect(
        find.byKey(const ValueKey('calendar-corner-cell')),
        findsOneWidget,
      );
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

Widget _calendarApp({
  String unitName = 'Квартира',
  List<RentalUnit>? units,
  List<Booking> bookings = const [],
}) {
  final useCases = BookingUseCases(
    _TestBookingRepository(
      units: units ?? [RentalUnit(id: 1, name: unitName)],
      bookings: bookings,
    ),
  );
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

Booking _booking({
  required int id,
  required int rentalUnitId,
  required String clientName,
}) {
  final now = DateTime.now();
  final firstDay = DateTime.utc(now.year, now.month);
  final daysToMonday = (DateTime.monday - firstDay.weekday + 7) % 7;
  final start = firstDay.add(Duration(days: daysToMonday));
  return Booking(
    id: id,
    rentalUnitId: rentalUnitId,
    startDate: start,
    endDate: start.add(const Duration(days: 3)),
    clientName: clientName,
  );
}

Finder _detailBooking(int bookingId) => find.byWidgetPredicate((widget) {
  final key = widget.key;
  return key is ValueKey<String> &&
      key.value.startsWith('calendar-detail-booking-$bookingId-');
});

ValueKey<String> _detailBookingSegmentKey(int bookingId, DateTime weekStart) =>
    ValueKey(
      'calendar-detail-booking-$bookingId-'
      '${weekStart.year}-${weekStart.month}-${weekStart.day}',
    );

ValueKey<String> _detailDayKey(DateTime date) =>
    ValueKey('calendar-detail-day-${date.year}-${date.month}-${date.day}');

ValueKey<String> _detailMonthPageKey(DateTime month) =>
    ValueKey('calendar-detail-month-page-${month.year}-${month.month}');

Finder _keyStartingWith(String prefix) => find.byWidgetPredicate((widget) {
  final key = widget.key;
  return key is ValueKey<String> && key.value.startsWith(prefix);
});

String _monthLabel(DateTime date) {
  final monthText = DateFormat.yMMMM('ru').format(date);
  return '${monthText[0].toUpperCase()}${monthText.substring(1)}';
}

class _TestBookingRepository implements BookingRepository {
  _TestBookingRepository({required this.units, required this.bookings});

  final List<RentalUnit> units;
  final List<Booking> bookings;

  @override
  Stream<List<RentalUnit>> watchRentalUnits() => Stream.value(units);

  @override
  Stream<List<Booking>> watchBookings() => Stream.value(bookings);

  @override
  Future<List<Booking>> getBookingsForUnit(int rentalUnitId) async => bookings
      .where((booking) => booking.rentalUnitId == rentalUnitId)
      .toList();

  @override
  Future<void> addRentalUnit(String name) async {}

  @override
  Future<Booking> saveBooking(Booking booking) async => booking;

  @override
  Future<void> deleteBooking(int id) async {}
}
