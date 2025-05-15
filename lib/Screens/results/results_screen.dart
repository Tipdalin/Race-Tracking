import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/participant_provider.dart';
import '../../providers/segment_time_provider.dart';
import '../../models/race.dart';
import '../../models/participant.dart';
import '../../models/segment_time.dart';
import '../../widgets/shared/loading_widget.dart';

class ResultsScreen extends StatefulWidget {
  final Race race;

  const ResultsScreen({super.key, required this.race});

  @override
  State<ResultsScreen> createState() => _ResultsScreenState();
}

class _ResultsScreenState extends State<ResultsScreen> {
  bool _sortByOverallTime = true;

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
    final segmentTimeProvider = Provider.of<SegmentTimeProvider>(
      context,
      listen: false,
    );

    participantProvider.watchParticipantsByRaceId(widget.race.id);
    segmentTimeProvider.watchSegmentTimesByRaceId(widget.race.id);
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
          'Results - ${widget.race.name}',
          style: const TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        actions: [
          PopupMenuButton<String>(
            iconColor: Colors.white,
            onSelected: _handleMenuSelection,
            itemBuilder:
                (context) => [
                  const PopupMenuItem(
                    value: 'sort_overall',
                    child: Row(
                      children: [
                        Icon(Icons.sort),
                        SizedBox(width: 8),
                        Text('Sort by Overall Time'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'sort_segment',
                    child: Row(
                      children: [
                        Icon(Icons.sort_by_alpha),
                        SizedBox(width: 8),
                        Text('Sort by Current Segment'),
                      ],
                    ),
                  ),
                  const PopupMenuDivider(),
                  const PopupMenuItem(
                    value: 'export',
                    child: Row(
                      children: [
                        Icon(Icons.download),
                        SizedBox(width: 8),
                        Text('Export Results'),
                      ],
                    ),
                  ),
                ],
          ),
        ],
      ),
      body: Column(
        children: [
          _buildRaceInfo(),
          _buildResultsHeader(),
          Expanded(child: _buildResultsList()),
        ],
      ),
    );
  }

