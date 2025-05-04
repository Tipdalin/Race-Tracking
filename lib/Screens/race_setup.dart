import 'package:flutter/material.dart';

class RaceSetupScreen extends StatelessWidget {
  const RaceSetupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Race Setup")),
      body: const Center(
        child: Text(
          'Welcome to the Race Setup screen!',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
