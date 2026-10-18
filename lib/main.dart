import 'package:flutter/material.dart';

import 'data/local/app_database.dart';
import 'data/repositories/drift_booking_repository.dart';
import 'domain/usecases/booking_use_cases.dart';
import 'presentation/app/mango_rent_app.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  final database = AppDatabase();
  final useCases = BookingUseCases(DriftBookingRepository(database));
  runApp(MangoRentApp(useCases: useCases));
}
