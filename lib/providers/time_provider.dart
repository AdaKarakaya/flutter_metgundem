import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

// Her dakika güncellenen anlık saati sağlayan provider
final currentTimeProvider = StreamProvider<String>((ref) {
  final controller = StreamController<String>();

  // Timer'ı oluştur ve her dakika stream'e yeni değer ekle
  final timer = Timer.periodic(const Duration(minutes: 1), (timer) {
    controller.sink.add(DateFormat('h:mm').format(DateTime.now()));
  });

  // Provider kapandığında timer ve stream'i temizle
  ref.onDispose(() {
    timer.cancel();
    controller.close();
  });

  // İlk değeri hemen ekle
  controller.sink.add(DateFormat('h:mm').format(DateTime.now()));

  return controller.stream;
});