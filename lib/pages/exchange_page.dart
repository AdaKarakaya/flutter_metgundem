import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_application_1/providers/exchange_provider.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:flutter_application_1/models/exchange_rate.dart';
import 'package:flutter_application_1/pages/detail_page.dart';

class ExchangePage extends ConsumerStatefulWidget {
  const ExchangePage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _ExchangePageState createState() => _ExchangePageState();
}

class _ExchangePageState extends ConsumerState<ExchangePage> {
  final TextEditingController _searchController = TextEditingController();
  List<ExchangeRate> _filteredRates = [];
  bool _isInitialized = false;

  // Öne çıkan kurların sembolleri
  final List<String> _prominentSymbols = ['USD', 'EUR', 'BTC', 'ETH'];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_filterRates);
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterRates);
    _searchController.dispose();
    super.dispose();
  }

  void _filterRates() {
    final allRates = ref.read(exchangeRateProvider).value ?? [];
    final query = _searchController.text.toLowerCase();

    setState(() {
      if (query.isEmpty) {
        // Arama metni boşsa, tüm kurları göster
        _filteredRates = allRates;
      } else {
        // Arama metnine göre kurları filtrele
        _filteredRates = allRates.where((rate) {
          return rate.name.toLowerCase().contains(query) ||
                 rate.symbol.toLowerCase().contains(query);
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final exchangeRates = ref.watch(exchangeRateProvider);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode ? Colors.grey[900] : Colors.grey[100],
      appBar: AppBar(
        title: Text(
          'Kurlar ve Kriptolar',
          style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
        ),
        centerTitle: false,
        elevation: 0,
        backgroundColor: isDarkMode ? Colors.grey[900] : Colors.grey[100],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          // ignore: unused_result
          await ref.refresh(exchangeRateProvider.future);
          _filterRates(); // Yeniledikten sonra arama filtresini yeniden uygula
        },
        child: exchangeRates.when(
          data: (rates) {
            // Sadece ilk veri geldiğinde _filteredRates listesini başlat
            if (!_isInitialized) {
              _filteredRates = rates;
              _isInitialized = true;
            }

            final prominentRates = _filteredRates.where((rate) => _prominentSymbols.contains(rate.symbol)).toList();
            final otherRates = _filteredRates.where((rate) => !_prominentSymbols.contains(rate.symbol)).toList();

            // Arama sonucu boşsa ve arama metni boş değilse "Bulunamadı" mesajını göster
            if (_filteredRates.isEmpty && _searchController.text.isNotEmpty) {
              return CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                      child: TextField(
                        controller: _searchController,
                        style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
                        decoration: InputDecoration(
                          hintText: 'Ara...',
                          hintStyle: TextStyle(color: isDarkMode ? Colors.grey : Colors.grey[600]),
                          prefixIcon: Icon(Icons.search, color: isDarkMode ? Colors.grey : Colors.grey[600]),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30.0),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: isDarkMode ? Colors.grey[800] : Colors.grey[300],
                          contentPadding: const EdgeInsets.symmetric(vertical: 10.0),
                        ),
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 50.0),
                        child: Text(
                          'Sonuç bulunamadı.',
                          style: TextStyle(color: isDarkMode ? Colors.white70 : Colors.grey),
                        ),
                      ),
                    ),
                  )
                ],
              );
            }
            
            return CustomScrollView(
              slivers: [
                // Arama çubuğu her zaman en üstte kalacak
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: TextField(
                      controller: _searchController,
                      style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
                      decoration: InputDecoration(
                        hintText: 'Ara...',
                        hintStyle: TextStyle(color: isDarkMode ? Colors.grey : Colors.grey[600]),
                        prefixIcon: Icon(Icons.search, color: isDarkMode ? Colors.grey : Colors.grey[600]),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30.0),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: isDarkMode ? Colors.grey[800] : Colors.grey[300],
                        contentPadding: const EdgeInsets.symmetric(vertical: 10.0),
                      ),
                    ),
                  ),
                ),
                
                // Öne çıkan kurlar sadece arama yapılmadığında gösterilir
                if (_searchController.text.isEmpty && prominentRates.isNotEmpty) ...[
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 16.0, left: 16.0, right: 16.0),
                      child: Text(
                        'Öne Çıkanlar',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: isDarkMode ? Colors.white : Colors.black),
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    sliver: SliverGrid(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 1.5,
                        crossAxisSpacing: 16.0,
                        mainAxisSpacing: 16.0,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final rate = prominentRates[index];
                          return _buildProminentRateCard(context, rate, isDarkMode);
                        },
                        childCount: prominentRates.length,
                      ),
                    ),
                  ),
                ],

                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 24.0, left: 16.0, right: 16.0),
                    child: Text(
                      _searchController.text.isNotEmpty ? 'Arama Sonuçları' : 'Tüm Kurlar',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: isDarkMode ? Colors.white : Colors.black),
                    ),
                  ),
                ),
                AnimationLimiter(
                  child: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final rate = otherRates[index];
                        return AnimationConfiguration.staggeredList(
                          position: index,
                          duration: const Duration(milliseconds: 375),
                          child: SlideAnimation(
                            verticalOffset: 50.0,
                            child: FadeInAnimation(
                              child: _buildRateListTile(context, rate, isDarkMode),
                            ),
                          ),
                        );
                      },
                      childCount: otherRates.length,
                    ),
                  ),
                ),
              ],
            );
          },
          loading: () => Center(child: CircularProgressIndicator(color: isDarkMode ? Colors.white : Colors.black)),
          error: (error, stack) => Center(child: Text('Hata: $error', style: TextStyle(color: isDarkMode ? Colors.white : Colors.black))),
        ),
      ),
    );
  }

  Widget _buildProminentRateCard(BuildContext context, ExchangeRate rate, bool isDarkMode) {
    final isPositive = rate.change >= 0;
    final color = isPositive ? Colors.green : Colors.red;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => DetailPage(rate: rate)),
        );
      },
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        color: isDarkMode ? Colors.grey[850] : Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      rate.symbol,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isDarkMode ? Colors.white : Colors.black,
                      ),
                    ),
                    Text(
                      rate.name,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: isDarkMode ? Colors.white70 : Colors.black54,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 1,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Flexible(
                      child: Text(
                        rate.value.toStringAsFixed(2),
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isDarkMode ? Colors.white : Colors.black,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        '${isPositive ? '+' : ''}${rate.change.toStringAsFixed(2)}%',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: color, fontWeight: FontWeight.bold),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRateListTile(BuildContext context, ExchangeRate rate, bool isDarkMode) {
    final isPositive = rate.change >= 0;
    final color = isPositive ? Colors.green : Colors.red;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => DetailPage(rate: rate)),
        );
      },
      child: Card(
        elevation: 2,
        margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        color: isDarkMode ? Colors.grey[850] : Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              SizedBox(
                width: 50,
                child: Text(
                  rate.symbol,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? Colors.white : Colors.black,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 2,
                child: Text(
                  rate.name,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: isDarkMode ? Colors.white : Colors.black,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Expanded(
                flex: 1,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      rate.value.toStringAsFixed(2),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isDarkMode ? Colors.white : Colors.black,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${isPositive ? '+' : ''}${rate.change.toStringAsFixed(2)}%',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: color, fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}