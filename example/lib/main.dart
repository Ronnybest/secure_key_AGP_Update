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
  final _secureKeyPlugin = SecureKey();

  int? level;

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
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              width: double.maxFinite,
            ),
            OutlinedButton(
                onPressed: () async {
                  await _secureKeyPlugin.createPairKey();
                },
                child: const Text('Create')),
            const SizedBox(height: 16),
            OutlinedButton(
                onPressed: () async {
                  await _secureKeyPlugin.getPublicKey();
                },
                child: const Text('Get key')),
            const SizedBox(height: 16),
            OutlinedButton(
                onPressed: () async {
                  await _secureKeyPlugin.getPublicKeyData();
                },
                child: const Text('Get data')),
            OutlinedButton(
                onPressed: () async {
                  await _secureKeyPlugin.getPrivatekey();
                },
                child: const Text('Get Private Key')),
          ],
        ),
      ),
    );
  }
}
//