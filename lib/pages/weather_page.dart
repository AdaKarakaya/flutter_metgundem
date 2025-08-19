import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_application_1/providers/weather_provider.dart';

class WeatherPage extends ConsumerWidget {
  const WeatherPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final weatherState = ref.watch(weatherProvider);
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Hava Durumu',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
        backgroundColor: Colors.transparent, // AppBar'ı şeffaf yap
        elevation: 0,
        iconTheme: IconThemeData(
          color: theme.colorScheme.onSurface,
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.my_location, color: theme.colorScheme.onSurface),
            onPressed: () {
              ref.read(weatherProvider.notifier).fetchWeatherDataByCurrentLocation();
            },
          ),
        ],
      ),
      extendBodyBehindAppBar: true, // AppBar'ın arkasına body'yi genişlet
      body: Stack(
        children: [
          // Dinamik Arka Plan
          Positioned.fill(
            child: weatherState.when(
              data: (data) => _buildWeatherBackground(data['current']['weather'][0]['icon'], isDarkMode),
              loading: () => Container(
                color: isDarkMode ? Colors.black : Colors.lightBlue[100],
              ),
              error: (e, s) => Container(
                color: theme.colorScheme.errorContainer,
              ),
            ),
          ),
          // Ana İçerik
          weatherState.when(
            data: (data) => _buildWeatherData(context, ref, data),
            loading: () => Center(child: CircularProgressIndicator(color: theme.colorScheme.primary)),
            error: (e, s) => Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.warning_amber_rounded, size: 64, color: theme.colorScheme.error),
                    const SizedBox(height: 16),
                    Text(
                      e.toString(),
                      style: theme.textTheme.titleLarge?.copyWith(color: theme.colorScheme.error),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeatherBackground(String iconCode, bool isDarkMode) {
    final String weatherType = iconCode.substring(0, 2);
    AssetImage backgroundImage;
    
    if (isDarkMode) {
      if (weatherType == '01') { // clear sky
        backgroundImage = const AssetImage('assets/images/clear_night.jpg');
      } else if (weatherType == '02' || weatherType == '03' || weatherType == '04') { // clouds
        backgroundImage = const AssetImage('assets/images/cloudy_night.jpg');
      } else if (weatherType == '09' || weatherType == '10') { // rain
        backgroundImage = const AssetImage('assets/images/rainy_night.jpg');
      } else if (weatherType == '11') { // thunderstorm
        backgroundImage = const AssetImage('assets/images/thunder_night.jpg');
      } else if (weatherType == '13') { // snow
        backgroundImage = const AssetImage('assets/images/snowy_night.jpg');
      } else {
        backgroundImage = const AssetImage('assets/images/default_night.jpg');
      }
    } else {
      if (weatherType == '01') { // clear sky
        backgroundImage = const AssetImage('assets/images/clear_day.jpg');
      } else if (weatherType == '02' || weatherType == '03' || weatherType == '04') { // clouds
        backgroundImage = const AssetImage('assets/images/cloudy_day.jpg');
      } else if (weatherType == '09' || weatherType == '10') { // rain
        backgroundImage = const AssetImage('assets/images/rainy_day.jpg');
      } else if (weatherType == '11') { // thunderstorm
        backgroundImage = const AssetImage('assets/images/thunder_day.jpg');
      } else if (weatherType == '13') { // snow
        backgroundImage = const AssetImage('assets/images/snowy_day.jpg');
      } else {
        backgroundImage = const AssetImage('assets/images/default_day.jpg');
      }
    }
    
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 800),
      transitionBuilder: (Widget child, Animation<double> animation) {
        return FadeTransition(opacity: animation, child: child);
      },
      child: Image(
        key: ValueKey<String>(weatherType), // Animasyon için key kullan
        image: backgroundImage,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
      ),
    );
  }
  
  Widget _buildWeatherData(BuildContext context, WidgetRef ref, Map<String, dynamic> data) {
    return RefreshIndicator(
      onRefresh: () async {
        final query = ref.read(searchQueryProvider);
        if (query.isNotEmpty) {
          await ref.read(weatherProvider.notifier).fetchWeatherDataByCity(query);
        }
      },
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        children: [
          const SizedBox(height: 80),
          _buildSearchBar(context, ref),
          const SizedBox(height: 24),
          _buildCurrentWeatherInfo(context, data['current']),
          const SizedBox(height: 24),
          _buildForecastSection(context, data['forecast']),
        ],
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context, WidgetRef ref) {
    final TextEditingController _searchController = TextEditingController(text: ref.read(searchQueryProvider));

    return TextField(
      controller: _searchController,
      onSubmitted: (value) {
        if (value.isNotEmpty) {
          ref.read(searchQueryProvider.notifier).state = value;
          ref.read(weatherProvider.notifier).fetchWeatherDataByCity(value);
        }
      },
      style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
      decoration: InputDecoration(
        labelText: 'Şehir Ara',
        labelStyle: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6)),
        filled: true,
        fillColor: Theme.of(context).cardColor,
        prefixIcon: Icon(Icons.search, color: Theme.of(context).colorScheme.onSurface),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildCurrentWeatherInfo(BuildContext context, Map<String, dynamic> data) {
    final String cityName = data['name'];
    final double temperature = data['main']['temp'];
    final String description = data['weather'][0]['description'];
    final String iconCode = data['weather'][0]['icon'];

    return Column(
      children: [
        Text(
          cityName,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            shadows: [
              const Shadow(blurRadius: 5.0, color: Colors.black26),
            ],
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Image.network(
          'https://openweathermap.org/img/wn/$iconCode@4x.png',
          height: 150,
          fit: BoxFit.cover,
        ),
        Text(
          '${temperature.round()}°C',
          style: Theme.of(context).textTheme.displayLarge?.copyWith(
            fontWeight: FontWeight.w300,
            color: Colors.white,
            shadows: [
              const Shadow(blurRadius: 5.0, color: Colors.black26),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          description.toUpperCase(),
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: Colors.white.withOpacity(0.9),
            shadows: [
              const Shadow(blurRadius: 5.0, color: Colors.black26),
            ],
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        _buildInfoGrid(context, data),
      ],
    );
  }

  Widget _buildInfoGrid(BuildContext context, Map<String, dynamic> data) {
    final double feelsLike = data['main']['feels_like'];
    final int humidity = data['main']['humidity'];
    final double windSpeed = data['wind']['speed'];
    final String visibility = data['visibility'] != null ? '${(data['visibility'] / 1000).round()} km' : 'N/A';
    final int pressure = data['main']['pressure'];
    
    // Saat ve dakika formatı için
    String formatTime(int timestamp) {
      final time = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
      return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
    }

    final String sunrise = formatTime(data['sys']['sunrise']);
    final String sunset = formatTime(data['sys']['sunset']);

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      childAspectRatio: 2.5,
      mainAxisSpacing: 16.0,
      crossAxisSpacing: 16.0,
      children: [
        _buildMetricItem(context, 'Hissedilen', '${feelsLike.round()}°C', Icons.thermostat_outlined),
        _buildMetricItem(context, 'Rüzgar', '${windSpeed.round()} m/s', Icons.air),
        _buildMetricItem(context, 'Nem', '%$humidity', Icons.water_drop_outlined),
        _buildMetricItem(context, 'Görüş', visibility, Icons.visibility_outlined),
        _buildMetricItem(context, 'Basınç', '$pressure hPa', Icons.speed_outlined),
        _buildMetricItem(context, 'Gün Doğumu', sunrise, Icons.wb_sunny_outlined),
        _buildMetricItem(context, 'Gün Batımı', sunset, Icons.mode_night_outlined),
      ],
    );
  }

  Widget _buildMetricItem(BuildContext context, String title, String value, IconData icon) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.cardColor.withOpacity(0.5),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: theme.colorScheme.onSurface.withOpacity(0.8)),
              const SizedBox(width: 8),
              Text(
                title,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.8),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildForecastSection(BuildContext context, Map<String, dynamic> forecastData) {
    // API'den gelen 3 saatlik verileri günlük verilere dönüştürüyoruz.
    final List forecastList = forecastData['list'];
    final Map<String, dynamic> dailyForecast = {};
    
    // Her günün öğlen saatlerindeki veriyi seçerek 5 günlük tahmini oluşturuyoruz
    for (var item in forecastList) {
      final String date = item['dt_txt'].split(' ')[0];
      final String time = item['dt_txt'].split(' ')[1];
      if (time == '12:00:00') { // Öğlen 12:00 verisini al
        dailyForecast[date] = item;
      }
    }

    final List dailyItems = dailyForecast.values.toList();

    if (dailyItems.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '5 Günlük Tahmin',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 12),
        Card(
          color: Theme.of(context).cardColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          elevation: 4,
          child: ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: dailyItems.length,
            itemBuilder: (context, index) {
              final dailyData = dailyItems[index];
              final date = DateTime.fromMillisecondsSinceEpoch(dailyData['dt'] * 1000);
              final dayName = _getDayName(date.weekday);
              final temp = dailyData['main']['temp'].round();
              final iconCode = dailyData['weather'][0]['icon'];

              return ListTile(
                leading: Image.network('https://openweathermap.org/img/wn/$iconCode.png', width: 48, height: 48),
                title: Text(
                  dayName,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                trailing: Text(
                  '$temp°C',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  String _getDayName(int weekday) {
    switch (weekday) {
      case 1: return 'Pazartesi';
      case 2: return 'Salı';
      case 3: return 'Çarşamba';
      case 4: return 'Perşembe';
      case 5: return 'Cuma';
      case 6: return 'Cumartesi';
      case 7: return 'Pazar';
      default: return '';
    }
  }
}