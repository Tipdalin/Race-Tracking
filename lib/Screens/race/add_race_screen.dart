// screens/race/add_race_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/race_provider.dart';
import '../../models/race.dart';
import '../../utils/constants.dart';
import '../../utils/validators.dart';
import '../../widgets/shared/custom_text_field.dart';
import '../../widgets/shared/custom_button.dart';

class AddRaceScreen extends StatefulWidget {
  const AddRaceScreen({super.key});

  @override
  State<AddRaceScreen> createState() => _AddRaceScreenState();
}

class _AddRaceScreenState extends State<AddRaceScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  String _selectedType = AppConstants.triathlon;
  List<Segment> _segments = [];

  @override
  void initState() {
    super.initState();
    _loadDefaultSegments();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _loadDefaultSegments() {
    final defaultSegments = AppConstants.defaultSegments[_selectedType] ?? [];
    _segments =
        defaultSegments
            .map(
              (seg) => Segment(
                name: seg['name'],
                distance: seg['distance'],
                order: seg['order'],
              ),
            )
            .toList();
    setState(() {});
  }

  Future<void> _createRace() async {
    if (!_formKey.currentState!.validate()) return;

    final raceProvider = Provider.of<RaceProvider>(context, listen: false);

    final raceId = await raceProvider.createRace(
      _nameController.text.trim(),
      _selectedType,
      _segments,
    );

    if (raceId != null && mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Race "${_nameController.text}" created successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to create race: ${raceProvider.error}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
            backgroundColor: Colors.blue[100],

      appBar: AppBar(
        backgroundColor: Colors.blue,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          color: Colors.white,
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Add New Race',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomTextField(
                controller: _nameController,
                labelText: 'Race Name',
                validator:
                    (value) => Validators.validateRequired(value, 'Race name'),
                prefixIcon: const Icon(Icons.sports_score),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedType,
                decoration: const InputDecoration(
                  labelText: 'Race Type',
                  prefixIcon: Icon(Icons.category),
                  border: OutlineInputBorder(),
                ),
                items: _buildRaceTypeItems(),
                onChanged: (value) {
                  setState(() {
                    _selectedType = value!;
                    _loadDefaultSegments();
                  });
                },
              ),
              const SizedBox(height: 24),
              const Text(
                'Segments',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              _buildSegmentsList(),
              const SizedBox(height: 24),
              Consumer<RaceProvider>(
                builder: (context, raceProvider, child) {
                  return CustomButton(
                    text: 'Create Race',
                    onPressed: raceProvider.isLoading ? null : _createRace,
                    isLoading: raceProvider.isLoading,
                    icon: Icons.add,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<DropdownMenuItem<String>> _buildRaceTypeItems() {
    const raceTypes = {
      AppConstants.triathlon: 'Triathlon',
      AppConstants.marathon: 'Marathon',
      AppConstants.cycling: 'Cycling',
      AppConstants.swimming: 'Swimming',
      AppConstants.aquathlon: 'Aquathlon',
      AppConstants.runAndBike: 'Run & Bike',
    };

    return raceTypes.entries.map((entry) {
      return DropdownMenuItem(value: entry.key, child: Text(entry.value));
    }).toList();
  }

  Widget _buildSegmentsList() {
    if (_segments.isEmpty) {
      return const Text('No segments configured for this race type.');
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children:
              _segments.map((segment) {
                return ListTile(
                  leading: CircleAvatar(child: Text(segment.order.toString())),
                  title: Text(_formatSegmentName(segment.name)),
                  subtitle: Text(segment.distance),
                  trailing: Icon(
                    _getSegmentIcon(segment.name),
                    color: Theme.of(context).primaryColor,
                  ),
                );
              }).toList(),
        ),
      ),
    );
  }

  String _formatSegmentName(String name) {
    // Convert snake_case to Title Case
    return name
        .replaceAll('_', ' ')
        .split(' ')
        .map((word) {
          return word.substring(0, 1).toUpperCase() + word.substring(1);
        })
        .join(' ');
  }

  IconData _getSegmentIcon(String segmentName) {
    switch (segmentName.toLowerCase()) {
      case 'swim':
        return Icons.pool;
      case 'cycle':
        return Icons.directions_bike;
      case 'run':
      case 'run1':
      case 'run2':
        return Icons.directions_run;
      default:
        return Icons.sports;
    }
  }
}
