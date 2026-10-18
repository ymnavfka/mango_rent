import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/booking.dart';
import '../../../domain/entities/rental_unit.dart';
import '../../../domain/repositories/booking_repository.dart';
import '../../../domain/usecases/booking_use_cases.dart';

class CalendarSelection {
  const CalendarSelection(this.rentalUnitId, this.date);

  final int rentalUnitId;
  final DateTime date;
}

class CalendarState {
  const CalendarState({
    required this.units,
    required this.bookings,
    required this.month,
    required this.rangeStartMonth,
    required this.isLoading,
    this.selection,
    this.notice,
  });

  factory CalendarState.initial() {
    final now = DateTime.now();
    return CalendarState(
      units: const [],
      bookings: const [],
      month: DateTime.utc(now.year, now.month),
      rangeStartMonth: DateTime.utc(now.year, now.month - 3),
      isLoading: true,
    );
  }

  static const monthsInWindow = 6;

  final List<RentalUnit> units;
  final List<Booking> bookings;
  final DateTime month;
  final DateTime rangeStartMonth;
  final bool isLoading;
  final CalendarSelection? selection;
  final String? notice;

  DateTime get rangeEnd => DateTime.utc(
    rangeStartMonth.year,
    rangeStartMonth.month + monthsInWindow,
  );

  List<DateTime> get dates {
    final count = rangeEnd.difference(rangeStartMonth).inDays;
    return List.generate(
      count,
      (index) => rangeStartMonth.add(Duration(days: index)),
    );
  }

  CalendarState copyWith({
    List<RentalUnit>? units,
    List<Booking>? bookings,
    DateTime? month,
    DateTime? rangeStartMonth,
    bool? isLoading,
    CalendarSelection? selection,
    bool clearSelection = false,
    String? notice,
    bool clearNotice = false,
  }) {
    return CalendarState(
      units: units ?? this.units,
      bookings: bookings ?? this.bookings,
      month: month ?? this.month,
      rangeStartMonth: rangeStartMonth ?? this.rangeStartMonth,
      isLoading: isLoading ?? this.isLoading,
      selection: clearSelection ? null : selection ?? this.selection,
      notice: clearNotice ? null : notice ?? this.notice,
    );
  }
}

class CalendarCubit extends Cubit<CalendarState> {
  CalendarCubit(this._useCases) : super(CalendarState.initial()) {
    _unitsSubscription = _useCases.watchRentalUnits().listen(
      (units) {
        if (isClosed) return;
        emit(state.copyWith(units: units, isLoading: false));
      },
      onError: (Object error) =>
          _showNotice('Не удалось загрузить объекты: $error'),
    );
    _bookingsSubscription = _useCases.watchBookings().listen(
      (bookings) {
        if (isClosed) return;
        emit(state.copyWith(bookings: bookings));
      },
      onError: (Object error) =>
          _showNotice('Не удалось загрузить бронирования: $error'),
    );
  }

  final BookingUseCases _useCases;
  StreamSubscription<List<RentalUnit>>? _unitsSubscription;
  StreamSubscription<List<Booking>>? _bookingsSubscription;

  DateTime changeMonth(int offset) {
    final targetMonth = DateTime.utc(
      state.month.year,
      state.month.month + offset,
    );
    final resetRange =
        targetMonth.isBefore(state.rangeStartMonth) ||
        !targetMonth.isBefore(state.rangeEnd);
    final rangeStartMonth = resetRange
        ? DateTime.utc(
            targetMonth.year,
            targetMonth.month - CalendarState.monthsInWindow ~/ 2,
          )
        : state.rangeStartMonth;
    emit(
      state.copyWith(
        month: targetMonth,
        rangeStartMonth: rangeStartMonth,
        clearSelection: true,
      ),
    );
    return targetMonth;
  }

  DateTime goToToday() {
    final now = DateTime.now();
    final todayMonth = DateTime.utc(now.year, now.month);
    emit(
      state.copyWith(
        month: todayMonth,
        rangeStartMonth: DateTime.utc(
          now.year,
          now.month - CalendarState.monthsInWindow ~/ 2,
        ),
        clearSelection: true,
      ),
    );
    return todayMonth;
  }

  void setVisibleMonth(DateTime month) {
    if (state.month == month) return;
    emit(state.copyWith(month: month));
  }

  void setRangeStartMonth(DateTime month) {
    if (state.rangeStartMonth == month) return;
    emit(state.copyWith(rangeStartMonth: month));
  }

  Future<Booking?> tapCell(int rentalUnitId, DateTime date) async {
    final selection = state.selection;
    if (selection == null || selection.rentalUnitId != rentalUnitId) {
      emit(state.copyWith(selection: CalendarSelection(rentalUnitId, date)));
      return null;
    }

    emit(state.copyWith(clearSelection: true));
    final first = selection.date.isBefore(date) ? selection.date : date;
    final last = selection.date.isAfter(date) ? selection.date : date;
    final booking = Booking(
      id: null,
      rentalUnitId: rentalUnitId,
      startDate: first,
      endDate: last.add(const Duration(days: 1)),
    );

    try {
      return await _useCases.saveBooking(booking);
    } on BookingConflictException {
      _showNotice('В выбранном диапазоне уже есть бронирование.');
    } catch (error) {
      _showNotice('Не удалось создать бронирование: $error');
    }
    return null;
  }

  Future<void> addRentalUnit(String name) => _useCases.addRentalUnit(name);

  String unitName(int rentalUnitId) {
    for (final unit in state.units) {
      if (unit.id == rentalUnitId) return unit.name;
    }
    return '';
  }

  void clearNotice() => emit(state.copyWith(clearNotice: true));

  void _showNotice(String message) {
    if (isClosed) return;
    emit(state.copyWith(notice: message));
  }

  @override
  Future<void> close() async {
    await _unitsSubscription?.cancel();
    await _bookingsSubscription?.cancel();
    await super.close();
  }
}
