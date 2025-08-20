import 'package:envied/envied.dart';

part 'env.g.dart';

@Envied(path: '.env')
abstract class Env {
  @EnviedField(varName: 'WEB_API_KEY', obfuscate: true)
  static final String webApiKey = _Env.webApiKey;
  @EnviedField(varName: 'WEB_APP_ID')
  static const String webAppId = _Env.webAppId;
  @EnviedField(varName: 'WEB_MESSAGING_SENDER_ID')
  static const String webMessagingSenderId = _Env.webMessagingSenderId;
  @EnviedField(varName: 'WEB_PROJECT_ID')
  static const String webProjectId = _Env.webProjectId;
  @EnviedField(varName: 'WEB_AUTH_DOMAIN')
  static const String webAuthDomain = _Env.webAuthDomain;
  @EnviedField(varName: 'WEB_STORAGE_BUCKET')
  static const String webStorageBucket = _Env.webStorageBucket;
  @EnviedField(varName: 'WEB_MEASUREMENT_ID')
  static const String webMeasurementId = _Env.webMeasurementId;

  @EnviedField(varName: 'ANDROID_API_KEY', obfuscate: true)
  static final String androidApiKey = _Env.androidApiKey;
  @EnviedField(varName: 'ANDROID_APP_ID')
  static const String androidAppId = _Env.androidAppId;
  @EnviedField(varName: 'ANDROID_MESSAGING_SENDER_ID')
  static const String androidMessagingSenderId = _Env.androidMessagingSenderId;
  @EnviedField(varName: 'ANDROID_PROJECT_ID')
  static const String androidProjectId = _Env.androidProjectId;
  @EnviedField(varName: 'ANDROID_STORAGE_BUCKET')
  static const String androidStorageBucket = _Env.androidStorageBucket;
  
  @EnviedField(varName: 'IOS_API_KEY', obfuscate: true)
  static final String iosApiKey = _Env.iosApiKey;
  @EnviedField(varName: 'IOS_APP_ID')
  static const String iosAppId = _Env.iosAppId;
  @EnviedField(varName: 'IOS_MESSAGING_SENDER_ID')
  static const String iosMessagingSenderId = _Env.iosMessagingSenderId;
  @EnviedField(varName: 'IOS_PROJECT_ID')
  static const String iosProjectId = _Env.iosProjectId;
  @EnviedField(varName: 'IOS_STORAGE_BUCKET')
  static const String iosStorageBucket = _Env.iosStorageBucket;
  @EnviedField(varName: 'IOS_ANDROID_CLIENT_ID')
  static const String iosAndroidClientId = _Env.iosAndroidClientId;
  @EnviedField(varName: 'IOS_BUNDLE_ID')
  static const String iosBundleId = _Env.iosBundleId;

  @EnviedField(varName: 'MACOS_API_KEY', obfuscate: true)
  static final String macosApiKey = _Env.macosApiKey;
  @EnviedField(varName: 'MACOS_APP_ID')
  static const String macosAppId = _Env.macosAppId;
  @EnviedField(varName: 'MACOS_MESSAGING_SENDER_ID')
  static const String macosMessagingSenderId = _Env.macosMessagingSenderId;
  @EnviedField(varName: 'MACOS_PROJECT_ID')
  static const String macosProjectId = _Env.macosProjectId;
  @EnviedField(varName: 'MACOS_STORAGE_BUCKET')
  static const String macosStorageBucket = _Env.macosStorageBucket;
  @EnviedField(varName: 'MACOS_ANDROID_CLIENT_ID')
  static const String macosAndroidClientId = _Env.macosAndroidClientId;
  @EnviedField(varName: 'MACOS_BUNDLE_ID')
  static const String macosBundleId = _Env.macosBundleId;
  
  @EnviedField(varName: 'OPENWEATHER_API_KEY', obfuscate: true)
  static final String openweatherApiKey = _Env.openweatherApiKey;
}