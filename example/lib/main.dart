import 'package:flutter/material.dart';
import 'package:secure_key/secure_key.dart';

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
                    encryptedValue =
                        await _secureKeyPlugin.encryptWithRsa('Bearer ');
                    print('ENCRYPT: $encryptedValue');
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
                    var res = await _secureKeyPlugin
                        .decryptWithRsa(encryptedValue ?? '');
                    print('DECRYPT: $res');
                  } catch (e) {
                    print('DECRYPT:\n $e');
                  }
                },
                child: const Text('DECRYPT WITH RSA'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
//