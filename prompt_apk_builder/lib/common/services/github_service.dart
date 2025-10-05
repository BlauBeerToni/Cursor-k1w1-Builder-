import 'package:dio/dio.dart';
import 'package:prompt_apk_builder/common/models/ai_provider.dart';

class GitHubService {
  final String token;
  final Dio _dio;

  GitHubService(this.token) : _dio = Dio();

  Future<bool> validateToken() async {
    try {
      final response = await _dio.get(
        'https://api.github.com/user',
        options: Options(
          headers: {
            'Authorization': 'token $token',
            'Accept': 'application/vnd.github.v3+json',
          },
        ),
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  Future<bool> repositoryExists(String owner, String repo) async {
    try {
      final response = await _dio.get(
        'https://api.github.com/repos/$owner/$repo',
        options: Options(
          headers: {
            'Authorization': 'token $token',
            'Accept': 'application/vnd.github.v3+json',
          },
        ),
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  Future<void> createRepository(String name, {String description = '', bool isPrivate = false}) async {
    try {
      await _dio.post(
        'https://api.github.com/user/repos',
        options: Options(
          headers: {
            'Authorization': 'token $token',
            'Accept': 'application/vnd.github.v3+json',
          },
        ),
        data: {
          'name': name,
          'description': description,
          'private': isPrivate,
          'auto_init': true,
        },
      );
    } catch (e) {
      throw Exception('Failed to create repository: $e');
    }
  }

  Future<void> commitFiles({
    required String owner,
    required String repo,
    required String branch,
    required String message,
    required List<GitHubFile> files,
  }) async {
    try {
      // Get the current commit SHA
      final refResponse = await _dio.get(
        'https://api.github.com/repos/$owner/$repo/git/ref/heads/$branch',
        options: Options(
          headers: {
            'Authorization': 'token $token',
            'Accept': 'application/vnd.github.v3+json',
          },
        ),
      );

      if (refResponse.statusCode != 200) {
        throw Exception('Branch not found');
      }

      final currentSha = refResponse.data['object']['sha'];

      // Get the current tree
      final commitResponse = await _dio.get(
        'https://api.github.com/repos/$owner/$repo/git/commits/$currentSha',
        options: Options(
          headers: {
            'Authorization': 'token $token',
            'Accept': 'application/vnd.github.v3+json',
          },
        ),
      );

      final treeSha = commitResponse.data['tree']['sha'];

      // Create blobs for each file
      final blobs = <Map<String, dynamic>>[];
      for (final file in files) {
        final blobResponse = await _dio.post(
          'https://api.github.com/repos/$owner/$repo/git/blobs',
          options: Options(
            headers: {
              'Authorization': 'token $token',
              'Accept': 'application/vnd.github.v3+json',
            },
          ),
          data: {
            'content': file.content,
            'encoding': 'utf-8',
          },
        );

        blobs.add({
          'path': file.path,
          'mode': '100644',
          'type': 'blob',
          'sha': blobResponse.data['sha'],
        });
      }

      // Create a new tree
      final treeResponse = await _dio.post(
        'https://api.github.com/repos/$owner/$repo/git/trees',
        options: Options(
          headers: {
            'Authorization': 'token $token',
            'Accept': 'application/vnd.github.v3+json',
          },
        ),
        data: {
          'base_tree': treeSha,
          'tree': blobs,
        },
      );

      final newTreeSha = treeResponse.data['sha'];

      // Create the commit
      final commitResponse = await _dio.post(
        'https://api.github.com/repos/$owner/$repo/git/commits',
        options: Options(
          headers: {
            'Authorization': 'token $token',
            'Accept': 'application/vnd.github.v3+json',
          },
        ),
        data: {
          'message': message,
          'tree': newTreeSha,
          'parents': [currentSha],
        },
      );

      final newCommitSha = commitResponse.data['sha'];

      // Update the reference
      await _dio.patch(
        'https://api.github.com/repos/$owner/$repo/git/refs/heads/$branch',
        options: Options(
          headers: {
            'Authorization': 'token $token',
            'Accept': 'application/vnd.github.v3+json',
          },
        ),
        data: {
          'sha': newCommitSha,
        },
      );
    } catch (e) {
      throw Exception('Failed to commit files: $e');
    }
  }

  Future<void> triggerWorkflow({
    required String owner,
    required String repo,
    required String workflowId,
  }) async {
    try {
      await _dio.post(
        'https://api.github.com/repos/$owner/$repo/actions/workflows/$workflowId/dispatches',
        options: Options(
          headers: {
            'Authorization': 'token $token',
            'Accept': 'application/vnd.github.v3+json',
          },
        ),
        data: {
          'ref': 'main',
        },
      );
    } catch (e) {
      throw Exception('Failed to trigger workflow: $e');
    }
  }
}

// GitHub File Model
class GitHubFile {
  final String path;
  final String content;

  const GitHubFile({
    required this.path,
    required this.content,
  });
}