// screens/dashboard/dashboard_screen.dart - Enhanced with better error handling
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/race_provider.dart';
import '../../providers/participant_provider.dart';
import '../../widgets/shared/loading_widget.dart';
import '../../models/race.dart';
import '../race/add_race_screen.dart';
import '../race/race_setup_screen.dart';
import '../participant/add_participant_screen.dart';
import '../time_tracking/time_tracking_screen.dart';
import '../results/results_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    // Initialize data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RaceProvider>().watchAllRaces();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Race Tracking Dashboard'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddDialog(context),
          ),
        ],
      ),
      body: Column(
        children: [
          TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: 'Races', icon: Icon(Icons.directions_run)),
              Tab(text: 'Active Races', icon: Icon(Icons.timer)),
              Tab(text: 'Results', icon: Icon(Icons.leaderboard)),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: const [_RacesTab(), _ActiveRacesTab(), _ResultsTab()],
            ),
          ),
        ],
      ),
    );
  }

  void _showAddDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Add New'),
            content: const Text('What would you like to add?'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AddRaceScreen(),
                    ),
                  );
                },
                child: const Text('Race'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AddParticipantScreen(),
                    ),
                  );
                },
                child: const Text('Participant'),
              ),
            ],
          ),
    );
  }
}

class _RacesTab extends StatelessWidget {
  const _RacesTab();

  @override
  Widget build(BuildContext context) {
    return Consumer<RaceProvider>(
      builder: (context, raceProvider, child) {
        if (raceProvider.isLoading) {
          return const LoadingWidget(message: 'Loading races...');
        }

        if (raceProvider.error != null) {
          return _buildErrorWidget(context, raceProvider);
        }

        final races = raceProvider.races;

        if (races.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.directions_run, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text('No races found'),
                Text('Tap + to create your first race'),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async => raceProvider.watchAllRaces(),
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: races.length,
            itemBuilder: (context, index) {
              final race = races[index];
              return _RaceCard(race: race);
            },
          ),
        );
      },
    );
  }

  Widget _buildErrorWidget(BuildContext context, RaceProvider raceProvider) {
    final isPermissionError = raceProvider.error!.contains('permission-denied');

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isPermissionError ? Icons.lock_outline : Icons.error_outline,
              size: 64,
              color: isPermissionError ? Colors.orange : Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              isPermissionError ? 'Permission Required' : 'Error Loading Data',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              isPermissionError
                  ? 'Authentication is required to access race data.'
                  : 'Unable to load races from the server.',
              style: const TextStyle(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                raceProvider.error!,
                style: const TextStyle(fontSize: 12, fontFamily: 'monospace'),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 24),
            if (isPermissionError) ...[
              ElevatedButton.icon(
                onPressed: () async {
                  // Try to authenticate and then refresh
                  final success = await raceProvider.retryAuthentication();
                  if (success) {
                    await raceProvider.refreshAfterAuth();
                  }
                },
                icon: const Icon(Icons.login),
                label: const Text('Login and Retry'),
              ),
              const SizedBox(height: 8),
            ],
            OutlinedButton.icon(
              onPressed: () {
                // Simple retry
                raceProvider.watchAllRaces();
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () {
                // Show more details about the error
                _showErrorDialog(context, raceProvider.error!);
              },
              child: const Text('Show Details'),
            ),
          ],
        ),
      ),
    );
  }

  void _showErrorDialog(BuildContext context, String error) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Error Details'),
            content: SingleChildScrollView(child: Text(error)),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ],
          ),
    );
  }
}

class _RaceCard extends StatelessWidget {
  final Race race;

