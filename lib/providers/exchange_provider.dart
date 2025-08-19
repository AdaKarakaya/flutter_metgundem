import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_application_1/services/exchange_service.dart';
import 'package:flutter_application_1/models/exchange_rate.dart';

// Use this provider for periodic updates.
final exchangeRateProvider = AutoDisposeFutureProvider<List<ExchangeRate>>((ref) async {
  final exchangeService = ExchangeService();

  final timer = Timer.periodic(const Duration(seconds: 15), (t) {
    ref.invalidateSelf();
  });

  ref.onDispose(() {
    timer.cancel();
  });

  return exchangeService.fetchRates();
});