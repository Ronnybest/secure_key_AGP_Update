
import 'secure_key_platform_interface.dart';

class SecureKey {
  Future<String?> getPlatformVersion() {
    return SecureKeyPlatform.instance.getPlatformVersion();
  }
}