  const _RaceCard({required this.race});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(race.name),
        subtitle: Text(race.type.toUpperCase()),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Chip(
              label: Text(race.statusString),
              backgroundColor: _getStatusColor(race.status),
            ),
            PopupMenuButton<String>(
              onSelected: (value) => _handleMenuSelection(context, value),
              itemBuilder:
                  (context) => [
                    if (race.status == RaceStatus.notStarted) ...[
                      const PopupMenuItem(
                        value: 'setup',
                        child: Row(
                          children: [
                            Icon(Icons.settings),
                            SizedBox(width: 8),
                            Text('Setup'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'start',
                        child: Row(
                          children: [
                            Icon(Icons.play_arrow),
                            SizedBox(width: 8),
                            Text('Start'),
                          ],
                        ),
                      ),
                    ],
                    if (race.status == RaceStatus.inProgress) ...[
                      const PopupMenuItem(
                        value: 'track',
                        child: Row(
                          children: [
                            Icon(Icons.timer),
                            SizedBox(width: 8),
                            Text('Track Times'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'finish',
                        child: Row(
                          children: [
                            Icon(Icons.stop),
                            SizedBox(width: 8),
                            Text('Finish'),
                          ],
                        ),
                      ),
                    ],
                    if (race.status == RaceStatus.finished) ...[
                      const PopupMenuItem(
                        value: 'results',
                        child: Row(
                          children: [
                            Icon(Icons.leaderboard),
                            SizedBox(width: 8),
                            Text('Results'),
                          ],
                        ),
                      ),
                    ],
                    const PopupMenuDivider(),
                    const PopupMenuItem(
                      value: 'reset',
                      child: Row(
                        children: [
                          Icon(Icons.refresh),
                          SizedBox(width: 8),
                          Text('Reset'),
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
          ],
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => RaceSetupScreen(race: race),
            ),
          );
        },
      ),
    );
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

  void _handleMenuSelection(BuildContext context, String value) async {
    final raceProvider = Provider.of<RaceProvider>(context, listen: false);
    final messenger = ScaffoldMessenger.of(context);

    switch (value) {
      case 'setup':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => RaceSetupScreen(race: race)),
        );
        break;
      case 'start':
        final success = await raceProvider.startRace(race.id);
        if (success) {
          messenger.showSnackBar(
            SnackBar(content: Text('${race.name} started!')),
          );
        }
        break;
      case 'track':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TimeTrackingScreen(race: race),
          ),
        );
        break;
      case 'finish':
        final success = await raceProvider.finishRace(race.id);
        if (success) {
          messenger.showSnackBar(
            SnackBar(content: Text('${race.name} finished!')),
          );
        }
        break;
      case 'results':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ResultsScreen(race: race)),
        );
        break;
      case 'reset':
        _showResetDialog(context, raceProvider);
        break;
      case 'delete':
        _showDeleteDialog(context, raceProvider);
        break;
    }
  }

  void _showResetDialog(BuildContext context, RaceProvider raceProvider) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Reset Race'),
            content: Text(
              'Are you sure you want to reset ${race.name}? All times will be lost.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.pop(context);
                  final success = await raceProvider.resetRace(race.id);
                  if (success && context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('${race.name} reset!')),
                    );
                  }
                },
                child: const Text('Reset'),
              ),
            ],
          ),
    );
  }

  void _showDeleteDialog(BuildContext context, RaceProvider raceProvider) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Delete Race'),
            content: Text('Are you sure you want to delete ${race.name}?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.pop(context);
                  final success = await raceProvider.deleteRace(race.id);
                  if (success && context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('${race.name} deleted!')),
                    );
                  }
                },
                child: const Text('Delete'),
              ),
            ],
          ),
    );
  }
}

class _ActiveRacesTab extends StatelessWidget {
  const _ActiveRacesTab();

  @override
  Widget build(BuildContext context) {
    return Consumer<RaceProvider>(
      builder: (context, raceProvider, child) {
        if (raceProvider.isLoading) {
          return const LoadingWidget(message: 'Loading races...');
        }

        final activeRaces =
            raceProvider.races
                .where((race) => race.status == RaceStatus.inProgress)
                .toList();

        if (activeRaces.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.timer_off, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text('No active races'),
                Text('Start a race to begin time tracking'),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: activeRaces.length,
          itemBuilder: (context, index) {
            final race = activeRaces[index];
            return Card(
              child: ListTile(
                title: Text(race.name),
                subtitle: Text(
                  '${race.type.toUpperCase()} - ${race.statusString}',
                ),
                trailing: const Icon(Icons.timer),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TimeTrackingScreen(race: race),
                    ),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }
}

class _ResultsTab extends StatelessWidget {
  const _ResultsTab();

  @override
  Widget build(BuildContext context) {
    return Consumer<RaceProvider>(
      builder: (context, raceProvider, child) {
        final finishedRaces =
            raceProvider.races
                .where((race) => race.status == RaceStatus.finished)
                .toList();

        if (finishedRaces.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.leaderboard, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text('No finished races'),
                Text('Complete a race to view results'),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: finishedRaces.length,
          itemBuilder: (context, index) {
            final race = finishedRaces[index];
            return Card(
              child: ListTile(
                title: Text(race.name),
                subtitle: Text(race.type.toUpperCase()),
                trailing: const Icon(Icons.leaderboard),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ResultsScreen(race: race),
                    ),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }
}
