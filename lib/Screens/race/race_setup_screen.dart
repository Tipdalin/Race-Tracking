import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/race_provider.dart';
import '../../providers/participant_provider.dart';
import '../../models/race.dart';
import '../../models/participant.dart';
import '../../widgets/shared/loading_widget.dart';
import '../participant/add_participant_screen.dart';
import '../participant/edit_participant_screen.dart';
import '../time_tracking/time_tracking_screen.dart';
import '../results/results_screen.dart';

class RaceSetupScreen extends StatefulWidget {
  final Race race;

  const RaceSetupScreen({super.key, required this.race});

  @override
  State<RaceSetupScreen> createState() => _RaceSetupScreenState();
}

class _RaceSetupScreenState extends State<RaceSetupScreen> {
  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  void _initializeData() {
    final participantProvider = Provider.of<ParticipantProvider>(
      context,
      listen: false,
    );
    participantProvider.watchParticipantsByRaceId(widget.race.id);
  }

  Future<void> _startRace() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Start Race'),
            content: Text(
              'Are you sure you want to start ${widget.race.name}?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Start'),
              ),
            ],
          ),
    );

    if (confirmed != true) return;

    final raceProvider = Provider.of<RaceProvider>(context, listen: false);
    final success = await raceProvider.startRace(widget.race.id);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${widget.race.name} started!',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Future<void> _deleteParticipant(Participant participant) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Delete Participant'),
            content: Text(
              'Are you sure you want to delete ${participant.fullName}?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Delete'),
              ),
            ],
          ),
    );

    if (confirmed != true) return;

    final participantProvider = Provider.of<ParticipantProvider>(
      context,
      listen: false,
    );
    final success = await participantProvider.deleteParticipant(participant.id);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${participant.fullName} deleted'),
          backgroundColor: Colors.orange,
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
        title: Text(
          'Setup - ${widget.race.name}',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Consumer<RaceProvider>(
        builder: (context, raceProvider, child) {
          final currentRace = raceProvider.races.firstWhere(
            (race) => race.id == widget.race.id,
            orElse: () => widget.race,
          );

          return Column(
            children: [
              _buildRaceInfo(currentRace),
              _buildActionButtons(currentRace),
              const Divider(),
              _buildParticipantsSection(),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (context) => AddParticipantScreen(selectedRace: widget.race),
            ),
          );
        },
        child: const Icon(Icons.person_add),
      ),
    );
  }

  Widget _buildRaceInfo(Race race) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      color: Colors.blue[100],
      child: Column(
        children: [
          Text(
            race.name,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            race.type.toUpperCase(),
            style: TextStyle(fontSize: 16, color: Colors.white),
          ),
          const SizedBox(height: 8),
          Chip(
            label: Text(race.statusString),
            backgroundColor: _getStatusColor(race.status),
          ),
          const SizedBox(height: 16),
          _buildSegmentsList(race),
        ],
      ),
    );
  }

  Widget _buildSegmentsList(Race race) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Segments:',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children:
              race.segments.map((segment) {
                return Chip(
                  label: Text(
                    '${_formatSegmentName(segment.name)} (${segment.distance})',
                  ),
                  avatar: Icon(_getSegmentIcon(segment.name)),
                );
              }).toList(),
        ),
      ],
    );
  }

  Widget _buildActionButtons(Race race) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          if (race.status == RaceStatus.notStarted) ...[
            ElevatedButton.icon(
              onPressed: _startRace,
              icon: const Icon(Icons.play_arrow),
              label: const Text('Start Race'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
            ),
          ],
          if (race.status == RaceStatus.inProgress) ...[
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TimeTrackingScreen(race: race),
                  ),
                );
              },
              icon: const Icon(Icons.timer),
              label: const Text('Track Times'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
              ),
            ),
          ],
          if (race.status == RaceStatus.finished) ...[
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ResultsScreen(race: race),
                  ),
                );
              },
              icon: const Icon(Icons.leaderboard),
              label: const Text('View Results'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildParticipantsSection() {
    return Expanded(
      child: Column(
        children: [
          Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                color: Colors.blue[100],
              ),
              Consumer<ParticipantProvider>(
                builder: (context, participantProvider, child) {
                  final participantCount =
                      participantProvider.participants.length;
                  return Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    color: Colors.blue[100],
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Participants',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.blue,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            'Total: $participantCount',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
          Expanded(child: _buildParticipantsList()),
        ],
      ),
    );
  }

  Widget _buildParticipantsList() {
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
                Icon(Icons.people_outline, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'No participants yet',
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
                SizedBox(height: 8),
                Text(
                  'Tap + to add participants',
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
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
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).primaryColor,
          child: Text(
            participant.bibNumber,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          participant.fullName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          '${participant.age} years • ${participant.genderString}',
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) => _handleParticipantAction(value, participant),
          itemBuilder:
              (context) => [
                const PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit),
                      SizedBox(width: 8),
                      Text('Edit'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete),
                      SizedBox(width: 8),
                      Text('Delete'),
                    ],
                  ),
                ),
              ],
        ),
      ),
    );
  }

  void _handleParticipantAction(String action, Participant participant) {
    switch (action) {
      case 'edit':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (context) => EditParticipantScreen(participant: participant),
          ),
        );
        break;
      case 'delete':
        _deleteParticipant(participant);
        break;
    }
  }

  Color _getStatusColor(RaceStatus status) {
    switch (status) {
      case RaceStatus.notStarted:
        return Colors.grey.shade300;
      case RaceStatus.inProgress:
        return Colors.orange.shade200;
      case RaceStatus.finished:
        return Colors.green.shade200;
    }
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

  String _formatSegmentName(String name) {
    return name
        .replaceAll('_', ' ')
        .split(' ')
        .map((word) {
          return word.substring(0, 1).toUpperCase() + word.substring(1);
        })
        .join(' ');
  }
}
