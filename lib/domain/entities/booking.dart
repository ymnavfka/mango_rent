import '../rules/calendar_day.dart';

enum BookingStatus {
  unpaid,
  depositPaid,
  paid,
  closed,
}

class Booking {
  const Booking({
    required this.id,
    required this.rentalUnitId,
    required this.startDate,
    required this.endDate,
    this.status = BookingStatus.unpaid,
    this.clientName = '',
    this.clientPhone = '',
    this.amount,
    this.deposit = '',
    this.guests = 1,
    this.children = 0,
    this.hasPets = false,
    this.source,
    this.comment = '',
  });

  final int? id;
  final int rentalUnitId;

  final DateTime startDate; // Check-in; inclusive.
  final DateTime endDate; // Checkout; exclusive.

  final BookingStatus status;
  final String clientName;
  final String clientPhone;
  final double? amount;
  final String deposit;
  final int guests;
  final int children;
  final bool hasPets;
  final String? source;
  final String comment;

  int get nights =>
      calendarDay(endDate).difference(calendarDay(startDate)).inDays;

  Booking copyWith({
    int? id,
    int? rentalUnitId,
    DateTime? startDate,
    DateTime? endDate,
    BookingStatus? status,
    String? clientName,
    String? clientPhone,
    double? amount,
    bool clearAmount = false,
    String? deposit,
    int? guests,
    int? children,
    bool? hasPets,
    String? source,
    bool clearSource = false,
    String? comment,
  }) {
    return Booking(
      id: id ?? this.id,
      rentalUnitId: rentalUnitId ?? this.rentalUnitId,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      status: status ?? this.status,
      clientName: clientName ?? this.clientName,
      clientPhone: clientPhone ?? this.clientPhone,
      amount: clearAmount ? null : amount ?? this.amount,
      deposit: deposit ?? this.deposit,
      guests: guests ?? this.guests,
      children: children ?? this.children,
      hasPets: hasPets ?? this.hasPets,
      source: clearSource ? null : source ?? this.source,
      comment: comment ?? this.comment,
    );
  }
}
