import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/booking.dart';
import '../../../domain/usecases/booking_use_cases.dart';

class BookingEditorState {
  const BookingEditorState({required this.booking, this.notice});

  final Booking booking;
  final String? notice;

  BookingEditorState copyWith({
    Booking? booking,
    String? notice,
    bool clearNotice = false,
  }) {
    return BookingEditorState(
      booking: booking ?? this.booking,
      notice: clearNotice ? null : notice ?? this.notice,
    );
  }
}

class BookingEditorCubit extends Cubit<BookingEditorState> {
  BookingEditorCubit({
    required Booking booking,
    required BookingUseCases useCases,
  })
    : _useCases = useCases,
      super(BookingEditorState(booking: booking));

  final BookingUseCases _useCases;
  Future<void> _writeQueue = Future<void>.value();

  void change(Booking updated) {
    emit(state.copyWith(booking: updated));
    _writeQueue = _writeQueue
        .catchError((Object _) {})
        .then((_) => _useCases.saveBooking(updated))
        .then<void>((_) {})
        .catchError((Object error) {
          if (isClosed) return;
          emit(state.copyWith(notice: 'Не удалось сохранить: $error'));
        });
  }

  Future<void> deleteBooking() async {
    await _writeQueue;
    final id = state.booking.id;
    if (id != null) await _useCases.deleteBooking(id);
  }

  void clearNotice() => emit(state.copyWith(clearNotice: true));
}
