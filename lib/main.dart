import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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

    // For web development, we'll use a simpler approach
    if (kIsWeb) {
      // Initialize without authentication for now
      await initializeWithoutAuth();
    } else {
      // Mobile platforms can use authentication
      await initializeWithAuth();
    }

    runApp(const MyApp());
  } catch (e) {
    print('Error during initialization: $e');
    runApp(ErrorApp(error: e.toString()));
  }
}

// Initialize without authentication (for web debugging)
Future<void> initializeWithoutAuth() async {
  try {
    // Initialize Firebase service first
    await FirebaseService.initialize();
    print('Firebase service initialized without auth');
  } catch (e) {
    print('Error initializing Firebase service: $e');
    rethrow;
  }
}

// Initialize with authentication (for mobile)
Future<void> initializeWithAuth() async {
  try {
    // Check if user is already signed in
    User? currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      // Try to sign in anonymously
      await retryOperation(() async {
        UserCredential userCredential =
            await FirebaseAuth.instance.signInAnonymously();
        print('Signed in anonymously: ${userCredential.user?.uid}');
        return userCredential;
      }, maxAttempts: 3);
    } else {
      print('User already signed in: ${currentUser.uid}');
    }

    // Create user document if needed
    currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      await createUserDocument(currentUser.uid);
    }

    await FirebaseService.initialize();
    print('Firebase service initialized with auth');
  } catch (e) {
    print('Error initializing with auth: $e');
    // Fall back to no-auth initialization
    await initializeWithoutAuth();
  }
}

// Function to retry operations with exponential backoff
Future<T> retryOperation<T>(
  Future<T> Function() operation, {
  int maxAttempts = 3,
  Duration baseDelay = const Duration(seconds: 1),
}) async {
  int attempt = 0;
  late dynamic lastError;

  while (attempt < maxAttempts) {
    try {
      return await operation();
    } catch (e) {
      lastError = e;
      attempt++;

      if (attempt >= maxAttempts) {
        print('Max retry attempts reached. Last error: $e');
        rethrow;
      }

      Duration delay = baseDelay * pow(2, attempt - 1);
      print('Retry attempt $attempt after ${delay.inMilliseconds}ms');
      await Future.delayed(delay);
    }
  }

  throw lastError;
}

// Function to create user document with required role
Future<void> createUserDocument(String userId) async {
  try {
    await retryOperation(() async {
      final userDoc =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(userId)
              .get();

      if (!userDoc.exists) {
        await FirebaseFirestore.instance.collection('users').doc(userId).set({
          'role': 'race_manager',
          'createdAt': FieldValue.serverTimestamp(),
          'uid': userId,
          'platform': kIsWeb ? 'web' : 'mobile',
        });
        print('User document created for $userId');
      } else {
        print('User document already exists for $userId');
      }
    });
  } catch (e) {
    print('Error creating user document: $e');
    // Don't rethrow - app can still work without user document
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
                  'This is likely due to Firebase configuration or network issues.',
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
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () {
                    // Try without auth
                    runApp(const MyApp());
                  },
                  child: const Text('Continue without authentication'),
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
        home: const AuthWrapper(),
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

// Wrapper to handle authentication state
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      // For web, go directly to dashboard
      return const DashboardScreen();
    }

    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Authentication Error'),
                  Text(snapshot.error.toString()),
                  ElevatedButton(
                    onPressed: () {
                      // Continue to dashboard anyway
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (_) => const DashboardScreen(),
                        ),
                      );
                    },
                    child: const Text('Continue without auth'),
                  ),
                ],
              ),
            ),
          );
        }

        // Always go to dashboard
        return const DashboardScreen();
      },
    );
  }
}
