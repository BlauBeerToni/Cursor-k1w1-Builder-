// Example usage of the Supabase Build Tracking system
// This file demonstrates how to integrate build tracking into your app

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'build_runs_service.dart';
import 'build_providers.dart';
import 'model/build_run.dart';

class BuildTrackingExample extends ConsumerStatefulWidget {
  const BuildTrackingExample({super.key});

  @override
  ConsumerState<BuildTrackingExample> createState() => _BuildTrackingExampleState();
}

class _BuildTrackingExampleState extends ConsumerState<BuildTrackingExample> {
  String? currentBuildId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Build Tracking Example')),
      body: Column(
        children: [
          // Create new build button
          ElevatedButton(
            onPressed: _createNewBuild,
            child: const Text('Start New Build'),
          ),

          const SizedBox(height: 20),

          // Show current build progress if available
          if (currentBuildId != null) ...[
            const Text('Build Progress:'),
            _BuildProgressWidget(buildId: currentBuildId!),
          ],
        ],
      ),
    );
  }

  Future<void> _createNewBuild() async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please log in first')),
      );
      return;
    }

    // Create a new build run
    final buildId = await BuildRunsService().createRun(
      userId: userId,
      prompt: 'Example Flutter app with counter',
      repo: 'https://github.com/example/repo',
    );

    setState(() {
      currentBuildId = buildId;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Build started: $buildId')),
      );
    }
  }
}

class _BuildProgressWidget extends ConsumerWidget {
  final String buildId;

  const _BuildProgressWidget({required this.buildId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final buildAsync = ref.watch(buildRunStreamProvider(buildId));

    return buildAsync.when(
      data: (run) => Column(
        children: [
          LinearProgressIndicator(
            value: BuildRunsService.progress(run),
          ),
          const SizedBox(height: 8),
          Text(
            '${run.step} • ${(BuildRunsService.progress(run) * 100).toStringAsFixed(0)}% • '
            '${BuildRunsService.eta(run)?.inSeconds ?? 0}s left',
          ),
          if (run.apkUrl != null) ...[
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () => _downloadApk(run.apkUrl!),
              child: const Text('Download APK'),
            ),
          ],
          if (run.aabUrl != null) ...[
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () => _downloadAab(run.aabUrl!),
              child: const Text('Download AAB'),
            ),
          ],
        ],
      ),
      loading: () => const LinearProgressIndicator(),
      error: (e, _) => Text('Error: $e'),
    );
  }

  void _downloadApk(String url) {
    // Implement APK download logic
    print('Downloading APK: $url');
  }

  void _downloadAab(String url) {
    // Implement AAB download logic
    print('Downloading AAB: $url');
  }
}