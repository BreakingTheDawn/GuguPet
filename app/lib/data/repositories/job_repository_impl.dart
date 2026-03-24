import '../models/job_event.dart';
import '../datasources/local/job_local_datasource.dart';
import 'job_repository.dart';

/// 求职事件仓库实现
/// 协调数据源操作，提供业务逻辑层接口
class JobRepositoryImpl implements JobRepository {
  final JobLocalDatasource _localDatasource;

  /// 构造函数
  /// [localDatasource] 本地数据源，默认使用SQLite实现
  JobRepositoryImpl({JobLocalDatasource? localDatasource})
      : _localDatasource = localDatasource ?? SqliteJobEventLocalDatasource();

  @override
  Future<List<JobEvent>> getJobEvents(String userId) async {
    return await _localDatasource.getJobEvents(userId);
  }

  @override
  Future<void> saveJobEvent(JobEvent event) async {
    await _localDatasource.saveJobEvent(event);
  }

  @override
  Future<void> deleteJobEvent(String id) async {
    // 直接通过ID删除，无需先查询
    await _localDatasource.deleteJobEventById(id);
  }

  @override
  Future<Map<String, int>> getWeeklyStats(String userId) async {
    return await _localDatasource.getWeeklyStats(userId);
  }

  @override
  Future<int> getTotalSubmissions(String userId) async {
    return await _localDatasource.getTotalSubmissions(userId);
  }
}
