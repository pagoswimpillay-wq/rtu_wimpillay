import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'pantallas/inicio_pasajero.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const AplicacionWimpillay());
}

class AplicacionWimpillay extends StatelessWidget {
  const AplicacionWimpillay({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Wimpillay',
      theme: ThemeData(primarySwatch: Colors.green),
      home: const InicioPasajero(),
    );
  }
}
