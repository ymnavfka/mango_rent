import 'package:flutter_test/flutter_test.dart';
import 'package:mango_rent/domain/entities/booking.dart';
import 'package:mango_rent/presentation/theme/app_palette.dart';

void main() {
  test('formats Russian night counts with correct plural forms', () {
    expect(nightLabel(0), '0 ночей');
    expect(nightLabel(1), '1 ночь');
    expect(nightLabel(2), '2 ночи');
    expect(nightLabel(4), '4 ночи');
    expect(nightLabel(5), '5 ночей');
    expect(nightLabel(11), '11 ночей');
    expect(nightLabel(21), '21 ночь');
    expect(nightLabel(24), '24 ночи');
  });

  test('formats whole and fractional amounts for display', () {
    expect(amountText(1200), '1200');
    expect(amountText(1200.5), '1200.5');
  });

  test('provides fallback for unknown stored booking statuses', () {
    expect(BookingStatus.fromStorage('paid'), BookingStatus.paid);
    expect(BookingStatus.fromStorage('unrecognized'), BookingStatus.unpaid);
  });

  test(
    'normalizes dates by day and compares dates without time components',
    () {
      final local = DateTime(2026, 10, 12, 23, 45);
      expect(asLocalDate(local), DateTime(2026, 10, 12));
      expect(sameDay(local, DateTime.utc(2026, 10, 12, 1)), isTrue);
      expect(sameDay(local, DateTime(2026, 10, 13)), isFalse);
    },
  );
}
