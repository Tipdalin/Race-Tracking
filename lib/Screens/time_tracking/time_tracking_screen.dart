// screens/time_tracking/time_tracking_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/race_provider.dart';
import '../../providers/participant_provider.dart';
import '../../providers/segment_time_provider.dart';
import '../../models/race.dart';
import '../../models/participant.dart';
import '../../widgets/shared/loading_widget.dart';

class TimeTrackingScreen extends StatefulWidget {
  final Race race;

  const TimeTrackingScreen({super.key, required this.race});

  @override
  State<TimeTrackingScreen> createState() => _TimeTrackingScreenState();
}

class _TimeTrackingScreenState extends State<TimeTrackingScreen> {
  String? _selectedSegment;
  List<Participant> _participants = [];

  @override
  void initState() {
    super.initState();
    _initializeData();
    _selectFirstSegment();
  }

  void _initializeData() {
    final participantProvider = Provider.of<ParticipantProvider>(
      context,
      listen: false,
    );
    final segmentTimeProvider = Provider.of<SegmentTimeProvider>(
      context,
      listen: false,
    );

    participantProvider.watchParticipantsByRaceId(widget.race.id);
    segmentTimeProvider.watchSegmentTimesByRaceId(widget.race.id);
  }

  void _selectFirstSegment() {
    if (widget.race.segments.isNotEmpty) {
      _selectedSegment = widget.race.segments.first.name;
    }
  }

  Future<void> _trackTime(Participant participant) async {
    if (_selectedSegment == null) return;

    final segmentTimeProvider = Provider.of<SegmentTimeProvider>(
      context,
      listen: false,
    );

    final success = await segmentTimeProvider.trackTime(
      participant.id,
      widget.race.id,
      _selectedSegment!,
    );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Time tracked for ${participant.fullName}'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Future<void> _untrackTime(Participant participant) async {
    if (_selectedSegment == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Untrack Time'),
            content: Text(
              'Remove time for ${participant.fullName} in $_selectedSegment?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Untrack'),
              ),
            ],
          ),
    );

    if (confirmed != true) return;

    final segmentTimeProvider = Provider.of<SegmentTimeProvider>(
      context,
      listen: false,
    );

    final success = await segmentTimeProvider.untrackTime(
      participant.id,
      _selectedSegment!,
    );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Time untracked for ${participant.fullName}'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Track Times - ${widget.race.name}'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          _buildSegmentSelector(),
          _buildCurrentTime(),
          Expanded(child: _buildParticipantGrid()),
        ],
      ),
    );
  }

  Widget _buildSegmentSelector() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      color: Theme.of(context).primaryColor.withOpacity(0.1),
      child: Column(
        children: [
          const Text(
            'Select Segment',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children:
                widget.race.segments.map((segment) {
                  final isSelected = _selectedSegment == segment.name;
                  return ChoiceChip(
                    label: Text(_formatSegmentName(segment.name)),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        _selectedSegment = segment.name;
                      });
                    },
                    selectedColor: Theme.of(context).primaryColor,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : null,
                    ),
                  );
                }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentTime() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      child: Text(
        'Current Time: ${TimeOfDay.now().format(context)}',
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildParticipantGrid() {
    return Consumer<ParticipantProvider>(
      builder: (context, participantProvider, child) {
        if (participantProvider.isLoading) {
          return const LoadingWidget(message: 'Loading participants...');
        }

        final participants = participantProvider.participants;

        if (participants.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.people, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text('No participants found'),
                Text('Add participants to the race first'),
              ],
            ),
          );
        }

        return GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.8,
          ),
          itemCount: participants.length,
          itemBuilder: (context, index) {
            final participant = participants[index];
            return _buildParticipantCard(participant);
          },
        );
      },
    );
  }

  Widget _buildParticipantCard(Participant participant) {
    return Consumer<SegmentTimeProvider>(
      builder: (context, segmentTimeProvider, child) {
        final segmentTime =
            _selectedSegment != null
                ? segmentTimeProvider.getParticipantSegmentTime(
                  participant.id,
                  _selectedSegment!,
                )
                : null;

        final hasStarted = segmentTime?.startTime != null;
        final hasCompleted = segmentTime?.isCompleted ?? false;

        Color cardColor;
        Color textColor = Colors.black;
        IconData icon;

        if (hasCompleted) {
          cardColor = Colors.green.shade200;
          icon = Icons.check_circle;
        } else if (hasStarted) {
          cardColor = Colors.orange.shade200;
          icon = Icons.timer;
        } else {
          cardColor = Colors.grey.shade200;
          icon = Icons.play_circle_outline;
        }

        return Card(
          color: cardColor,
          child: InkWell(
            onTap: () => _trackTime(participant),
            onLongPress: hasStarted ? () => _untrackTime(participant) : null,
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, size: 32, color: textColor),
                  const SizedBox(height: 8),
                  Text(
                    participant.bibNumber,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    participant.fullName,
                    style: TextStyle(fontSize: 12, color: textColor),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (segmentTime != null && hasStarted) ...[
                    const SizedBox(height: 4),
                    Text(
                      hasCompleted ? segmentTime.durationString : 'Started',
                      style: TextStyle(
                        fontSize: 10,
                        color: textColor,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
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
}
