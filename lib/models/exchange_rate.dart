class ExchangeRate {
  final String id; // Yeni eklendi
  final String symbol;
  final String name;
  final double value;
  final double change;

  ExchangeRate({
    required this.id, // Yeni eklendi
    required this.symbol,
    required this.name,
    required this.value,
    required this.change,
  });
}