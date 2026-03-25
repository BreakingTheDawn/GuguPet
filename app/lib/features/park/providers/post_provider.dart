import 'package:flutter/foundation.dart';
import '../data/models/models.dart';
import '../services/social_service.dart';

// ═══════════════════════════════════════════════════════════════════════════════
/// 动态状态管理
/// 负责动态流、发布动态、点赞评论等状态管理
// ═══════════════════════════════════════════════════════════════════════════════
class PostProvider extends ChangeNotifier {
  // ────────────────────────────────────────────────────────────────────────────
  // 依赖注入
  // ────────────────────────────────────────────────────────────────────────────

  final SocialService _socialService;

  PostProvider({required SocialService socialService}) : _socialService = socialService;

  // ────────────────────────────────────────────────────────────────────────────
  // 状态变量
  // ────────────────────────────────────────────────────────────────────────────

  /// 当前用户ID
  String? _currentUserId;
  String? get currentUserId => _currentUserId;

  /// 当前用户昵称
  String? _currentUserName;
  String? get currentUserName => _currentUserName;

  /// 动态列表
  List<UserPost> _posts = [];
  List<UserPost> get posts => _posts;

  /// 当前动态详情
  UserPost? _currentPost;
  UserPost? get currentPost => _currentPost;

  /// 当前动态的评论列表
  List<PostComment> _comments = [];
  List<PostComment> get comments => _comments;

  /// 已点赞的动态ID集合
  final Set<String> _likedPostIds = {};

  /// 是否加载中
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  /// 是否正在发布
  bool _isPosting = false;
  bool get isPosting => _isPosting;

  /// 错误信息
  String? _error;
  String? get error => _error;

  // ────────────────────────────────────────────────────────────────────────────
  // 初始化方法
  // ────────────────────────────────────────────────────────────────────────────

  /// 设置当前用户信息
  void setCurrentUser(String userId, String userName) {
    _currentUserId = userId;
    _currentUserName = userName;
    notifyListeners();
  }

  // ────────────────────────────────────────────────────────────────────────────
  // 动态流方法
  // ────────────────────────────────────────────────────────────────────────────

