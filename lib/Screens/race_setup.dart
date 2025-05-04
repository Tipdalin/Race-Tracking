import 'package:flutter/material.dart';
import 'edit_participant.dart';

class RaceSetupScreen extends StatelessWidget {
  const RaceSetupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final participants = [
      {'number': '001', 'name': 'Kim Jennie', 'age': '28', 'gender': 'Female'},
      {'number': '002', 'name': 'Rosie', 'age': '27', 'gender': 'Female'},
      {'number': '003', 'name': 'Kim Jisoo', 'age': '30', 'gender': 'Female'},
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey[300],
        title: const Text('Race Setup', style: TextStyle(color: Colors.black)),
        leading: const BackButton(color: Colors.black),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const TextField(decoration: InputDecoration(labelText: 'Race Name', border: OutlineInputBorder())),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: 'Triathlon',
              decoration: const InputDecoration(labelText: 'Type', border: OutlineInputBorder()),
              items: const [
                DropdownMenuItem(value: 'Triathlon', child: Text('Triathlon')),
                DropdownMenuItem(value: 'Marathon', child: Text('Marathon')),
              ],
              onChanged: (_) {},
            ),
            const SizedBox(height: 20),
            const Align(alignment: Alignment.centerLeft, child: Text("Participants", style: TextStyle(fontSize: 16))),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: participants.length,
                itemBuilder: (context, index) {
                  final p = participants[index];
                  return Card(
                    child: ListTile(
                      leading: Text(p['number']!),
                      title: Text(p['name']!),
                      trailing: TextButton(
                        child: const Text("Edit"),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => EditParticipantScreen(
                                name: p['name']!,
                                age: p['age']!,
                                gender: p['gender']!,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {},
              child: const Text('Start Race'),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, '/add-participant'),
        child: const Icon(Icons.add),
      ),
    );
  }
}
