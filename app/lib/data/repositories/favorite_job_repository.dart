import '../models/favorite_job.dart';

/// 收藏职位仓库接口
/// 定义收藏职位的业务操作接口
abstract class FavoriteJobRepository {
  /// 获取指定用户的收藏职位列表
  /// [userId] 用户ID
  /// 返回收藏职位列表
  Future<List<FavoriteJob>> getFavoriteJobs(String userId);

  /// 添加收藏职位
  /// [job] 收藏职位数据
  Future<void> addFavoriteJob(FavoriteJob job);

  /// 取消收藏职位
  /// [userId] 用户ID
  /// [jobId] 职位ID
  Future<void> removeFavoriteJob(String userId, String jobId);

  /// 检查职位是否已收藏
  /// [userId] 用户ID
  /// [jobId] 职位ID
  /// 返回是否已收藏
  Future<bool> isFavorited(String userId, String jobId);

  /// 根据ID获取收藏记录
  /// [id] 收藏记录ID
  /// 返回收藏职位数据，不存在则返回null
  Future<FavoriteJob?> getFavoriteJobById(String id);

  /// 获取收藏数量
  /// [userId] 用户ID
  /// 返回收藏数量
  Future<int> getFavoriteCount(String userId);
}
