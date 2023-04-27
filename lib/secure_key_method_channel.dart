import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'secure_key_platform_interface.dart';

/// An implementation of [SecureKeyPlatform] that uses method channels.
class MethodChannelSecureKey extends SecureKeyPlatform {
  @visibleForTesting
  final methodChannel = const MethodChannel('secure_key');

  @override
  Future<void> createPairKey() async {
    await methodChannel.invokeMethod<void>('createPairKey');
  }

  @override
  Future<void> getPublicKey() async {
    await methodChannel.invokeMethod<void>('getPublicKey');
  }

  @override
  Future<void> getPublicKeyData() async {
    await methodChannel.invokeMethod<void>('getPublicKeyData');
  }

  @override
  Future<void> getPrivatekey() async {
    await methodChannel.invokeMethod<void>('getPrivatekey');
  }
}
