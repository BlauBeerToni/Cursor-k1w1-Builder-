import 'package:dio/dio.dart';
import 'package:prompt_apk_builder/common/models/ai_provider.dart';

class OllamaProvider implements AIProvider {
  final String endpoint;
  final Dio _dio;

  OllamaProvider(this.endpoint) : _dio = Dio();

  @override
  String get name => 'ollama';

  @override
  String get displayName => 'Ollama';

  @override
  bool get requiresApiKey => false;

  @override
  bool get isLocal => true;

  @override
  Future<AIResponse> generateCode(AIRequest request) async {
    try {
      final response = await _dio.post(
        '$endpoint/api/generate',
        data: {
          'model': request.model,
          'prompt': '${request.systemPrompt}\n\n${request.prompt}',
          'stream': false,
          'options': {
            'temperature': request.temperature,
            'num_predict': request.maxTokens,
          },
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;
        final content = data['response'] ?? '';
        final tokensUsed = data['eval_count'] ?? 0;

        return AIResponse(
          content: content,
          model: request.model,
          tokensUsed: tokensUsed,
          success: true,
        );
      } else {
        return AIResponse.error('Ollama API error: ${response.statusCode}');
      }
    } catch (e) {
      return AIResponse.error('Ollama error: $e');
    }
  }

  @override
  Future<bool> validateConnection() async {
    try {
      final response = await _dio.get('$endpoint/api/tags');
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}