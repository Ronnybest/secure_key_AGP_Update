import 'package:flutter/services.dart';
import 'package:secure_key/exception/plugin_exception.dart';

import 'secure_key_platform_interface.dart';

class SecureKey {
  late bool _isInitialize;

  SecureKey() {
    _isInitialize = false;
  }

  Future<bool> initialize({int size = 1024}) async {
    _isInitialize = false;
    try {
      _isInitialize = await SecureKeyPlatform.instance.initialize(size);
    } catch (e) {
      if (e is PlatformException) {
        throw SecureKeyException(e.code, e.message ?? '');
      }
    }
    return _isInitialize;
  }

  Future<String?> getPublicKey() async {
    try {
      return await SecureKeyPlatform.instance.getPublicKey();
    } catch (e) {
      if (e is PlatformException) {
        throw SecureKeyException(e.code, e.message ?? '');
      }
    }
    return null;
  }

  Future<bool> createPairKey() async {
    try {
      return await SecureKeyPlatform.instance.createPairKey();
    } catch (e) {
      if (e is PlatformException) {
        throw SecureKeyException(e.code, e.message ?? '');
      }
    }
    return false;
  }

  Future<bool> deleteKey() async {
    try {
      return await SecureKeyPlatform.instance.deleteKey();
    } catch (e) {
      if (e is PlatformException) {
        throw SecureKeyException(e.code, e.message ?? '');
      }
    }
    return false;
  }

  Future<String?> signSha256(String input) async {
    try {
      return await SecureKeyPlatform.instance.signSha256(input);
    } catch (e) {
      if (e is PlatformException) {
        throw SecureKeyException(e.code, e.message ?? '');
      }
    }
    return null;
  }
}
