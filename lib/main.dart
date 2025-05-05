import 'package:flutter/material.dart';
import 'screens/homepage.dart';
import 'screens/race_setup.dart';
import 'screens/add_race.dart';
import 'screens/add_participant.dart';
import 'screens/edit_participant.dart';
import 'screens/dashboard.dart';

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
        '/dashboard': (context) => const DashboardScreen(),
        '/race-setup': (context) => const RaceSetupScreen(),
        '/add-race': (context) => const AddRaceScreen(),
        '/add-participant': (context) => const AddParticipantScreen(),
      },
      // For screens that need arguments
      onGenerateRoute: (settings) {
        if (settings.name == '/edit-participant') {
          final args = settings.arguments as Map<String, String>;
          return MaterialPageRoute(
            builder: (context) => EditParticipantScreen(
              name: args['name'] ?? '',
              age: args['age'] ?? '',
              gender: args['gender'] ?? 'Female',
            ),
          );
        }
        return null;
      },
    );
  }
}