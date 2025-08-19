import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_application_1/models/historical_data.dart';
import 'package:flutter_application_1/services/exchange_service.dart';

// Her bir kur için ayrı bir tarihi veri sağlayıcısı oluşturmak için `family` kullanırız.
final historicalDataProvider = FutureProvider.family
    .autoDispose<List<HistoricalData>, String>((ref, currencyId) async {
  return ExchangeService().fetchHistoricalData(currencyId);
});