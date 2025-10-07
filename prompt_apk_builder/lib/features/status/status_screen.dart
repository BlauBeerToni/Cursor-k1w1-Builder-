import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prompt_apk_builder/features/builds/build_runs_service.dart';
import 'package:prompt_apk_builder/features/builds/model/build_run.dart';

class StatusScreen extends ConsumerStatefulWidget {
  const StatusScreen({super.key});

  @override
  ConsumerState<StatusScreen> createState() => _StatusScreenState();
}

class _StatusScreenState extends ConsumerState<StatusScreen> {
  final List<String> _logs = [];
  final ScrollController _scrollController = ScrollController();
  String? _currentBuildId;

  @override
  void initState() {
    super.initState();
    _startBuild();
  }

  Future<void> _startBuild() async {
    // In a real implementation, you would get this from navigation arguments
    // For demo purposes, we'll simulate creating a build
    setState(() {
      _logs.add('Build wird gestartet...');
    });

    // Simulate build creation and progress
    await Future.delayed(const Duration(seconds: 1));

    // In real usage, you would create the build through the service
    // final buildId = await BuildRunsService().createRun(...);
    // Then watch the build progress

    _simulateBuildProgress();
  }

  void _simulateBuildProgress() {
    // Simulate build steps
    final steps = [
      'In Warteschlange...',
      'Code wird abgerufen...',
      'Abhängigkeiten werden installiert...',
      'Code wird formatiert...',
      'Code wird analysiert...',
      'APK wird gebaut...',
      'Build abgeschlossen!',
    ];

    int stepIndex = 0;

    void nextStep() {
      if (stepIndex < steps.length && mounted) {
        setState(() {
          _logs.add(steps[stepIndex]);
        });

        stepIndex++;

        if (stepIndex < steps.length) {
          Future.delayed(const Duration(seconds: 2), nextStep);
        }
      }
    }

    nextStep();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Build Status'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Column(
        children: [
          // Progress Section
          Container(
            padding: const EdgeInsets.all(16),
            color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Build läuft...',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    Text(
                      '${(_calculateProgress() * 100).toInt()}%',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                LinearProgressIndicator(
                  value: _calculateProgress(),
                  minHeight: 8,
                ),
                const SizedBox(height: 8),
                Text(
                  'Verbleibende Zeit: ~${_calculateETA()}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),

          // Build Steps
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Build-Schritte',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 16),
                _buildStepList(),
              ],
            ),
          ),

          // Logs Section
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Logs',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Colors.white,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.copy, color: Colors.white),
                          onPressed: _copyLogs,
                          tooltip: 'Logs kopieren',
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      child: ListView.builder(
                        controller: _scrollController,
                        itemCount: _logs.length,
                        itemBuilder: (context, index) {
                          return Text(
                            _logs[index],
                            style: const TextStyle(
                              color: Colors.white,
                              fontFamily: 'monospace',
                              fontSize: 12,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Result Actions
          if (_isBuildCompleted()) ...[
            Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Build erfolgreich abgeschlossen!',
                    style: TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.download),
                          label: const Text('APK herunterladen'),
                          onPressed: () {
                            // TODO: Implement APK download
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.download),
                          label: const Text('AAB herunterladen'),
                          onPressed: () {
                            // TODO: Implement AAB download
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  OutlinedButton.icon(
                    icon: const Icon(Icons.open_in_new),
                    label: const Text('Build ansehen'),
                    onPressed: () {
                      // TODO: Open build URL
                    },
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStepList() {
    final steps = [
      {'name': 'In Warteschlange', 'status': 'completed', 'icon': Icons.schedule},
      {'name': 'Code abrufen', 'status': 'running', 'icon': Icons.download},
      {'name': 'Abhängigkeiten installieren', 'status': 'pending', 'icon': Icons.inventory},
      {'name': 'Code formatieren', 'status': 'pending', 'icon': Icons.format_align_left},
      {'name': 'Code analysieren', 'status': 'pending', 'icon': Icons.analytics},
      {'name': 'APK bauen', 'status': 'pending', 'icon': Icons.build},
      {'name': 'AAB signieren', 'status': 'pending', 'icon': Icons.security},
      {'name': 'Hochladen', 'status': 'pending', 'icon': Icons.cloud_upload},
    ];

    return Column(
      children: steps.map((step) {
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: _getStepColor(step['status'] as String),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  step['icon'] as IconData,
                  size: 16,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  step['name'] as String,
                  style: TextStyle(
                    color: _getStepTextColor(step['status'] as String),
                  ),
                ),
              ),
              Icon(
                _getStepIcon(step['status'] as String),
                color: _getStepColor(step['status'] as String),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Color _getStepColor(String status) {
    switch (status) {
      case 'completed':
        return Colors.green;
      case 'running':
        return Colors.blue;
      case 'failed':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Color _getStepTextColor(String status) {
    switch (status) {
      case 'completed':
        return Colors.green;
      case 'running':
        return Colors.blue;
      case 'failed':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getStepIcon(String status) {
    switch (status) {
      case 'completed':
        return Icons.check_circle;
      case 'running':
        return Icons.sync;
      case 'failed':
        return Icons.error;
      default:
        return Icons.radio_button_unchecked;
    }
  }

  double _calculateProgress() {
    // Calculate progress based on logs length vs total expected steps
    const totalSteps = 7; // Based on our simulation steps
    return (_logs.length / totalSteps).clamp(0.0, 1.0);
  }

  String _calculateETA() {
    final progress = _calculateProgress();
    if (progress == 0) return 'Berechnung...';
    if (progress >= 1) return 'Fertig';

    final remaining = (1 - progress) * 5; // Assume 5 minutes total
    final minutes = remaining.toInt();
    final seconds = ((remaining - minutes) * 60).toInt();

    return '${minutes}:${seconds.toString().padLeft(2, '0')}';
  }

  bool _isBuildCompleted() {
    return _logs.contains('Build abgeschlossen!');
  }

  void _copyLogs() {
    // TODO: Implement log copying
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Logs wurden kopiert')),
    );
  }
}