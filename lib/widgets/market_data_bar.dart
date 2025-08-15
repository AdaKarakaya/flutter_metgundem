// lib/widgets/market_data_bar.dart

import 'package:flutter/material.dart';

class MarketDataBar extends StatelessWidget {
  const MarketDataBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: const SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _MarketItem(symbol: 'EUR/TRY', price: '47.82342', change: '+0.20'),
            SizedBox(width: 24),
            _MarketItem(symbol: 'BTC/USD', price: '2,39T', change: '-1.554.801'),
            SizedBox(width: 24),
            _MarketItem(symbol: 'ETH/USD', price: '566,47B', change: '+12.361.977'),
            SizedBox(width: 24),
            _MarketItem(symbol: 'BIST 100', price: '100', change: '0'),
          ],
        ),
      ),
    );
  }
}

class _MarketItem extends StatelessWidget {
  final String symbol;
  final String price;
  final String change;
  const _MarketItem({required this.symbol, required this.price, required this.change});

  Color get _changeColor {
    if (change.startsWith('+')) return Colors.green;
    if (change.startsWith('-')) return Colors.red;
    return Colors.white;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          symbol,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        const SizedBox(width: 8),
        Text(
          price,
          style: const TextStyle(color: Colors.white),
        ),
        const SizedBox(width: 8),
        Text(
          change,
          style: TextStyle(color: _changeColor),
        ),
      ],
    );
  }
}