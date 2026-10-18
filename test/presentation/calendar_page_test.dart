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

void main() {
  group('Calendar month heading', () {
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
      final datesBox = tester.renderObject<RenderBox>(find.text('ОБЪЕКТ'));
      expect(headingBox.size.width, greaterThan(350));
      expect(
        headingBox.localToGlobal(Offset.zero).dy,
        lessThan(datesBox.localToGlobal(Offset.zero).dy),
      );
      expect(
        tester.widget<Text>(headingFinder).style?.fontSize,
        greaterThanOrEqualTo(22),
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

Widget _calendarApp() {
  final useCases = BookingUseCases(_TestBookingRepository());
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
  @override
  Stream<List<RentalUnit>> watchRentalUnits() =>
      Stream.value(const [RentalUnit(id: 1, name: 'Квартира')]);

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
