import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prompt_apk_builder/app/providers/providers.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  late TextEditingController _githubTokenController;
  late TextEditingController _githubRepoController;
  late TextEditingController _githubBranchController;
  late TextEditingController _backendUrlController;
  late TextEditingController _aiModelController;
  late TextEditingController _openaiApiKeyController;
  late TextEditingController _anthropicApiKeyController;
  late TextEditingController _hfApiKeyController;
  late TextEditingController _ollamaEndpointController;

  String _selectedAiProvider = 'huggingface';
  bool _isPublicRepo = false;
  bool _obscureTokens = true;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _loadSettings();
  }

  void _initializeControllers() {
    _githubTokenController = TextEditingController();
    _githubRepoController = TextEditingController();
    _githubBranchController = TextEditingController();
    _backendUrlController = TextEditingController();
    _aiModelController = TextEditingController();
    _openaiApiKeyController = TextEditingController();
    _anthropicApiKeyController = TextEditingController();
    _hfApiKeyController = TextEditingController();
    _ollamaEndpointController = TextEditingController();
  }

  Future<void> _loadSettings() async {
    final settings = ref.read(settingsProvider);
    final secureStorage = ref.read(secureStorageProvider);

    setState(() {
      _githubTokenController.text = settings.githubToken;
      _githubRepoController.text = settings.githubRepo;
      _githubBranchController.text = settings.githubBranch;
      _backendUrlController.text = settings.backendUrl;
      _selectedAiProvider = settings.aiProvider;
      _aiModelController.text = settings.aiModel;
      _openaiApiKeyController.text = settings.openaiApiKey;
      _anthropicApiKeyController.text = settings.anthropicApiKey;
      _hfApiKeyController.text = settings.hfApiKey;
      _ollamaEndpointController.text = settings.ollamaEndpoint;
      _isPublicRepo = settings.isPublicRepo;
    });
  }

  Future<void> _saveSettings() async {
    final secureStorage = ref.read(secureStorageProvider);

    // Save sensitive data to secure storage
    await secureStorage.write(key: 'github_token', value: _githubTokenController.text);
    await secureStorage.write(key: 'openai_api_key', value: _openaiApiKeyController.text);
    await secureStorage.write(key: 'anthropic_api_key', value: _anthropicApiKeyController.text);
    await secureStorage.write(key: 'hf_api_key', value: _hfApiKeyController.text);

    // Update settings provider
    ref.read(settingsProvider.notifier).state = Settings(
      githubToken: _githubTokenController.text,
      githubRepo: _githubRepoController.text,
      githubBranch: _githubBranchController.text,
      backendUrl: _backendUrlController.text,
      aiProvider: _selectedAiProvider,
      aiModel: _aiModelController.text,
      openaiApiKey: _openaiApiKeyController.text,
      anthropicApiKey: _anthropicApiKeyController.text,
      hfApiKey: _hfApiKeyController.text,
      ollamaEndpoint: _ollamaEndpointController.text,
      isPublicRepo: _isPublicRepo,
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Einstellungen gespeichert')),
      );
    }
  }

  Future<void> _testConnection() async {
    // TODO: Implement connection testing
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Verbindung wird getestet...')),
    );
  }

  @override
  void dispose() {
    _githubTokenController.dispose();
    _githubRepoController.dispose();
    _githubBranchController.dispose();
    _backendUrlController.dispose();
    _aiModelController.dispose();
    _openaiApiKeyController.dispose();
    _anthropicApiKeyController.dispose();
    _hfApiKeyController.dispose();
    _ollamaEndpointController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Einstellungen'),
        actions: [
          TextButton(
            onPressed: _saveSettings,
            child: const Text('Speichern'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // GitHub Settings
            _buildSectionCard(
              title: 'GitHub',
              children: [
                _buildTextField(
                  controller: _githubTokenController,
                  label: 'GitHub Token',
                  hint: 'ghp_...',
                  obscureText: _obscureTokens,
                  suffixIcon: IconButton(
                    icon: Icon(_obscureTokens ? Icons.visibility_off : Icons.visibility),
                    onPressed: () => setState(() => _obscureTokens = !_obscureTokens),
                  ),
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _githubRepoController,
                  label: 'Repository',
                  hint: 'username/repository',
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _githubBranchController,
                  label: 'Branch',
                  hint: 'main',
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Checkbox(
                      value: _isPublicRepo,
                      onChanged: (value) => setState(() => _isPublicRepo = value!),
                    ),
                    const Text('Öffentliches Repository'),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Backend Settings
            _buildSectionCard(
              title: 'Backend',
              children: [
                _buildTextField(
                  controller: _backendUrlController,
                  label: 'Backend URL',
                  hint: 'http://localhost:8000',
                ),
              ],
            ),

            const SizedBox(height: 16),

            // AI Provider Settings
            _buildSectionCard(
              title: 'KI-Anbieter',
              children: [
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'Anbieter',
                    border: OutlineInputBorder(),
                  ),
                  value: _selectedAiProvider,
                  items: const [
                    DropdownMenuItem(value: 'huggingface', child: Text('Hugging Face')),
                    DropdownMenuItem(value: 'openai', child: Text('OpenAI')),
                    DropdownMenuItem(value: 'anthropic', child: Text('Anthropic')),
                    DropdownMenuItem(value: 'ollama', child: Text('Ollama')),
                  ],
                  onChanged: (value) => setState(() => _selectedAiProvider = value!),
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _aiModelController,
                  label: 'Modell',
                  hint: 'microsoft/DialoGPT-medium',
                ),
                if (_selectedAiProvider == 'openai') ...[
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _openaiApiKeyController,
                    label: 'OpenAI API Key',
                    hint: 'sk-...',
                    obscureText: _obscureTokens,
                    suffixIcon: IconButton(
                      icon: Icon(_obscureTokens ? Icons.visibility_off : Icons.visibility),
                      onPressed: () => setState(() => _obscureTokens = !_obscureTokens),
                    ),
                  ),
                ],
                if (_selectedAiProvider == 'anthropic') ...[
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _anthropicApiKeyController,
                    label: 'Anthropic API Key',
                    hint: 'sk-ant-api...',
                    obscureText: _obscureTokens,
                    suffixIcon: IconButton(
                      icon: Icon(_obscureTokens ? Icons.visibility_off : Icons.visibility),
                      onPressed: () => setState(() => _obscureTokens = !_obscureTokens),
                    ),
                  ),
                ],
                if (_selectedAiProvider == 'huggingface') ...[
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _hfApiKeyController,
                    label: 'Hugging Face API Key',
                    hint: 'hf_...',
                    obscureText: _obscureTokens,
                    suffixIcon: IconButton(
                      icon: Icon(_obscureTokens ? Icons.visibility_off : Icons.visibility),
                      onPressed: () => setState(() => _obscureTokens = !_obscureTokens),
                    ),
                  ),
                ],
                if (_selectedAiProvider == 'ollama') ...[
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _ollamaEndpointController,
                    label: 'Ollama Endpoint',
                    hint: 'http://localhost:11434',
                  ),
                ],
              ],
            ),

            const SizedBox(height: 24),

            // Test Connection Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.wifi),
                label: const Text('Verbindung testen'),
                onPressed: _testConnection,
              ),
            ),

            const SizedBox(height: 16),

            // Info Card
            Card(
              color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Hinweise',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '• Tokens werden sicher im Android Keystore gespeichert\n'
                      '• Verwende einen fine-grained GitHub Token für Repository-Zugriff\n'
                      '• Bei öffentlichen Repositories werden kostenlose GitHub Actions verwendet\n'
                      '• Alle sensiblen Daten werden verschlüsselt gespeichert',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard({required String title, required List<Widget> children}) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    bool obscureText = false,
    Widget? suffixIcon,
  }) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: const OutlineInputBorder(),
        suffixIcon: suffixIcon,
      ),
      obscureText: obscureText,
    );
  }
}