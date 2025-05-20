import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
//import '../../providers/race_provider.dart';
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

  Future<void> _startAllParticipants() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Start All Participants'),
            content: Text(
              'Start the race for all participants?\n\n'
              'Everyone will begin with ${_formatSegmentName(widget.race.segments.first.name)} and auto-progress through segments.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              ElevatedButton.icon(
                onPressed: () => Navigator.pop(context, true),
                icon: const Icon(Icons.play_arrow),
                label: const Text('Start Race'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
    );

    if (confirmed != true) return;

    // Show loading
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            SizedBox(width: 16),
            Text('Starting all participants...'),
          ],
        ),
        duration: Duration(seconds: 5),
      ),
    );

    final participantProvider = Provider.of<ParticipantProvider>(
      context,
      listen: false,
    );
    final segmentTimeProvider = Provider.of<SegmentTimeProvider>(
      context,
      listen: false,
    );

    final participants = participantProvider.participants;
    final firstSegment = widget.race.segments.first.name;
    int successCount = 0;

    // Start all participants in the FIRST segment only
    for (final participant in participants) {
      final success = await segmentTimeProvider.trackTime(
        participant.id,
        widget.race.id,
        firstSegment,
      );
      if (success) successCount++;
    }

    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    if (successCount == participants.length) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Race started! All ${participants.length} participants began ${_formatSegmentName(firstSegment)}.',
          ),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 3),
        ),
      );

      // Auto-select the first segment
      setState(() {
        _selectedSegment = firstSegment;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Started $successCount of ${participants.length} participants',
          ),
          backgroundColor: Colors.orange,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  Future<void> _trackTime(Participant participant) async {
    if (_selectedSegment == null) return;

    final segmentTimeProvider = Provider.of<SegmentTimeProvider>(
      context,
      listen: false,
    );

    final segmentTime = segmentTimeProvider.getParticipantSegmentTime(
      participant.id,
      _selectedSegment!,
    );

    final hasStarted = segmentTime?.startTime != null;
    final hasCompleted = segmentTime?.isCompleted ?? false;

    if (!hasStarted) {
      // Start the participant in current segment
      final success = await segmentTimeProvider.trackTime(
        participant.id,
        widget.race.id,
        _selectedSegment!,
      );

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${participant.fullName} started ${_formatSegmentName(_selectedSegment!)}',
            ),
            backgroundColor: Colors.blue,
            duration: const Duration(seconds: 1),
          ),
        );
      }
    } else if (!hasCompleted) {
      // Finish current segment and auto-start next segment
      final success = await segmentTimeProvider.trackTime(
        participant.id,
        widget.race.id,
        _selectedSegment!,
      );

      if (success && mounted) {
        // Get next segment
        final currentSegmentIndex = widget.race.segments.indexWhere(
          (s) => s.name == _selectedSegment,
        );
        final hasNextSegment =
            currentSegmentIndex < widget.race.segments.length - 1;

        if (hasNextSegment) {
          final nextSegment = widget.race.segments[currentSegmentIndex + 1];

          // Auto-start next segment
          final nextSuccess = await segmentTimeProvider.trackTime(
            participant.id,
            widget.race.id,
            nextSegment.name,
          );

          if (nextSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  '${participant.fullName} finished ${_formatSegmentName(_selectedSegment!)} and started ${_formatSegmentName(nextSegment.name)}!',
                ),
                backgroundColor: Colors.green,
                duration: const Duration(seconds: 2),
              ),
            );
          }
        } else {
          // Race completed!
          final totalTime = _calculateTotalTime(
            participant.id,
            segmentTimeProvider,
          );
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '🏆 ${participant.fullName} finished the race! Total time: $totalTime',
              ),
              backgroundColor: Colors.blue,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      }
    }
  }

  String _calculateTotalTime(
    String participantId,
    SegmentTimeProvider segmentTimeProvider,
  ) {
    Duration totalDuration = Duration.zero;

    for (final segment in widget.race.segments) {
      final segmentTime = segmentTimeProvider.getParticipantSegmentTime(
        participantId,
        segment.name,
      );

      if (segmentTime?.isCompleted == true && segmentTime?.duration != null) {
        totalDuration += segmentTime!.duration!;
      }
    }

    final hours = totalDuration.inHours;
    final minutes = totalDuration.inMinutes.remainder(60);
    final seconds = totalDuration.inSeconds.remainder(60);

    if (hours > 0) {
      return '${hours}h ${minutes}m ${seconds}s';
    } else {
      return '${minutes}m ${seconds}s';
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

  void _showDetailedTimes() {
    showDialog(
      context: context,
      builder:
          (context) => Dialog(
            child: Container(
              padding: const EdgeInsets.all(16),
              height: 500,
              child: Column(
                children: [
                  const Text(
                    'All Participant Times',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: Consumer<ParticipantProvider>(
                      builder: (context, participantProvider, child) {
                        return Consumer<SegmentTimeProvider>(
                          builder: (context, segmentTimeProvider, child) {
                            return ListView.builder(
                              itemCount:
                                  participantProvider.participants.length,
                              itemBuilder: (context, index) {
                                final participant =
                                    participantProvider.participants[index];
                                return _buildDetailedTimeCard(
                                  participant,
                                  segmentTimeProvider,
                                );
                              },
                            );
                          },
                        );
                      },
                    ),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Close'),
                  ),
                ],
              ),
            ),
          ),
    );
  }

  Widget _buildDetailedTimeCard(
    Participant participant,
    SegmentTimeProvider segmentTimeProvider,
  ) {
    final isRaceFinished = _isRaceFinished(participant.id, segmentTimeProvider);
    final totalTime =
        isRaceFinished
            ? _calculateTotalTime(participant.id, segmentTimeProvider)
            : null;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${participant.bibNumber} - ${participant.fullName}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                if (isRaceFinished)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      '🏆 Finished',
                      style: TextStyle(color: Colors.white, fontSize: 10),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children:
                  widget.race.segments.map((segment) {
                    final segmentTime = segmentTimeProvider
                        .getParticipantSegmentTime(
                          participant.id,
                          segment.name,
                        );
                    return _buildSegmentColumn(
                      _formatSegmentName(segment.name),
                      segmentTime,
                    );
                  }).toList(),
            ),
            if (totalTime != null) ...[
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.purple.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Total Race Time: $totalTime',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSegmentColumn(String title, segmentTime) {
    return Column(
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          segmentTime?.isCompleted == true
              ? segmentTime!.durationString
              : segmentTime?.startTime != null
              ? 'Started'
              : 'Not Started',
          style: TextStyle(
            fontSize: 9,
            color:
                segmentTime?.isCompleted == true
                    ? Colors.green
                    : segmentTime?.startTime != null
                    ? Colors.orange
                    : Colors.grey,
          ),
        ),
      ],
    );
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
          'Track Times - ${widget.race.name}',
          style: TextStyle(color: Colors.white, fontSize: 24),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.list_alt, color: Colors.white),
            onPressed: _showDetailedTimes,
            tooltip: 'View All Times',
          ),
        ],
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
      child: Column(
        children: [
          Text(
            'Current Time: ${TimeOfDay.now().format(context)}',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _startAllParticipants,
            icon: const Icon(Icons.play_arrow),
            label: const Text('🏁 START RACE (All Participants)'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 50),
            ),
          ),
        ],
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

        // Check current segment and overall progress
        final currentSegment = _getCurrentSegment(
          participant.id,
          segmentTimeProvider,
        );
        final isRaceFinished = _isRaceFinished(
          participant.id,
          segmentTimeProvider,
        );

        Color cardColor;
        Color textColor = Colors.black;
        IconData icon;
        String statusText = '';

        if (isRaceFinished) {
          cardColor = Colors.purple.shade200;
          icon = Icons.emoji_events;
          statusText = 'Race Complete!';
        } else if (hasCompleted) {
          cardColor = Colors.green.shade200;
          icon = Icons.check_circle;
          statusText = segmentTime!.durationString;
        } else if (hasStarted) {
          cardColor = Colors.orange.shade200;
          icon = Icons.timer;
          statusText = 'In Progress...';
        } else {
          cardColor = Colors.grey.shade200;
          icon = Icons.play_circle_outline;
          statusText = 'Ready';
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
                  Icon(icon, size: 28, color: textColor),
                  const SizedBox(height: 6),
                  Text(
                    participant.bibNumber,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    participant.fullName,
                    style: TextStyle(fontSize: 10, color: textColor),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    statusText,
                    style: TextStyle(
                      fontSize: 9,
                      color: textColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (currentSegment != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      'Current: ${_formatSegmentName(currentSegment)}',
                      style: TextStyle(
                        fontSize: 8,
                        color: textColor,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                  if (isRaceFinished) ...[
                    const SizedBox(height: 2),
                    Text(
                      'Total: ${_calculateTotalTime(participant.id, segmentTimeProvider)}',
                      style: TextStyle(
                        fontSize: 8,
                        color: textColor,
                        fontWeight: FontWeight.bold,
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

  String? _getCurrentSegment(
    String participantId,
    SegmentTimeProvider segmentTimeProvider,
  ) {
    for (final segment in widget.race.segments) {
      final segmentTime = segmentTimeProvider.getParticipantSegmentTime(
        participantId,
        segment.name,
      );

      if (segmentTime?.startTime != null && segmentTime?.isCompleted != true) {
        return segment.name;
      }
    }
    return null;
  }

  bool _isRaceFinished(
    String participantId,
    SegmentTimeProvider segmentTimeProvider,
  ) {
    for (final segment in widget.race.segments) {
      final segmentTime = segmentTimeProvider.getParticipantSegmentTime(
        participantId,
        segment.name,
      );

      if (segmentTime?.isCompleted != true) {
        return false;
      }
    }
    return true;
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
