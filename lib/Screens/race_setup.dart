import 'package:flutter/material.dart';
import 'edit_participant.dart';

class RaceSetupScreen extends StatefulWidget {
  const RaceSetupScreen({super.key});

  @override
  State<RaceSetupScreen> createState() => _RaceSetupScreenState();
}

class _RaceSetupScreenState extends State<RaceSetupScreen> {
  final raceNameController = TextEditingController();
  String raceType = 'Triathlon';
  String raceId = '';
  String raceStatus = 'Not Started';

  // Default participants list
  final participants = [
    {'number': '001', 'name': 'Kim Jennie', 'age': '28', 'gender': 'Female'},
    {'number': '002', 'name': 'Rosie', 'age': '27', 'gender': 'Female'},
    {'number': '003', 'name': 'Kim Jisoo', 'age': '30', 'gender': 'Female'},
  ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Get race data from arguments
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args != null && args is Map<String, dynamic>) {
      raceNameController.text = args['name'] ?? '';
      raceType = args['type'] ?? 'Triathlon';
      raceId = args['id'] ?? '';
      raceStatus = args['status'] ?? 'Not Started';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey[300],
        title: Text(
          'Race Details',
          style: const TextStyle(color: Colors.black)
        ),
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
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: raceType,
              decoration: const InputDecoration(
                labelText: 'Type',
                border: OutlineInputBorder()
              ),
              items: const [
                DropdownMenuItem(value: 'Triathlon', child: Text('Triathlon')),
                DropdownMenuItem(value: 'Marathon', child: Text('Marathon')),
                
              ],
              onChanged: (value) => setState(() => raceType = value!),
            ),
            const SizedBox(height: 10),
            // Added status dropdown for editing
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
            const SizedBox(height: 20),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text("Participants", style: TextStyle(fontSize: 16))
            ),
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
                      subtitle: Text('Age: ${p['age']!} | ${p['gender']!}'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextButton(
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
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () {
                              // Show delete confirmation
                              _showDeleteParticipantDialog(context, p['name']!);
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    // Save race and return to dashboard
                    final updatedRace = {
                      'id': raceId,
                      'name': raceNameController.text,
                      'type': raceType,
                      'status': raceStatus,
                    };
                    Navigator.pop(context, updatedRace);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[300],
                  ),
                  child: const Text('Save Changes', style: TextStyle(color: Colors.black)),
                ),
                ElevatedButton(
                  onPressed: () {
                    // Start the race and change status
                    setState(() {
                      raceStatus = 'In Progress';
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Race started!'))
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[400],
                  ),
                  child: const Text('Start Race', style: TextStyle(color: Colors.white)),
                ),
              ],
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

  Future<void> _showDeleteParticipantDialog(BuildContext context, String name) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Participant'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Are you sure you want to delete $name?'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Delete'),
              onPressed: () {
                // Delete logic would go here
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}