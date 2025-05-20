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

  // Calculate total race time for a participant
  Duration? _calculateParticipantTotalTime(
    String participantId,
    SegmentTimeProvider segmentTimeProvider,
  ) {
    Duration totalDuration = Duration.zero;
    bool hasAnyCompletedSegment = false;

    for (final segment in widget.race.segments) {
      final segmentTime = segmentTimeProvider.getParticipantSegmentTime(
        participantId,
        segment.name,
      );

      if (segmentTime?.isCompleted == true && segmentTime?.duration != null) {
        totalDuration += segmentTime!.duration!;
        hasAnyCompletedSegment = true;
      } else {
        // If any segment is not completed, return null (incomplete race)
        return null;
      }
    }

    return hasAnyCompletedSegment ? totalDuration : null;
  }

  // Check if participant completed the entire race
  bool _isRaceCompleted(
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

  // Get participant's current segment
  String _getCurrentSegment(
    String participantId,
    SegmentTimeProvider segmentTimeProvider,
  ) {
    for (final segment in widget.race.segments) {
      final segmentTime = segmentTimeProvider.getParticipantSegmentTime(
        participantId,
        segment.name,
      );

      // If started but not completed, this is current segment
      if (segmentTime?.startTime != null && segmentTime?.isCompleted != true) {
        return segment.name;
      }
    }

    // If no current segment, find first not started
    for (final segment in widget.race.segments) {
      final segmentTime = segmentTimeProvider.getParticipantSegmentTime(
        participantId,
        segment.name,
      );

      if (segmentTime?.startTime == null) {
        return segment.name;
      }
    }

    return 'Finished';
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
                        Text('Sort by Current Progress'),
                      ],
                    ),
                  ),
                  const PopupMenuDivider(),
                  const PopupMenuItem(
                    value: 'live_update',
                    child: Row(
                      children: [
                        Icon(Icons.refresh),
                        SizedBox(width: 8),
                        Text('Live Updates'),
                      ],
                    ),
                  ),
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
      color: Colors.blue[100],
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
      color: Colors.blue[100],
      child: Consumer<SegmentTimeProvider>(
        builder: (context, segmentTimeProvider, child) {
          final totalParticipants =
              context.read<ParticipantProvider>().participants.length;
          final finishedParticipants =
              context
                  .read<ParticipantProvider>()
                  .participants
                  .where((p) => _isRaceCompleted(p.id, segmentTimeProvider))
                  .length;

          return Row(
            children: [
              const Text(
                'Results',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    _sortByOverallTime ? 'Overall Time' : 'Current Progress',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                  Text(
                    'Finished: $finishedParticipants/$totalParticipants',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildResultsList() {
    return Consumer2<ParticipantProvider, SegmentTimeProvider>(
      builder: (context, participantProvider, segmentTimeProvider, child) {
        if (participantProvider.isLoading) {
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
        final totalTimeA = _calculateParticipantTotalTime(
          a.id,
          segmentTimeProvider,
        );
        final totalTimeB = _calculateParticipantTotalTime(
          b.id,
          segmentTimeProvider,
        );

        // Completed participants first
        if (totalTimeA == null && totalTimeB != null) return 1;
        if (totalTimeA != null && totalTimeB == null) return -1;
        if (totalTimeA == null && totalTimeB == null) return 0;

        return totalTimeA!.compareTo(totalTimeB!);
      } else {
        // Sort by progress (number of completed segments)
        final completedA =
            widget.race.segments
                .where(
                  (s) =>
                      segmentTimeProvider
                          .getParticipantSegmentTime(a.id, s.name)
                          ?.isCompleted ==
                      true,
                )
                .length;
        final completedB =
            widget.race.segments
                .where(
                  (s) =>
                      segmentTimeProvider
                          .getParticipantSegmentTime(b.id, s.name)
                          ?.isCompleted ==
                      true,
                )
                .length;

        if (completedA != completedB) {
          return completedB.compareTo(completedA); // More completed first
        }

        // If same completion level, sort by total time of completed segments
        Duration totalA = Duration.zero;
        Duration totalB = Duration.zero;

        for (final segment in widget.race.segments) {
          final segmentTimeA = segmentTimeProvider.getParticipantSegmentTime(
            a.id,
            segment.name,
          );
          final segmentTimeB = segmentTimeProvider.getParticipantSegmentTime(
            b.id,
            segment.name,
          );

          if (segmentTimeA?.isCompleted == true &&
              segmentTimeA?.duration != null) {
            totalA += segmentTimeA!.duration!;
          }
          if (segmentTimeB?.isCompleted == true &&
              segmentTimeB?.duration != null) {
            totalB += segmentTimeB!.duration!;
          }
        }

        return totalA.compareTo(totalB);
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
    final totalTime = _calculateParticipantTotalTime(
      participant.id,
      segmentTimeProvider,
    );
    final isCompleted = _isRaceCompleted(participant.id, segmentTimeProvider);
    final currentSegment = _getCurrentSegment(
      participant.id,
      segmentTimeProvider,
    );

    return Card(
      elevation: isCompleted ? 4 : 2,
      color: isCompleted ? Colors.purple.shade50 : null,
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor:
              isCompleted ? _getPositionColor(position) : Colors.grey,
          child:
              isCompleted
                  ? Text(
                    position.toString(),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  )
                  : const Icon(Icons.timer, color: Colors.white),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                participant.fullName,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            if (isCompleted)
              const Icon(
                Icons.emoji_events,
                color: Colors.blueAccent,
                size: 20,
              ),
          ],
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
              )
            else
              Text(
                'Current: ${_formatSegmentName(currentSegment)}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.orange[700],
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
                  decoration: BoxDecoration(color: Colors.blue),
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
                ...widget.race.segments.asMap().entries.map((entry) {
                  final segment = entry.value;
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

                  final isCurrentSegment =
                      currentSegment == segment.name && !isCompleted;

                  return TableRow(
                    decoration: BoxDecoration(
                      color: isCurrentSegment ? Colors.orange.shade50 : null,
                    ),
                    children: [
                      TableCell(
                        child: Padding(
                          padding: const EdgeInsets.all(8),
                          child: Row(
                            children: [
                              Text(_formatSegmentName(segment.name)),
                              if (isCurrentSegment) const SizedBox(width: 4),
                              if (isCurrentSegment)
                                const Icon(
                                  Icons.arrow_forward,
                                  size: 16,
                                  color: Colors.orange,
                                ),
                            ],
                          ),
                        ),
                      ),
                      TableCell(
                        child: Padding(
                          padding: const EdgeInsets.all(8),
                          child: Text(
                            segmentTime.duration != null
                                ? _formatDuration(segmentTime.duration!)
                                : '--:--:--',
                            style: TextStyle(
                              fontWeight:
                                  segmentTime.isCompleted
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                              color:
                                  segmentTime.isCompleted
                                      ? Colors.green[700]
                                      : null,
                            ),
                          ),
                        ),
                      ),
                      TableCell(
                        child: Padding(
                          padding: const EdgeInsets.all(8),
                          child: _buildStatusIcon(
                            segmentTime,
                            isCurrentSegment,
                          ),
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ],
            ),
          ),
          if (totalTime != null)
            Container(
              margin: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blueGrey),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.emoji_events, color: Colors.red),
                  const SizedBox(width: 8),
                  Text(
                    'Race Complete! Total Time: ${_formatDuration(totalTime)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStatusIcon(SegmentTime segmentTime, bool isCurrentSegment) {
    if (segmentTime.isCompleted) {
      return const Icon(Icons.check_circle, color: Colors.green);
    } else if (segmentTime.startTime != null || isCurrentSegment) {
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
        return const Color(0xFFFFD700); // Gold
      case 2:
        return const Color(0xFFC0C0C0); // Silver
      case 3:
        return const Color(0xFFCD7F32); // Bronze
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
      case 'live_update':
        _initializeData(); // Refresh data
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Results refreshed!'),
            duration: Duration(seconds: 1),
          ),
        );
        break;
      case 'export':
        _exportResults();
        break;
    }
  }

  void _exportResults() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Export Results'),
            content: const Text(
              'Export functionality will be implemented here.\n\n'
              'This would typically save results as CSV or PDF with:\n'
              '• Participant rankings\n'
              '• Segment times\n'
              '• Total times\n'
              '• Current progress',
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
