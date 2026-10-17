import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart';

import 'data/local/app_database.dart';
import 'data/repositories/drift_booking_repository.dart';
import 'domain/entities/booking.dart';
import 'domain/entities/rental_unit.dart';
import 'domain/repositories/booking_repository.dart';
import 'domain/usecases/booking_use_cases.dart';

const _ink = Color(0xFF202923);
const _mutedInk = Color(0xFF748078);
const _green = Color(0xFF2E7652);
const _line = Color(0xFFE5EAE4);
const _page = Color(0xFFF6F8F5);
const _dayWidth = 66.0;
const _rowHeight = 78.0;

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  final database = AppDatabase();
  final useCases = BookingUseCases(DriftBookingRepository(database));
  runApp(MangoRentApp(useCases: useCases));
}

class MangoRentApp extends StatelessWidget {
  const MangoRentApp({super.key, required this.useCases});

  final BookingUseCases useCases;

  @override
  Widget build(BuildContext context) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: _green,
      primary: _green,
      surface: Colors.white,
      brightness: Brightness.light,
    );

    return MaterialApp(
      title: 'Mango Rent',
      debugShowCheckedModeBanner: false,
      locale: const Locale('ru'),
      supportedLocales: const [Locale('ru')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: colorScheme,
        scaffoldBackgroundColor: _page,
        fontFamily: 'Roboto',
        textTheme: const TextTheme(
          headlineSmall: TextStyle(
            color: _ink,
            fontSize: 22,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.4,
          ),
          titleMedium: TextStyle(color: _ink, fontWeight: FontWeight.w600),
          bodyMedium: TextStyle(color: _ink),
          bodySmall: TextStyle(color: _mutedInk),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFFFAFBF9),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 13,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: _line),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: _line),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: _green, width: 1.5),
          ),
        ),
      ),
      home: CalendarPage(useCases: useCases),
    );
  }
}

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key, required this.useCases});

  final BookingUseCases useCases;

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  late DateTime _month;
  late final ScrollController _leftScrollController;
  late final ScrollController _rightScrollController;
  late final ScrollController _horizontalController;
  StreamSubscription<List<RentalUnit>>? _unitsSubscription;
  StreamSubscription<List<Booking>>? _bookingsSubscription;

  List<RentalUnit> _units = const [];
  List<Booking> _bookings = const [];
  _CellSelection? _selection;
  bool _loading = true;
  bool _syncingScroll = false;
  bool _initialScrollQueued = false;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _month = DateTime.utc(now.year, now.month);
    _leftScrollController = ScrollController()..addListener(_syncLeftToRight);
    _rightScrollController = ScrollController()..addListener(_syncRightToLeft);
    _horizontalController = ScrollController();

    _unitsSubscription = widget.useCases.watchRentalUnits().listen(
      (units) {
        if (!mounted) return;
        setState(() {
          _units = units;
          _loading = false;
        });
      },
      onError: (Object error) =>
          _showSnack('Не удалось загрузить объекты: $error'),
    );
    _bookingsSubscription = widget.useCases.watchBookings().listen(
      (bookings) {
        if (!mounted) return;
        setState(() => _bookings = bookings);
      },
      onError: (Object error) =>
          _showSnack('Не удалось загрузить бронирования: $error'),
    );
  }

  @override
  void dispose() {
    _unitsSubscription?.cancel();
    _bookingsSubscription?.cancel();
    _leftScrollController
      ..removeListener(_syncLeftToRight)
      ..dispose();
    _rightScrollController
      ..removeListener(_syncRightToLeft)
      ..dispose();
    _horizontalController.dispose();
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

  List<DateTime> get _dates {
    final count = DateTime.utc(
      _month.year,
      _month.month + 1,
    ).difference(_month).inDays;
    return List.generate(count, (index) => _month.add(Duration(days: index)));
  }

  DateTime get _monthEnd => DateTime.utc(_month.year, _month.month + 1);

  void _changeMonth(int offset) {
    setState(() {
      _month = DateTime.utc(_month.year, _month.month + offset);
      _selection = null;
    });
    if (_horizontalController.hasClients) _horizontalController.jumpTo(0);
  }

  void _goToToday() {
    final now = DateTime.now();
    setState(() {
      _month = DateTime.utc(now.year, now.month);
      _selection = null;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToToday());
  }

  void _scrollToToday() {
    if (!_horizontalController.hasClients) return;
    final desiredOffset = (_today().day - 3) * _dayWidth;
    final offset = desiredOffset
        .clamp(0.0, _horizontalController.position.maxScrollExtent)
        .toDouble();
    _horizontalController.jumpTo(offset);
  }

  void _showSnack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _addRentalUnit() async {
    final controller = TextEditingController();
    final name = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Новый объект'),
        content: TextField(
          controller: controller,
          autofocus: true,
          textCapitalization: TextCapitalization.sentences,
          decoration: const InputDecoration(
            labelText: 'Название объекта',
            hintText: 'Например, Апартаменты у моря',
          ),
          onSubmitted: (value) => Navigator.of(dialogContext).pop(value),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Отмена'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(controller.text),
            child: const Text('Добавить'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (name == null) return;
    if (name.trim().isEmpty) {
      _showSnack('Введите название объекта.');
      return;
    }
    await widget.useCases.addRentalUnit(name);
  }

  Future<void> _tapCell(int rentalUnitId, DateTime date) async {
    final selected = _selection;
    if (selected == null) {
      setState(() => _selection = _CellSelection(rentalUnitId, date));
      return;
    }
    if (selected.rentalUnitId != rentalUnitId) {
      setState(() => _selection = _CellSelection(rentalUnitId, date));
      return;
    }

    setState(() => _selection = null);
    final first = selected.date.isBefore(date) ? selected.date : date;
    final last = selected.date.isAfter(date) ? selected.date : date;
    final booking = Booking(
      id: null,
      rentalUnitId: rentalUnitId,
      startDate: first,
      endDate: last.add(const Duration(days: 1)),
    );

    try {
      final saved = await widget.useCases.saveBooking(booking);
      if (!mounted) return;
      final matchingUnits = _units.where((unit) => unit.id == rentalUnitId);
      final unitName = matchingUnits.isEmpty ? '' : matchingUnits.first.name;
      await _openBookingEditor(saved, unitName);
    } on BookingConflictException {
      _showSnack('В выбранном диапазоне уже есть бронирование.');
    } catch (error) {
      _showSnack('Не удалось создать бронирование: $error');
    }
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
    final matchingUnits = _units.where(
      (unit) => unit.id == booking.rentalUnitId,
    );
    final unitName = matchingUnits.isEmpty ? '' : matchingUnits.first.name;
    await _openBookingEditor(booking, unitName);
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final compact = width < 520;
    if (_units.isNotEmpty && !_initialScrollQueued) {
      _initialScrollQueued = true;
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToToday());
    }

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildToolbar(compact),
            _buildSectionHeading(compact),
            if (_loading)
              const Expanded(child: Center(child: CircularProgressIndicator()))
            else if (_units.isEmpty)
              Expanded(child: _buildEmptyState())
            else ...[
              _buildLegend(compact),
              Expanded(child: _buildCalendar(width)),
              if (_selection != null)
                const Padding(
                  padding: EdgeInsets.fromLTRB(16, 0, 16, 10),
                  child: Text(
                    'Выберите вторую дату в той же строке',
                    style: TextStyle(
                      color: _green,
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
  }

  Widget _buildToolbar(bool compact) {
    final monthText = compact
        ? DateFormat('MMM yyyy', 'ru').format(_month)
        : DateFormat.yMMMM('ru').format(_month);
    final formattedMonth = monthText.isEmpty
        ? monthText
        : '${monthText[0].toUpperCase()}${monthText.substring(1)}';

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
            child: const Icon(Icons.spa_rounded, color: _green, size: 21),
          ),
          const SizedBox(width: 9),
          Text(
            compact ? 'Mango' : 'Mango rent',
            style: const TextStyle(
              color: _ink,
              fontWeight: FontWeight.w800,
              fontSize: 18,
              letterSpacing: -0.5,
            ),
          ),
          const Spacer(),
          IconButton(
            visualDensity: VisualDensity.compact,
            tooltip: 'Предыдущий месяц',
            onPressed: () => _changeMonth(-1),
            icon: const Icon(Icons.chevron_left_rounded),
          ),
          ConstrainedBox(
            constraints: BoxConstraints(maxWidth: compact ? 90 : 150),
            child: Text(
              formattedMonth,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: _ink,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          IconButton(
            visualDensity: VisualDensity.compact,
            tooltip: 'Следующий месяц',
            onPressed: () => _changeMonth(1),
            icon: const Icon(Icons.chevron_right_rounded),
          ),
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

  Widget _buildSectionHeading(bool compact) {
    return Padding(
      padding: EdgeInsets.fromLTRB(compact ? 18 : 22, 9, compact ? 14 : 22, 9),
      child: Row(
        children: [
          const Text(
            'Объекты',
            style: TextStyle(
              color: _ink,
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
                style: const TextStyle(color: _mutedInk, fontSize: 12),
              ),
            ),
          const Spacer(),
          FilledButton.tonalIcon(
            onPressed: _addRentalUnit,
            icon: const Icon(Icons.add_rounded, size: 18),
            label: Text(compact ? 'Добавить' : 'Добавить объект'),
            style: FilledButton.styleFrom(
              foregroundColor: _green,
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
            border: Border.all(color: _line),
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
                  color: _green,
                  size: 32,
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'Начните с первого объекта',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: _ink,
                  fontSize: 19,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Добавьте квартиру или дом — здесь появится календарь бронирований.',
                textAlign: TextAlign.center,
                style: TextStyle(color: _mutedInk, height: 1.45),
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
    final leftWidth = screenWidth >= 760 ? 198.0 : 142.0;
    final dates = _dates;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        screenWidth < 520 ? 8 : 18,
        0,
        screenWidth < 520 ? 8 : 18,
        12,
      ),
      child: Row(
        children: [
          SizedBox(
            width: leftWidth,
            child: Column(
              children: [
                Container(
                  height: 56,
                  padding: const EdgeInsets.only(left: 14, bottom: 2),
                  alignment: Alignment.centerLeft,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    border: Border(
                      bottom: BorderSide(color: _line),
                      right: BorderSide(color: _line),
                    ),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(14),
                    ),
                  ),
                  child: const Text(
                    'ОБЪЕКТ',
                    style: TextStyle(
                      color: _mutedInk,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      border: Border(right: BorderSide(color: _line)),
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(14),
                      ),
                    ),
                    child: ListView.builder(
                      controller: _leftScrollController,
                      itemExtent: _rowHeight,
                      itemCount: _units.length,
                      itemBuilder: (context, index) =>
                          _buildUnitLabel(_units[index], index),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(14),
                bottomRight: Radius.circular(14),
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: _line),
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
                            itemExtent: _rowHeight,
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
    );
  }

  Widget _buildUnitLabel(RentalUnit unit, int index) {
    final initials = unit.name.trim().isEmpty
        ? '•'
        : unit.name.trim().characters.first.toUpperCase();
    return Container(
      height: _rowHeight,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: _line)),
      ),
      child: Row(
        children: [
          Container(
            width: 31,
            height: 31,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: index.isEven
                  ? const Color(0xFFE9F2EB)
                  : const Color(0xFFF1EEE6),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              initials,
              maxLines: 1,
              style: const TextStyle(
                color: _green,
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              unit.name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: _ink,
                fontSize: 12,
                fontWeight: FontWeight.w600,
                height: 1.2,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateHeader(DateTime date) {
    final isWeekend = date.weekday >= DateTime.saturday;
    final isToday = _sameDay(date, _today());
    final background = isToday ? const Color(0xFFEAF3EB) : Colors.white;
    return Container(
      width: _dayWidth,
      height: 56,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: background,
        border: const Border(
          bottom: BorderSide(color: _line),
          right: BorderSide(color: _line),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            DateFormat.E('ru').format(date).toUpperCase(),
            style: TextStyle(
              color: isWeekend ? const Color(0xFFB16B5F) : _mutedInk,
              fontSize: 9,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            '${date.day}',
            style: TextStyle(
              color: isToday ? _green : _ink,
              fontSize: 14,
              fontWeight: isToday ? FontWeight.w800 : FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarRow(RentalUnit unit, List<DateTime> dates) {
    final unitBookings = _bookings
        .where(
          (booking) =>
              booking.rentalUnitId == unit.id &&
              booking.startDate.isBefore(_monthEnd) &&
              booking.endDate.isAfter(_month),
        )
        .toList(growable: false);
    final cells = <Widget>[];
    for (final date in dates) {
      final isSelected =
          _selection?.rentalUnitId == unit.id &&
          _sameDay(_selection!.date, date);
      final isWeekend = date.weekday >= DateTime.saturday;
      cells.add(
        SizedBox(
          width: _dayWidth,
          height: _rowHeight,
          child: Material(
            color: isSelected
                ? const Color(0xFFDCEDE0)
                : isWeekend
                ? const Color(0xFFFCFCFB)
                : Colors.white,
            child: InkWell(
              onTap: () => _tapCell(unit.id, date),
              child: Container(
                decoration: const BoxDecoration(
                  border: Border(
                    right: BorderSide(color: _line),
                    bottom: BorderSide(color: _line),
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
          final startOffset = booking.startDate.difference(_month).inDays;
          final endOffset = booking.endDate.difference(_month).inDays;
          final startIndex = startOffset.clamp(0, dates.length).toInt();
          final endIndex = endOffset.clamp(0, dates.length).toInt();
          final visibleDays = (endIndex - startIndex)
              .clamp(1, dates.length)
              .toInt();
          final left = startIndex * _dayWidth + 3;
          final width = visibleDays * _dayWidth - 6;
          final palette = _statusPalette(booking.status);

          return Positioned(
            left: left,
            top: 8,
            width: width,
            height: _rowHeight - 16,
            child: Material(
              color: palette.background,
              borderRadius: BorderRadius.circular(10),
              child: InkWell(
                borderRadius: BorderRadius.circular(10),
                onTap: () => _editBooking(booking),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 7,
                    vertical: 6,
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
                              booking.clientName.isEmpty
                                  ? 'Бронь'
                                  : booking.clientName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: palette.foreground,
                                fontSize: 9,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            Text(
                              '${booking.nights}н · ${booking.guests + booking.children}ч',
                              maxLines: 1,
                              style: TextStyle(
                                color: palette.foreground,
                                fontSize: 9,
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
                              '${_nightLabel(booking.nights)} · ${booking.guests + booking.children} чел.',
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
      height: _rowHeight,
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

class _CellSelection {
  const _CellSelection(this.rentalUnitId, this.date);

  final int rentalUnitId;
  final DateTime date;
}

class _StatusLegendItem extends StatelessWidget {
  const _StatusLegendItem({required this.status, required this.compact});

  final BookingStatus status;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final palette = _statusPalette(status);
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

class BookingEditorSheet extends StatefulWidget {
  const BookingEditorSheet({
    super.key,
    required this.initialBooking,
    required this.unitName,
    required this.useCases,
  });

  final Booking initialBooking;
  final String unitName;
  final BookingUseCases useCases;

  @override
  State<BookingEditorSheet> createState() => _BookingEditorSheetState();
}

class _BookingEditorSheetState extends State<BookingEditorSheet> {
  late Booking _booking;
  Future<void> _writeQueue = Future<void>.value();

  @override
  void initState() {
    super.initState();
    _booking = widget.initialBooking;
  }

  void _change(Booking updated) {
    setState(() => _booking = updated);
    _writeQueue = _writeQueue
        .catchError((Object _) {})
        .then((_) => widget.useCases.saveBooking(updated))
        .then<void>((_) {})
        .catchError((Object error) {
          if (!mounted) return;
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(content: Text('Не удалось сохранить: $error')),
            );
        });
  }

  Future<void> _pickStartDate() async {
    final selected = await showDatePicker(
      context: context,
      initialDate: _asLocalDate(_booking.startDate),
      firstDate: DateTime(2000),
      lastDate: DateTime(2120),
      helpText: 'Дата заезда',
      cancelText: 'Отмена',
      confirmText: 'Выбрать',
    );
    if (selected == null) return;
    final newStart = DateTime.utc(selected.year, selected.month, selected.day);
    final duration = _booking.nights < 1 ? 1 : _booking.nights;
    _change(
      _booking.copyWith(
        startDate: newStart,
        endDate: newStart.add(Duration(days: duration)),
      ),
    );
  }

  Future<void> _pickEndDate() async {
    final minDate = _booking.startDate.add(const Duration(days: 1));
    final selected = await showDatePicker(
      context: context,
      initialDate: _asLocalDate(
        _booking.endDate.isAfter(_booking.startDate)
            ? _booking.endDate
            : minDate,
      ),
      firstDate: _asLocalDate(minDate),
      lastDate: DateTime(2120),
      helpText: 'Дата выезда',
      cancelText: 'Отмена',
      confirmText: 'Выбрать',
    );
    if (selected == null) return;
    final newEnd = DateTime.utc(selected.year, selected.month, selected.day);
    _change(_booking.copyWith(endDate: newEnd));
  }

  Future<void> _deleteBooking() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Удалить бронирование?'),
        content: const Text('Запись будет удалена из календаря.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Отмена'),
          ),
          FilledButton.tonal(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(
              foregroundColor: const Color(0xFFB54135),
            ),
            child: const Text('Удалить'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await _writeQueue;
    final id = _booking.id;
    if (id != null) await widget.useCases.deleteBooking(id);
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final viewInsets = MediaQuery.viewInsetsOf(context);
    final screenHeight = MediaQuery.sizeOf(context).height;
    final availableHeight = (screenHeight - viewInsets.bottom)
        .clamp(320.0, screenHeight)
        .toDouble();
    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: EdgeInsets.only(bottom: viewInsets.bottom),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 620),
          height: availableHeight * 0.92,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 10),
              Container(
                width: 38,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFD8DED8),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 12, 10),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Бронирование',
                            style: TextStyle(
                              color: _ink,
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          if (widget.unitName.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 3),
                              child: Text(
                                widget.unitName,
                                style: const TextStyle(
                                  color: _mutedInk,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    IconButton(
                      tooltip: 'Закрыть',
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close_rounded),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, color: _line),
              Expanded(
                child: SingleChildScrollView(
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 26),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _sectionLabel('ДАТЫ ПРОЖИВАНИЯ'),
                      const SizedBox(height: 8),
                      _buildDatesCard(),
                      const SizedBox(height: 19),
                      _sectionLabel('СТАТУС'),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<BookingStatus>(
                        initialValue: _booking.status,
                        decoration: const InputDecoration(
                          labelText: 'Статус оплаты',
                        ),
                        items: BookingStatus.values
                            .map(
                              (status) => DropdownMenuItem(
                                value: status,
                                child: Text(status.label),
                              ),
                            )
                            .toList(growable: false),
                        onChanged: (status) {
                          if (status != null) {
                            _change(_booking.copyWith(status: status));
                          }
                        },
                      ),
                      const SizedBox(height: 19),
                      _sectionLabel('КЛИЕНТ'),
                      const SizedBox(height: 8),
                      TextFormField(
                        initialValue: _booking.clientName,
                        textCapitalization: TextCapitalization.words,
                        decoration: const InputDecoration(
                          labelText: 'Имя клиента',
                        ),
                        onChanged: (value) =>
                            _change(_booking.copyWith(clientName: value)),
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        initialValue: _booking.clientPhone,
                        keyboardType: TextInputType.phone,
                        decoration: const InputDecoration(
                          labelText: 'Номер клиента',
                          prefixIcon: Icon(Icons.phone_outlined),
                        ),
                        onChanged: (value) =>
                            _change(_booking.copyWith(clientPhone: value)),
                      ),
                      const SizedBox(height: 19),
                      _sectionLabel('ОПЛАТА'),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              initialValue: _booking.amount == null
                                  ? ''
                                  : _amountText(_booking.amount!),
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                    decimal: true,
                                  ),
                              decoration: const InputDecoration(
                                labelText: 'Сумма',
                              ),
                              onChanged: (value) {
                                final normalized = value
                                    .replaceAll(',', '.')
                                    .trim();
                                final parsed = double.tryParse(normalized);
                                _change(
                                  _booking.copyWith(
                                    amount: parsed,
                                    clearAmount: normalized.isEmpty,
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextFormField(
                              initialValue: _booking.deposit,
                              decoration: const InputDecoration(
                                labelText: 'Залог / предоплата',
                              ),
                              onChanged: (value) =>
                                  _change(_booking.copyWith(deposit: value)),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 19),
                      _sectionLabel('ГОСТИ'),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              initialValue: '${_booking.guests}',
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: 'Количество человек',
                              ),
                              onChanged: (value) => _change(
                                _booking.copyWith(
                                  guests: int.tryParse(value) ?? 0,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextFormField(
                              initialValue: '${_booking.children}',
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: 'Количество детей',
                              ),
                              onChanged: (value) => _change(
                                _booking.copyWith(
                                  children: int.tryParse(value) ?? 0,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      SwitchListTile.adaptive(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 2,
                        ),
                        title: const Text(
                          'Гости с животными',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        subtitle: Text(
                          _booking.hasPets ? 'С животными' : 'Без животных',
                          style: const TextStyle(
                            fontSize: 12,
                            color: _mutedInk,
                          ),
                        ),
                        value: _booking.hasPets,
                        activeTrackColor: const Color(0xFFBBD8C2),
                        activeThumbColor: _green,
                        onChanged: (value) =>
                            _change(_booking.copyWith(hasPets: value)),
                      ),
                      const SizedBox(height: 14),
                      _sectionLabel('ИСТОЧНИК И КОММЕНТАРИЙ'),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String?>(
                        initialValue: _booking.source,
                        decoration: const InputDecoration(
                          labelText: 'Откуда бронь',
                        ),
                        items: const [
                          DropdownMenuItem<String?>(
                            value: null,
                            child: Text('Не указано'),
                          ),
                          DropdownMenuItem<String?>(
                            value: 'Booking.com',
                            child: Text('Booking.com'),
                          ),
                          DropdownMenuItem<String?>(
                            value: 'Airbnb',
                            child: Text('Airbnb'),
                          ),
                          DropdownMenuItem<String?>(
                            value: 'Авито',
                            child: Text('Авито'),
                          ),
                          DropdownMenuItem<String?>(
                            value: 'Сайт',
                            child: Text('Сайт'),
                          ),
                          DropdownMenuItem<String?>(
                            value: 'Прямое обращение',
                            child: Text('Прямое обращение'),
                          ),
                          DropdownMenuItem<String?>(
                            value: 'Другое',
                            child: Text('Другое'),
                          ),
                        ],
                        onChanged: (value) => _change(
                          _booking.copyWith(
                            source: value,
                            clearSource: value == null,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        initialValue: _booking.comment,
                        minLines: 3,
                        maxLines: 5,
                        textCapitalization: TextCapitalization.sentences,
                        decoration: const InputDecoration(
                          labelText: 'Комментарий',
                          alignLabelWithHint: true,
                        ),
                        onChanged: (value) =>
                            _change(_booking.copyWith(comment: value)),
                      ),
                      const SizedBox(height: 18),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 13,
                          vertical: 11,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F6F1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Row(
                          children: [
                            Icon(
                              Icons.cloud_done_outlined,
                              size: 17,
                              color: _green,
                            ),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Изменения сохраняются автоматически',
                                style: TextStyle(
                                  color: _green,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: TextButton.icon(
                          onPressed: _deleteBooking,
                          icon: const Icon(Icons.delete_outline_rounded),
                          label: const Text('Удалить бронирование'),
                          style: TextButton.styleFrom(
                            foregroundColor: const Color(0xFFB54135),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDatesCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F7F2),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: const Color(0xFFE2ECE3)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _datePickerTile(
                  'Заезд',
                  _booking.startDate,
                  _pickStartDate,
                ),
              ),
              Container(
                width: 1,
                height: 42,
                margin: const EdgeInsets.symmetric(horizontal: 12),
                color: const Color(0xFFDDE8DE),
              ),
              Expanded(
                child: _datePickerTile('Выезд', _booking.endDate, _pickEndDate),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              _nightLabel(_booking.nights),
              style: const TextStyle(
                color: _green,
                fontWeight: FontWeight.w800,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _datePickerTile(String label, DateTime date, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 3),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(color: _mutedInk, fontSize: 11)),
            const SizedBox(height: 4),
            Row(
              children: [
                Expanded(
                  child: Text(
                    DateFormat('d MMM yyyy', 'ru').format(_asLocalDate(date)),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: _ink,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const Icon(
                  Icons.edit_calendar_outlined,
                  size: 16,
                  color: _green,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionLabel(String label) => Text(
    label,
    style: const TextStyle(
      color: _mutedInk,
      fontSize: 10,
      fontWeight: FontWeight.w800,
      letterSpacing: 1,
    ),
  );
}

class _StatusPalette {
  const _StatusPalette({
    required this.background,
    required this.foreground,
    required this.border,
  });

  final Color background;
  final Color foreground;
  final Color border;
}

_StatusPalette _statusPalette(BookingStatus status) {
  return switch (status) {
    BookingStatus.unpaid => const _StatusPalette(
      background: Color(0xFFFFF1DF),
      foreground: Color(0xFF8D5A16),
      border: Color(0xFFF2D5AC),
    ),
    BookingStatus.depositPaid => const _StatusPalette(
      background: Color(0xFFE8F2FC),
      foreground: Color(0xFF2F6798),
      border: Color(0xFFC8DCEE),
    ),
    BookingStatus.paid => const _StatusPalette(
      background: Color(0xFFE7F4E8),
      foreground: Color(0xFF34734B),
      border: Color(0xFFC9E2CD),
    ),
    BookingStatus.closed => const _StatusPalette(
      background: Color(0xFFEDEFEF),
      foreground: Color(0xFF636D68),
      border: Color(0xFFD8DDDA),
    ),
  };
}

DateTime _asLocalDate(DateTime date) =>
    DateTime(date.year, date.month, date.day);

bool _sameDay(DateTime first, DateTime second) =>
    first.year == second.year &&
    first.month == second.month &&
    first.day == second.day;

String _nightLabel(int nights) {
  final mod10 = nights % 10;
  final mod100 = nights % 100;
  final suffix = mod100 >= 11 && mod100 <= 14
      ? 'ночей'
      : mod10 == 1
      ? 'ночь'
      : mod10 >= 2 && mod10 <= 4
      ? 'ночи'
      : 'ночей';
  return '$nights $suffix';
}

String _amountText(double amount) => amount == amount.roundToDouble()
    ? amount.toStringAsFixed(0)
    : amount.toString();
