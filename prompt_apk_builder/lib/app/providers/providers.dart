import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

// Secure Storage Provider
final secureStorageProvider = Provider<FlutterSecureStorage>((ref) {
  return const FlutterSecureStorage();
});

// Shared Preferences Provider
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('SharedPreferences not initialized');
});

// Dio Client Provider
final dioProvider = Provider<Dio>((ref) {
  final dio = Dio();

  // Add interceptors based on environment
  if (const String.fromEnvironment('FLUTTER_APP_FLAVOR') == 'development') {
    dio.interceptors.add(PrettyDioLogger(
      requestHeader: true,
      requestBody: true,
      responseBody: true,
      responseHeader: false,
      error: true,
      compact: true,
      maxWidth: 90,
    ));
  }

  return dio;
});

// Environment Variables Provider
final envProvider = Provider<Map<String, String>>((ref) {
  // This would be populated from .env file
  // For now, return empty map
  return {};
});

// App State Provider
final appStateProvider = StateProvider<AppState>((ref) {
  return AppState.idle;
});

// Build State Provider
final buildStateProvider = StateProvider<BuildState>((ref) {
  return BuildState.initial();
});

// Settings Provider
final settingsProvider = StateProvider<Settings>((ref) {
  return Settings.initial();
});

// History Provider
final historyProvider = StateProvider<List<BuildHistory>>((ref) {
  return [];
});

// App State Enum
enum AppState {
  idle,
  loading,
  error,
}

// Build State Model
class BuildState {
  final String currentStep;
  final double progress;
  final String status;
  final String? errorMessage;
  final Map<String, dynamic>? buildData;

  const BuildState({
    required this.currentStep,
    required this.progress,
    required this.status,
    this.errorMessage,
    this.buildData,
  });

  factory BuildState.initial() {
    return const BuildState(
      currentStep: '',
      progress: 0.0,
      status: 'idle',
    );
  }

  BuildState copyWith({
    String? currentStep,
    double? progress,
    String? status,
    String? errorMessage,
    Map<String, dynamic>? buildData,
  }) {
    return BuildState(
      currentStep: currentStep ?? this.currentStep,
      progress: progress ?? this.progress,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      buildData: buildData ?? this.buildData,
    );
  }
}

// Settings Model
class Settings {
  final String githubToken;
  final String githubRepo;
  final String githubBranch;
  final String backendUrl;
  final String aiProvider;
  final String aiModel;
  final String openaiApiKey;
  final String anthropicApiKey;
  final String hfApiKey;
  final String ollamaEndpoint;
  final bool isPublicRepo;

  const Settings({
    required this.githubToken,
    required this.githubRepo,
    required this.githubBranch,
    required this.backendUrl,
    required this.aiProvider,
    required this.aiModel,
    required this.openaiApiKey,
    required this.anthropicApiKey,
    required this.hfApiKey,
    required this.ollamaEndpoint,
    required this.isPublicRepo,
  });

  factory Settings.initial() {
    return const Settings(
      githubToken: '',
      githubRepo: '',
      githubBranch: 'main',
      backendUrl: 'http://localhost:8000',
      aiProvider: 'huggingface',
      aiModel: 'microsoft/DialoGPT-medium',
      openaiApiKey: '',
      anthropicApiKey: '',
      hfApiKey: '',
      ollamaEndpoint: 'http://localhost:11434',
      isPublicRepo: false,
    );
  }

  Settings copyWith({
    String? githubToken,
    String? githubRepo,
    String? githubBranch,
    String? backendUrl,
    String? aiProvider,
    String? aiModel,
    String? openaiApiKey,
    String? anthropicApiKey,
    String? hfApiKey,
    String? ollamaEndpoint,
    bool? isPublicRepo,
  }) {
    return Settings(
      githubToken: githubToken ?? this.githubToken,
      githubRepo: githubRepo ?? this.githubRepo,
      githubBranch: githubBranch ?? this.githubBranch,
      backendUrl: backendUrl ?? this.backendUrl,
      aiProvider: aiProvider ?? this.aiProvider,
      aiModel: aiModel ?? this.aiModel,
      openaiApiKey: openaiApiKey ?? this.openaiApiKey,
      anthropicApiKey: anthropicApiKey ?? this.anthropicApiKey,
      hfApiKey: hfApiKey ?? this.hfApiKey,
      ollamaEndpoint: ollamaEndpoint ?? this.ollamaEndpoint,
      isPublicRepo: isPublicRepo ?? this.isPublicRepo,
    );
  }
}

// Build History Model
class BuildHistory {
  final String id;
  final String prompt;
  final DateTime timestamp;
  final String status;
  final String? apkUrl;
  final String? aabUrl;
  final String? runUrl;

  const BuildHistory({
    required this.id,
    required this.prompt,
    required this.timestamp,
    required this.status,
    this.apkUrl,
    this.aabUrl,
    this.runUrl,
  });
}