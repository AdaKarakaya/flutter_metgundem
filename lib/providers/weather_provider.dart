import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_application_1/services/weather_service.dart';

// Hava durumu servisini sağlayan provider
final weatherServiceProvider = Provider((ref) => WeatherService());

// Hava durumu verilerini yöneten ve asenkron işlem yapan provider
// Artık hem anlık hem de tahmin verilerini tutacak
final weatherProvider = StateNotifierProvider<WeatherNotifier, AsyncValue<Map<String, dynamic>>>((ref) {
  return WeatherNotifier(ref.watch(weatherServiceProvider));
});

// Arama metnini yöneten provider
final searchQueryProvider = StateProvider<String>((ref) => 'İstanbul');

// Hava durumu bilgisini çeken StateNotifier
class WeatherNotifier extends StateNotifier<AsyncValue<Map<String, dynamic>>> {
  final WeatherService _weatherService;

  WeatherNotifier(this._weatherService) : super(const AsyncValue.loading()) {
    fetchWeatherDataByCity('İstanbul'); // Uygulama başladığında İstanbul'un hava durumunu çek
  }

  Future<void> fetchWeatherDataByCity(String cityName) async {
    state = const AsyncValue.loading();
    try {
      final currentWeather = await _weatherService.getWeatherByCityName(cityName);
      final forecastWeather = await _weatherService.getForecastByCityName(cityName);

      final combinedData = {
        'current': currentWeather,
        'forecast': forecastWeather,
      };

      state = AsyncValue.data(combinedData);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> fetchWeatherDataByCurrentLocation() async {
    state = const AsyncValue.loading();
    try {
      Position position = await _determinePosition();
      final currentWeather = await _weatherService.getWeatherByCoordinates(position.latitude, position.longitude);
      final forecastWeather = await _weatherService.getForecastByCoordinates(position.latitude, position.longitude);

      final combinedData = {
        'current': currentWeather,
        'forecast': forecastWeather,
      };

      state = AsyncValue.data(combinedData);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Konum servisleri kapalı.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Konum izni reddedildi.');
      }
    }
    
    if (permission == LocationPermission.deniedForever) {
      return Future.error('Konum izinleri kalıcı olarak reddedildi, uygulama ayarlarından açınız.');
    } 

    return await Geolocator.getCurrentPosition();
  }
}