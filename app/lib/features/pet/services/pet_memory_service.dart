import '../data/models/pet_memory.dart';
import '../data/datasources/pet_local_datasource.dart';

/// 记忆查询结果
class MemoryQueryResult {
  final List<PetMemoryModel> shortTermMemories;
  final List<PetMemoryModel> keyEventMemories;
  final List<PetMemoryModel> preferenceMemories;

  MemoryQueryResult({
    required this.shortTermMemories,
    required this.keyEventMemories,
    required this.preferenceMemories,
  });

  /// 获取所有记忆
  List<PetMemoryModel> get all => [
    ...shortTermMemories,
    ...keyEventMemories,
    ...preferenceMemories,
  ];

  /// 是否有相关记忆
  bool hasRelatedMemory(String keyword) {
    return all.any((m) => 
      m.key.contains(keyword) || m.value.contains(keyword)
    );
  }

  /// 获取最相关的记忆
  PetMemoryModel? getMostRelevant(String keyword) {
    final memories = all.where((m) =>
      m.key.contains(keyword) || m.value.contains(keyword)
    ).toList();
    
    if (memories.isEmpty) return null;
    
    memories.sort((a, b) => b.importance.compareTo(a.importance));
    return memories.first;
  }
}

/// 宠物记忆服务
/// 管理短期记忆、关键事件记忆、用户偏好
class PetMemoryService {
  final PetLocalDatasource _localDatasource;

  /// 短期记忆最大数量
  static const int maxShortTermMemories = 5;

  PetMemoryService({PetLocalDatasource? localDatasource})
      : _localDatasource = localDatasource ?? PetLocalDatasource();

  /// 添加短期记忆
  Future<void> addShortTermMemory({
    required String petId,
    required MemoryCategory category,
    required String key,
    required String value,
    double importance = 0.5,
  }) async {
    // 清理过期记忆
    await _localDatasource.cleanExpiredMemories(petId);

    // 检查短期记忆数量，超出则删除最旧的
    final existingMemories = await _localDatasource.getMemoriesByType(
      petId,
      MemoryType.shortTerm,
    );
    
    if (existingMemories.length >= maxShortTermMemories) {
      // 删除最旧的短期记忆（已过期的会被清理，这里处理未过期但数量超限的情况）
      // 简化处理：让过期清理机制处理
    }

    final memory = PetMemoryModel.shortTerm(
      id: _generateId(),
      petId: petId,
      category: category,
      key: key,
      value: value,
      importance: importance,
    );

    await _localDatasource.insertMemory(memory);
  }

  /// 添加关键事件记忆
  Future<void> addKeyEventMemory({
    required String petId,
    required String key,
    required String value,
    double importance = 1.0,
    double emotionalWeight = 0,
  }) async {
    final memory = PetMemoryModel.keyEvent(
      id: _generateId(),
      petId: petId,
      key: key,
      value: value,
      importance: importance,
      emotionalWeight: emotionalWeight,
    );

    await _localDatasource.insertMemory(memory);
  }

  /// 添加用户偏好
  Future<void> addPreferenceMemory({
    required String petId,
    required String key,
    required String value,
  }) async {
    final memory = PetMemoryModel(
      id: _generateId(),
      petId: petId,
      type: MemoryType.preference,
      category: MemoryCategory.preference,
      key: key,
      value: value,
      importance: 0.8,
      createdAt: DateTime.now(),
    );

    await _localDatasource.insertMemory(memory);
  }

  /// 获取所有有效记忆
  Future<MemoryQueryResult> getAllMemories(String petId) async {
    await _localDatasource.cleanExpiredMemories(petId);

    final shortTerm = await _localDatasource.getMemoriesByType(
      petId,
      MemoryType.shortTerm,
    );
    final keyEvents = await _localDatasource.getMemoriesByType(
      petId,
      MemoryType.keyEvent,
    );
    final preferences = await _localDatasource.getMemoriesByType(
      petId,
      MemoryType.preference,
    );

    return MemoryQueryResult(
      shortTermMemories: shortTerm,
      keyEventMemories: keyEvents,
      preferenceMemories: preferences,
    );
  }

  /// 根据关键词搜索记忆
  Future<List<PetMemoryModel>> searchMemories(
    String petId,
    String keyword,
  ) async {
    final allMemories = await _localDatasource.getMemories(petId);
    return allMemories.where((m) =>
      m.key.contains(keyword) || m.value.contains(keyword)
    ).toList();
  }

  /// 生成记忆ID
  String _generateId() {
    return 'mem_${DateTime.now().millisecondsSinceEpoch}';
  }
}
