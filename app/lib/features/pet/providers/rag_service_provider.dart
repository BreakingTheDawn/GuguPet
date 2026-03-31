import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import '../services/rag_service_manager.dart';
import '../services/embedding_service.dart';
import '../services/retrieval_service.dart';
import '../data/models/vector_memory.dart';
import '../data/models/retrieval_result.dart';
import '../../../core/services/ai_config_loader_service.dart';

/// RAG服务状态
enum RAGServiceStatus {
  /// 未初始化
  uninitialized,
  /// 初始化中
  initializing,
  /// 已就绪
  ready,
  /// 错误
  error,
}

/// RAG服务Provider
/// 提供RAG服务的状态管理和访问接口
class RAGServiceProvider extends ChangeNotifier {
  final RAGServiceManager _manager;
  final AIConfigLoaderService? _aiConfig;

  RAGServiceStatus _status = RAGServiceStatus.uninitialized;
  String? _errorMessage;

  RAGServiceProvider({
    AIConfigLoaderService? aiConfig,
  })  : _manager = RAGServiceManager(),
        _aiConfig = aiConfig;

  /// 获取服务状态
  RAGServiceStatus get status => _status;

  /// 是否已就绪
  bool get isReady => _status == RAGServiceStatus.ready;

  /// 获取错误信息
  String? get errorMessage => _errorMessage;

  /// 获取嵌入服务
  EmbeddingService? get embeddingService => _manager.embeddingService;

  /// 获取检索服务
  RetrievalService? get retrievalService => _manager.retrievalService;

  /// 获取当前提供商
  String get currentProvider => _manager.currentProvider;

  /// 初始化RAG服务
  Future<void> initialize(Database database) async {
    if (_status == RAGServiceStatus.initializing) {
      debugPrint('📚 RAG服务正在初始化中...');
      return;
    }

    _status = RAGServiceStatus.initializing;
    _errorMessage = null;
    notifyListeners();

    try {
      await _manager.initializeWithAIConfig(
        database: database,
        aiConfig: _aiConfig,
      );

      if (_manager.isInitialized) {
        _status = RAGServiceStatus.ready;
        debugPrint('📚 RAG服务Provider已就绪');
      } else {
        _status = RAGServiceStatus.error;
        _errorMessage = 'RAG服务初始化失败';
      }
    } catch (e) {
      _status = RAGServiceStatus.error;
      _errorMessage = e.toString();
      debugPrint('❌ RAG服务Provider初始化错误: $e');
    }

    notifyListeners();
  }

  /// 使用指定配置初始化
  Future<void> initializeWithConfig({
    required Database database,
    required String provider,
    required EmbeddingConfig config,
  }) async {
    _status = RAGServiceStatus.initializing;
    notifyListeners();

    try {
      await _manager.initialize(
        database: database,
        provider: provider,
        config: config,
      );

      _status = _manager.isInitialized
          ? RAGServiceStatus.ready
          : RAGServiceStatus.error;
    } catch (e) {
      _status = RAGServiceStatus.error;
      _errorMessage = e.toString();
    }

    notifyListeners();
  }

  /// 切换嵌入服务提供商
  Future<void> switchProvider({
    required String provider,
    required EmbeddingConfig config,
  }) async {
    await _manager.switchProvider(
      provider: provider,
      config: config,
    );
    notifyListeners();
  }

  /// 存储记忆
  Future<bool> storeMemory({
    required String petId,
    required String content,
    MemoryType type = MemoryType.shortTerm,
    MemoryCategory category = MemoryCategory.emotion,
    double importance = 0.5,
  }) async {
    return await _manager.storeMemory(
      petId: petId,
      content: content,
      type: type,
      category: category,
      importance: importance,
    );
  }

  /// 检索记忆
  Future<RetrievalResult> search({
    required String query,
    required String petId,
    int topK = 5,
    double threshold = 0.6,
  }) async {
    return await _manager.search(
      query: query,
      petId: petId,
      topK: topK,
      threshold: threshold,
    );
  }

  /// 清理过期记忆
  Future<void> cleanExpiredMemories(String petId) async {
    await _manager.cleanExpiredMemories(petId);
  }

  @override
  void dispose() {
    _manager.dispose();
    super.dispose();
  }
}
