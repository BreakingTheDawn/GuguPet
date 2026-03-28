import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/services/image_storage.dart';

// ═══════════════════════════════════════════════════════════════════════════════
/// 图片选择器组件
/// 支持从相册选择图片和拍照，最多支持9张图片
// ═══════════════════════════════════════════════════════════════════════════════
class ImagePickerWidget extends StatefulWidget {
  // ────────────────────────────────────────────────────────────────────────────
  // 属性定义
  // ────────────────────────────────────────────────────────────────────────────

  /// 最大图片数量
  final int maxImages;

  /// 初始图片列表
  final List<String> initialImages;

  /// 图片变化回调
  final Function(List<String>) onImagesChanged;

  /// 是否显示添加按钮
  final bool showAddButton;

  // ────────────────────────────────────────────────────────────────────────────
  // 构造函数
  // ────────────────────────────────────────────────────────────────────────────

  const ImagePickerWidget({
    super.key,
    this.maxImages = 9,
    this.initialImages = const [],
    required this.onImagesChanged,
    this.showAddButton = true,
  });

  @override
  State<ImagePickerWidget> createState() => _ImagePickerWidgetState();
}

class _ImagePickerWidgetState extends State<ImagePickerWidget> {
  // ────────────────────────────────────────────────────────────────────────────
  // 私有属性
  // ────────────────────────────────────────────────────────────────────────────

  /// 图片选择器实例
  final ImagePicker _picker = ImagePicker();

  /// 已选择的图片路径列表
  late List<String> _images;

  /// 是否正在加载
  bool _isLoading = false;

