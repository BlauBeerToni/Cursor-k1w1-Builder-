import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:prompt_apk_builder/app/providers/providers.dart';

class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    // TODO: Load actual history from storage
    // For now, add some sample data
    ref.read(historyProvider.notifier).state = [
      const BuildHistory(
        id: '1',
        prompt: 'Erstelle eine Todo-App mit lokaler Datenspeicherung...',
        timestamp: 1705312200000, // 2024-01-15T10:30:00Z in milliseconds
        status: 'completed',
        apkUrl: 'https://example.com/app1.apk',
        aabUrl: 'https://example.com/app1.aab',
        runUrl: 'https://github.com/user/repo/actions/runs/1',
      ),
      const BuildHistory(
        id: '2',
        prompt: 'Erstelle eine Chat-App mit WebSocket-Verbindungen...',
        timestamp: 1705248300000, // 2024-01-14T15:45:00Z in milliseconds
        status: 'failed',
        runUrl: 'https://github.com/user/repo/actions/runs/2',
      ),
      const BuildHistory(
        id: '3',
        prompt: 'Erstelle eine einfache CRUD-App mit Authentifizierung...',
        timestamp: 1705138800000, // 2024-01-13T09:20:00Z in milliseconds
        status: 'completed',
        apkUrl: 'https://example.com/app3.apk',
        runUrl: 'https://github.com/user/repo/actions/runs/3',
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final history = ref.watch(historyProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Build-Verlauf'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadHistory,
          ),
        ],
      ),
      body: history.isEmpty
          ? _buildEmptyState()
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: history.length,
              itemBuilder: (context, index) {
                final build = history[index];
                return _buildHistoryCard(build);
              },
            ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.history,
            size: 64,
            color: Colors.grey,
          ),
          const SizedBox(height: 16),
          Text(
            'Keine Builds vorhanden',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Starte deinen ersten Build, um ihn hier zu sehen',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Jetzt starten'),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryCard(BuildHistory build) {
    final dateFormat = DateFormat('dd.MM.yyyy HH:mm');
    final timestamp = DateTime.fromMillisecondsSinceEpoch(build.timestamp);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    dateFormat.format(timestamp),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getStatusColor(build.status),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _getStatusText(build.status),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Prompt preview
            Text(
              build.prompt.length > 100
                  ? '${build.prompt.substring(0, 100)}...'
                  : build.prompt,
              style: Theme.of(context).textTheme.bodyMedium,
            ),

            const SizedBox(height: 16),

            // Action buttons
            Row(
              children: [
                if (build.apkUrl != null)
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.download, size: 16),
                      label: const Text('APK'),
                      onPressed: () => _downloadFile(build.apkUrl!),
                    ),
                  ),
                if (build.apkUrl != null && build.aabUrl != null)
                  const SizedBox(width: 8),
                if (build.aabUrl != null)
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.download, size: 16),
                      label: const Text('AAB'),
                      onPressed: () => _downloadFile(build.aabUrl!),
                    ),
                  ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.open_in_new, size: 16),
                    label: const Text('Build'),
                    onPressed: () => _openUrl(build.runUrl),
                  ),
                ),
                const SizedBox(width: 8),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    switch (value) {
                      case 'retry':
                        _retryBuild(build);
                        break;
                      case 'delete':
                        _deleteBuild(build);
                        break;
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'retry',
                      child: Row(
                        children: [
                          Icon(Icons.refresh),
                          SizedBox(width: 8),
                          Text('Erneut versuchen'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, color: Colors.red),
                          SizedBox(width: 8),
                          Text(
                            'Löschen',
                            style: TextStyle(color: Colors.red),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'completed':
        return Colors.green;
      case 'failed':
        return Colors.red;
      case 'running':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'completed':
        return 'Erfolgreich';
      case 'failed':
        return 'Fehlgeschlagen';
      case 'running':
        return 'Läuft';
      default:
        return 'Unbekannt';
    }
  }

  void _downloadFile(String url) {
    // TODO: Implement file download
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Download gestartet: $url')),
    );
  }

  void _openUrl(String? url) {
    if (url != null) {
      // TODO: Implement URL opening
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Öffne: $url')),
      );
    }
  }

  void _retryBuild(BuildHistory build) {
    // TODO: Implement retry logic
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Build ${build.id} wird erneut versucht')),
    );
  }

  void _deleteBuild(BuildHistory build) {
    setState(() {
      ref.read(historyProvider.notifier).state =
          ref.read(historyProvider).where((b) => b.id != build.id).toList();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Build ${build.id} wurde gelöscht')),
    );
  }
}