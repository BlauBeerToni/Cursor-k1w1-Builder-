class BuildRun {
  final String id;
  final String? runId;
  final String status;     // queued|running|failed|success
  final String step;       // checkout|pub_get|build_apk|...
  final int stepIndex;
  final int stepsTotal;
  final String? apkUrl;
  final String? aabUrl;
  final DateTime? startedAt;
  final DateTime? finishedAt;
  final int? durationMs;

  const BuildRun({
    required this.id,
    this.runId,
    required this.status,
    required this.step,
    required this.stepIndex,
    required this.stepsTotal,
    this.apkUrl,
    this.aabUrl,
    this.startedAt,
    this.finishedAt,
    this.durationMs,
  });

  factory BuildRun.fromMap(Map<String, dynamic> m) => BuildRun(
    id: m['id'],
    runId: m['run_id']?.toString(),
    status: m['status'],
    step: m['step'] ?? 'queued',
    stepIndex: (m['step_index'] ?? 0) as int,
    stepsTotal: (m['steps_total'] ?? 8) as int,
    apkUrl: m['apk_url'],
    aabUrl: m['aab_url'],
    startedAt: m['started_at'] != null ? DateTime.parse(m['started_at']) : null,
    finishedAt: m['finished_at'] != null ? DateTime.parse(m['finished_at']) : null,
    durationMs: m['duration_ms'],
  );

  Map<String, dynamic> toMap() => {
    'id': id,
    'run_id': runId,
    'status': status,
    'step': step,
    'step_index': stepIndex,
    'steps_total': stepsTotal,
    'apk_url': apkUrl,
    'aab_url': aabUrl,
    'started_at': startedAt?.toIso8601String(),
    'finished_at': finishedAt?.toIso8601String(),
    'duration_ms': durationMs,
  };

  @override
  String toString() => 'BuildRun(id: $id, status: $status, step: $step, progress: ${stepIndex}/${stepsTotal})';
}