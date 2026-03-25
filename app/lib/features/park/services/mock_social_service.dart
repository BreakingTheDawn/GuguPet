import 'package:flutter/material.dart';
import '../data/models/models.dart';
import '../data/datasources/park_local_datasource.dart';
import 'social_service.dart';

// ═══════════════════════════════════════════════════════════════════════════════
/// Mock社交服务实现
/// 使用本地数据模拟社交功能
/// 为未来接入真实后端预留扩展点
// ═══════════════════════════════════════════════════════════════════════════════
class MockSocialService implements SocialService {
  final ParkLocalDatasource _datasource;

  MockSocialService({required ParkLocalDatasource datasource})
      : _datasource = datasource;

  // ────────────────────────────────────────────────────────────────────────────
  // Mock数据 - 模拟公园用户
  // ────────────────────────────────────────────────────────────────────────────

  /// 预设的Mock用户数据
  static final List<Map<String, dynamic>> _mockUsersData = [
    {
      'id': 'user_001',
      'name': '码农阿贤',
      'title': '全栈工程师',
      'zoneId': 'forest',
      'petColor': 0xFF4A78C8,
      'petAccessory': 'glasses',
    },
    {
      'id': 'user_002',
      'name': '设计师小美',
      'title': 'UI/UX设计师',
      'zoneId': 'forest',
      'petColor': 0xFFC87AB8,
      'petAccessory': 'bow',
    },
    {
      'id': 'user_003',
      'name': '产品老王',
      'title': '产品经理',
      'zoneId': 'forest',
      'petColor': 0xFF4A9E5A,
      'petAccessory': 'tie',
    },
    {
      'id': 'user_004',
      'name': '运营小李',
      'title': '品牌运营',
      'zoneId': 'lake',
      'petColor': 0xFFC89040,
      'petAccessory': 'hardhat',
    },
    {
      'id': 'user_005',
      'name': 'HR阿珍',
      'title': '人才招募',
      'zoneId': 'lake',
      'petColor': 0xFF7A58C8,
      'petAccessory': 'crown',
    },
    {
      'id': 'user_006',
      'name': '前端小张',
      'title': '前端开发',
      'zoneId': 'designer',
      'petColor': 0xFF5A9EC8,
      'petAccessory': 'glasses',
    },
    {
      'id': 'user_007',
      'name': '后端大刘',
      'title': '后端架构师',
      'zoneId': 'designer',
      'petColor': 0xFFC85A5A,
      'petAccessory': 'tie',
    },
    {
      'id': 'user_008',
      'name': '测试小王',
      'title': '测试工程师',
      'zoneId': 'product',
      'petColor': 0xFF5AC85A,
      'petAccessory': 'none',
    },
  ];

  /// 区域ID映射
  static const Map<String, String> _zoneIdMap = {
    '码农森林': 'forest',
    '金币湖畔': 'lake',
    '设计师草原': 'designer',
    '产品家园': 'product',
  };

  // ═══════════════════════════════════════════════════════════════════════════════
  // 公园用户相关
  // ═══════════════════════════════════════════════════════════════════════════════

  @override
  Future<List<ParkUser>> getParkUsers(String zoneId) async {
    // 将中文名称转换为内部ID
    final internalZoneId = _zoneIdMap[zoneId] ?? zoneId;
    
    // 过滤出当前区域的用户
    final filteredUsers = _mockUsersData
        .where((user) => user['zoneId'] == internalZoneId)
        .toList();
    
    // 转换为ParkUser对象
    return filteredUsers.map((data) {
      return ParkUser(
        id: data['id'] as String,
        name: data['name'] as String,
        title: data['title'] as String?,
        zoneId: data['zoneId'] as String,
        petColor: Color(data['petColor'] as int),
        petAccessory: data['petAccessory'] as String? ?? 'none',
        lastActiveAt: DateTime.now().subtract(
          Duration(minutes: DateTime.now().minute % 30),
        ),
      );
    }).toList();
  }

