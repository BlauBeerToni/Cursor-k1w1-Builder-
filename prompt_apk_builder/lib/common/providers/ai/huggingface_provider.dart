import 'package:dio/dio.dart';
import 'package:prompt_apk_builder/common/models/ai_provider.dart';

class HuggingFaceProvider implements AIProvider {
  final String apiKey;
  final Dio _dio;

  HuggingFaceProvider(this.apiKey) : _dio = Dio();

  @override
  String get name => 'huggingface';

  @override
  String get displayName => 'Hugging Face';

  @override
  bool get requiresApiKey => true;

  @override
  bool get isLocal => false;

  @override
  Future<AIResponse> generateCode(AIRequest request) async {
    try {
      final response = await _dio.post(
        'https://api-inference.huggingface.co/models/${request.model}',
        options: Options(
          headers: {
            'Authorization': 'Bearer $apiKey',
            'Content-Type': 'application/json',
          },
        ),
        data: {
          'inputs': '${request.systemPrompt}\n\n${request.prompt}',
          'parameters': {
            'temperature': request.temperature,
            'max_new_tokens': request.maxTokens,
            'return_full_text': false,
          },
          'options': {
            'wait_for_model': true,
          },
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;
        final content = data[0]['generated_text'] ?? '';
        // Estimate tokens (rough calculation)
        final tokensUsed = (content.length / 4).round();

        return AIResponse(
          content: content,
          model: request.model,
          tokensUsed: tokensUsed,
          success: true,
        );
      } else {
        return AIResponse.error('Hugging Face API error: ${response.statusCode}');
      }
    } catch (e) {
      return AIResponse.error('Hugging Face error: $e');
    }
  }

  @override
  Future<bool> validateConnection() async {
    try {
      // Try a simple model info request
      final response = await _dio.get(
        'https://huggingface.co/api/models/microsoft/DialoGPT-medium',
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