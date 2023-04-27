import 'secure_key_platform_interface.dart';

class SecureKey {
  Future<void> createPairKey() async {
    return await SecureKeyPlatform.instance.createPairKey();
  }

  Future<void> getPublicKey() async {
    return await SecureKeyPlatform.instance.getPublicKey();
  }

  Future<void> getPublicKeyData() async {
    return await SecureKeyPlatform.instance.getPublicKeyData();
  }

  Future<void> getPrivatekey() async {
    return await SecureKeyPlatform.instance.getPrivatekey();
  }
}
