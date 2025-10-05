import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'model/build_run.dart';

final _sb = Supabase.instance.client;

class BuildRunsService {
  Future<String> createRun({
    required String userId,
    required String prompt,
    String? repo,
  }) async {
    final r = await _sb.from('build_runs').insert({
      'user_id': userId,
      'prompt': prompt,
      'repo': repo,
      'status': 'queued',
      'step': 'queued',
      'step_index': 0,
    }).select('id').single();
    return r['id'] as String;
  }

  Stream<BuildRun> watchRun(String runId, String userId) {
    return _sb
        .from('build_runs')
        .stream(primaryKey: ['id'])
        .eq('id', runId)
        .eq('user_id', userId)
        .map((rows) => BuildRun.fromMap(rows.first));
  }

  Future<void> updateRunStep({
    required String runId,
    required String step,
    required int stepIndex,
    String? status,
    String? runIdFromGitHub,
    String? apkUrl,
    String? aabUrl,
  }) async {
    final updates = <String, dynamic>{
      'step': step,
      'step_index': stepIndex,
    };

    if (status != null) updates['status'] = status;
    if (runIdFromGitHub != null) updates['run_id'] = runIdFromGitHub;
    if (apkUrl != null) updates['apk_url'] = apkUrl;
    if (aabUrl != null) updates['aab_url'] = aabUrl;

    // Set finished_at if status is success or failed
    if (status == 'success' || status == 'failed') {
      updates['finished_at'] = DateTime.now().toIso8601String();
    }

    await _sb.from('build_runs').update(updates).eq('id', runId);
  }

  // Fortschritt 0..1
  static double progress(BuildRun r) {
    if (r.stepsTotal <= 0) return 0;
    final p = r.stepIndex / r.stepsTotal;
    return p.clamp(0, 1).toDouble();
  }

  // ETA (sehr simpel): wenn startedAt & stepIndex>0 vorhanden
  static Duration? eta(BuildRun r) {
    if (r.startedAt == null || r.stepIndex <= 0) return null;
    final elapsed = DateTime.now().difference(r.startedAt!);
    final perStep = elapsed.inMilliseconds / r.stepIndex;
    final remaining = ((r.stepsTotal - r.stepIndex) * perStep).round();
    return Duration(milliseconds: remaining);
  }
}