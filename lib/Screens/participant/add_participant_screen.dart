import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/participant_provider.dart';
import '../../providers/race_provider.dart';
import '../../models/participant.dart';
import '../../models/race.dart';
import '../../utils/validators.dart';
import '../../widgets/shared/custom_text_field.dart';
import '../../widgets/shared/custom_button.dart';

class AddParticipantScreen extends StatefulWidget {
  final Race? selectedRace;

  const AddParticipantScreen({super.key, this.selectedRace});

  @override
  State<AddParticipantScreen> createState() => _AddParticipantScreenState();
}

class _AddParticipantScreenState extends State<AddParticipantScreen> {
  final _formKey = GlobalKey<FormState>();
  final _bibNumberController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _ageController = TextEditingController();
  Gender _selectedGender = Gender.male;
  Race? _selectedRace;

  @override
  void initState() {
    super.initState();
    _selectedRace = widget.selectedRace;
    _generateBibNumber();
  }

  @override
  void dispose() {
    _bibNumberController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  void _generateBibNumber() {
    // Generate a random 3-digit BIB number
    final random = DateTime.now().millisecondsSinceEpoch % 1000;
    _bibNumberController.text = random.toString().padLeft(3, '0');
  }

  Future<void> _addParticipant() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedRace == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a race first'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final participantProvider = Provider.of<ParticipantProvider>(
      context,
      listen: false,
    );

    final participantId = await participantProvider.createParticipant(
      bibNumber: _bibNumberController.text.trim(),
      firstName: _firstNameController.text.trim(),
      lastName: _lastNameController.text.trim(),
      age: int.parse(_ageController.text),
      gender: _selectedGender,
      raceId: _selectedRace!.id,
    );

    if (participantId != null && mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Participant added successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to add participant: ${participantProvider.error}',
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Participant'), centerTitle: true),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Race Selection (if not pre-selected)
              if (widget.selectedRace == null) ...[
                _buildRaceSelector(),
                const SizedBox(height: 16),
              ] else ...[
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        const Icon(Icons.directions_run),
                        const SizedBox(width: 8),
                        Text(
                          'Adding to: ${_selectedRace!.name}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // BIB Number
              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      controller: _bibNumberController,
                      labelText: 'BIB Number',
                      keyboardType: TextInputType.number,
                      validator: Validators.validateBibNumber,
                      prefixIcon: const Icon(Icons.confirmation_number),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: _generateBibNumber,
                    icon: const Icon(Icons.refresh),
                    tooltip: 'Generate new BIB',
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // First Name
              CustomTextField(
                controller: _firstNameController,
                labelText: 'First Name',
                validator:
                    (value) => Validators.validateRequired(value, 'First name'),
                prefixIcon: const Icon(Icons.person),
              ),
              const SizedBox(height: 16),

              // Last Name
              CustomTextField(
                controller: _lastNameController,
                labelText: 'Last Name',
                validator:
                    (value) => Validators.validateRequired(value, 'Last name'),
                prefixIcon: const Icon(Icons.person),
              ),
              const SizedBox(height: 16),

              // Age
              CustomTextField(
                controller: _ageController,
                labelText: 'Age',
                keyboardType: TextInputType.number,
                validator: Validators.validateAge,
                prefixIcon: const Icon(Icons.cake),
              ),
              const SizedBox(height: 16),

              // Gender
              DropdownButtonFormField<Gender>(
                value: _selectedGender,
                decoration: const InputDecoration(
                  labelText: 'Gender',
                  prefixIcon: Icon(Icons.people),
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: Gender.male, child: Text('Male')),
                  DropdownMenuItem(value: Gender.female, child: Text('Female')),
                  DropdownMenuItem(value: Gender.other, child: Text('Other')),
                ],
                onChanged: (value) {
                  setState(() => _selectedGender = value!);
                },
              ),
              const SizedBox(height: 24),

              // Add Button
              Consumer<ParticipantProvider>(
                builder: (context, participantProvider, child) {
                  return CustomButton(
                    text: 'Add Participant',
                    onPressed:
                        participantProvider.isLoading ? null : _addParticipant,
                    isLoading: participantProvider.isLoading,
                    icon: Icons.person_add,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRaceSelector() {
    return Consumer<RaceProvider>(
      builder: (context, raceProvider, child) {
        final availableRaces =
            raceProvider.races
                .where((race) => race.status != RaceStatus.finished)
                .toList();

        if (availableRaces.isEmpty) {
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Icon(Icons.warning, color: Colors.orange),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text('No available races. Create a race first.'),
                  ),
                ],
              ),
            ),
          );
        }

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Select Race',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<Race>(
                  value: _selectedRace,
                  decoration: const InputDecoration(
                    labelText: 'Race',
                    prefixIcon: Icon(Icons.sports_score),
                    border: OutlineInputBorder(),
                  ),
                  validator:
                      (value) => value == null ? 'Please select a race' : null,
                  items:
                      availableRaces.map((race) {
                        return DropdownMenuItem(
                          value: race,
                          child: Text('${race.name} (${race.statusString})'),
                        );
                      }).toList(),
                  onChanged: (value) {
                    setState(() => _selectedRace = value);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
