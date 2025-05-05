import 'package:flutter/material.dart';

class AddRaceScreen extends StatefulWidget {
  const AddRaceScreen({super.key});

  @override
  State<AddRaceScreen> createState() => _AddRaceScreenState();
}

class _AddRaceScreenState extends State<AddRaceScreen> {
  final raceNameController = TextEditingController();
  String raceType = 'Triathlon';
  String raceStatus = 'Not Started'; // Added status field with default value

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey[300],
        title: const Text('Add New Race', style: TextStyle(color: Colors.black)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: raceNameController,
              decoration: const InputDecoration(
                labelText: 'Race Name',
                border: OutlineInputBorder()
              )
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: raceType,
              decoration: const InputDecoration(
                labelText: 'Type',
                border: OutlineInputBorder()
              ),
              items: const [
                DropdownMenuItem(value: 'Triathlon', child: Text('Triathlon')),
                DropdownMenuItem(value: 'Marathon', child: Text('Marathon')),
                DropdownMenuItem(value: 'Cycling', child: Text('Cycling')),
                DropdownMenuItem(value: 'Swimming', child: Text('Swimming')),
              ],
              onChanged: (value) => setState(() => raceType = value!),
            ),
            const SizedBox(height: 16),
            // Added status dropdown
            DropdownButtonFormField<String>(
              value: raceStatus,
              decoration: const InputDecoration(
                labelText: 'Status',
                border: OutlineInputBorder()
              ),
              items: const [
                DropdownMenuItem(value: 'Not Started', child: Text('Not Started')),
                DropdownMenuItem(value: 'In Progress', child: Text('In Progress')),
                DropdownMenuItem(value: 'Finished', child: Text('Finished')),
              ],
              onChanged: (value) => setState(() => raceStatus = value!),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                // Validate inputs
                if (raceNameController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please enter a race name'))
                  );
                  return;
                }

                // Create race object - now includes the selected status
                final newRace = {
                  'id': DateTime.now().millisecondsSinceEpoch.toString(),
                  'name': raceNameController.text,
                  'type': raceType,
                  'status': raceStatus, // Use selected status instead of hardcoded value
                };
                
                // Return the new race to previous screen
                Navigator.pop(context, newRace);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[300],
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text("Add Race", style: TextStyle(color: Colors.black)),
            ),
          ],
        ),
      ),
    );
  }
}