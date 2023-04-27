import 'package:flutter_test/flutter_test.dart';
import 'package:secure_key/secure_key_platform_interface.dart';
import 'package:secure_key/secure_key_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockSecureKeyPlatform
    with MockPlatformInterfaceMixin
    implements SecureKeyPlatform {
  @override
  Future<void> createPairKey() {
    throw UnimplementedError();
  }

  @override
  Future<void> getPublicKey() {
    throw UnimplementedError();
  }

  @override
  Future<void> getPublicKeyData() {
    throw UnimplementedError();
  }
  
  @override
  Future<void> getPrivatekey() {
    // TODO: implement getPrivatekey
    throw UnimplementedError();
  }
}

void main() {
  final SecureKeyPlatform initialPlatform = SecureKeyPlatform.instance;

  test('$MethodChannelSecureKey is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelSecureKey>());
  });

  // test('getPlatformVersion', () async {
  //   SecureKey secureKeyPlugin = SecureKey();
  //   MockSecureKeyPlatform fakePlatform = MockSecureKeyPlatform();
  //   SecureKeyPlatform.instance = fakePlatform;

  //   // expect(await secureKeyPlugin.getPlatformVersion(), '42');
  // });
}
