import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'secure_key_platform_interface.dart';

/// An implementation of [SecureKeyPlatform] that uses method channels.
class MethodChannelSecureKey extends SecureKeyPlatform {
  @visibleForTesting
  final methodChannel = const MethodChannel('secure_key');

  @override
  Future<bool> initialize(int size) async {
    final result =
        await methodChannel.invokeMethod<bool>('initialize', {'size': size});
    return result ?? false;
  }

  @override
  Future<String?> getPublicKey() async {
    return await methodChannel.invokeMethod<String>('getPublicKey');
  }

  @override
  Future<bool> createPairKey() async {
    final result = await methodChannel.invokeMethod<bool>('createPairKey');
    return result ?? false;
  }

  @override
  Future<bool> deleteKey() async {
    final result = await methodChannel.invokeMethod<bool?>('deleteKey');
    return result ?? false;
  }

  @override
  Future<String?> encryptWithRsa(String input) async {
    return await methodChannel
        .invokeMethod<String>('encryptWithRsa', {'encryptInput': input});
  }

  @override
  Future<String?> decryptWithRsa(String input) async {
    return await methodChannel
        .invokeMethod('decryptWithRsa', {'decryptInput': input});
  }

  @override
  Future<String?> signSha256(String input) async {
    return await methodChannel
        .invokeMethod<String>('signSha256', {'inputSha256': input});
  }

  @override
  Future<Uint8List?> signSha256Bytes(String input) async {
    return await methodChannel
        .invokeMethod<Uint8List>('signSha256Bytes', {'inputSha256': input});
  }

  @override
  Future<Uint8List?> getPublicKeyBytes() async {
    return await methodChannel.invokeMethod<Uint8List>('getPublicKeyBytes');
  }
}
