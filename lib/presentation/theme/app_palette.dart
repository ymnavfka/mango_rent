import 'package:flutter/material.dart';

import '../../domain/entities/booking.dart';

const ink = Color(0xFF202923);
const mutedInk = Color(0xFF748078);
const green = Color(0xFF2E7652);
const line = Color(0xFFE5EAE4);
const page = Color(0xFFF6F8F5);
const rowHeight = 78.0;

double objectColumnWidthForScreen(double screenWidth) {
  if (screenWidth < 520) return 45;
  if (screenWidth < 760) return 60;
  if (screenWidth < 1200) return 77;
  return 90;
}

double dayWidthForScreen(double screenWidth) {
  final horizontalPadding = screenWidth < 520 ? 16.0 : 36.0;
  final objectColumnWidth = objectColumnWidthForScreen(screenWidth);
  final availableWidth =
      screenWidth - horizontalPadding - objectColumnWidth - 2;
  final preferredWidth = screenWidth < 520
      ? 44.0
      : screenWidth < 800
      ? 46.0
      : screenWidth < 1200
      ? 48.0
      : 52.0;

  return (availableWidth / 9).clamp(1.0, preferredWidth).toDouble();
}

class StatusPalette {
  const StatusPalette({
    required this.background,
    required this.foreground,
    required this.border,
  });

  final Color background;
  final Color foreground;
  final Color border;
}

StatusPalette statusPalette(BookingStatus status) {
  return switch (status) {
    BookingStatus.unpaid => const StatusPalette(
      background: Color(0xFFFFF1DF),
      foreground: Color(0xFF8D5A16),
      border: Color(0xFFF2D5AC),
    ),
    BookingStatus.depositPaid => const StatusPalette(
      background: Color(0xFFE8F2FC),
      foreground: Color(0xFF2F6798),
      border: Color(0xFFC8DCEE),
    ),
    BookingStatus.paid => const StatusPalette(
      background: Color(0xFFE7F4E8),
      foreground: Color(0xFF34734B),
      border: Color(0xFFC9E2CD),
    ),
    BookingStatus.closed => const StatusPalette(
      background: Color(0xFFEDEFEF),
      foreground: Color(0xFF636D68),
      border: Color(0xFFD8DDDA),
    ),
  };
}

DateTime asLocalDate(DateTime date) =>
    DateTime(date.year, date.month, date.day);

bool sameDay(DateTime first, DateTime second) =>
    first.year == second.year &&
    first.month == second.month &&
    first.day == second.day;

String nightLabel(int nights) {
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

String amountText(double amount) => amount == amount.roundToDouble()
    ? amount.toStringAsFixed(0)
    : amount.toString();
