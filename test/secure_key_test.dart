import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:secure_key/secure_key_platform_interface.dart';

class MockSecureKeyPlatform
    with MockPlatformInterfaceMixin
    implements SecureKeyPlatform {
  @override
  Future<bool> createPairKey() {
    // TODO: implement createPairKey
    throw UnimplementedError();
  }

  @override
  Future<bool> deleteKey() {
    // TODO: implement deleteKey
    throw UnimplementedError();
  }

  @override
  Future<String?> getPublicKey() {
    // TODO: implement getPublicKey
    throw UnimplementedError();
  }

  @override
  Future<bool> initialize(int size) {
    // TODO: implement initialize
    throw UnimplementedError();
  }

  @override
  Future<String?> signSha256(String input) {
    // TODO: implement signSha256
    throw UnimplementedError();
  }

  @override
  Future<Uint8List?> getPublicKeyBytes() {
    // TODO: implement getPublicKeyBytes
    throw UnimplementedError();
  }

  @override
  Future<Uint8List?> signSha256Bytes(String input) {
    // TODO: implement signSha256Bytes
    throw UnimplementedError();
  }

  @override
  Future<String> decryptWithRsa(String input) {
    // TODO: implement decryptWithRsa
    throw UnimplementedError();
  }

  @override
  Future<String> encryptWithRsa(String input) {
    // TODO: implement encryptWithRsa
    throw UnimplementedError();
  }
}

void main() {
  // test('$MethodChannelSecureKey is the default instance', () {
  //   expect(initialPlatform, isInstanceOf<MethodChannelSecureKey>());
  // });

  // test('getPlatformVersion', () async {
  //   SecureKey secureKeyPlugin = SecureKey();
  //   MockSecureKeyPlatform fakePlatform = MockSecureKeyPlatform();
  //   SecureKeyPlatform.instance = fakePlatform;

  //   // expect(await secureKeyPlugin.getPlatformVersion(), '42');
  // });
}
