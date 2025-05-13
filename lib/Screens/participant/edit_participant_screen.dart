// screens/participant/edit_participant_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/participant_provider.dart';
import '../../models/participant.dart'; // Ensure this imports Gender enum
import '../../utils/validators.dart';
import '../../widgets/shared/custom_text_field.dart';
import '../../widgets/shared/custom_button.dart';

class EditParticipantScreen extends StatefulWidget {
  final Participant participant;

  const EditParticipantScreen({super.key, required this.participant});

  @override
  State<EditParticipantScreen> createState() => _EditParticipantScreenState();
}

class _EditParticipantScreenState extends State<EditParticipantScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _bibNumberController;
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _ageController;
  late Gender _selectedGender;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    _bibNumberController = TextEditingController(
      text: widget.participant.bibNumber,
    );
    _firstNameController = TextEditingController(
      text: widget.participant.firstName,
    );
    _lastNameController = TextEditingController(
      text: widget.participant.lastName,
    );
    _ageController = TextEditingController(
      text: widget.participant.age.toString(),
    );
    _selectedGender = widget.participant.gender;
  }

  @override
  void dispose() {
    _bibNumberController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  Future<void> _updateParticipant() async {
    if (!_formKey.currentState!.validate()) return;

    final participantProvider = Provider.of<ParticipantProvider>(
      context,
      listen: false,
    );

    final updatedParticipant = widget.participant.copyWith(
      bibNumber: _bibNumberController.text.trim(),
      firstName: _firstNameController.text.trim(),
      lastName: _lastNameController.text.trim(),
      age: int.parse(_ageController.text),
      gender: _selectedGender,
    );

    final success = await participantProvider.updateParticipant(
      updatedParticipant,
    );

    if (success && mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Participant updated successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to update participant: ${participantProvider.error}',
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Participant'), centerTitle: true),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // BIB Number (read-only in edit mode)
              CustomTextField(
                controller: _bibNumberController,
                labelText: 'BIB Number',
                readOnly: true,
                prefixIcon: const Icon(Icons.confirmation_number),
              ),
              const SizedBox(height: 8),
              const Text(
                'BIB number cannot be changed',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                  fontStyle: FontStyle.italic,
                ),
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

              // Update Button
              Consumer<ParticipantProvider>(
                builder: (context, participantProvider, child) {
                  return CustomButton(
                    text: 'Update Participant',
                    onPressed:
                        participantProvider.isLoading
                            ? null
                            : _updateParticipant,
                    isLoading: participantProvider.isLoading,
                    icon: Icons.save,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
