import 'package:dio/dio.dart';
import 'package:prompt_apk_builder/common/models/ai_provider.dart';

class BackendService {
  final String baseUrl;
  final Dio _dio;

  BackendService({required this.baseUrl}) : _dio = Dio();

  Future<String> generateAndBuild({
    required String prompt,
    required String projectName,
    required String packageId,
    required AIProvider aiProvider,
    required String githubToken,
    required String githubRepo,
    required String githubBranch,
    required bool isPublic,
  }) async {
    try {
      final response = await _dio.post(
        '$baseUrl/generate',
        data: {
          'prompt': prompt,
          'project_name': projectName,
          'package_id': packageId,
          'ai_provider': aiProvider.name,
          'github_token': githubToken,
          'github_repo': githubRepo,
          'github_branch': githubBranch,
          'is_public': isPublic,
        },
      );

      if (response.statusCode == 200) {
        return response.data['build_id'];
      } else {
        throw Exception('Backend error: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to start build: $e');
    }
  }

  Future<BuildStatus> getBuildStatus(String buildId) async {
    try {
      final response = await _dio.get('$baseUrl/status/$buildId');

      if (response.statusCode == 200) {
        final data = response.data;
        return BuildStatus(
          id: buildId,
          status: data['status'],
          progress: data['progress']?.toDouble() ?? 0.0,
          currentStep: data['current_step'] ?? '',
          logs: List<String>.from(data['logs'] ?? []),
          apkUrl: data['apk_url'],
          aabUrl: data['aab_url'],
          runUrl: data['run_url'],
          errorMessage: data['error_message'],
        );
      } else {
        throw Exception('Failed to get build status');
      }
    } catch (e) {
      throw Exception('Failed to get build status: $e');
    }
  }

  Stream<BuildStatus> watchBuildStatus(String buildId) async* {
    while (true) {
      try {
        final status = await getBuildStatus(buildId);

        if (status.status == 'completed' || status.status == 'failed') {
          yield status;
          break;
        }

        yield status;
        await Future.delayed(const Duration(seconds: 2));
      } catch (e) {
        yield BuildStatus.error('Failed to get build status: $e');
        break;
      }
    }
  }
}

// Build Status Model
class BuildStatus {
  final String id;
  final String status;
  final double progress;
  final String currentStep;
  final List<String> logs;
  final String? apkUrl;
  final String? aabUrl;
  final String? runUrl;
  final String? errorMessage;

  const BuildStatus({
    required this.id,
    required this.status,
    required this.progress,
    required this.currentStep,
    required this.logs,
    this.apkUrl,
    this.aabUrl,
    this.runUrl,
    this.errorMessage,
  });

  factory BuildStatus.error(String message) {
    return BuildStatus(
      id: '',
      status: 'error',
      progress: 0.0,
      currentStep: '',
      logs: [message],
      errorMessage: message,
    );
  }

  bool get isCompleted => status == 'completed';
  bool get isFailed => status == 'failed';
  bool get isRunning => status == 'running' || status == 'queued';

  BuildStatus copyWith({
    String? id,
    String? status,
    double? progress,
    String? currentStep,
    List<String>? logs,
    String? apkUrl,
    String? aabUrl,
    String? runUrl,
    String? errorMessage,
  }) {
    return BuildStatus(
      id: id ?? this.id,
      status: status ?? this.status,
      progress: progress ?? this.progress,
      currentStep: currentStep ?? this.currentStep,
      logs: logs ?? this.logs,
      apkUrl: apkUrl ?? this.apkUrl,
      aabUrl: aabUrl ?? this.aabUrl,
      runUrl: runUrl ?? this.runUrl,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}