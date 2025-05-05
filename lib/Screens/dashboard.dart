import 'package:flutter/material.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Dummy data for races and participants
    final races = [
      {'id': '1', 'name': 'Race1', 'type': 'Triathlon', 'status': 'Not Started'},
      {'id': '2', 'name': 'Race2', 'type': 'Triathlon', 'status': 'In Progress'},
      {'id': '3', 'name': 'Race3', 'type': 'Triathlon', 'status': 'Not Started'},
      {'id': '4', 'name': 'Race4', 'type': 'Triathlon', 'status': 'Finished'},
    ];

    final participants = [
      {'number': '001', 'name': 'Kim Jennie', 'age': '28', 'gender': 'Female'},
      {'number': '002', 'name': 'Rosie', 'age': '27', 'gender': 'Female'},
      {'number': '003', 'name': 'Kim Jisoo', 'age': '30', 'gender': 'Female'},
    ];

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Dashboard'),
          backgroundColor: Colors.grey[300],
          centerTitle: true,
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Races'),
              Tab(text: 'Participants'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Races Tab
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Total Races: ${races.length}', 
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: races.length,
                    itemBuilder: (context, index) {
                      final race = races[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        child: ListTile(
                          title: Text(race['name']!),
                          subtitle: Text(race['type']!),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Chip(
                                label: Text(race['status']!),
                                backgroundColor: _getStatusColor(race['status']!),
                              ),
                              IconButton(
                                icon: const Icon(Icons.edit),
                                onPressed: () async {
                                  // Navigate to edit race screen
                                  final result = await Navigator.pushNamed(
                                    context, 
                                    '/race-setup', 
                                    arguments: race
                                  );
                                  
                                  if (result != null) {
                                    // Update race with returned data
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('Race updated: ${(result as Map)['name']}'))
                                    );
                                  }
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () {
                                  // Show delete confirmation
                                  _showDeleteConfirmationDialog(context, 'race', race['name']!);
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
            
            // Participants Tab
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Total Participants: ${participants.length}', 
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: participants.length,
                    itemBuilder: (context, index) {
                      final participant = participants[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        child: ListTile(
                          leading: CircleAvatar(
                            child: Text(participant['number']!),
                          ),
                          title: Text(participant['name']!),
                          subtitle: Text('Age: ${participant['age']!} | ${participant['gender']!}'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit),
                                onPressed: () async {
                                  // Navigate to edit participant screen
                                  final result = await Navigator.pushNamed(
                                    context, 
                                    '/edit-participant',
                                    arguments: participant,
                                  );
                                  
                                  if (result != null) {
                                    // Update participant with returned data
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('Participant updated: ${(result as Map)['name']}'))
                                    );
                                  }
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () {
                                  // Show delete confirmation
                                  _showDeleteConfirmationDialog(context, 'participant', participant['name']!);
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
        floatingActionButton: Builder(
          builder: (context) {
            // Get current tab index
            final tabIndex = DefaultTabController.of(context).index;
            
            return FloatingActionButton(
              onPressed: () async {
                if (tabIndex == 0) {
                  // Navigate to add race screen
                  final result = await Navigator.pushNamed(context, '/add-race');
                  if (result != null) {
                    // Handle new race data
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Race added: ${(result as Map)['name']}'))
                    );
                  }
                } else {
                  // Navigate to add participant screen
                  final result = await Navigator.pushNamed(context, '/add-participant');
                  if (result != null) {
                    // Handle new participant data
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Participant added: ${(result as Map)['name']}'))
                    );
                  }
                }
              },
              child: const Icon(Icons.add),
            );
          }
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Not Started':
        return Colors.grey.shade300;
      case 'In Progress':
        return Colors.blue.shade200;
      case 'Finished':
        return Colors.green.shade200;
      default:
        return Colors.grey.shade300;
    }
  }

  Future<void> _showDeleteConfirmationDialog(BuildContext context, String itemType, String itemName) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete $itemType'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Are you sure you want to delete $itemName?'),
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