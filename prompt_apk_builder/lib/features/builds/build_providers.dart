import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'build_runs_service.dart';
import 'model/build_run.dart';

final buildRunStreamProvider = StreamProvider.family<BuildRun, String>((ref, runId) {
  final userId = Supabase.instance.client.auth.currentUser?.id;
  if (userId == null) {
    throw Exception('User must be authenticated to watch build runs');
  }
  return BuildRunsService().watchRun(runId, userId);
});

final buildProgressProvider = Provider.family<double, BuildRun>((ref, run) {
  return BuildRunsService.progress(run);
});

final buildEtaProvider = Provider.family<Duration?, BuildRun>((ref, run) {
  return BuildRunsService.eta(run);
});

// Provider for creating new build runs
final createBuildRunProvider = FutureProvider.family<String, ({
  String prompt,
  String? repo,
})>((ref, args) async {
  final userId = Supabase.instance.client.auth.currentUser?.id;
  if (userId == null) {
    throw Exception('User must be authenticated to create build runs');
  }
  return BuildRunsService().createRun(
    userId: userId,
    prompt: args.prompt,
    repo: args.repo,
  );
});

// Provider for updating build run steps
final updateBuildRunProvider = FutureProvider.family<void, ({
  String runId,
  String step,
  int stepIndex,
  String? status,
  String? runIdFromGitHub,
  String? apkUrl,
  String? aabUrl,
})>((ref, args) async {
  return BuildRunsService().updateRunStep(
    runId: args.runId,
    step: args.step,
    stepIndex: args.stepIndex,
    status: args.status,
    runIdFromGitHub: args.runIdFromGitHub,
    apkUrl: args.apkUrl,
    aabUrl: args.aabUrl,
  );
});