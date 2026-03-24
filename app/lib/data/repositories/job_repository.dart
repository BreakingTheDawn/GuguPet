import '../models/job_event.dart';

abstract class JobRepository {
  Future<List<JobEvent>> getJobEvents(String userId);
  Future<void> saveJobEvent(JobEvent event);
  Future<void> deleteJobEvent(String id);
  Future<Map<String, int>> getWeeklyStats(String userId);
  Future<int> getTotalSubmissions(String userId);
}
