import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'embedding_service.dart';
import 'retrieval_service.dart';
import '../data/datasources/vector_memory_datasource.dart';
import '../data/models/vector_memory.dart';
import '../data/models/retrieval_result.dart';
import '../../../core/services/ai_config_loader_service.dart';
import '../../../core/services/security_service.dart';

/// RAG服务管理器
/// 负责初始化和管理RAG相关的服务实例
class RAGServiceManager extends ChangeNotifier {
  /// 单例实例
  static final RAGServiceManager _instance = RAGServiceManager._internal();
  factory RAGServiceManager() => _instance;
  RAGServiceManager._internal();

  /// 嵌入服务实例
  EmbeddingService? _embeddingService;

  /// 检索服务实例
  RetrievalService? _retrievalService;

  /// 数据源实例
  VectorMemoryDatasourceImpl? _datasource;

  /// 是否已初始化
  bool _initialized = false;

  /// 当前使用的嵌入提供商
  String _currentProvider = 'local';

  /// 获取嵌入服务
  EmbeddingService? get embeddingService => _embeddingService;

  /// 获取检索服务
  RetrievalService? get retrievalService => _retrievalService;

  /// 获取数据源
  VectorMemoryDatasourceImpl? get datasource => _datasource;

  /// 是否已初始化
  bool get isInitialized => _initialized;

  /// 当前提供商
  String get currentProvider => _currentProvider;

  /// 初始化RAG服务
  /// [database] 数据库实例
  /// [provider] 嵌入服务提供商（openai/glm/gemini/local）
  /// [config] 嵌入服务配置（可选，默认使用本地服务）
  Future<void> initialize({
    required Database database,
    String provider = 'local',
    EmbeddingConfig? config,
  }) async {
    if (_initialized) {
      debugPrint('📚 RAG服务已初始化，跳过重复初始化');
      return;
    }

    try {
      debugPrint('📚 开始初始化RAG服务...');

      // 1. 初始化数据源
      _datasource = VectorMemoryDatasourceImpl(database);
      debugPrint('  ✅ 向量记忆数据源已创建');

      // 2. 初始化嵌入服务
      _currentProvider = provider;
      if (config != null && config.isConfigured) {
        _embeddingService = EmbeddingServiceFactory.create(
          provider: provider,
          config: config,
        );
      } else {
        // 默认使用本地嵌入服务（离线可用）
        _embeddingService = LocalEmbeddingService(
          const EmbeddingConfig(
            apiKey: '',
            endpoint: '',
            model: 'local',
            dimension: 384,
          ),
        );
        _currentProvider = 'local';
      }
      debugPrint('  ✅ 嵌入服务已创建: ${_embeddingService!.providerName}');

      // 3. 初始化检索服务
      _retrievalService = RetrievalServiceImpl(
        embeddingService: _embeddingService!,
        datasource: _datasource!,
      );
      debugPrint('  ✅ 检索服务已创建');

      _initialized = true;
      debugPrint('📚 RAG服务初始化完成');

      notifyListeners();
    } catch (e) {
      debugPrint('❌ RAG服务初始化失败: $e');
      _initialized = false;
    }
  }

  /// 使用AI配置初始化RAG服务
  /// 从AI配置加载器中读取嵌入服务配置
  Future<void> initializeWithAIConfig({
    required Database database,
    AIConfigLoaderService? aiConfig,
  }) async {
    // 尝试从AI配置中获取嵌入服务配置
    EmbeddingConfig? embeddingConfig;
    String provider = 'local';

    try {
      // 加载AI配置
      final config = await AIConfigLoaderService.getConfig();
      final enabledProvider = config.enabledProvider;
      
      if (enabledProvider != null) {
        // 从安全存储中获取API Key
        final apiKeyStorageKey = enabledProvider.apiKeyStorageKey;
        String apiKey = '';
        
        if (apiKeyStorageKey.isNotEmpty) {
          apiKey = await SecurityService().secureRead(apiKeyStorageKey) ?? '';
        }
        
        final providerId = enabledProvider.id;
        
        if (apiKey.isNotEmpty) {
          // 根据AI提供商配置嵌入服务
          if (providerId == 'openai') {
            embeddingConfig = EmbeddingConfig(
              apiKey: apiKey,
              endpoint: 'https://api.openai.com/v1/embeddings',
              model: 'text-embedding-3-small',
              dimension: 1536,
            );
            provider = 'openai';
          } else if (providerId == 'glm') {
            embeddingConfig = EmbeddingConfig(
              apiKey: apiKey,
              endpoint: 'https://open.bigmodel.cn/api/paas/v4/embeddings',
              model: 'embedding-3',
              dimension: 1024,
            );
            provider = 'glm';
          }
        }
      }
    } catch (e) {
      debugPrint('加载AI配置失败，使用本地嵌入服务: $e');
    }

    await initialize(
      database: database,
      provider: provider,
      config: embeddingConfig,
    );
  }

  /// 切换嵌入服务提供商
  Future<void> switchProvider({
    required String provider,
    required EmbeddingConfig config,
  }) async {
    if (!_initialized || _datasource == null) {
      debugPrint('⚠️ RAG服务未初始化，无法切换提供商');
      return;
    }

    try {
      _embeddingService = EmbeddingServiceFactory.create(
        provider: provider,
        config: config,
      );
      _currentProvider = provider;

      _retrievalService = RetrievalServiceImpl(
        embeddingService: _embeddingService!,
        datasource: _datasource!,
      );

      debugPrint('📚 已切换嵌入服务提供商: ${_embeddingService!.providerName}');
      notifyListeners();
    } catch (e) {
      debugPrint('❌ 切换嵌入服务提供商失败: $e');
    }
  }

  /// 存储记忆
  /// [petId] 宠物ID
  /// [content] 记忆内容
  /// [type] 记忆类型
  /// [category] 记忆分类
  /// [importance] 重要性（0-1）
  Future<bool> storeMemory({
    required String petId,
    required String content,
    MemoryType type = MemoryType.shortTerm,
    MemoryCategory category = MemoryCategory.emotion,
    double importance = 0.5,
  }) async {
    if (!_initialized || _retrievalService == null) {
      debugPrint('⚠️ RAG服务未初始化，无法存储记忆');
      return false;
    }

    try {
      // 生成向量嵌入
      final embedding = await _embeddingService!.embed(content);
      if (embedding.isEmpty) {
        debugPrint('⚠️ 生成向量嵌入失败');
        return false;
      }

      // 创建记忆对象
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

      // 存储到数据库
      await _datasource!.insertMemory(memory);
      debugPrint('📚 记忆已存储: ${memory.id}');
      return true;
    } catch (e) {
      debugPrint('❌ 存储记忆失败: $e');
      return false;
    }
  }

  /// 检索相关记忆
  Future<RetrievalResult> search({
    required String query,
    required String petId,
    int topK = 5,
    double threshold = 0.6,
  }) async {
    if (!_initialized || _retrievalService == null) {
      debugPrint('⚠️ RAG服务未初始化，返回空结果');
      return RetrievalResult.empty();
    }

    return await _retrievalService!.search(
      query: query,
      petId: petId,
      topK: topK,
      threshold: threshold,
    );
  }

  /// 清理过期记忆
  Future<void> cleanExpiredMemories(String petId) async {
    if (_datasource == null) return;
    await _datasource!.cleanExpiredMemories(petId);
    debugPrint('📚 已清理过期记忆: $petId');
  }

  /// 释放资源
  @override
  void dispose() {
    _embeddingService = null;
    _retrievalService = null;
    _datasource = null;
    _initialized = false;
    super.dispose();
  }
}
