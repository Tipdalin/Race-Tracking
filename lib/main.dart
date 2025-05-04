import 'package:flutter/material.dart';
import 'screens/homepage.dart';
import 'screens/race_setup.dart';
import 'screens/add_participant.dart';
//import 'screens/edit_participant.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Race Tracking App',
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => const MyHomePage(),
        '/race-setup': (context) => const RaceSetupScreen(),
        '/add-participant': (context) => const AddParticipantScreen(),
      },
    );
  }
}
