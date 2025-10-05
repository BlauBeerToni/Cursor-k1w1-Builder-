// AI Provider Interface
abstract class AIProvider {
  String get name;
  String get displayName;
  bool get requiresApiKey;
  bool get isLocal;

  Future<AIResponse> generateCode(AIRequest request);
  Future<bool> validateConnection();
}

// AI Request Model
class AIRequest {
  final String prompt;
  final String systemPrompt;
  final String model;
  final double temperature;
  final int maxTokens;

  const AIRequest({
    required this.prompt,
    required this.systemPrompt,
    required this.model,
    this.temperature = 0.7,
    this.maxTokens = 4000,
  });

  Map<String, dynamic> toJson() {
    return {
      'prompt': prompt,
      'system_prompt': systemPrompt,
      'model': model,
      'temperature': temperature,
      'max_tokens': maxTokens,
    };
  }
}

// AI Response Model
class AIResponse {
  final String content;
  final String model;
  final int tokensUsed;
  final bool success;
  final String? errorMessage;

  const AIResponse({
    required this.content,
    required this.model,
    required this.tokensUsed,
    this.success = true,
    this.errorMessage,
  });

  factory AIResponse.error(String message) {
    return AIResponse(
      content: '',
      model: '',
      tokensUsed: 0,
      success: false,
      errorMessage: message,
    );
  }
}

// Plan Generation Response
class PlanResponse {
  final String plan;
  final List<String> features;
  final Map<String, String> dependencies;
  final FileTree fileTree;
  final List<String> buildSteps;

  const PlanResponse({
    required this.plan,
    required this.features,
    required this.dependencies,
    required this.fileTree,
    required this.buildSteps,
  });
}

// Code Generation Response
class CodeGenerationResponse {
  final List<GeneratedFile> files;
  final String summary;

  const CodeGenerationResponse({
    required this.files,
    required this.summary,
  });
}

// Generated File Model
class GeneratedFile {
  final String path;
  final String content;
  final String purpose;

  const GeneratedFile({
    required this.path,
    required this.content,
    required this.purpose,
  });

  Map<String, dynamic> toJson() {
    return {
      'path': path,
      'content': content,
      'purpose': purpose,
    };
  }
}

// File Tree Model
class FileTree {
  final String root;
  final List<FileTreeNode> children;

  const FileTree({
    required this.root,
    required this.children,
  });
}

// File Tree Node
class FileTreeNode {
  final String name;
  final String type; // 'file' or 'directory'
  final List<FileTreeNode>? children;
  final String? purpose;

  const FileTreeNode({
    required this.name,
    required this.type,
    this.children,
    this.purpose,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'type': type,
      'children': children?.map((child) => child.toJson()).toList(),
      'purpose': purpose,
    };
  }
}