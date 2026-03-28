import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'image_compress_service.dart';

// ═══════════════════════════════════════════════════════════════════════════════
/// 图片本地存储服务
/// 负责将用户选择的图片保存到应用本地存储目录
// ═══════════════════════════════════════════════════════════════════════════════
class ImageStorage {
  // ────────────────────────────────────────────────────────────────────────────
  // 常量配置
  // ────────────────────────────────────────────────────────────────────────────

  /// 图片存储子目录名称
  static const String imageDirName = 'post_images';

  /// 单张图片最大大小（10MB）
  static const int maxImageSize = 10 * 1024 * 1024;

  // ────────────────────────────────────────────────────────────────────────────
  // 私有属性
  // ────────────────────────────────────────────────────────────────────────────

  /// 图片存储目录缓存
  static Directory? _imageDir;

  // ────────────────────────────────────────────────────────────────────────────
  // 公开方法
  // ────────────────────────────────────────────────────────────────────────────

  /// 初始化图片存储目录
  /// 
  /// 在应用启动时调用，确保存储目录存在
  static Future<void> init() async {
    _imageDir = await _getImageDirectory();
    if (!_imageDir!.existsSync()) {
      _imageDir!.createSync(recursive: true);
    }
  }

  /// 保存图片到本地
  /// 
  /// [sourcePath] 源图片路径
  /// [compress] 是否压缩，默认true
  /// 
  /// 返回保存后的本地路径，失败返回null
  static Future<String?> save(
    String sourcePath, {
    bool compress = true,
  }) async {
    try {
      final sourceFile = File(sourcePath);
      
      // 检查源文件是否存在
      if (!sourceFile.existsSync()) {
        return null;
      }

      // 检查文件大小
      final fileSize = await sourceFile.length();
      if (fileSize > maxImageSize) {
        return null;
      }

      // 确保存储目录存在
      final imageDir = await _getImageDirectory();
      if (!imageDir.existsSync()) {
        imageDir.createSync(recursive: true);
      }

      // 生成唯一文件名
      final fileName = _generateFileName(sourcePath);
      final targetPath = path.join(imageDir.path, fileName);

      // 压缩并保存
      if (compress) {
        final compressedPath = await ImageCompressService.compress(sourceFile);
        if (compressedPath != null) {
          final compressedFile = File(compressedPath);
          await compressedFile.copy(targetPath);
          // 删除临时压缩文件
          await compressedFile.delete();
        } else {
          // 压缩失败，直接复制原文件
          await sourceFile.copy(targetPath);
        }
      } else {
        await sourceFile.copy(targetPath);
      }

      return targetPath;
    } catch (e) {
      return null;
    }
  }

  /// 批量保存图片
  /// 
  /// [sourcePaths] 源图片路径列表
  /// [compress] 是否压缩，默认true
  /// 
  /// 返回保存后的本地路径列表
  static Future<List<String>> saveAll(
    List<String> sourcePaths, {
    bool compress = true,
  }) async {
    final results = <String>[];
    
    for (final sourcePath in sourcePaths) {
      final savedPath = await save(sourcePath, compress: compress);
      if (savedPath != null) {
        results.add(savedPath);
      }
    }
    
    return results;
  }

  /// 删除本地图片
  /// 
  /// [imagePath] 图片路径
  /// 
  /// 返回是否删除成功
  static Future<bool> delete(String imagePath) async {
    try {
      final file = File(imagePath);
      if (file.existsSync()) {
        await file.delete();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  /// 批量删除图片
  /// 
  /// [imagePaths] 图片路径列表
  static Future<void> deleteAll(List<String> imagePaths) async {
    for (final imagePath in imagePaths) {
      await delete(imagePath);
    }
  }

  /// 检查图片是否存在
  /// 
  /// [imagePath] 图片路径
  static bool exists(String imagePath) {
    return File(imagePath).existsSync();
  }

  /// 获取图片文件
  /// 
  /// [imagePath] 图片路径
  static File? getFile(String imagePath) {
    final file = File(imagePath);
    return file.existsSync() ? file : null;
  }

  /// 清理所有存储的图片
  /// 
  /// 谨慎使用，会删除所有图片
  static Future<void> clearAll() async {
    try {
      final imageDir = await _getImageDirectory();
      if (imageDir.existsSync()) {
        await imageDir.delete(recursive: true);
      }
    } catch (e) {
      // 忽略清理错误
    }
  }

  /// 获取存储目录大小
  /// 
  /// 返回总大小（字节）
  static Future<int> getStorageSize() async {
    try {
      final imageDir = await _getImageDirectory();
      if (!imageDir.existsSync()) {
        return 0;
      }

      int totalSize = 0;
      final files = imageDir.listSync(recursive: true);
      for (final file in files) {
        if (file is File) {
          totalSize += await file.length();
        }
      }
      
      return totalSize;
    } catch (e) {
      return 0;
    }
  }

  /// 获取存储目录路径
  static Future<String> getStoragePath() async {
    final imageDir = await _getImageDirectory();
    return imageDir.path;
  }

  // ────────────────────────────────────────────────────────────────────────────
  // 私有方法
  // ────────────────────────────────────────────────────────────────────────────

  /// 获取图片存储目录
  static Future<Directory> _getImageDirectory() async {
    if (_imageDir != null) {
      return _imageDir!;
    }

    final appDir = await getApplicationDocumentsDirectory();
    return Directory(path.join(appDir.path, imageDirName));
  }

  /// 生成唯一文件名
  static String _generateFileName(String sourcePath) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final extension = path.extension(sourcePath).toLowerCase();
    final validExtension = _isValidImageExtension(extension) ? extension : '.jpg';
    return 'img_$timestamp$validExtension';
  }

  /// 检查是否为有效的图片扩展名
  static bool _isValidImageExtension(String extension) {
    const validExtensions = ['.jpg', '.jpeg', '.png', '.gif', '.webp'];
    return validExtensions.contains(extension.toLowerCase());
  }
}