  Widget _buildRaceInfo() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      color: Theme.of(context).primaryColor.withOpacity(0.1),
      child: Column(
        children: [
          Text(
            widget.race.name,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            widget.race.type.toUpperCase(),
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          Chip(
            label: Text(widget.race.statusString),
            backgroundColor: _getStatusColor(widget.race.status),
          ),
        ],
      ),
    );
  }

  Widget _buildResultsHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.grey[100],
      child: Row(
        children: [
          const Text(
            'Results',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const Spacer(),
          Text(
            _sortByOverallTime ? 'Overall Time' : 'Current Segment',
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildResultsList() {
    return Consumer2<ParticipantProvider, SegmentTimeProvider>(
      builder: (context, participantProvider, segmentTimeProvider, child) {
        if (participantProvider.isLoading || segmentTimeProvider.isLoading) {
          return const LoadingWidget(message: 'Loading results...');
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
              ],
            ),
          );
        }

        // Sort participants based on selection
        final sortedParticipants = _sortParticipants(
          participants,
          segmentTimeProvider,
        );

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: sortedParticipants.length,
          itemBuilder: (context, index) {
            final participant = sortedParticipants[index];
            return _buildResultsCard(
              participant,
              index + 1,
              segmentTimeProvider,
            );
          },
        );
      },
    );
  }

  List<Participant> _sortParticipants(
    List<Participant> participants,
    SegmentTimeProvider segmentTimeProvider,
  ) {
    return List<Participant>.from(participants)..sort((a, b) {
      if (_sortByOverallTime) {
        final totalTimeA = segmentTimeProvider.getParticipantTotalTime(a.id);
        final totalTimeB = segmentTimeProvider.getParticipantTotalTime(b.id);

        if (totalTimeA == null && totalTimeB == null) return 0;
        if (totalTimeA == null) return 1;
        if (totalTimeB == null) return -1;

        return totalTimeA.compareTo(totalTimeB);
      } else {
        // Sort by current segment (for simplicity, use first segment)
        final firstSegment =
            widget.race.segments.isNotEmpty
                ? widget.race.segments.first.name
                : null;
        if (firstSegment == null) return 0;

        final segmentTimeA = segmentTimeProvider.getParticipantSegmentTime(
          a.id,
          firstSegment,
        );
        final segmentTimeB = segmentTimeProvider.getParticipantSegmentTime(
          b.id,
          firstSegment,
        );

        if (segmentTimeA?.duration == null && segmentTimeB?.duration == null)
          return 0;
        if (segmentTimeA?.duration == null) return 1;
        if (segmentTimeB?.duration == null) return -1;

        return segmentTimeA!.duration!.compareTo(segmentTimeB!.duration!);
      }
    });
  }

  Widget _buildResultsCard(
    Participant participant,
    int position,
    SegmentTimeProvider segmentTimeProvider,
  ) {
    final participantTimes = segmentTimeProvider.getParticipantSegmentTimes(
      participant.id,
    );
    final totalTime = segmentTimeProvider.getParticipantTotalTime(
      participant.id,
    );

    return Card(
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: _getPositionColor(position),
          child: Text(
            position.toString(),
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        title: Text(
          participant.fullName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('BIB: ${participant.bibNumber}'),
            if (totalTime != null)
              Text(
                'Total: ${_formatDuration(totalTime)}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Table(
              border: TableBorder.all(color: Colors.grey[300]!),
              children: [
                const TableRow(
                  decoration: BoxDecoration(color: Colors.grey),
                  children: [
                    TableCell(
                      child: Padding(
                        padding: EdgeInsets.all(8),
                        child: Text(
                          'Segment',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    TableCell(
                      child: Padding(
                        padding: EdgeInsets.all(8),
                        child: Text(
                          'Time',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    TableCell(
                      child: Padding(
                        padding: EdgeInsets.all(8),
                        child: Text(
                          'Status',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
                ...widget.race.segments.map((segment) {
                  final segmentTime = participantTimes.firstWhere(
                    (st) => st.segmentName == segment.name,
                    orElse:
                        () => SegmentTime(
                          id: '',
                          participantId: participant.id,
                          raceId: widget.race.id,
                          segmentName: segment.name,
                          trackedBy: '',
                          createdAt: DateTime.now(),
                        ),
                  );

                  return TableRow(
                    children: [
                      TableCell(
                        child: Padding(
                          padding: const EdgeInsets.all(8),
                          child: Text(_formatSegmentName(segment.name)),
                        ),
                      ),
                      TableCell(
                        child: Padding(
                          padding: const EdgeInsets.all(8),
                          child: Text(
                            segmentTime.duration != null
                                ? _formatDuration(segmentTime.duration!)
                                : '--:--:--',
                          ),
                        ),
                      ),
                      TableCell(
                        child: Padding(
                          padding: const EdgeInsets.all(8),
                          child: _buildStatusIcon(segmentTime),
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusIcon(SegmentTime segmentTime) {
    if (segmentTime.isCompleted) {
      return const Icon(Icons.check_circle, color: Colors.green);
    } else if (segmentTime.startTime != null) {
      return const Icon(Icons.timer, color: Colors.orange);
    } else {
      return const Icon(Icons.remove_circle_outline, color: Colors.grey);
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

  Color _getPositionColor(int position) {
    switch (position) {
      case 1:
        return const Color.fromARGB(255, 255, 179, 0)!; // Gold
      case 2:
        return const Color.fromARGB(255, 255, 0, 0)!; // Silver
      case 3:
        return const Color.fromARGB(255, 93, 189, 10)!; // Bronze
      default:
        return Theme.of(context).primaryColor;
    }
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    final seconds = duration.inSeconds % 60;

    return '${hours.toString().padLeft(2, '0')}:'
        '${minutes.toString().padLeft(2, '0')}:'
        '${seconds.toString().padLeft(2, '0')}';
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

  void _handleMenuSelection(String value) {
    switch (value) {
      case 'sort_overall':
        setState(() => _sortByOverallTime = true);
        break;
      case 'sort_segment':
        setState(() => _sortByOverallTime = false);
        break;
      case 'export':
        _exportResults();
        break;
    }
  }

  void _exportResults() {
    // Simple placeholder for export functionality
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Export Results'),
            content: const Text(
              'Export functionality will be implemented here.\n\nThis would typically save results as CSV or PDF.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
    );
  }
}
