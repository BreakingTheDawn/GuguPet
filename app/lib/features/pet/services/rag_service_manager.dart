import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';

import '../../../core/services/ai_config_loader_service.dart';
import '../data/datasources/vector_memory_datasource.dart';
import '../data/models/retrieval_result.dart';
import '../data/models/vector_memory.dart';
import 'embedding_service.dart';
import 'retrieval_service.dart';

/// Manages the RAG service graph used by pet memory retrieval.
class RAGServiceManager extends ChangeNotifier {
  static final RAGServiceManager _instance = RAGServiceManager._internal();

  factory RAGServiceManager() => _instance;

  RAGServiceManager._internal();

  static const EmbeddingConfig _ollamaConfig = EmbeddingConfig(
    apiKey: '',
    endpoint: 'http://127.0.0.1:11434/api/embed',
    model: 'qwen3-embedding:4b',
    dimension: 2560,
  );

  static const EmbeddingConfig _localConfig = EmbeddingConfig(
    apiKey: '',
    endpoint: '',
    model: 'local',
    dimension: 384,
  );

  /// Current embedding service instance.
  EmbeddingService? _embeddingService;

  /// Current retrieval service instance.
  RetrievalService? _retrievalService;

  /// Current vector-memory datasource.
  VectorMemoryDatasourceImpl? _datasource;

  /// Whether the service graph has been initialized.
  bool _initialized = false;

  /// Current embedding provider id.
  String _currentProvider = 'ollama';

  /// Current embedding service.
  EmbeddingService? get embeddingService => _embeddingService;

  /// Current retrieval service.
  RetrievalService? get retrievalService => _retrievalService;

  /// Current vector-memory datasource.
  VectorMemoryDatasourceImpl? get datasource => _datasource;

  /// Whether RAG services are ready.
  bool get isInitialized => _initialized;

  /// Current embedding provider id.
  String get currentProvider => _currentProvider;

  /// Initializes RAG services.
  ///
  /// Development defaults to local Ollama embedding. Cloud embedding providers
  /// are only used when the caller passes an explicit provider and config.
  Future<void> initialize({
    required Database database,
    String provider = 'ollama',
    EmbeddingConfig? config,
  }) async {
    if (_initialized) {
      debugPrint(
        'RAG service is already initialized; skipping duplicate init.',
      );
      return;
    }

    try {
      debugPrint('Starting RAG service initialization...');

      // Build the datasource first so retrieval and writes share one database.
      _datasource = VectorMemoryDatasourceImpl(database);
      debugPrint('  Vector memory datasource created.');

      // Build the embedding provider. Ollama is the default local deployment.
      final providerId = provider.toLowerCase();
      final embeddingConfig = config ?? _defaultEmbeddingConfig(providerId);
      _embeddingService = EmbeddingServiceFactory.create(
        provider: providerId,
        config: embeddingConfig,
      );
      _currentProvider = providerId;
      debugPrint(
        '  Embedding service created: ${_embeddingService!.providerName}',
      );

      // Build retrieval on top of the selected embedding service.
      _retrievalService = RetrievalServiceImpl(
        embeddingService: _embeddingService!,
        datasource: _datasource!,
      );
      debugPrint('  Retrieval service created.');

      _initialized = true;
      debugPrint('RAG service initialization completed.');

      notifyListeners();
    } catch (e) {
      debugPrint('RAG service initialization failed: $e');
      _initialized = false;
    }
  }

  /// Initializes RAG while respecting the local-first embedding policy.
  ///
  /// Chat provider credentials are not reused for embeddings. Production cloud
  /// embedding should call [initialize] or [switchProvider] with explicit config.
  Future<void> initializeWithAIConfig({
    required Database database,
    AIConfigLoaderService? aiConfig,
  }) async {
    await initialize(database: database);
  }

  /// Switches the embedding provider after RAG has been initialized.
  Future<void> switchProvider({
    required String provider,
    required EmbeddingConfig config,
  }) async {
    if (!_initialized || _datasource == null) {
      debugPrint('RAG service is not initialized; provider switch skipped.');
      return;
    }

    try {
      final providerId = provider.toLowerCase();
      _embeddingService = EmbeddingServiceFactory.create(
        provider: providerId,
        config: config,
      );
      _currentProvider = providerId;

      _retrievalService = RetrievalServiceImpl(
        embeddingService: _embeddingService!,
        datasource: _datasource!,
      );

      debugPrint(
        'Embedding provider switched: ${_embeddingService!.providerName}',
      );
      notifyListeners();
    } catch (e) {
      debugPrint('Embedding provider switch failed: $e');
    }
  }

  /// Stores a memory with its embedding vector.
  Future<bool> storeMemory({
    required String petId,
    required String content,
    MemoryType type = MemoryType.shortTerm,
    MemoryCategory category = MemoryCategory.emotion,
    double importance = 0.5,
  }) async {
    if (!_initialized || _retrievalService == null || _datasource == null) {
      debugPrint('RAG service is not initialized; memory write skipped.');
      return false;
    }

    try {
      // Generate the vector before writing so empty embeddings never persist.
      final embedding = await _embeddingService!.embed(content);
      if (embedding.isEmpty) {
        debugPrint('Embedding generation failed; memory write skipped.');
        return false;
      }

      // Short-term memories expire after 24 hours; other memory types persist.
      final memory = VectorMemory(
        id: 'mem_${DateTime.now().millisecondsSinceEpoch}',
        petId: petId,
        type: type,
        category: category,
        content: content,
        embedding: embedding,
        importance: importance,
        createdAt: DateTime.now(),
        expiresAt: type == MemoryType.shortTerm
            ? DateTime.now().add(const Duration(hours: 24))
            : null,
      );

      await _datasource!.insertMemory(memory);
      debugPrint('Memory stored: ${memory.id}');
      return true;
    } catch (e) {
      debugPrint('Memory write failed: $e');
      return false;
    }
  }

  /// Searches memories relevant to the query for a single pet.
  Future<RetrievalResult> search({
    required String query,
    required String petId,
    int topK = 5,
    double threshold = 0.6,
  }) async {
    if (!_initialized || _retrievalService == null) {
      debugPrint('RAG service is not initialized; returning empty result.');
      return RetrievalResult.empty();
    }

    return _retrievalService!.search(
      query: query,
      petId: petId,
      topK: topK,
      threshold: threshold,
    );
  }

  /// Removes expired memories for a pet.
  Future<void> cleanExpiredMemories(String petId) async {
    if (_datasource == null) return;
    await _datasource!.cleanExpiredMemories(petId);
    debugPrint('Expired memories cleaned: $petId');
  }

  /// Releases service references.
  @override
  void dispose() {
    _embeddingService = null;
    _retrievalService = null;
    _datasource = null;
    _initialized = false;
    _currentProvider = 'ollama';
    super.dispose();
  }

  /// Returns the built-in config for local development providers.
  EmbeddingConfig _defaultEmbeddingConfig(String provider) {
    switch (provider) {
      case 'ollama':
        return _ollamaConfig;
      case 'local':
        return _localConfig;
      default:
        throw EmbeddingException(
          'Embedding config is required for provider: $provider',
          provider: provider,
        );
    }
  }
}
