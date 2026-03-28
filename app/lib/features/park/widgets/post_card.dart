import 'dart:io';
import 'package:flutter/material.dart';
import '../data/models/models.dart';

// ═══════════════════════════════════════════════════════════════════════════════
/// 动态卡片组件
/// 展示用户发布的动态内容
// ═══════════════════════════════════════════════════════════════════════════════
class PostCard extends StatelessWidget {
  // ────────────────────────────────────────────────────────────────────────────
  // 属性定义
  // ────────────────────────────────────────────────────────────────────────────

  /// 动态数据
  final UserPost post;
  
  /// 是否已点赞
  final bool isLiked;
  
  /// 点赞回调
  final VoidCallback? onLike;
  
  /// 评论回调
  final VoidCallback? onComment;
  
  /// 点击回调
  final VoidCallback? onTap;
  
  /// 删除回调
  final VoidCallback? onDelete;

  // ────────────────────────────────────────────────────────────────────────────
  // 构造函数
  // ────────────────────────────────────────────────────────────────────────────

  const PostCard({
    super.key,
    required this.post,
    this.isLiked = false,
    this.onLike,
    this.onComment,
    this.onTap,
    this.onDelete,
  });

  // ────────────────────────────────────────────────────────────────────────────
  // 构建方法
  // ────────────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 用户信息头部
            _buildHeader(),
            
