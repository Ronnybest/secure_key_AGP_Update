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

  Future<void> createPairKey() {
    throw UnimplementedError('createPairKey() has not been implemented.');
  }

  Future<void> getPublicKey() {
    throw UnimplementedError('getPublicKey() has not been implemented.');
  }

  Future<void> getPublicKeyData() {
    throw UnimplementedError('getPublicKeyData() has not been implemented.');
  }

  Future<void> getPrivatekey() async {
    throw UnimplementedError('getPrivatekey() has not been implemented.');
  }
}
