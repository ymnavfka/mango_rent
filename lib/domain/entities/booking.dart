enum BookingStatus {
  unpaid('Не оплачено', 'unpaid'),
  depositPaid('Внесён залог', 'deposit_paid'),
  paid('Оплачено', 'paid'),
  closed('Закрыто', 'closed');

  const BookingStatus(this.label, this.storageValue);

  final String label;
  final String storageValue;

  static BookingStatus fromStorage(String value) =>
      BookingStatus.values.firstWhere(
        (status) => status.storageValue == value,
        orElse: () => BookingStatus.unpaid,
      );
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

  /// Check-in date, inclusive. Dates are normalized to UTC midnight.
  final DateTime startDate;

  /// Check-out date, exclusive. The number of nights is endDate - startDate.
  final DateTime endDate;

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

  int get nights => endDate.difference(startDate).inDays;

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
