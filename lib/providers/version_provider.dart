import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';

// FutureProvider kullanarak uygulamanın sürümünü asenkron olarak çekiyoruz
final appVersionProvider = FutureProvider<String>((ref) async {
  try {
    final info = await PackageInfo.fromPlatform();
    return info.version;
  } catch (e) {
    return 'Bilinmiyor';
  }
});