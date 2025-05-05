import 'package:flutter/material.dart';

class EditParticipantScreen extends StatefulWidget {
  final String name;
  final String age;
  final String gender;

  const EditParticipantScreen({
    super.key,
    required this.name,
    required this.age,
    required this.gender,
  });

  @override
  State<EditParticipantScreen> createState() => _EditParticipantScreenState();
}

class _EditParticipantScreenState extends State<EditParticipantScreen> {
  late TextEditingController nameController;
  late TextEditingController ageController;
  late String gender;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.name);
    ageController = TextEditingController(text: widget.age);
    gender = widget.gender;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Participant"),
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
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: ageController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Age",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: gender,
              decoration: const InputDecoration(
                labelText: "Gender",
                border: OutlineInputBorder(),
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
                
                // Return the updated participant data
                final updatedParticipant = {
                  'name': nameController.text,
                  'age': ageController.text,
                  'gender': gender,
                };
                
                Navigator.pop(context, updatedParticipant);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[300],
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text("Save Changes", style: TextStyle(color: Colors.black)),
            ),
          ],
        ),
      ),
    );
  }
}