  /// 加载动态流
  /// [limit] 数量限制
  Future<void> loadFeed({int? limit}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      _posts = await _socialService.getFeed(limit: limit);
      
      // 检查已点赞状态
      if (_currentUserId != null) {
        _likedPostIds.clear();
        for (final post in _posts) {
          final liked = await _socialService.isPostLiked(post.id, _currentUserId!);
          if (liked) {
            _likedPostIds.add(post.id);
          }
        }
      }
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      debugPrint('加载动态流失败: $e');
      notifyListeners();
    }
  }

  /// 加载用户的动态
  /// [userId] 用户ID
  Future<void> loadUserPosts(String userId, {int? limit}) async {
    _isLoading = true;
    notifyListeners();
    
    try {
      _posts = await _socialService.getUserPosts(userId, limit: limit);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      debugPrint('加载用户动态失败: $e');
      notifyListeners();
    }
  }

  /// 加载动态详情
  /// [postId] 动态ID
  Future<void> loadPostDetail(String postId) async {
    _isLoading = true;
    notifyListeners();
    
    try {
      _currentPost = await _socialService.getPost(postId);
      _comments = await _socialService.getComments(postId);
      
      // 检查点赞状态
      if (_currentUserId != null) {
        final liked = await _socialService.isPostLiked(postId, _currentUserId!);
        if (liked) {
          _likedPostIds.add(postId);
        } else {
          _likedPostIds.remove(postId);
        }
      }
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      debugPrint('加载动态详情失败: $e');
      notifyListeners();
    }
  }

  /// 刷新动态流
  Future<void> refresh() async {
    await loadFeed();
  }

  // ────────────────────────────────────────────────────────────────────────────
  // 发布动态方法
  // ────────────────────────────────────────────────────────────────────────────

  /// 发布动态
  /// [content] 动态内容
  /// [type] 动态类型
  /// [images] 图片列表
  Future<bool> publishPost({
    required String content,
    PostType type = PostType.daily,
    List<String> images = const [],
  }) async {
    if (_currentUserId == null || _currentUserName == null) return false;
    
    _isPosting = true;
    notifyListeners();
    
    try {
      final post = UserPost(
        id: 'post_${DateTime.now().millisecondsSinceEpoch}',
        userId: _currentUserId!,
        userName: _currentUserName!,
        content: content,
        images: images,
        type: type,
        createdAt: DateTime.now(),
      );
      
      await _socialService.publishPost(post);
      
      // 刷新动态流
      await loadFeed();
      
      _isPosting = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isPosting = false;
      notifyListeners();
      debugPrint('发布动态失败: $e');
      return false;
    }
  }

  /// 删除动态
  /// [postId] 动态ID
  Future<bool> deletePost(String postId) async {
    try {
      await _socialService.deletePost(postId);
      
      // 从列表中移除
      _posts.removeWhere((post) => post.id == postId);
      _likedPostIds.remove(postId);
      
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      debugPrint('删除动态失败: $e');
      return false;
    }
  }

  // ────────────────────────────────────────────────────────────────────────────
  // 点赞方法
  // ────────────────────────────────────────────────────────────────────────────

  /// 点赞动态
  /// [postId] 动态ID
  Future<bool> likePost(String postId) async {
    if (_currentUserId == null) return false;
    
    try {
      await _socialService.likePost(postId, _currentUserId!);
      
      // 更新本地状态
      _likedPostIds.add(postId);
      
      // 更新点赞数
      final index = _posts.indexWhere((p) => p.id == postId);
      if (index != -1) {
        _posts[index] = _posts[index].copyWith(
          likeCount: _posts[index].likeCount + 1,
        );
      }
      
      // 更新当前动态
      if (_currentPost?.id == postId) {
        _currentPost = _currentPost!.copyWith(
          likeCount: _currentPost!.likeCount + 1,
        );
      }
      
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('点赞失败: $e');
      return false;
    }
  }

  /// 取消点赞
  /// [postId] 动态ID
  Future<bool> unlikePost(String postId) async {
    if (_currentUserId == null) return false;
    
    try {
      await _socialService.unlikePost(postId, _currentUserId!);
      
      // 更新本地状态
      _likedPostIds.remove(postId);
      
      // 更新点赞数
      final index = _posts.indexWhere((p) => p.id == postId);
      if (index != -1 && _posts[index].likeCount > 0) {
        _posts[index] = _posts[index].copyWith(
          likeCount: _posts[index].likeCount - 1,
        );
      }
      
      // 更新当前动态
      if (_currentPost?.id == postId && _currentPost!.likeCount > 0) {
        _currentPost = _currentPost!.copyWith(
          likeCount: _currentPost!.likeCount - 1,
        );
      }
      
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('取消点赞失败: $e');
      return false;
    }
  }

  /// 切换点赞状态
  /// [postId] 动态ID
  Future<bool> toggleLike(String postId) async {
    if (isPostLiked(postId)) {
      return await unlikePost(postId);
    } else {
      return await likePost(postId);
    }
  }

  /// 检查动态是否已点赞
  bool isPostLiked(String postId) => _likedPostIds.contains(postId);

  // ────────────────────────────────────────────────────────────────────────────
  // 评论方法
  // ────────────────────────────────────────────────────────────────────────────

  /// 发表评论
  /// [postId] 动态ID
  /// [content] 评论内容
  Future<bool> addComment(String postId, String content) async {
    if (_currentUserId == null || _currentUserName == null) return false;
    
    try {
      await _socialService.addComment(
        postId,
        _currentUserId!,
        _currentUserName!,
        content,
      );
      
      // 刷新评论列表
      _comments = await _socialService.getComments(postId);
      
      // 更新评论数
      final index = _posts.indexWhere((p) => p.id == postId);
      if (index != -1) {
        _posts[index] = _posts[index].copyWith(
          commentCount: _posts[index].commentCount + 1,
        );
      }
      
      // 更新当前动态
      if (_currentPost?.id == postId) {
        _currentPost = _currentPost!.copyWith(
          commentCount: _currentPost!.commentCount + 1,
        );
      }
      
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('发表评论失败: $e');
      return false;
    }
  }

  /// 删除评论
  /// [commentId] 评论ID
  Future<bool> deleteComment(String commentId) async {
    try {
      await _socialService.deleteComment(commentId);
      
      // 刷新评论列表
      if (_currentPost != null) {
        _comments = await _socialService.getComments(_currentPost!.id);
      }
      
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('删除评论失败: $e');
      return false;
    }
  }

  /// 清除当前动态
  void clearCurrentPost() {
    _currentPost = null;
    _comments = [];
    notifyListeners();
  }

  // ────────────────────────────────────────────────────────────────────────────
  // 工具方法
  // ────────────────────────────────────────────────────────────────────────────

  /// 清除错误
  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// 清除所有数据
  void clear() {
    _posts = [];
    _comments = [];
    _currentPost = null;
    _likedPostIds.clear();
    _currentUserId = null;
    _currentUserName = null;
    _error = null;
    notifyListeners();
  }

  /// 获取动态类型显示名称
  String getPostTypeDisplayName(PostType type) {
    switch (type) {
      case PostType.experience:
        return '求职经验';
      case PostType.interview:
        return '面试分享';
      case PostType.offer:
        return 'Offer庆祝';
      case PostType.daily:
        return '日常动态';
    }
  }

  /// 获取动态类型图标
  String getPostTypeIcon(PostType type) {
    switch (type) {
      case PostType.experience:
        return '💡';
      case PostType.interview:
        return '🎯';
      case PostType.offer:
        return '🎉';
      case PostType.daily:
        return '📝';
    }
  }
}
