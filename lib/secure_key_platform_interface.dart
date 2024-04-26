import 'dart:typed_data';

import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'secure_key_method_channel.dart';

abstract class SecureKeyPlatform extends PlatformInterface {
  /// Constructs a SecureKeyPlatform.
  SecureKeyPlatform() : super(token: _token);

  static final Object _token = Object();

  static SecureKeyPlatform _instance = MethodChannelSecureKey();

  /// The default instance of [SecureKeyPlatform] to use.
  ///
  /// Defaults to [MethodChannelSecureKey].
  static SecureKeyPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [SecureKeyPlatform] when
  /// they register themselves.
  static set instance(SecureKeyPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<bool> initialize(int size) {
    throw UnimplementedError('initialize() has not been implemented.');
  }

  Future<String?> getPublicKey() {
    throw UnimplementedError('getPublicKey() has not been implemented.');
  }

  Future<Uint8List?> getPublicKeyBytes() {
    throw UnimplementedError('getPublicKeybytes() has not been implemented.');
  }

  Future<bool> createPairKey() {
    throw UnimplementedError('createPairKey() has not been implemented.');
  }

  Future<bool> deleteKey() async {
    throw UnimplementedError('deleteKey() has not been implemented.');
  }

  Future<String?> decryptWithRsa(String input) {
    throw UnimplementedError('decryptWithRsa() has not been implemented.');
  }

  Future<String?> encryptWithRsa(String input) {
    throw UnimplementedError('encryptWithRsa() has not been implemented.');
  }

  Future<String?> signSha256(String input) {
    throw UnimplementedError('signSha256() has not been implemented.');
  }

  Future<Uint8List?> signSha256Bytes(String input) {
    throw UnimplementedError('signSha256Bytes() has not been implemented.');
  }
}
