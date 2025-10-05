import 'package:prompt_apk_builder/common/models/ai_provider.dart';
import 'package:prompt_apk_builder/common/providers/ai/openai_provider.dart';
import 'package:prompt_apk_builder/common/providers/ai/huggingface_provider.dart';
import 'package:prompt_apk_builder/common/providers/ai/ollama_provider.dart';

class AIProviderFactory {
  static AIProvider createProvider({
    required String providerName,
    String? apiKey,
    String? endpoint,
  }) {
    switch (providerName.toLowerCase()) {
      case 'openai':
        if (apiKey == null || apiKey.isEmpty) {
          throw ArgumentError('OpenAI API key is required');
        }
        return OpenAIProvider(apiKey);

      case 'huggingface':
        if (apiKey == null || apiKey.isEmpty) {
          throw ArgumentError('Hugging Face API key is required');
        }
        return HuggingFaceProvider(apiKey);

      case 'ollama':
        final finalEndpoint = endpoint ?? 'http://localhost:11434';
        return OllamaProvider(finalEndpoint);

      default:
        throw ArgumentError('Unknown AI provider: $providerName');
    }
  }

  static List<String> getSupportedProviders() {
    return ['openai', 'huggingface', 'ollama'];
  }

  static Map<String, String> getProviderDisplayNames() {
    return {
      'openai': 'OpenAI',
      'huggingface': 'Hugging Face',
      'ollama': 'Ollama (Local)',
    };
  }
}