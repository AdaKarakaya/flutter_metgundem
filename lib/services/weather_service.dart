import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class WeatherService {
  final String _apiKey = dotenv.env['OPENWEATHER_API_KEY'] ?? '';
  final String _baseUrl = 'https://api.openweathermap.org/data/2.5/weather';
  final String _forecastUrl = 'https://api.openweathermap.org/data/2.5/forecast';

  Future<Map<String, dynamic>> getWeatherByCityName(String cityName) async {
    final response = await http.get(Uri.parse('$_baseUrl?q=$cityName&appid=$_apiKey&units=metric&lang=tr'));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Şehir bulunamadı veya bir hata oluştu.');
    }
  }

  Future<Map<String, dynamic>> getForecastByCityName(String cityName) async {
    final response = await http.get(Uri.parse('$_forecastUrl?q=$cityName&appid=$_apiKey&units=metric&lang=tr'));
    
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Tahmin verileri alınamadı.');
    }
  }

  Future<Map<String, dynamic>> getWeatherByCoordinates(double lat, double lon) async {
    final response = await http.get(Uri.parse('$_baseUrl?lat=$lat&lon=$lon&appid=$_apiKey&units=metric&lang=tr'));
    
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Konum bilgisi alınamadı.');
    }
  }

  Future<Map<String, dynamic>> getForecastByCoordinates(double lat, double lon) async {
    final response = await http.get(Uri.parse('$_forecastUrl?lat=$lat&lon=$lon&appid=$_apiKey&units=metric&lang=tr'));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Tahmin verileri alınamadı.');
    }
  }
}