import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_application_1/models/exchange_rate.dart';
import 'package:flutter_application_1/models/historical_data.dart';
import 'package:intl/intl.dart';
import 'dart:developer'; // 'log' fonksiyonu için ekle

class ExchangeService {
  Future<List<ExchangeRate>> fetchRates() async {
    final List<ExchangeRate> allRates = [];

    // Para birimleri için API'den verileri çek
    final usdRatesResponse = await http.get(Uri.parse('https://open.er-api.com/v6/latest/USD'));
    
    if (usdRatesResponse.statusCode != 200) {
      throw Exception('Failed to load currency rates');
    }

    final data = json.decode(usdRatesResponse.body);
    final Map<String, dynamic> rates = data['rates'];
    
    final double usdToTryRate = rates['TRY'].toDouble();

    allRates.add(ExchangeRate(
      id: 'try',
      symbol: 'TRY',
      name: 'Türk Lirası',
      value: 1.0,
      change: 0.0,
    ));

    rates.forEach((symbol, value) {
      if (symbol == 'TRY') return; 

      final double tryBasedValue = usdToTryRate / value;
      
      allRates.add(ExchangeRate(
        id: symbol.toLowerCase(),
        symbol: symbol,
        name: _getCurrencyName(symbol),
        value: tryBasedValue,
        change: 0.0, 
      ));
    });

    final cryptoResponse = await http.get(Uri.parse('https://api.coingecko.com/api/v3/simple/price?ids=bitcoin,ethereum&vs_currencies=usd&include_24hr_change=true'));
    
    if (cryptoResponse.statusCode == 200) {
      final cryptoData = json.decode(cryptoResponse.body);
      
      final double btcUsdPrice = cryptoData['bitcoin']['usd'].toDouble();
      final double ethUsdPrice = cryptoData['ethereum']['usd'].toDouble();
      
      allRates.add(ExchangeRate(
        id: 'bitcoin',
        symbol: 'BTC',
        name: 'Bitcoin',
        value: btcUsdPrice * usdToTryRate,
        change: cryptoData['bitcoin']['usd_24h_change'].toDouble(),
      ));
      allRates.add(ExchangeRate(
        id: 'ethereum',
        symbol: 'ETH',
        name: 'Ethereum',
        value: ethUsdPrice * usdToTryRate,
        change: cryptoData['ethereum']['usd_24h_change'].toDouble(),
      ));
    }

    return allRates;
  }

  static const List<String> supportedCryptoIds = [
    'bitcoin',
    'ethereum',
  ];

  Future<List<HistoricalData>> fetchHistoricalData(String currencyId) async {
    // 1. Türk Lirası için özel durum
    if (currencyId == 'try') {
      final now = DateTime.now();
      return List.generate(
        30,
        (index) => HistoricalData(
          date: now.subtract(Duration(days: 30 - index)),
          value: 1.0,
        ),
      );
    }

    // 2. Kripto paralar için CoinGecko API'si
    if (supportedCryptoIds.contains(currencyId)) {
      final response = await http.get(Uri.parse(
          'https://api.coingecko.com/api/v3/coins/$currencyId/market_chart?vs_currency=try&days=30&interval=daily'
      ));

      if (response.statusCode != 200) {
        throw Exception('Failed to load historical crypto data for $currencyId');
      }

      final data = json.decode(response.body);
      final List<dynamic> prices = data['prices'];

      return prices.map((point) {
        final timestamp = point[0] as int;
        final value = point[1] as double;
        return HistoricalData(
          date: DateTime.fromMillisecondsSinceEpoch(timestamp),
          value: value,
        );
      }).toList();
    } else {
      // 3. Geleneksel para birimleri için exchangerate.host API'si (USD bazlı)
      final endDate = DateTime.now();
      final startDate = endDate.subtract(const Duration(days: 30));
      final formattedStartDate = DateFormat('yyyy-MM-dd').format(startDate);
      final formattedEndDate = DateFormat('yyyy-MM-dd').format(endDate);
      
      final String accessKey = 'fxr_live_7da263d514f1d2024f8a556cec568731f80c';
      
      // Tekrar 'access_key' parametresini kullan
      final url = 'https://api.fxratesapi.com/timeseries?access_key=$accessKey&base=USD&symbols=TRY,${currencyId.toUpperCase()}&start_date=$formattedStartDate&end_date=$formattedEndDate';
      
      log('Fetching historical data for $currencyId from URL: $url'); 
      
      final response = await http.get(Uri.parse(url));

      if (response.statusCode != 200) {
        log('API call failed with status code: ${response.statusCode}'); 
        throw Exception('Failed to load historical fiat data for $currencyId');
      }

      final data = json.decode(response.body);
      log('Received API data: $data');
      
      if (data['rates'] == null || data['rates'] is! Map) {
        log('API data is missing rates key or is not a Map.');
        return [];
      }

      final Map<String, dynamic> rates = Map<String, dynamic>.from(data['rates']);
      
      final List<HistoricalData> history = [];
      rates.forEach((date, currencyRates) {
        final tryValue = (currencyRates['TRY'] as num?)?.toDouble();
        final baseValue = (currencyRates[currencyId.toUpperCase()] as num?)?.toDouble();

        if (tryValue != null && baseValue != null && baseValue != 0) {
          final value = tryValue / baseValue;
          history.add(HistoricalData(
            date: DateTime.parse(date),
            value: value,
          ));
        }
      });
      
      history.sort((a, b) => a.date.compareTo(b.date));

      log('Final history list count: ${history.length}');

      return history;
    }
  }

  String _getCurrencyName(String symbol) {
    switch (symbol) {
      case 'USD':
        return 'ABD Doları';
      case 'EUR':
        return 'Euro';
      case 'GBP':
        return 'İngiliz Sterlini';
      case 'JPY':
        return 'Japon Yeni';
      case 'AUD':
        return 'Avustralya Doları';
      case 'CAD':
        return 'Kanada Doları';
      case 'CHF':
        return 'İsviçre Frangı';
      default:
        return symbol;
    }
  }
}