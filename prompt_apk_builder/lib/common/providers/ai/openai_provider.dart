import 'package:dio/dio.dart';
import 'package:prompt_apk_builder/common/models/ai_provider.dart';

class OpenAIProvider implements AIProvider {
  final String apiKey;
  final Dio _dio;

  OpenAIProvider(this.apiKey) : _dio = Dio();

  @override
  String get name => 'openai';

  @override
  String get displayName => 'OpenAI';

  @override
  bool get requiresApiKey => true;

  @override
  bool get isLocal => false;

  @override
  Future<AIResponse> generateCode(AIRequest request) async {
    try {
      final response = await _dio.post(
        'https://api.openai.com/v1/chat/completions',
        options: Options(
          headers: {
            'Authorization': 'Bearer $apiKey',
            'Content-Type': 'application/json',
          },
        ),
        data: {
          'model': request.model,
          'messages': [
            {'role': 'system', 'content': request.systemPrompt},
            {'role': 'user', 'content': request.prompt},
          ],
          'temperature': request.temperature,
          'max_tokens': request.maxTokens,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;
        final content = data['choices'][0]['message']['content'];
        final tokensUsed = data['usage']['total_tokens'];

        return AIResponse(
          content: content,
          model: request.model,
          tokensUsed: tokensUsed,
          success: true,
        );
      } else {
        return AIResponse.error('OpenAI API error: ${response.statusCode}');
      }
    } catch (e) {
      return AIResponse.error('OpenAI error: $e');
    }
  }

  @override
  Future<bool> validateConnection() async {
    try {
      final response = await _dio.get(
        'https://api.openai.com/v1/models',
        options: Options(
          headers: {
            'Authorization': 'Bearer $apiKey',
          },
        ),
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}