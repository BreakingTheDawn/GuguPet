import '../models/models.dart';

// ═══════════════════════════════════════════════════════════════════════════════
/// 好友仓库接口
/// 定义好友相关的数据操作
// ═══════════════════════════════════════════════════════════════════════════════
abstract class FriendRepository {
  /// 获取好友列表
  /// [userId] 用户ID
  /// [status] 好友状态过滤，可选
  Future<List<Friend>> getFriends(String userId, {FriendStatus? status});
  
  /// 获取单个好友关系
  /// [userId] 当前用户ID
  /// [friendId] 好友ID
  Future<Friend?> getFriend(String userId, String friendId);
  
  /// 添加好友关系
  /// [friend] 好友关系对象
  Future<void> addFriend(Friend friend);
  
  /// 更新好友状态
  /// [id] 关系ID
  /// [status] 新状态
  Future<void> updateFriendStatus(String id, FriendStatus status);
  
  /// 删除好友关系
  /// [id] 关系ID
  Future<void> removeFriend(String id);
  
  /// 检查是否为好友
  /// [userId] 当前用户ID
  /// [friendId] 目标用户ID
  Future<bool> isFriend(String userId, String friendId);
  
  /// 获取好友数量
  /// [userId] 用户ID
  Future<int> getFriendCount(String userId);
}

// ═══════════════════════════════════════════════════════════════════════════════
/// 动态仓库接口
/// 定义动态相关的数据操作
// ═══════════════════════════════════════════════════════════════════════════════
abstract class PostRepository {
  /// 获取动态列表
  /// [limit] 数量限制，可选
  /// [userId] 用户ID过滤，可选
  /// [type] 类型过滤，可选
  Future<List<UserPost>> getPosts({
    int? limit,
    String? userId,
    PostType? type,
  });
  
  /// 获取单条动态
  /// [postId] 动态ID
  Future<UserPost?> getPost(String postId);
  
  /// 创建动态
  /// [post] 动态对象
  Future<void> createPost(UserPost post);
  
  /// 删除动态
  /// [postId] 动态ID
  Future<void> deletePost(String postId);
  
  /// 更新点赞数
  /// [postId] 动态ID
  /// [delta] 变化量（+1 或 -1）
  Future<void> updateLikeCount(String postId, int delta);
  
  /// 更新评论数
  /// [postId] 动态ID
  /// [delta] 变化量
  Future<void> updateCommentCount(String postId, int delta);
}

// ═══════════════════════════════════════════════════════════════════════════════
/// 评论仓库接口
/// 定义评论相关的数据操作
// ═══════════════════════════════════════════════════════════════════════════════
abstract class CommentRepository {
  /// 获取动态的评论列表
  /// [postId] 动态ID
  Future<List<PostComment>> getComments(String postId);
  
  /// 添加评论
  /// [comment] 评论对象
  Future<void> addComment(PostComment comment);
  
  /// 删除评论
  /// [commentId] 评论ID
  Future<void> deleteComment(String commentId);
  
  /// 获取评论数量
  /// [postId] 动态ID
  Future<int> getCommentCount(String postId);
}

// ═══════════════════════════════════════════════════════════════════════════════
/// 点赞仓库接口
/// 定义点赞相关的数据操作
// ═══════════════════════════════════════════════════════════════════════════════
abstract class LikeRepository {
  /// 点赞
  /// [postId] 动态ID
  /// [userId] 用户ID
  Future<void> like(String postId, String userId);
  
  /// 取消点赞
  /// [postId] 动态ID
  /// [userId] 用户ID
  Future<void> unlike(String postId, String userId);
  
  /// 检查是否已点赞
  /// [postId] 动态ID
  /// [userId] 用户ID
  Future<bool> isLiked(String postId, String userId);
  
  /// 获取点赞列表
  /// [postId] 动态ID
  Future<List<PostLike>> getLikes(String postId);
}

// ═══════════════════════════════════════════════════════════════════════════════
/// 公园互动仓库接口
/// 定义公园互动相关的数据操作
// ═══════════════════════════════════════════════════════════════════════════════
abstract class ParkInteractionRepository {
  /// 记录互动
  /// [interaction] 互动对象
  Future<void> recordInteraction(ParkInteraction interaction);
  
  /// 获取用户的互动记录
  /// [userId] 用户ID
  /// [limit] 数量限制
  Future<List<ParkInteraction>> getRecentInteractions(
    String userId, {
    int? limit,
  });
  
  /// 获取用户收到的互动
  /// [targetId] 目标用户ID
  /// [limit] 数量限制
  Future<List<ParkInteraction>> getReceivedInteractions(
    String targetId, {
    int? limit,
  });
}