  @override
  Future<ParkUser?> getUserProfile(String userId) async {
    final userData = _mockUsersData.firstWhere(
      (user) => user['id'] == userId,
      orElse: () => <String, dynamic>{},
    );
    
    if (userData.isEmpty) return null;
    
    return ParkUser(
      id: userData['id'] as String,
      name: userData['name'] as String,
      title: userData['title'] as String?,
      zoneId: userData['zoneId'] as String,
      petColor: Color(userData['petColor'] as int),
      petAccessory: userData['petAccessory'] as String? ?? 'none',
      lastActiveAt: DateTime.now().subtract(
        Duration(minutes: DateTime.now().minute % 30),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════════
  // 好友系统相关
  // ═══════════════════════════════════════════════════════════════════════════════

  @override
  Future<void> sendFriendRequest(
    String currentUserId,
    String targetUserId,
    String targetUserName, {
    String? targetUserTitle,
  }) async {
    final friend = Friend(
      id: 'friend_${currentUserId}_$targetUserId',
      userId: currentUserId,
      friendId: targetUserId,
      friendName: targetUserName,
      friendTitle: targetUserTitle,
      status: FriendStatus.pending,
      createdAt: DateTime.now(),
    );
    
    await _datasource.addFriend(friend);
    debugPrint('好友申请已发送: $targetUserName');
  }

  @override
  Future<void> acceptFriendRequest(String friendId) async {
    await _datasource.updateFriendStatus(friendId, FriendStatus.accepted);
    debugPrint('好友申请已接受: $friendId');
  }

  @override
  Future<void> rejectFriendRequest(String friendId) async {
    await _datasource.removeFriend(friendId);
    debugPrint('好友申请已拒绝: $friendId');
  }

  @override
  Future<List<Friend>> getFriends(String userId, {FriendStatus? status}) {
    return _datasource.getFriends(userId, status: status);
  }

  @override
  Future<void> removeFriend(String friendId) async {
    await _datasource.removeFriend(friendId);
    debugPrint('好友已删除: $friendId');
  }

  @override
  Future<bool> isFriend(String userId, String targetUserId) {
    return _datasource.isFriend(userId, targetUserId);
  }

  // ═══════════════════════════════════════════════════════════════════════════════
  // 动态系统相关
  // ═══════════════════════════════════════════════════════════════════════════════

  @override
  Future<void> publishPost(UserPost post) async {
    await _datasource.createPost(post);
    debugPrint('动态已发布: ${post.id}');
  }

  @override
  Future<List<UserPost>> getFeed({int? limit}) {
    return _datasource.getPosts(limit: limit);
  }

  @override
  Future<UserPost?> getPost(String postId) {
    return _datasource.getPost(postId);
  }

  @override
  Future<List<UserPost>> getUserPosts(String userId, {int? limit}) {
    return _datasource.getPosts(userId: userId, limit: limit);
  }

  @override
  Future<void> deletePost(String postId) async {
    await _datasource.deletePost(postId);
    debugPrint('动态已删除: $postId');
  }

  // ═══════════════════════════════════════════════════════════════════════════════
  // 互动系统相关
  // ═══════════════════════════════════════════════════════════════════════════════

  @override
  Future<void> likePost(String postId, String userId) async {
    await _datasource.like(postId, userId);
    debugPrint('已点赞动态: $postId');
  }

  @override
  Future<void> unlikePost(String postId, String userId) async {
    await _datasource.unlike(postId, userId);
    debugPrint('已取消点赞: $postId');
  }

  @override
  Future<bool> isPostLiked(String postId, String userId) {
    return _datasource.isLiked(postId, userId);
  }

  @override
  Future<void> addComment(
    String postId,
    String userId,
    String userName,
    String content,
  ) async {
    final comment = PostComment(
      id: 'comment_${DateTime.now().millisecondsSinceEpoch}',
      postId: postId,
      userId: userId,
      userName: userName,
      content: content,
      createdAt: DateTime.now(),
    );
    
    await _datasource.addComment(comment);
    debugPrint('评论已添加: ${comment.id}');
  }

  @override
  Future<List<PostComment>> getComments(String postId) {
    return _datasource.getComments(postId);
  }

  @override
  Future<void> deleteComment(String commentId) async {
    await _datasource.deleteComment(commentId);
    debugPrint('评论已删除: $commentId');
  }

  @override
  Future<void> sendInteraction(
    String userId,
    String targetUserId,
    InteractionType type,
  ) async {
    final interaction = ParkInteraction(
      id: 'interaction_${DateTime.now().millisecondsSinceEpoch}',
      userId: userId,
      targetId: targetUserId,
      type: type,
      createdAt: DateTime.now(),
    );
    
    await _datasource.recordInteraction(interaction);
    debugPrint('互动已记录: ${type.name} -> $targetUserId');
  }

  @override
  Future<List<ParkInteraction>> getRecentInteractions(
    String userId, {
    int? limit,
  }) {
    return _datasource.getRecentInteractions(userId, limit: limit);
  }
}
