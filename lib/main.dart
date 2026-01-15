import 'package:flutter/material.dart';
import 'screens/config_loader_screen.dart';

void main() {
  runApp(const AgroAhpApp());
}

class AgroAhpApp extends StatelessWidget {
  const AgroAhpApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Agro-AHP Pro',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
        fontFamily: 'Roboto', // Default, but can be customized
      ),
      home: const ConfigLoaderScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
