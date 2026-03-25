import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/post_provider.dart';
import '../widgets/post_card.dart';
import '../data/models/models.dart';

// ═══════════════════════════════════════════════════════════════════════════════
/// 动态流页面
/// 展示所有用户发布的动态
// ═══════════════════════════════════════════════════════════════════════════════
class PostFeedPage extends StatefulWidget {
  const PostFeedPage({super.key});

  @override
  State<PostFeedPage> createState() => _PostFeedPageState();
}

class _PostFeedPageState extends State<PostFeedPage> {
  @override
  void initState() {
    super.initState();
    
    // 加载动态流
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PostProvider>().loadFeed();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('动态'),
        actions: [
          // 发布动态按钮
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showPublishDialog(context),
          ),
        ],
      ),
      body: Consumer<PostProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.posts.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.posts.isEmpty) {
            return _buildEmptyState();
          }

          return RefreshIndicator(
            onRefresh: () => provider.refresh(),
            child: ListView.builder(
              padding: const EdgeInsets.only(top: 8, bottom: 80),
              itemCount: provider.posts.length,
              itemBuilder: (context, index) {
                final post = provider.posts[index];
                final isCurrentUserPost = post.userId == provider.currentUserId;
                return PostCard(
                  post: post,
                  isLiked: provider.isPostLiked(post.id),
                  onLike: () => provider.toggleLike(post.id),
                  onComment: () => _navigateToDetail(context, post),
                  onTap: () => _navigateToDetail(context, post),
                  onDelete: isCurrentUserPost 
                      ? () => _showDeleteConfirmDialog(context, post, provider)
                      : null,
                );
              },
            ),
          );
        },
      ),
    );
  }

  /// 构建空状态
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.article_outlined,
            size: 64,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 16),
          const Text(
            '暂无动态',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '成为第一个发布动态的人吧！',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _showPublishDialog(context),
            icon: const Icon(Icons.add),
            label: const Text('发布动态'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  /// 跳转到动态详情页
  void _navigateToDetail(BuildContext context, UserPost post) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PostDetailPage(postId: post.id),
      ),
    );
  }

  /// 显示删除确认对话框
  void _showDeleteConfirmDialog(
    BuildContext context,
    UserPost post,
    PostProvider provider,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('删除动态'),
        content: const Text('确定要删除这条动态吗？删除后无法恢复。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final success = await provider.deletePost(post.id);
              if (success && mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('动态已删除')),
                );
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('删除'),
          ),
        ],
      ),
    );
  }

  /// 显示发布动态对话框
  void _showPublishDialog(BuildContext context) {
    final contentController = TextEditingController();
    PostType selectedType = PostType.daily;
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('发布动态'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 动态类型选择
              const Text(
                '动态类型',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: PostType.values.map((type) {
                  return ChoiceChip(
                    label: Text(_getPostTypeLabel(type)),
                    selected: selectedType == type,
                    onSelected: (selected) {
                      if (selected) {
                        setState(() => selectedType = type);
                      }
                    },
                  );
                }).toList(),
              ),
              
              const SizedBox(height: 16),
              
              // 内容输入框
              TextField(
                controller: contentController,
                maxLines: 4,
                maxLength: 500,
                decoration: const InputDecoration(
                  hintText: '分享你的求职故事...',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('取消'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (contentController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('请输入动态内容')),
                  );
                  return;
                }
                
                Navigator.pop(context);
                
                final success = await context.read<PostProvider>().publishPost(
                  content: contentController.text.trim(),
                  type: selectedType,
                );
                
                if (success && mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('动态发布成功')),
                  );
                }
              },
              child: const Text('发布'),
            ),
          ],
        ),
      ),
    );
  }

  /// 获取动态类型标签
  String _getPostTypeLabel(PostType type) {
    switch (type) {
      case PostType.experience:
        return '💡 求职经验';
      case PostType.interview:
        return '🎯 面试分享';
      case PostType.offer:
        return '🎉 Offer庆祝';
      case PostType.daily:
        return '📝 日常动态';
    }
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
/// 动态详情页面
/// 展示单条动态的详细内容和评论
// ═══════════════════════════════════════════════════════════════════════════════
class PostDetailPage extends StatefulWidget {
  final String postId;

  const PostDetailPage({super.key, required this.postId});

  @override
  State<PostDetailPage> createState() => _PostDetailPageState();
}

class _PostDetailPageState extends State<PostDetailPage> {
  final _commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    
    // 加载动态详情
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PostProvider>().loadPostDetail(widget.postId);
    });
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('动态详情'),
      ),
      body: Consumer<PostProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading || provider.currentPost == null) {
            return const Center(child: CircularProgressIndicator());
          }

          final post = provider.currentPost!;
          
          return Column(
            children: [
              // 动态内容
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      // 动态卡片
                      PostCard(
                        post: post,
                        isLiked: provider.isPostLiked(post.id),
                        onLike: () => provider.toggleLike(post.id),
                      ),
                      
                      const Divider(),
                      
                      // 评论列表
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Text(
                              '评论 (${provider.comments.length})',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      if (provider.comments.isEmpty)
                        Padding(
                          padding: const EdgeInsets.all(32),
                          child: Text(
                            '暂无评论，来说点什么吧~',
                            style: TextStyle(
                              color: Colors.grey.shade500,
                            ),
                          ),
                        )
                      else
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: provider.comments.length,
                          itemBuilder: (context, index) {
                            final comment = provider.comments[index];
                            return CommentItem(
                              comment: comment,
                              isCurrentUser: comment.userId == provider.currentUserId,
                              onDelete: () => provider.deleteComment(comment.id),
                            );
                          },
                        ),
                      
                      const SizedBox(height: 80),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
      
      // 底部评论输入框
      bottomSheet: _buildCommentInput(context),
    );
  }

  /// 构建评论输入框
  Widget _buildCommentInput(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 8,
        bottom: MediaQuery.of(context).padding.bottom + 8,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _commentController,
              decoration: InputDecoration(
                hintText: '写下你的评论...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: () => _submitComment(context),
            icon: const Icon(Icons.send),
            color: Colors.blue,
          ),
        ],
      ),
    );
  }

  /// 提交评论
  void _submitComment(BuildContext context) async {
    final content = _commentController.text.trim();
    if (content.isEmpty) return;
    
    _commentController.clear();
    
    final success = await context.read<PostProvider>().addComment(
      widget.postId,
      content,
    );
    
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('评论成功')),
      );
    }
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
/// 评论项组件（内联定义，避免循环导入）
// ═══════════════════════════════════════════════════════════════════════════════
class CommentItem extends StatelessWidget {
  final dynamic comment;
  final bool isCurrentUser;
  final VoidCallback? onDelete;

  const CommentItem({
    super.key,
    required this.comment,
    this.isCurrentUser = false,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: Colors.blue.shade100,
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Text('🐧', style: TextStyle(fontSize: 16)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  comment.userName,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  comment.content,
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),
          ),
          if (isCurrentUser && onDelete != null)
            GestureDetector(
              onTap: onDelete,
              child: Padding(
                padding: const EdgeInsets.only(left: 8),
                child: Icon(
                  Icons.close,
                  size: 16,
                  color: Colors.grey.shade400,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
