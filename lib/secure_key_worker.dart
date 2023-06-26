import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:secure_key/exception/plugin_exception.dart';
import 'package:secure_key/secure_key_platform_interface.dart';

class SecureKey {
  late bool _isInitialize;

  SecureKey() {
    _isInitialize = false;
  }

  get isInitialize => _isInitialize;

  Future<bool> initialize({int size = 2048}) async {
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

  Future<String?> getPublicKey({bytes = false}) async {
    try {
      if (bytes) {
        Uint8List? bytes = await SecureKeyPlatform.instance.getPublicKeyBytes();
        if (bytes == null) {
          return null;
        }
        return base64.encode(bytes);
      } else {
        return await SecureKeyPlatform.instance.getPublicKey();
      }
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

  Future<String?> signSha256(String input, {bytes = false}) async {
    try {
      if (bytes) {
        Uint8List? bytes =
            await SecureKeyPlatform.instance.signSha256Bytes(input);
        if (bytes == null) {
          return null;
        }
        return base64.encode(bytes);
      } else {
        return await SecureKeyPlatform.instance.signSha256(input);
      }
    } catch (e) {
      if (e is PlatformException) {
        throw SecureKeyException(e.code, e.message ?? '');
      }
    }
    return null;
  }
}
