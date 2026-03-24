import '../models/favorite_job.dart';
import '../datasources/local/favorite_job_local_datasource.dart';
import 'favorite_job_repository.dart';

/// 收藏职位仓库实现
/// 封装数据源操作，提供统一的业务逻辑接口
class FavoriteJobRepositoryImpl implements FavoriteJobRepository {
  // ═══════════════════════════════════════════════════════════
  // 依赖注入
  // ═══════════════════════════════════════════════════════════
  final FavoriteJobLocalDatasource _localDatasource;

  /// 构造函数
  /// [localDatasource] 本地数据源，默认使用SQLite实现
  FavoriteJobRepositoryImpl({FavoriteJobLocalDatasource? localDatasource})
      : _localDatasource = localDatasource ?? SqliteFavoriteJobLocalDatasource();

  // ═══════════════════════════════════════════════════════════
  // 接口实现
  // ═══════════════════════════════════════════════════════════

  @override
  Future<List<FavoriteJob>> getFavoriteJobs(String userId) async {
    return await _localDatasource.getFavoriteJobs(userId);
  }

  @override
  Future<void> addFavoriteJob(FavoriteJob job) async {
    await _localDatasource.addFavoriteJob(job);
  }

  @override
  Future<void> removeFavoriteJob(String userId, String jobId) async {
    await _localDatasource.removeFavoriteJob(userId, jobId);
  }

  @override
  Future<bool> isFavorited(String userId, String jobId) async {
    return await _localDatasource.isFavorited(userId, jobId);
  }

  @override
  Future<FavoriteJob?> getFavoriteJobById(String id) async {
    return await _localDatasource.getFavoriteJobById(id);
  }

  @override
  Future<int> getFavoriteCount(String userId) async {
    return await _localDatasource.getFavoriteCount(userId);
  }
}
