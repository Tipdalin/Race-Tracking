import 'package:flutter/material.dart';
import 'package:race_tracking/Screens/race_setup.dart';

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 0, 0, 0),
        title: const Center(
          child: Text(
            'Race Tracking App',
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.normal,
              color: Color.fromARGB(255, 255, 255, 255),
            ),
          ),
        ),
      ),
      body: Container(
        color: const Color.fromARGB(255, 0, 0, 0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Image.asset(
                'assets/1.2.png',
                width: 500,
                height: 500,
                fit: BoxFit.cover,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 255, 255, 255),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 50,
                    vertical: 20,
                  ),
                  textStyle: const TextStyle(
                    fontSize: 20,
                    color: Color.fromARGB(255, 0, 0, 0),
                  ),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const RaceSetupScreen(),
                    ),
                  );
                },
                child: const Text('Get Started'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
