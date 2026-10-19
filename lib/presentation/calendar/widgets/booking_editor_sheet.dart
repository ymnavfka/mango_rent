import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../domain/entities/booking.dart';
import '../../../domain/usecases/booking_use_cases.dart';
import '../../theme/app_palette.dart';
import '../cubit/booking_editor_cubit.dart';

class BookingEditorSheet extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          BookingEditorCubit(booking: initialBooking, useCases: useCases),
      child: _BookingEditorView(unitName: unitName),
    );
  }
}

class _BookingEditorView extends StatefulWidget {
  const _BookingEditorView({required this.unitName});

  final String unitName;

  @override
  State<_BookingEditorView> createState() => _BookingEditorViewState();
}

class _BookingEditorViewState extends State<_BookingEditorView> {
  Booking get _booking => context.read<BookingEditorCubit>().state.booking;

  void _change(Booking updated) =>
      context.read<BookingEditorCubit>().change(updated);

  Future<void> _pickStartDate() async {
    final selected = await showDatePicker(
      context: context,
      initialDate: asLocalDate(_booking.startDate),
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
      initialDate: asLocalDate(
        _booking.endDate.isAfter(_booking.startDate)
            ? _booking.endDate
            : minDate,
      ),
      firstDate: asLocalDate(minDate),
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
    final editor = context.read<BookingEditorCubit>();
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
    await editor.deleteBooking();
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<BookingEditorCubit, BookingEditorState>(
      listenWhen: (previous, current) => current.notice != null,
      listener: (context, state) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(state.notice!)));
        context.read<BookingEditorCubit>().clearNotice();
      },
      child: BlocBuilder<BookingEditorCubit, BookingEditorState>(
        builder: (context, _) => _buildEditor(),
      ),
    );
  }

  Widget _buildEditor() {
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
                              color: ink,
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
                                  color: mutedInk,
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
              const Divider(height: 1, color: line),
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
                        items: BookingStatus.values.map((status) {
                          final palette = statusPalette(status);
                          return DropdownMenuItem(
                            value: status,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  key: ValueKey(
                                    'booking-status-color-${status.storageValue}',
                                  ),
                                  width: 14,
                                  height: 14,
                                  decoration: BoxDecoration(
                                    color: palette.background,
                                    border: Border.all(color: palette.border),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  status.label,
                                  style: TextStyle(color: palette.foreground),
                                ),
                              ],
                            ),
                          );
                        }).toList(growable: false),
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
                                  : amountText(_booking.amount!),
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
                          style: const TextStyle(fontSize: 12, color: mutedInk),
                        ),
                        value: _booking.hasPets,
                        activeTrackColor: const Color(0xFFBBD8C2),
                        activeThumbColor: green,
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
                              color: green,
                            ),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Изменения сохраняются автоматически',
                                style: TextStyle(
                                  color: green,
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
              nightLabel(_booking.nights),
              style: const TextStyle(
                color: green,
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
            Text(label, style: const TextStyle(color: mutedInk, fontSize: 11)),
            const SizedBox(height: 4),
            Row(
              children: [
                Expanded(
                  child: Text(
                    DateFormat('d MMM yyyy', 'ru').format(asLocalDate(date)),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: ink,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const Icon(
                  Icons.edit_calendar_outlined,
                  size: 16,
                  color: green,
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
      color: mutedInk,
      fontSize: 10,
      fontWeight: FontWeight.w800,
      letterSpacing: 1,
    ),
  );
}
