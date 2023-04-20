import 'package:flutter_test/flutter_test.dart';
import 'package:secure_key/secure_key.dart';
import 'package:secure_key/secure_key_platform_interface.dart';
import 'package:secure_key/secure_key_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockSecureKeyPlatform
    with MockPlatformInterfaceMixin
    implements SecureKeyPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final SecureKeyPlatform initialPlatform = SecureKeyPlatform.instance;

  test('$MethodChannelSecureKey is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelSecureKey>());
  });

  test('getPlatformVersion', () async {
    SecureKey secureKeyPlugin = SecureKey();
    MockSecureKeyPlatform fakePlatform = MockSecureKeyPlatform();
    SecureKeyPlatform.instance = fakePlatform;

    expect(await secureKeyPlugin.getPlatformVersion(), '42');
  });
}
