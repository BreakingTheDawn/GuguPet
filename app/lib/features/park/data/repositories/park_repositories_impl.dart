import '../models/models.dart';
import '../datasources/park_local_datasource.dart';
import 'park_repositories.dart';

// ═══════════════════════════════════════════════════════════════════════════════
/// 好友仓库实现类
/// 实现好友相关的数据操作
// ═══════════════════════════════════════════════════════════════════════════════
class FriendRepositoryImpl implements FriendRepository {
  final ParkLocalDatasource _datasource;

  FriendRepositoryImpl({required ParkLocalDatasource datasource})
      : _datasource = datasource;

  @override
  Future<List<Friend>> getFriends(String userId, {FriendStatus? status}) {
    return _datasource.getFriends(userId, status: status);
  }

  @override
  Future<Friend?> getFriend(String userId, String friendId) {
    return _datasource.getFriend(userId, friendId);
  }

  @override
  Future<void> addFriend(Friend friend) {
    return _datasource.addFriend(friend);
  }

  @override
  Future<void> updateFriendStatus(String id, FriendStatus status) {
    return _datasource.updateFriendStatus(id, status);
  }

  @override
  Future<void> removeFriend(String id) {
    return _datasource.removeFriend(id);
  }

  @override
  Future<bool> isFriend(String userId, String friendId) {
    return _datasource.isFriend(userId, friendId);
  }

  @override
  Future<int> getFriendCount(String userId) {
    return _datasource.getFriendCount(userId);
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
/// 动态仓库实现类
/// 实现动态相关的数据操作
// ═══════════════════════════════════════════════════════════════════════════════
class PostRepositoryImpl implements PostRepository {
  final ParkLocalDatasource _datasource;

  PostRepositoryImpl({required ParkLocalDatasource datasource})
      : _datasource = datasource;

  @override
  Future<List<UserPost>> getPosts({
    int? limit,
    String? userId,
    PostType? type,
  }) {
    return _datasource.getPosts(limit: limit, userId: userId, type: type);
  }

  @override
  Future<UserPost?> getPost(String postId) {
    return _datasource.getPost(postId);
  }

  @override
  Future<void> createPost(UserPost post) {
    return _datasource.createPost(post);
  }

  @override
  Future<void> deletePost(String postId) {
    return _datasource.deletePost(postId);
  }

  @override
  Future<void> updateLikeCount(String postId, int delta) {
    return _datasource.updateLikeCount(postId, delta);
  }

  @override
  Future<void> updateCommentCount(String postId, int delta) {
    return _datasource.updateCommentCount(postId, delta);
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
/// 评论仓库实现类
/// 实现评论相关的数据操作
// ═══════════════════════════════════════════════════════════════════════════════
class CommentRepositoryImpl implements CommentRepository {
  final ParkLocalDatasource _datasource;

  CommentRepositoryImpl({required ParkLocalDatasource datasource})
      : _datasource = datasource;

  @override
  Future<List<PostComment>> getComments(String postId) {
    return _datasource.getComments(postId);
  }

  @override
  Future<void> addComment(PostComment comment) {
    return _datasource.addComment(comment);
  }

  @override
  Future<void> deleteComment(String commentId) {
    return _datasource.deleteComment(commentId);
  }

  @override
  Future<int> getCommentCount(String postId) {
    return _datasource.getCommentCount(postId);
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
/// 点赞仓库实现类
/// 实现点赞相关的数据操作
// ═══════════════════════════════════════════════════════════════════════════════
class LikeRepositoryImpl implements LikeRepository {
  final ParkLocalDatasource _datasource;

  LikeRepositoryImpl({required ParkLocalDatasource datasource})
      : _datasource = datasource;

  @override
  Future<void> like(String postId, String userId) {
    return _datasource.like(postId, userId);
  }

  @override
  Future<void> unlike(String postId, String userId) {
    return _datasource.unlike(postId, userId);
  }

  @override
  Future<bool> isLiked(String postId, String userId) {
    return _datasource.isLiked(postId, userId);
  }

  @override
  Future<List<PostLike>> getLikes(String postId) {
    return _datasource.getLikes(postId);
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
/// 公园互动仓库实现类
/// 实现公园互动相关的数据操作
// ═══════════════════════════════════════════════════════════════════════════════
class ParkInteractionRepositoryImpl implements ParkInteractionRepository {
  final ParkLocalDatasource _datasource;

  ParkInteractionRepositoryImpl({required ParkLocalDatasource datasource})
      : _datasource = datasource;

  @override
  Future<void> recordInteraction(ParkInteraction interaction) {
    return _datasource.recordInteraction(interaction);
  }

  @override
  Future<List<ParkInteraction>> getRecentInteractions(
    String userId, {
    int? limit,
  }) {
    return _datasource.getRecentInteractions(userId, limit: limit);
  }

  @override
  Future<List<ParkInteraction>> getReceivedInteractions(
    String targetId, {
    int? limit,
  }) {
    return _datasource.getReceivedInteractions(targetId, limit: limit);
  }
}
