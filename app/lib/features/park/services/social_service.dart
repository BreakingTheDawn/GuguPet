import '../data/models/models.dart';

// ═══════════════════════════════════════════════════════════════════════════════
/// 社交服务接口
/// 定义社交相关的业务操作
/// 预留后端对接扩展点
// ═══════════════════════════════════════════════════════════════════════════════
abstract class SocialService {
  // ==================== 公园用户 ====================
  
  /// 获取公园内的用户列表
  /// [zoneId] 区域ID
  Future<List<ParkUser>> getParkUsers(String zoneId);
  
  /// 获取用户资料
  /// [userId] 用户ID
  Future<ParkUser?> getUserProfile(String userId);
  
  // ==================== 好友系统 ====================
  
  /// 发送好友申请
  /// [currentUserId] 当前用户ID
  /// [currentUserName] 当前用户名称
  /// [targetUserId] 目标用户ID
  /// [targetUserName] 目标用户昵称
  /// [targetUserTitle] 目标用户职位标签
  Future<void> sendFriendRequest(
    String currentUserId,
    String currentUserName,
    String targetUserId,
    String targetUserName, {
    String? targetUserTitle,
  });
  
  /// 接受好友申请
  /// [friendId] 好友关系ID
  Future<void> acceptFriendRequest(String friendId);
  
  /// 拒绝好友申请
  /// [friendId] 好友关系ID
  Future<void> rejectFriendRequest(String friendId);
  
  /// 获取好友列表
  /// [userId] 用户ID
  /// [status] 状态过滤
  Future<List<Friend>> getFriends(String userId, {FriendStatus? status});
  
  /// 获取收到的好友申请列表
  /// [userId] 当前用户ID（作为接收方）
  Future<List<Friend>> getReceivedFriendRequests(String userId);
  
  /// 删除好友
  /// [friendId] 好友ID
  Future<void> removeFriend(String friendId);
  
  /// 检查是否为好友
  /// [userId] 当前用户ID
  /// [targetUserId] 目标用户ID
  Future<bool> isFriend(String userId, String targetUserId);
  
  // ==================== 动态系统 ====================
  
  /// 发布动态
  /// [post] 动态对象
  Future<void> publishPost(UserPost post);
  
  /// 获取动态流
  /// [limit] 数量限制
  Future<List<UserPost>> getFeed({int? limit});
  
  /// 获取单条动态
  /// [postId] 动态ID
  Future<UserPost?> getPost(String postId);
  
  /// 获取用户的动态
  /// [userId] 用户ID
  /// [limit] 数量限制
  Future<List<UserPost>> getUserPosts(String userId, {int? limit});
  
  /// 删除动态
  /// [postId] 动态ID
  Future<void> deletePost(String postId);
  
  // ==================== 互动系统 ====================
  
  /// 点赞动态
  /// [postId] 动态ID
  /// [userId] 用户ID
  Future<void> likePost(String postId, String userId);
  
  /// 取消点赞
  /// [postId] 动态ID
  /// [userId] 用户ID
  Future<void> unlikePost(String postId, String userId);
  
  /// 检查是否已点赞
  /// [postId] 动态ID
  /// [userId] 用户ID
  Future<bool> isPostLiked(String postId, String userId);
  
  /// 发表评论
  /// [postId] 动态ID
  /// [userId] 用户ID
  /// [userName] 用户昵称
  /// [content] 评论内容
  Future<void> addComment(
    String postId,
    String userId,
    String userName,
    String content,
  );
  
  /// 获取评论列表
  /// [postId] 动态ID
  Future<List<PostComment>> getComments(String postId);
  
  /// 删除评论
  /// [commentId] 评论ID
  Future<void> deleteComment(String commentId);
  
  /// 发送公园互动
  /// [userId] 发起者ID
  /// [targetUserId] 目标用户ID
  /// [type] 互动类型
  Future<void> sendInteraction(
    String userId,
    String targetUserId,
    InteractionType type,
  );
  
  /// 获取用户的互动记录
  /// [userId] 用户ID
  /// [limit] 数量限制
  Future<List<ParkInteraction>> getRecentInteractions(
    String userId, {
    int? limit,
  });
}
