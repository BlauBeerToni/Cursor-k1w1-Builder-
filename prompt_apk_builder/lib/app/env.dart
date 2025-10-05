import 'package:flutter_dotenv/flutter_dotenv.dart';

class Env {
  static String get supabaseUrl => dotenv.get('SUPABASE_URL', fallback: '');
  static String get supabaseAnon => dotenv.get('SUPABASE_ANON_KEY', fallback: '');
  static String get appId => dotenv.get('ANDROID_APP_ID', fallback: 'com.example.app');
  static String? get buildWebhook => dotenv.maybeGet('BUILD_WEBHOOK_URL');

  // Legacy support for existing env vars
  static String get backendUrl => dotenv.get('BACKEND_URL', fallback: 'http://localhost:8000');
  static String get githubToken => dotenv.get('GITHUB_TOKEN', fallback: '');
  static String get githubRepo => dotenv.get('GITHUB_REPO', fallback: '');
  static String get githubBranch => dotenv.get('GH_BRANCH', fallback: 'main');
  static String get aiProvider => dotenv.get('AI_PROVIDER', fallback: 'huggingface');
  static String get openaiApiKey => dotenv.get('OPENAI_API_KEY', fallback: '');
  static String get openaiModel => dotenv.get('OPENAI_MODEL', fallback: 'gpt-4');
  static double get openaiTemperature => double.parse(dotenv.get('OPENAI_TEMPERATURE', fallback: '0.7'));
  static int get openaiMaxTokens => int.parse(dotenv.get('OPENAI_MAX_TOKENS', fallback: '4000'));
  static String get anthropicApiKey => dotenv.get('ANTHROPIC_API_KEY', fallback: '');
  static String get anthropicModel => dotenv.get('ANTHROPIC_MODEL', fallback: 'claude-3-sonnet-20240229');
  static double get anthropicTemperature => double.parse(dotenv.get('ANTHROPIC_TEMPERATURE', fallback: '0.7'));
  static int get anthropicMaxTokens => int.parse(dotenv.get('ANTHROPIC_MAX_TOKENS', fallback: '4000'));
  static String get huggingfaceApiKey => dotenv.get('HF_API_KEY', fallback: '');
  static String get huggingfaceModel => dotenv.get('HF_MODEL', fallback: 'microsoft/DialoGPT-medium');
  static String get ollamaEndpoint => dotenv.get('OLLAMA_ENDPOINT', fallback: 'http://localhost:11434');
  static String get ollamaModel => dotenv.get('OLLAMA_MODEL', fallback: 'llama2');
  static String get sentryDsn => dotenv.get('SENTRY_DSN', fallback: '');
}