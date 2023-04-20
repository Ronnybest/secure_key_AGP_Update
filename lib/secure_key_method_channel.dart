import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'secure_key_platform_interface.dart';

/// An implementation of [SecureKeyPlatform] that uses method channels.
class MethodChannelSecureKey extends SecureKeyPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('secure_key');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}
