import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:prompt_apk_builder/app/providers/providers.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final TextEditingController _promptController = TextEditingController();
  bool _showAdvancedSettings = false;
  bool _isLoading = false;

  // Advanced settings state
  String _projectName = 'Meine App';
  String _packageId = 'com.example.meine_app';
  String _aiProvider = 'huggingface';
  String _aiModel = 'microsoft/DialoGPT-medium';
  double _temperature = 0.7;
  int _maxTokens = 4000;
  String _githubRepo = '';
  String _githubBranch = 'main';
  bool _isPublicRepo = false;
  bool _buildApk = true;
  bool _buildAab = false;
  bool _runTests = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final settings = ref.read(settingsProvider);
    setState(() {
      _githubRepo = settings.githubRepo;
      _githubBranch = settings.githubBranch;
      _aiProvider = settings.aiProvider;
      _aiModel = settings.aiModel;
      _isPublicRepo = settings.isPublicRepo;
    });
  }

  void _generateAndBuild() {
    if (_promptController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Bitte gib eine App-Beschreibung ein'),
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // TODO: Implement build logic
    // For now, navigate to status screen
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        context.go('/status');
      }
    });
  }

  @override
  void dispose() {
    _promptController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('App Builder'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => context.go('/settings'),
          ),
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () => context.go('/history'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'App-Beschreibung',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _promptController,
                      maxLines: 6,
                      decoration: const InputDecoration(
                        hintText: 'Beschreibe deine gewünschte App hier...',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 8,
                      children: [
                        _buildTemplateChip('CRUD + Auth'),
                        _buildTemplateChip('Chat App'),
                        _buildTemplateChip('Todo Liste'),
                        _buildTemplateChip('Camera App'),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Erweiterte Einstellungen',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        IconButton(
                          icon: Icon(
                            _showAdvancedSettings
                                ? Icons.expand_less
                                : Icons.expand_more,
                          ),
                          onPressed: () {
                            setState(() {
                              _showAdvancedSettings = !_showAdvancedSettings;
                            });
                          },
                        ),
                      ],
                    ),
                    if (_showAdvancedSettings) ...[
                      const SizedBox(height: 16),
                      _buildAdvancedSettings(),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isLoading ? null : _generateAndBuild,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
              ),
              child: _isLoading
                  ? const CircularProgressIndicator()
                  : const Text('Generieren & Bauen'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTemplateChip(String label) {
    return ActionChip(
      label: Text(label),
      onPressed: () {
        setState(() {
          _promptController.text = _getTemplatePrompt(label);
        });
      },
    );
  }

  String _getTemplatePrompt(String template) {
    switch (template) {
      case 'CRUD + Auth':
        return 'Erstelle eine Flutter-App mit CRUD-Operationen und Benutzerauthentifizierung. Die App soll Daten aus einer lokalen SQLite-Datenbank speichern und eine einfache Login-Registrierung haben.';
      case 'Chat App':
        return 'Erstelle eine Chat-App mit Echtzeit-Nachrichten. Die App soll WebSocket-Verbindungen verwenden und eine schöne UI mit Nachrichten-Bubbles haben.';
      case 'Todo Liste':
        return 'Erstelle eine Todo-App mit lokaler Datenspeicherung. Die App soll verschiedene Kategorien unterstützen und Erinnerungen setzen können.';
      case 'Camera App':
        return 'Erstelle eine Kamera-App mit Foto- und Videoaufnahme. Die App soll eine Galerie-Anzeige und einfache Bildbearbeitung haben.';
      default:
        return '';
    }
  }

  Widget _buildAdvancedSettings() {
    return Column(
      children: [
        TextField(
          decoration: const InputDecoration(
            labelText: 'Projektname',
            border: OutlineInputBorder(),
          ),
          controller: TextEditingController(text: _projectName),
          onChanged: (value) => _projectName = value,
        ),
        const SizedBox(height: 16),
        TextField(
          decoration: const InputDecoration(
            labelText: 'Package ID',
            border: OutlineInputBorder(),
          ),
          controller: TextEditingController(text: _packageId),
          onChanged: (value) => _packageId = value,
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'KI-Anbieter',
                  border: OutlineInputBorder(),
                ),
                value: _aiProvider,
                items: const [
                  DropdownMenuItem(value: 'huggingface', child: Text('Hugging Face')),
                  DropdownMenuItem(value: 'openai', child: Text('OpenAI')),
                  DropdownMenuItem(value: 'anthropic', child: Text('Anthropic')),
                  DropdownMenuItem(value: 'ollama', child: Text('Ollama')),
                ],
                onChanged: (value) => setState(() => _aiProvider = value!),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TextField(
                decoration: const InputDecoration(
                  labelText: 'KI-Modell',
                  border: OutlineInputBorder(),
                ),
                controller: TextEditingController(text: _aiModel),
                onChanged: (value) => _aiModel = value,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: TextField(
                decoration: const InputDecoration(
                  labelText: 'GitHub Repository',
                  border: OutlineInputBorder(),
                ),
                controller: TextEditingController(text: _githubRepo),
                onChanged: (value) => _githubRepo = value,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TextField(
                decoration: const InputDecoration(
                  labelText: 'Branch',
                  border: OutlineInputBorder(),
                ),
                controller: TextEditingController(text: _githubBranch),
                onChanged: (value) => _githubBranch = value,
              ),
            ),
          ],
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
        const SizedBox(height: 16),
        Row(
          children: [
            Checkbox(
              value: _buildApk,
              onChanged: (value) => setState(() => _buildApk = value!),
            ),
            const Text('APK bauen'),
            const SizedBox(width: 16),
            Checkbox(
              value: _buildAab,
              onChanged: (value) => setState(() => _buildAab = value!),
            ),
            const Text('AAB bauen'),
            const SizedBox(width: 16),
            Checkbox(
              value: _runTests,
              onChanged: (value) => setState(() => _runTests = value!),
            ),
            const Text('Tests ausführen'),
          ],
        ),
      ],
    );
  }
}