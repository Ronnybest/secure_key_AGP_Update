import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:secure_key/secure_key.dart';

const String token =
    'Bearer eyJhbGciOiJSUzI1NiJ9.eyJtaWJfY2xpZW50X2lkIjoiMGU2YTU1MjMtZWE5ZS00ZDhiLTg2MGUtY2YyMDk3MmUwZjE2IiwidG9rZW5faWQiOiJkYmUyNjE3OC02ZGMyLTRkYjktYWUzMi03ZGVkYTY1YzhjZWIiLCJzY29wZSI6ImdvdmVybm1lbnRfc2VydmljZXMgYmFua2luZyIsImNsaWVudF9waW4iOiIyMTQxMjIwMDE1MDI4OSIsImF1dGhfdXNlcl9pZCI6NTQsImp0aSI6ImFmZWFhMWUwLWM2NTItNDRmZC05NGFjLTI0NjUzOTU2OWFkOCIsInN1YiI6IjIxNDEyMjAwMTUwMjg5IiwiaWF0IjoxNzE0MTI5NTQ2LCJleHAiOjE3MTQxMjk4NDZ9.ccj70nmutfkjRLuhdZgiWXGQExQKh1qRXtbouoynAj60_HmS11TEftyEYOYBIRxstNJZrLHb-vXVLh9KlmmuHuwB24s3Ek7PcE8UTfibyQtFdGurEE2-k5EP843gvo9Wh2pLoWjT7X7ygYnvKVs_GBXlJVUKjwjN-bJLrmIMZHMvAUa31YEw-wkEbd04NpEHjoO6fxxEBUV5YgqZ8f5mMEvvVH-K65nz9O0mNH3C2Tm2kiKV2P8NrpqATSKhWGi0CZvmPHnJr7sAPVOxVgTOAqYUkYpxGkHhGyll48SR2oxd-rqQcp7pHcttsPglnMoI15FxXiI4Po085pGFg8-hZA';
void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _secureKeyPlugin = SecureKey.instance;
  final storage = const FlutterSecureStorage(
      iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock));

  int? level;

  List<String> llll = [];

  String? encryptedValue;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: SizedBox(
          width: MediaQuery.sizeOf(context).width,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              OutlinedButton(
                onPressed: () async {
                  try {
                    await _secureKeyPlugin.initialize(size: 2048);
                    print('INIT');
                  } catch (e) {
                    print('INIT:\n $e');
                  }
                },
                child: const Text('INIT'),
              ),
              const SizedBox(height: 16),
              OutlinedButton(
                  onPressed: () async {
                    try {
                      var result = await _secureKeyPlugin.createPairKey();
                      print('Create:$result');
                    } catch (e) {
                      print('Create:\n$e');
                    }
                  },
                  child: const Text('Create')),
              const SizedBox(height: 16),
              OutlinedButton(
                onPressed: () async {
                  try {
                    var result = await _secureKeyPlugin.deleteKey();
                    print('DELETE:$result');
                  } catch (e) {
                    print('DELETE:\n$e');
                  }
                },
                child: const Text('DELETE'),
              ),
              const SizedBox(height: 16),
              OutlinedButton(
                onPressed: () async {
                  try {
                    var result =
                        await _secureKeyPlugin.getPublicKey(bytes: true);
                    print('GET:$result');
                  } catch (e) {
                    print('GET:\n$e');
                  }
                },
                child: const Text('Get key'),
              ),
              const SizedBox(height: 16),
              OutlinedButton(
                onPressed: () async {
                  try {
                    var result =
                        await _secureKeyPlugin.signSha256('1234', bytes: true);
                    print('SIGN:$result');
                  } catch (e) {
                    print('SIGN:\n$e');
                  }
                },
                child: const Text('Sign sha 256'),
              ),
              const SizedBox(height: 16),
              OutlinedButton(
                onPressed: () async {
                  try {
                    var now = DateTime.now();

                    await _secureKeyPlugin.write(key: 'key', value: token);
                    print(
                        'ENCRYPT  TIME: ${DateTime.now().difference(now).inMilliseconds}');
                    setState(() {});
                  } catch (e) {
                    print('ENCRYPT:\n $e');
                  }
                },
                child: const Text('ENCRYPT WITH RSA'),
              ),
              OutlinedButton(
                onPressed: () async {
                  try {
                    var now = DateTime.now();
                    var res = await _secureKeyPlugin.read(key: 'key');

                    print(
                        'DECRYPT: $res   TIME: ${DateTime.now().difference(now).inMilliseconds}');
                  } catch (e) {
                    print('DECRYPT:\n $e');
                  }
                },
                child: const Text('DECRYPT WITH RSA'),
              ),
              OutlinedButton(
                onPressed: () async {
                  try {
                    var now = DateTime.now();
                    await storage.write(key: 'key', value: token);

                    print(
                        'SECURE STORAGE TIME: ${DateTime.now().difference(now).inMilliseconds}');
                  } catch (e) {
                    print('DECRYPT:\n $e');
                  }
                },
                child: const Text('SAVE INTO SECURE STORAGE'),
              ),
              OutlinedButton(
                onPressed: () async {
                  try {
                    var now = DateTime.now();
                    String? res = await storage.read(key: 'key');

                    print(
                        'SECURE STORAGE TIME READ: $res   TIME: ${DateTime.now().difference(now).inMilliseconds}');
                  } catch (e) {
                    print('DECRYPT:\n $e');
                  }
                },
                child: const Text('READ FROM SECURE STORAGE'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
//