  // ────────────────────────────────────────────────────────────────────────────
  // 生命周期方法
  // ────────────────────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _images = List.from(widget.initialImages);
  }

  // ────────────────────────────────────────────────────────────────────────────
  // 构建方法
  // ────────────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 图片网格
        if (_images.isNotEmpty)
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _images.asMap().entries.map((entry) {
              return _buildImageItem(entry.key, entry.value);
            }).toList(),
          ),

        // 添加按钮
        if (widget.showAddButton && _images.length < widget.maxImages)
          Padding(
            padding: EdgeInsets.only(top: _images.isNotEmpty ? 8 : 0),
            child: _buildAddButton(),
          ),

        // 图片数量提示
        if (_images.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              '已选择 ${_images.length}/${widget.maxImages} 张图片',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade500,
              ),
            ),
          ),
      ],
    );
  }

  /// 构建图片项
  Widget _buildImageItem(int index, String imagePath) {
    return Stack(
      children: [
        // 图片缩略图
        GestureDetector(
          onTap: () => _previewImage(index),
          child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: Colors.grey.shade200,
            ),
            clipBehavior: Clip.antiAlias,
            child: _buildImage(imagePath),
          ),
        ),

        // 删除按钮
        Positioned(
          top: -4,
          right: -4,
          child: GestureDetector(
            onTap: () => _removeImage(index),
            child: Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.6),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.close,
                size: 14,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// 构建图片显示
  Widget _buildImage(String imagePath) {
    // 检查是否为本地文件路径
    if (imagePath.startsWith('/') || imagePath.startsWith('file://')) {
      return Image.file(
        File(imagePath.replaceFirst('file://', '')),
        width: 80,
        height: 80,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color: Colors.grey.shade300,
            child: const Icon(Icons.broken_image, color: Colors.grey),
          );
        },
      );
    }

    // 网络图片
    return Image.network(
      imagePath,
      width: 80,
      height: 80,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          color: Colors.grey.shade300,
          child: const Icon(Icons.broken_image, color: Colors.grey),
        );
      },
    );
  }

  /// 构建添加按钮
  Widget _buildAddButton() {
    return GestureDetector(
      onTap: _isLoading ? null : _showImageSourceDialog,
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
          color: Colors.grey.shade50,
        ),
        child: _isLoading
            ? const Center(
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.add_photo_alternate_outlined,
                    size: 28,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '添加图片',
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  // ────────────────────────────────────────────────────────────────────────────
  // 私有方法
  // ────────────────────────────────────────────────────────────────────────────

  /// 显示图片来源选择对话框
  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('从相册选择'),
              onTap: () {
                Navigator.pop(context);
                _pickImages();
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('拍照'),
              onTap: () {
                Navigator.pop(context);
                _takePhoto();
              },
            ),
          ],
        ),
      ),
    );
  }

  /// 从相册选择图片
  Future<void> _pickImages() async {
    try {
      setState(() => _isLoading = true);

      final List<XFile> selected = await _picker.pickMultiImage(
        maxWidth: 1080,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (selected.isEmpty) {
        setState(() => _isLoading = false);
        return;
      }

      // 计算可添加的数量
      final remaining = widget.maxImages - _images.length;
      final toAdd = selected.take(remaining);

      // 保存图片到本地
      for (final xFile in toAdd) {
        final savedPath = await ImageStorage.save(xFile.path);
        if (savedPath != null) {
          _images.add(savedPath);
        }
      }

      widget.onImagesChanged(_images);
      setState(() => _isLoading = false);
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('选择图片失败，请重试')),
        );
      }
    }
  }

  /// 拍照
  Future<void> _takePhoto() async {
    try {
      setState(() => _isLoading = true);

      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1080,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (photo == null) {
        setState(() => _isLoading = false);
        return;
      }

      // 保存图片到本地
      final savedPath = await ImageStorage.save(photo.path);
      if (savedPath != null) {
        _images.add(savedPath);
        widget.onImagesChanged(_images);
      }

      setState(() => _isLoading = false);
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('拍照失败，请重试')),
        );
      }
    }
  }

  /// 移除图片
  void _removeImage(int index) {
    _images.removeAt(index);
    widget.onImagesChanged(_images);
    setState(() {});
  }

  /// 预览图片
  void _previewImage(int index) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ImagePreviewPage(
          images: _images,
          initialIndex: index,
          onDelete: (deleteIndex) {
            _removeImage(deleteIndex);
            Navigator.pop(context);
          },
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
/// 图片预览页面
/// 全屏预览已选择的图片
// ═══════════════════════════════════════════════════════════════════════════════
class ImagePreviewPage extends StatefulWidget {
  /// 图片列表
  final List<String> images;

  /// 初始索引
  final int initialIndex;

  /// 删除回调
  final Function(int)? onDelete;

  const ImagePreviewPage({
    super.key,
    required this.images,
    this.initialIndex = 0,
    this.onDelete,
  });

  @override
  State<ImagePreviewPage> createState() => _ImagePreviewPageState();
}

class _ImagePreviewPageState extends State<ImagePreviewPage> {
  late PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text('${_currentIndex + 1}/${widget.images.length}'),
        actions: [
          if (widget.onDelete != null)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () => _showDeleteConfirm(),
            ),
        ],
      ),
      body: PageView.builder(
        controller: _pageController,
        itemCount: widget.images.length,
        onPageChanged: (index) {
          setState(() => _currentIndex = index);
        },
        itemBuilder: (context, index) {
          final imagePath = widget.images[index];
          return Center(
            child: InteractiveViewer(
              child: _buildImage(imagePath),
            ),
          );
        },
      ),
    );
  }

  /// 构建图片
  Widget _buildImage(String imagePath) {
    if (imagePath.startsWith('/') || imagePath.startsWith('file://')) {
      return Image.file(
        File(imagePath.replaceFirst('file://', '')),
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return const Icon(Icons.broken_image, color: Colors.grey, size: 64);
        },
      );
    }

    return Image.network(
      imagePath,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) {
        return const Icon(Icons.broken_image, color: Colors.grey, size: 64);
      },
    );
  }

  /// 显示删除确认对话框
  void _showDeleteConfirm() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('删除图片'),
        content: const Text('确定要删除这张图片吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              widget.onDelete?.call(_currentIndex);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('删除'),
          ),
        ],
      ),
    );
  }
}