            // 动态内容
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _buildContent(),
            ),
            
            // 图片区域（如果有）
            if (post.images.isNotEmpty) _buildImages(),
            
            // 底部操作栏
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  /// 构建头部
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // 用户头像
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.blue.shade100,
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Text('🐧', style: TextStyle(fontSize: 20)),
            ),
          ),
          
          const SizedBox(width: 12),
          
          // 用户信息
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      post.userName,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 8),
                    _buildPostTypeTag(),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  _formatTime(post.createdAt),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          ),
          
          // 更多按钮
          if (onDelete != null)
            IconButton(
              icon: const Icon(Icons.more_horiz),
              onPressed: () => _showDeleteDialog(),
              iconSize: 20,
              color: Colors.grey,
            ),
        ],
      ),
    );
  }

  /// 构建动态类型标签
  Widget _buildPostTypeTag() {
    Color bgColor;
    String label;
    
    switch (post.type) {
      case PostType.experience:
        bgColor = Colors.orange.shade100;
        label = '求职经验';
        break;
      case PostType.interview:
        bgColor = Colors.blue.shade100;
        label = '面试分享';
        break;
      case PostType.offer:
        bgColor = Colors.green.shade100;
        label = 'Offer';
        break;
      case PostType.daily:
        bgColor = Colors.purple.shade100;
        label = '日常';
        break;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 10),
      ),
    );
  }

  /// 构建内容
  Widget _buildContent() {
    return Text(
      post.content,
      style: const TextStyle(
        fontSize: 14,
        height: 1.5,
      ),
      maxLines: 5,
      overflow: TextOverflow.ellipsis,
    );
  }

  /// 构建图片区域
  Widget _buildImages() {
    final imageCount = post.images.length;
    
    // 根据图片数量选择不同的布局
    if (imageCount == 1) {
      return _buildSingleImage();
    } else if (imageCount == 2) {
      return _buildTwoImages();
    } else if (imageCount <= 4) {
      return _buildFourImages();
    } else {
      return _buildNineImages();
    }
  }

  /// 构建单张图片
  Widget _buildSingleImage() {
    return Padding(
      padding: const EdgeInsets.only(top: 12, left: 16, right: 16),
      child: GestureDetector(
        onTap: () => _showImagePreview(0),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: _buildImageWidget(post.images.first, 200, double.infinity),
        ),
      ),
    );
  }

  /// 构建两张图片
  Widget _buildTwoImages() {
    return Padding(
      padding: const EdgeInsets.only(top: 12, left: 16, right: 16),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => _showImagePreview(0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: _buildImageWidget(post.images[0], 120, double.infinity),
              ),
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: GestureDetector(
              onTap: () => _showImagePreview(1),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: _buildImageWidget(post.images[1], 120, double.infinity),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 构建四张图片（2x2网格）
  Widget _buildFourImages() {
    return Padding(
      padding: const EdgeInsets.only(top: 12, left: 16, right: 16),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 4,
          mainAxisSpacing: 4,
          childAspectRatio: 1,
        ),
        itemCount: post.images.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () => _showImagePreview(index),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: _buildImageWidget(post.images[index], 100, 100),
            ),
          );
        },
      ),
    );
  }

  /// 构建九张图片（3x3网格）
  Widget _buildNineImages() {
    return Padding(
      padding: const EdgeInsets.only(top: 12, left: 16, right: 16),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 4,
          mainAxisSpacing: 4,
          childAspectRatio: 1,
        ),
        itemCount: post.images.length > 9 ? 9 : post.images.length,
        itemBuilder: (context, index) {
          final isLast = index == 8 && post.images.length > 9;
          return GestureDetector(
            onTap: () => _showImagePreview(index),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  _buildImageWidget(post.images[index], 80, 80),
                  if (isLast)
                    Container(
                      color: Colors.black.withValues(alpha: 0.5),
                      child: Center(
                        child: Text(
                          '+${post.images.length - 9}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  /// 构建图片组件
  Widget _buildImageWidget(String imagePath, double height, double width) {
    // 检查是否为本地文件路径
    if (imagePath.startsWith('/') || imagePath.startsWith('file://')) {
      return Image.file(
        File(imagePath.replaceFirst('file://', '')),
        height: height,
        width: width,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            height: height,
            width: width,
            color: Colors.grey.shade200,
            child: const Center(
              child: Icon(Icons.broken_image, size: 40, color: Colors.grey),
            ),
          );
        },
      );
    }

    // 网络图片
    return Image.network(
      imagePath,
      height: height,
      width: width,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          height: height,
          width: width,
          color: Colors.grey.shade200,
          child: const Center(
            child: Icon(Icons.broken_image, size: 40, color: Colors.grey),
          ),
        );
      },
    );
  }

  /// 显示图片预览
  void _showImagePreview(int initialIndex) {
    // 这里简化处理，实际可以跳转到专门的图片预览页面
    // 或者使用 photo_view 等库实现更好的预览效果
  }

  /// 构建底部操作栏
  Widget _buildFooter() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // 点赞按钮
          GestureDetector(
            onTap: onLike,
            child: Row(
              children: [
                Icon(
                  isLiked ? Icons.favorite : Icons.favorite_border,
                  size: 20,
                  color: isLiked ? Colors.red : Colors.grey,
                ),
                const SizedBox(width: 4),
                Text(
                  '${post.likeCount}',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(width: 24),
          
          // 评论按钮
          GestureDetector(
            onTap: onComment,
            child: Row(
              children: [
                Icon(
                  Icons.chat_bubble_outline,
                  size: 20,
                  color: Colors.grey.shade600,
                ),
                const SizedBox(width: 4),
                Text(
                  '${post.commentCount}',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          
          const Spacer(),
          
          // 分享按钮
          Icon(
            Icons.share_outlined,
            size: 20,
            color: Colors.grey.shade600,
          ),
        ],
      ),
    );
  }

  /// 格式化时间
  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);
    
    if (diff.inMinutes < 1) {
      return '刚刚';
    } else if (diff.inMinutes < 60) {
      return '${diff.inMinutes}分钟前';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}小时前';
    } else if (diff.inDays < 7) {
      return '${diff.inDays}天前';
    } else {
      return '${time.month}月${time.day}日';
    }
  }

  /// 显示删除确认对话框
  void _showDeleteDialog() {
    // 实际实现需要context，这里简化处理
    onDelete?.call();
  }
}
