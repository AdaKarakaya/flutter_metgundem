import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_application_1/models/exchange_rate.dart';
import 'package:flutter_application_1/providers/historical_data_provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

class DetailPage extends ConsumerWidget {
  final ExchangeRate rate;

  const DetailPage({super.key, required this.rate});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historicalData = ref.watch(historicalDataProvider(rate.id));
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode ? Colors.grey[900] : Colors.grey[100],
      appBar: AppBar(
        title: Text(
          rate.name,
          style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
        ),
        backgroundColor: isDarkMode ? Colors.grey[900] : Colors.grey[100],
        elevation: 0,
        iconTheme: IconThemeData(
          color: isDarkMode ? Colors.white : Colors.black,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Sembol ve isim
            Text(
              rate.symbol,
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.white : Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${rate.name} Fiyatı',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: isDarkMode ? Colors.white70 : Colors.black54,
              ),
            ),
            const SizedBox(height: 16),
            // Güncel Fiyat
            Text(
              rate.value.toStringAsFixed(2),
              style: Theme.of(context).textTheme.displaySmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.white : Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            // Değişim Yüzdesi
            Text(
              '${rate.change.toStringAsFixed(2)}%',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: rate.change >= 0 ? Colors.green : Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 32),
            
            // Grafik Alanı
            Expanded(
              child: historicalData.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stack) => Center(child: Text('Grafik verisi yüklenirken hata oluştu: $error')),
                data: (history) {
                  if (history.isEmpty) {
                    return Center(child: Text('Grafik verisi bulunamadı.', style: TextStyle(color: isDarkMode ? Colors.grey : Colors.grey[600])));
                  }
                  
                  // Grafik verilerini FlSpot formatına dönüştür
                  final spots = history.asMap().entries.map((e) {
                    final index = e.key.toDouble();
                    final dataPoint = e.value;
                    return FlSpot(index, dataPoint.value);
                  }).toList();

                  final minX = spots.first.x;
                  final maxX = spots.last.x;
                  final minY = spots.map((e) => e.y).reduce((a, b) => a < b ? a : b);
                  final maxY = spots.map((e) => e.y).reduce((a, b) => a > b ? a : b);

                  return Padding(
                    padding: const EdgeInsets.only(top: 16.0, right: 16.0, bottom: 4.0),
                    child: LineChart(
                      LineChartData(
                        // Grafik etkileşimi
                        lineTouchData: LineTouchData(
                          handleBuiltInTouches: true,
                          touchTooltipData: LineTouchTooltipData(
                            fitInsideHorizontally: true,
                            getTooltipItems: (touchedSpots) {
                              return touchedSpots.map((spot) {
                                final dataPoint = history[spot.spotIndex];
                                final formattedDate = DateFormat('dd MMM').format(dataPoint.date);
                                final formattedValue = dataPoint.value.toStringAsFixed(2);
                                return LineTooltipItem(
                                  '$formattedDate\n$formattedValue',
                                  const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                );
                              }).toList();
                            },
                          ),
                        ),
                        // Izgara çizgileri
                        gridData: FlGridData(
                          show: true,
                          drawVerticalLine: true,
                          getDrawingHorizontalLine: (value) => FlLine(
                            color: isDarkMode ? Colors.grey[800]! : Colors.grey[300]!,
                            strokeWidth: 1,
                          ),
                          getDrawingVerticalLine: (value) => FlLine(
                            color: isDarkMode ? Colors.grey[800]! : Colors.grey[300]!,
                            strokeWidth: 1,
                          ),
                        ),
                        // Kenarlık
                        borderData: FlBorderData(
                          show: true,
                          border: Border(
                            bottom: BorderSide(color: isDarkMode ? Colors.white70 : Colors.black54, width: 1),
                            left: BorderSide(color: isDarkMode ? Colors.white70 : Colors.black54, width: 1),
                          ),
                        ),
                        // Eksen başlıkları
                        titlesData: FlTitlesData(
                          show: true,
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 30,
                              getTitlesWidget: (value, meta) {
                                final isFirst = value.toInt() == 0;
                                final isLast = value.toInt() == spots.length - 1;
                                final date = history[value.toInt()].date;
                                return SideTitleWidget(
                                  axisSide: meta.axisSide,
                                  space: 8.0,
                                  child: Text(
                                    isFirst || isLast ? DateFormat('dd.MM').format(date) : '',
                                    style: TextStyle(color: isDarkMode ? Colors.white70 : Colors.black54),
                                  ),
                                );
                              },
                            ),
                          ),
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 40,
                              getTitlesWidget: (value, meta) {
                                return SideTitleWidget(
                                  axisSide: meta.axisSide,
                                  space: 8.0,
                                  child: Text(
                                    value.toStringAsFixed(0),
                                    style: TextStyle(color: isDarkMode ? Colors.white70 : Colors.black54),
                                  ),
                                );
                              },
                            ),
                          ),
                          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        ),
                        minX: minX,
                        maxX: maxX,
                        minY: minY,
                        maxY: maxY * 1.05,
                        // Çizgi grafiği verileri
                        lineBarsData: [
                          LineChartBarData(
                            spots: spots,
                            isCurved: true,
                            gradient: LinearGradient(
                              colors: [
                                (rate.change >= 0 ? Colors.green.shade400 : Colors.red.shade400),
                                (rate.change >= 0 ? Colors.green.shade900 : Colors.red.shade900),
                              ],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            ),
                            barWidth: 3,
                            dotData: const FlDotData(show: false),
                            belowBarData: BarAreaData(
                              show: true,
                              gradient: LinearGradient(
                                colors: [
                                  (rate.change >= 0 ? Colors.green : Colors.red).withOpacity(0.3),
                                  (rate.change >= 0 ? Colors.green : Colors.red).withOpacity(0.0),
                                ],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}