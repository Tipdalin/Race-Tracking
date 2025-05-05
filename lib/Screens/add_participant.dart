import 'package:flutter/material.dart';

class AddParticipantScreen extends StatefulWidget {
  const AddParticipantScreen({super.key});

  @override
  State<AddParticipantScreen> createState() => _AddParticipantScreenState();
}

class _AddParticipantScreenState extends State<AddParticipantScreen> {
  final nameController = TextEditingController();
  final ageController = TextEditingController();
  String gender = 'Female';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Participant'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: Colors.grey[300],
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: nameController, 
              decoration: const InputDecoration(
                labelText: "Name", 
                border: OutlineInputBorder()
              )
            ),
            const SizedBox(height: 10),
            TextField(
              controller: ageController, 
              keyboardType: TextInputType.number, 
              decoration: const InputDecoration(
                labelText: "Age", 
                border: OutlineInputBorder()
              )
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: gender,
              decoration: const InputDecoration(
                labelText: "Gender", 
                border: OutlineInputBorder()
              ),
              items: const [
                DropdownMenuItem(value: 'Male', child: Text('Male')),
                DropdownMenuItem(value: 'Female', child: Text('Female')),
                DropdownMenuItem(value: 'Other', child: Text('Other')),
              ],
              onChanged: (value) => setState(() => gender = value!),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Validate inputs
                if (nameController.text.isEmpty || ageController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please fill all fields'))
                  );
                  return;
                }
                
                // Create participant object
                final newParticipant = {
                  'name': nameController.text,
                  'age': ageController.text,
                  'gender': gender,
                  // In a real app, you would generate a unique number
                  'number': '00${DateTime.now().millisecondsSinceEpoch % 1000}',
                };
                
                // Return the new participant to previous screen
                Navigator.pop(context, newParticipant);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[300],
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text("Add Participant", style: TextStyle(color: Colors.black)),
            ),
          ],
        ),
      ),
    );
  }
}