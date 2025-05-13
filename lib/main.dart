import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

// Import your generated Firebase options
import 'firebase_options.dart';

// Import providers
import 'providers/race_provider.dart';
import 'providers/participant_provider.dart';
import 'providers/segment_time_provider.dart';

// Import Firebase service
import 'services/firebase_service.dart';

// Import screens
import 'screens/dashboard/dashboard_screen.dart';
import 'screens/race/add_race_screen.dart';
import 'screens/race/race_setup_screen.dart';
import 'screens/participant/add_participant_screen.dart';
import 'screens/participant/edit_participant_screen.dart';
import 'screens/time_tracking/time_tracking_screen.dart';
import 'screens/results/results_screen.dart';

// Import models
import 'models/race.dart';
import 'models/participant.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Initialize Firebase with platform-specific options
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('Firebase initialized successfully');

    // Initialize Firebase service without authentication
    await FirebaseService.initialize();
    print('Firebase service initialized');

    runApp(const MyApp());
  } catch (e) {
    print('Error during initialization: $e');
    runApp(ErrorApp(error: e.toString()));
  }
}

// Error app widget to show when initialization fails
class ErrorApp extends StatelessWidget {
  final String error;

  const ErrorApp({super.key, required this.error});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Race Tracking App'),
          backgroundColor: Colors.red,
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                const Text(
                  'Failed to initialize app',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  'This is likely due to Firebase configuration issues.',
                  style: TextStyle(color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    error,
                    style: const TextStyle(
                      fontSize: 12,
                      fontFamily: 'monospace',
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    // Restart the app
                    main();
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => RaceProvider()),
        ChangeNotifierProvider(create: (_) => ParticipantProvider()),
        ChangeNotifierProvider(create: (_) => SegmentTimeProvider()),
      ],
      child: MaterialApp(
        title: 'Race Tracking App',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        debugShowCheckedModeBanner: false,
        home: const DashboardScreen(),
        routes: {
          '/dashboard': (context) => const DashboardScreen(),
          '/add-race': (context) => const AddRaceScreen(),
          '/add-participant': (context) => const AddParticipantScreen(),
        },
        onGenerateRoute: (settings) {
          if (settings.name == '/race-setup') {
            final race = settings.arguments as Race;
            return MaterialPageRoute(
              builder: (context) => RaceSetupScreen(race: race),
            );
          } else if (settings.name == '/edit-participant') {
            final participant = settings.arguments as Participant;
            return MaterialPageRoute(
              builder:
                  (context) => EditParticipantScreen(participant: participant),
            );
          } else if (settings.name == '/time-tracking') {
            final race = settings.arguments as Race;
            return MaterialPageRoute(
              builder: (context) => TimeTrackingScreen(race: race),
            );
          } else if (settings.name == '/results') {
            final race = settings.arguments as Race;
            return MaterialPageRoute(
              builder: (context) => ResultsScreen(race: race),
            );
          }
          return null;
        },
      ),
    );
  }
}
