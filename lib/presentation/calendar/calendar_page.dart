import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/booking.dart';
import '../../domain/entities/rental_unit.dart';
import '../../domain/usecases/booking_use_cases.dart';
import '../theme/app_palette.dart';
import 'cubit/calendar_cubit.dart';
import 'widgets/booking_editor_sheet.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key, required this.useCases});

  final BookingUseCases useCases;

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  static const _monthsPerShift = 3;
  static const _edgeBufferDays = 30;
  static const _unitColumnHorizontalPadding = 7.0;

  late final ScrollController _leftScrollController;
  late final ScrollController _rightScrollController;
  late final ScrollController _horizontalController;

  bool _syncingScroll = false;
  bool _initialScrollQueued = false;
  bool _rangeAdjustmentPending = false;
  double _activeObjectColumnWidth = 32;
  double? _activeDayWidth;

  CalendarCubit get _cubit => context.read<CalendarCubit>();
  CalendarState get _calendar => _cubit.state;
  List<RentalUnit> get _units => _calendar.units;
  List<Booking> get _bookings => _calendar.bookings;
  CalendarSelection? get _selection => _calendar.selection;
  DateTime get _month => _calendar.month;
  DateTime get _rangeStartMonth => _calendar.rangeStartMonth;
  DateTime get _rangeEnd => _calendar.rangeEnd;
  List<DateTime> get _dates => _calendar.dates;

  double get _dayWidth =>
      _activeDayWidth ?? dayWidthForScreen(MediaQuery.sizeOf(context).width);

  @override
  void initState() {
    super.initState();
    _leftScrollController = ScrollController()..addListener(_syncLeftToRight);
    _rightScrollController = ScrollController()..addListener(_syncRightToLeft);
    _horizontalController = ScrollController()
      ..addListener(_handleTimelineScroll);
  }

  @override
  void dispose() {
    _leftScrollController
      ..removeListener(_syncLeftToRight)
      ..dispose();
    _rightScrollController
      ..removeListener(_syncRightToLeft)
      ..dispose();
    _horizontalController
      ..removeListener(_handleTimelineScroll)
      ..dispose();
    super.dispose();
  }

  void _syncLeftToRight() =>
      _syncScroll(_leftScrollController, _rightScrollController);

  void _syncRightToLeft() =>
      _syncScroll(_rightScrollController, _leftScrollController);

  void _syncScroll(ScrollController source, ScrollController target) {
    if (_syncingScroll || !source.hasClients || !target.hasClients) return;
    _syncingScroll = true;
    final offset = source.offset
        .clamp(0.0, target.position.maxScrollExtent)
        .toDouble();
    if ((target.offset - offset).abs() > 0.5) target.jumpTo(offset);
    _syncingScroll = false;
  }

  void _changeMonth(int offset) {
    final targetMonth = _cubit.changeMonth(offset);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToMonth(targetMonth);
    });
  }

  void _goToToday() {
    _cubit.goToToday();
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToToday());
  }

  void _scrollToToday() {
    if (!_horizontalController.hasClients) return;
    final desiredOffset =
        (_today().difference(_rangeStartMonth).inDays - 2) * _dayWidth;
    final offset = desiredOffset
        .clamp(0.0, _horizontalController.position.maxScrollExtent)
        .toDouble();
    _horizontalController.jumpTo(offset);
  }

  void _scrollToMonth(DateTime month) {
    if (!_horizontalController.hasClients) return;
    final desiredOffset = month.difference(_rangeStartMonth).inDays * _dayWidth;
    final offset = desiredOffset
        .clamp(0.0, _horizontalController.position.maxScrollExtent)
        .toDouble();
    _horizontalController.jumpTo(offset);
  }

  void _handleTimelineScroll() {
    if (!_horizontalController.hasClients || _rangeAdjustmentPending) return;
    final calendar = _calendar;
    final dates = calendar.dates;
    if (dates.isEmpty) return;

    final visibleIndex = (_horizontalController.offset / _dayWidth)
        .floor()
        .clamp(0, dates.length - 1)
        .toInt();
    final dateAtLeftEdge = dates[visibleIndex];
    final visibleMonth = DateTime.utc(
      dateAtLeftEdge.year,
      dateAtLeftEdge.month,
    );
    if (visibleMonth != calendar.month && mounted) {
      _cubit.setVisibleMonth(visibleMonth);
    }
    final position = _horizontalController.position;
    final edgeBuffer = _edgeBufferDays * _dayWidth;
    late DateTime nextRangeStart;
    late double nextOffset;
    if (position.pixels < edgeBuffer) {
      nextRangeStart = DateTime.utc(
        calendar.rangeStartMonth.year,
        calendar.rangeStartMonth.month - _monthsPerShift,
      );
      final addedDays = calendar.rangeStartMonth
          .difference(nextRangeStart)
          .inDays;
      nextOffset = position.pixels + addedDays * _dayWidth;
    } else if (position.maxScrollExtent - position.pixels < edgeBuffer) {
      nextRangeStart = DateTime.utc(
        calendar.rangeStartMonth.year,
        calendar.rangeStartMonth.month + _monthsPerShift,
      );
      final removedDays = nextRangeStart
          .difference(calendar.rangeStartMonth)
          .inDays;
      nextOffset = position.pixels - removedDays * _dayWidth;
    } else {
      return;
    }

    _rangeAdjustmentPending = true;
    _cubit.setRangeStartMonth(nextRangeStart);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (_horizontalController.hasClients) {
        final adjustedOffset = nextOffset
            .clamp(0.0, _horizontalController.position.maxScrollExtent)
            .toDouble();
        _horizontalController.jumpTo(adjustedOffset);
      }
      _rangeAdjustmentPending = false;
      _handleTimelineScroll();
    });
  }

  void _showSnack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _addRentalUnit() async {
    final name = await showDialog<String>(
      context: context,
      builder: (_) => const _AddRentalUnitDialog(),
    );
    if (name == null) return;
    if (name.trim().isEmpty) {
      _showSnack('Введите название объекта.');
      return;
    }
    await _cubit.addRentalUnit(name);
  }

  Future<void> _tapCell(int rentalUnitId, DateTime date) async {
    final saved = await _cubit.tapCell(rentalUnitId, date);
    if (saved == null || !mounted) return;
    await _openBookingEditor(saved, _cubit.unitName(rentalUnitId));
  }

  Future<void> _openBookingEditor(Booking booking, String unitName) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (context) => BookingEditorSheet(
        initialBooking: booking,
        unitName: unitName,
        useCases: widget.useCases,
      ),
    );
  }

  Future<void> _editBooking(Booking booking) async {
    await _openBookingEditor(booking, _cubit.unitName(booking.rentalUnitId));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<CalendarCubit, CalendarState>(
      listenWhen: (previous, current) => current.notice != null,
      listener: (context, state) {
        _showSnack(state.notice!);
        _cubit.clearNotice();
      },
      child: BlocBuilder<CalendarCubit, CalendarState>(
        builder: (context, state) {
          final width = MediaQuery.sizeOf(context).width;
          final compact = width < 520;
          _activeObjectColumnWidth = _objectColumnWidthForScreen(width);
          _activeDayWidth = dayWidthForScreen(
            width,
            objectColumnWidth: _activeObjectColumnWidth,
          );
          if (state.units.isNotEmpty && !_initialScrollQueued) {
            _initialScrollQueued = true;
            WidgetsBinding.instance.addPostFrameCallback(
              (_) => _scrollToToday(),
            );
          }

          return Scaffold(
            body: SafeArea(
              child: Column(
                children: [
                  _buildToolbar(compact),
                  _buildSectionHeading(compact),
                  if (state.isLoading)
                    const Expanded(
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else if (state.units.isEmpty)
                    Expanded(child: _buildEmptyState())
                  else ...[
                    _buildLegend(compact),
                    Expanded(child: _buildCalendar(width)),
                    if (state.selection != null)
                      const Padding(
                        padding: EdgeInsets.fromLTRB(16, 0, 16, 10),
                        child: Text(
                          'Выберите вторую дату в той же строке',
                          style: TextStyle(
                            color: green,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildToolbar(bool compact) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 13, 14, 4),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: const Color(0xFFE7F1E9),
              borderRadius: BorderRadius.circular(13),
            ),
            child: const Icon(Icons.spa_rounded, color: green, size: 21),
          ),
          const SizedBox(width: 9),
          Text(
            compact ? 'Mango' : 'Mango rent',
            style: const TextStyle(
              color: ink,
              fontWeight: FontWeight.w800,
              fontSize: 18,
              letterSpacing: -0.5,
            ),
          ),
          const Spacer(),
          if (compact)
            IconButton(
              visualDensity: VisualDensity.compact,
              tooltip: 'Текущий месяц',
              onPressed: () {
                _goToToday();
              },
              icon: const Icon(Icons.today_outlined, size: 20),
            )
          else
            TextButton(
              onPressed: () {
                _goToToday();
              },
              child: const Text('Сегодня'),
            ),
        ],
      ),
    );
  }

  Widget _buildMonthHeader(bool compact) {
    final monthText = DateFormat.yMMMM('ru').format(_month);
    final formattedMonth = monthText.isEmpty
        ? monthText
        : '${monthText[0].toUpperCase()}${monthText.substring(1)}';

    return Container(
      key: const ValueKey('calendar-month-header'),
      width: double.infinity,
      height: compact ? 62 : 70,
      padding: EdgeInsets.symmetric(horizontal: compact ? 4 : 12),
      alignment: Alignment.center,
      child: Row(
        children: [
          IconButton(
            tooltip: 'Предыдущий месяц',
            onPressed: () => _changeMonth(-1),
            icon: const Icon(Icons.chevron_left_rounded),
          ),
          Expanded(
            child: Text(
              formattedMonth,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: ink,
                fontSize: compact ? 25 : 28,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.6,
              ),
            ),
          ),
          IconButton(
            tooltip: 'Следующий месяц',
            onPressed: () => _changeMonth(1),
            icon: const Icon(Icons.chevron_right_rounded),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeading(bool compact) {
    return Padding(
      padding: EdgeInsets.fromLTRB(compact ? 18 : 22, 9, compact ? 14 : 22, 9),
      child: Row(
        children: [
          const Text(
            'Объекты',
            style: TextStyle(
              color: ink,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(width: 8),
          if (_units.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: const Color(0xFFE9EEE9),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${_units.length}',
                style: const TextStyle(color: mutedInk, fontSize: 12),
              ),
            ),
          const Spacer(),
          FilledButton.tonalIcon(
            onPressed: _addRentalUnit,
            icon: const Icon(Icons.add_rounded, size: 18),
            label: Text(compact ? 'Добавить' : 'Добавить объект'),
            style: FilledButton.styleFrom(
              foregroundColor: green,
              backgroundColor: const Color(0xFFE6F1E8),
              padding: EdgeInsets.symmetric(
                horizontal: compact ? 11 : 16,
                vertical: 11,
              ),
              textStyle: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 430),
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 34),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: line),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 70,
                height: 70,
                decoration: const BoxDecoration(
                  color: Color(0xFFEAF3EB),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.calendar_month_rounded,
                  color: green,
                  size: 32,
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'Начните с первого объекта',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: ink,
                  fontSize: 19,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Добавьте квартиру или дом — здесь появится календарь бронирований.',
                textAlign: TextAlign.center,
                style: TextStyle(color: mutedInk, height: 1.45),
              ),
              const SizedBox(height: 20),
              FilledButton.icon(
                onPressed: _addRentalUnit,
                icon: const Icon(Icons.add_rounded),
                label: const Text('Добавить объект'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLegend(bool compact) {
    return Padding(
      padding: EdgeInsets.fromLTRB(compact ? 16 : 22, 2, 18, 10),
      child: Wrap(
        spacing: compact ? 6 : 10,
        runSpacing: 6,
        children: BookingStatus.values
            .map(
              (status) => _StatusLegendItem(status: status, compact: compact),
            )
            .toList(growable: false),
      ),
    );
  }

  Widget _buildCalendar(double screenWidth) {
    final leftWidth = _activeObjectColumnWidth;
    final dates = _dates;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        screenWidth < 520 ? 8 : 18,
        0,
        screenWidth < 520 ? 8 : 18,
        12,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildMonthHeader(screenWidth < 520),
          Expanded(
            child: Row(
              children: [
                SizedBox(
                  key: const ValueKey('calendar-object-column'),
                  width: leftWidth,
                  child: Column(
                    children: [
                      Container(
                        key: const ValueKey('calendar-corner-cell'),
                        width: double.infinity,
                        height: 56,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          border: Border(
                            bottom: BorderSide(color: line),
                            right: BorderSide(color: line),
                          ),
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(14),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Container(
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            border: Border(right: BorderSide(color: line)),
                            borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(14),
                            ),
                          ),
                          child: ListView.builder(
                            controller: _leftScrollController,
                            itemExtent: rowHeight,
                            itemCount: _units.length,
                            itemBuilder: (context, index) =>
                                _buildUnitLabel(_units[index]),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ClipRRect(
                    key: const ValueKey('calendar-date-viewport'),
                    borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(14),
                      bottomRight: Radius.circular(14),
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: const Border(
                          left: BorderSide(color: line),
                          right: BorderSide(color: line),
                          bottom: BorderSide(color: line),
                        ),
                      ),
                      child: SingleChildScrollView(
                        controller: _horizontalController,
                        scrollDirection: Axis.horizontal,
                        child: SizedBox(
                          width: dates.length * _dayWidth,
                          child: Column(
                            children: [
                              SizedBox(
                                height: 56,
                                child: Row(
                                  children: dates
                                      .map((date) => _buildDateHeader(date))
                                      .toList(growable: false),
                                ),
                              ),
                              Expanded(
                                child: ListView.builder(
                                  controller: _rightScrollController,
                                  itemExtent: rowHeight,
                                  itemCount: _units.length,
                                  itemBuilder: (context, index) =>
                                      _buildCalendarRow(_units[index], dates),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUnitLabel(RentalUnit unit) {
    const horizontalPadding = _unitColumnHorizontalPadding / 2;
    final availableWidth = _activeObjectColumnWidth - horizontalPadding * 2;
    final fontSize = _unitNameFontSize(
      unit.name,
      availableWidth: availableWidth,
      availableHeight: rowHeight,
    );
    return Container(
      height: rowHeight,
      padding: const EdgeInsets.symmetric(horizontal: horizontalPadding),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: line)),
      ),
      alignment: Alignment.centerLeft,
      child: Text(
        unit.name,
        softWrap: true,
        overflow: TextOverflow.clip,
        style: TextStyle(
          color: ink,
          fontSize: fontSize,
          fontWeight: FontWeight.w600,
          height: 1.2,
        ),
      ),
    );
  }

  double _unitNameFontSize(
    String name, {
    required double availableWidth,
    required double availableHeight,
  }) {
    const baseFontSize = 11.0;
    const labelStyle = TextStyle(
      color: ink,
      fontWeight: FontWeight.w600,
      height: 1.2,
    );
    final direction = Directionality.of(context);
    final textScaler = MediaQuery.textScalerOf(context);

    bool fits(double fontSize) {
      final style = labelStyle.copyWith(fontSize: fontSize);
      final words = name.trim().split(RegExp(r'\s+'));
      for (final word in words) {
        if (word.isEmpty) continue;
        final wordPainter = TextPainter(
          text: TextSpan(text: word, style: style),
          textDirection: direction,
          textScaler: textScaler,
          maxLines: 1,
        )..layout();
        final wordFits = wordPainter.width <= availableWidth;
        wordPainter.dispose();
        if (!wordFits) return false;
      }

      final textPainter = TextPainter(
        text: TextSpan(text: name, style: style),
        textDirection: direction,
        textScaler: textScaler,
      )..layout(maxWidth: availableWidth);
      final textFits = textPainter.height <= availableHeight;
      textPainter.dispose();
      return textFits;
    }

    if (fits(baseFontSize)) return baseFontSize;

    var low = 0.5;
    var high = baseFontSize;
    for (var iteration = 0; iteration < 16; iteration++) {
      final candidate = (low + high) / 2;
      if (fits(candidate)) {
        low = candidate;
      } else {
        high = candidate;
      }
    }
    return low;
  }

  Widget _buildDateHeader(DateTime date) {
    final isWeekend = date.weekday >= DateTime.saturday;
    final isToday = sameDay(date, _today());
    final background = isToday ? const Color(0xFFEAF3EB) : Colors.white;
    return Container(
      key: ValueKey(
        'calendar-date-header-${date.year}-${date.month}-${date.day}',
      ),
      width: _dayWidth,
      height: 56,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: background,
        border: const Border(
          bottom: BorderSide(color: line),
          right: BorderSide(color: line),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 1),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              DateFormat.E('ru').format(date).toUpperCase(),
              style: TextStyle(
                color: isWeekend ? const Color(0xFFB16B5F) : mutedInk,
                fontSize: 13,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              '${date.day}',
              style: TextStyle(
                color: isToday ? green : ink,
                fontSize: 24,
                fontWeight: isToday ? FontWeight.w800 : FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  double _objectColumnWidthForScreen(double screenWidth) => screenWidth * 0.15;

  Widget _buildCalendarRow(RentalUnit unit, List<DateTime> dates) {
    final unitBookings = _bookings
        .where(
          (booking) =>
              booking.rentalUnitId == unit.id &&
              booking.startDate.isBefore(_rangeEnd) &&
              booking.endDate.isAfter(_rangeStartMonth),
        )
        .toList(growable: false);
    final cells = <Widget>[];
    for (final date in dates) {
      final isSelected =
          _selection?.rentalUnitId == unit.id &&
          sameDay(_selection!.date, date);
      final isToday = sameDay(date, _today());
      final isWeekend = date.weekday >= DateTime.saturday;
      cells.add(
        SizedBox(
          width: _dayWidth,
          height: rowHeight,
          child: Material(
            color: isSelected
                ? const Color(0xFFDCEDE0)
                : isToday
                ? const Color(0xFFEAF3EB)
                : isWeekend
                ? const Color(0xFFFCFCFB)
                : Colors.white,
            child: InkWell(
              onTap: () => _tapCell(unit.id, date),
              child: Container(
                decoration: const BoxDecoration(
                  border: Border(
                    right: BorderSide(color: line),
                    bottom: BorderSide(color: line),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }

    final bookingCards = unitBookings
        .map((booking) {
          final startOffset = booking.startDate
              .difference(_rangeStartMonth)
              .inDays;
          final endOffset = booking.endDate.difference(_rangeStartMonth).inDays;
          final timelineWidth = dates.length * _dayWidth;
          final startPosition = startOffset < 0
              ? 0.0
              : startOffset * _dayWidth + _dayWidth / 2;
          final endPosition = endOffset >= dates.length
              ? timelineWidth
              : endOffset * _dayWidth + _dayWidth / 2;
          final bookingWidth = endPosition - startPosition;
          final horizontalInset = _dayWidth < 6 ? 0.0 : 3.0;
          final left = startPosition + horizontalInset;
          final width = bookingWidth - horizontalInset * 2;
          final palette = statusPalette(booking.status);
          final compactCard = width < 38;
          final cardName = booking.clientName.isEmpty
              ? 'Б'
              : compactCard
              ? booking.clientName.characters.first
              : booking.clientName;
          final cardSummary = compactCard
              ? '${booking.nights}н·${booking.guests + booking.children}ч'
              : '${booking.nights}н · ${booking.guests + booking.children}ч';

          return Positioned(
            left: left,
            top: 8,
            width: width,
            height: rowHeight - 16,
            child: Material(
              color: palette.background,
              borderRadius: BorderRadius.circular(10),
              child: InkWell(
                borderRadius: BorderRadius.circular(10),
                onTap: () => _editBooking(booking),
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: width < 38
                        ? 1
                        : width < 60
                        ? 3
                        : 7,
                    vertical: width < 38 ? 2 : 6,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: palette.border),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x0D1E3223),
                        blurRadius: 5,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: width < 112
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              cardName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: palette.foreground,
                                fontSize: compactCard ? 7 : 9,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            Text(
                              cardSummary,
                              maxLines: 1,
                              overflow: TextOverflow.clip,
                              style: TextStyle(
                                color: palette.foreground,
                                fontSize: compactCard ? 7 : 9,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              booking.clientName.isEmpty
                                  ? 'Новое бронирование'
                                  : booking.clientName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: palette.foreground,
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              '${nightLabel(booking.nights)} · ${booking.guests + booking.children} чел.',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: palette.foreground.withValues(
                                  alpha: 0.86,
                                ),
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ),
          );
        })
        .toList(growable: false);

    return SizedBox(
      width: dates.length * _dayWidth,
      height: rowHeight,
      child: Stack(
        clipBehavior: Clip.hardEdge,
        children: [
          Row(children: cells),
          ...bookingCards,
        ],
      ),
    );
  }

  DateTime _today() {
    final now = DateTime.now();
    return DateTime.utc(now.year, now.month, now.day);
  }
}

class _AddRentalUnitDialog extends StatefulWidget {
  const _AddRentalUnitDialog();

  @override
  State<_AddRentalUnitDialog> createState() => _AddRentalUnitDialogState();
}

class _AddRentalUnitDialogState extends State<_AddRentalUnitDialog> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Новый объект'),
      content: TextField(
        controller: _controller,
        autofocus: true,
        textCapitalization: TextCapitalization.sentences,
        decoration: const InputDecoration(
          labelText: 'Название объекта',
          hintText: 'Например, Апартаменты у моря',
        ),
        onSubmitted: (value) => Navigator.of(context).pop(value),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Отмена'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(_controller.text),
          child: const Text('Добавить'),
        ),
      ],
    );
  }
}

class _StatusLegendItem extends StatelessWidget {
  const _StatusLegendItem({required this.status, required this.compact});

  final BookingStatus status;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final palette = statusPalette(status);
    return Container(
      padding: EdgeInsets.symmetric(horizontal: compact ? 8 : 10, vertical: 6),
      decoration: BoxDecoration(
        color: palette.background,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: palette.border),
      ),
      child: Text(
        status.label,
        style: TextStyle(
          color: palette.foreground,
          fontSize: compact ? 10 : 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
