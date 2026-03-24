import '../models/interaction.dart';
import '../datasources/local/interaction_local_datasource.dart';
import 'interaction_repository.dart';

/// 交互记录仓库实现
/// 协调数据源操作，提供业务逻辑层接口
class InteractionRepositoryImpl implements InteractionRepository {
  final InteractionLocalDatasource _localDatasource;

  /// 构造函数
  /// [localDatasource] 本地数据源，默认使用SQLite实现
  InteractionRepositoryImpl({InteractionLocalDatasource? localDatasource})
      : _localDatasource = localDatasource ?? SqliteInteractionLocalDatasource();

  @override
  Future<List<Interaction>> getInteractions(String userId) async {
    return await _localDatasource.getInteractions(userId);
  }

  @override
  Future<void> saveInteraction(Interaction interaction) async {
    await _localDatasource.saveInteraction(interaction);
  }

  @override
  Future<void> deleteInteraction(String id) async {
    // 直接通过ID删除，无需先查询
    await _localDatasource.deleteInteractionById(id);
  }

  @override
  Future<int> getInteractionCount(String userId) async {
    return await _localDatasource.getInteractionCount(userId);
  }

  @override
  Future<List<Interaction>> getRecentInteractions(String userId, int limit) async {
    return await _localDatasource.getRecentInteractions(userId, limit);
  }
}
