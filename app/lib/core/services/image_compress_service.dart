import 'dart:io';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

// ═══════════════════════════════════════════════════════════════════════════════
/// 图片压缩服务
/// 负责压缩用户上传的图片，减少存储空间占用
// ═══════════════════════════════════════════════════════════════════════════════
class ImageCompressService {
  // ────────────────────────────────────────────────────────────────────────────
  // 常量配置
  // ────────────────────────────────────────────────────────────────────────────

  /// 图片最大宽度
  static const int maxWidth = 1080;

  /// 图片最大高度
  static const int maxHeight = 1080;

  /// 压缩质量（0-100）
  static const int quality = 85;

  // ────────────────────────────────────────────────────────────────────────────
  // 公开方法
  // ────────────────────────────────────────────────────────────────────────────

  /// 压缩图片文件
  /// 
  /// [file] 原始图片文件
  /// [maxWidth] 最大宽度，默认1080
  /// [maxHeight] 最大高度，默认1080
  /// [quality] 压缩质量，默认85
  /// 
  /// 返回压缩后的文件路径，失败返回null
  static Future<String?> compress(
    File file, {
    int? maxWidth,
    int? maxHeight,
    int? quality,
  }) async {
    try {
      // 获取临时目录
      final tempDir = await getTemporaryDirectory();
      
      // 生成目标文件名
      final fileName = '${DateTime.now().millisecondsSinceEpoch}_${path.basename(file.path)}';
      final targetPath = path.join(tempDir.path, 'compressed_$fileName');

      // 执行压缩
      final compressedFile = await FlutterImageCompress.compressAndGetFile(
        file.absolute.path,
        targetPath,
        minWidth: maxWidth ?? ImageCompressService.maxWidth,
        minHeight: maxHeight ?? ImageCompressService.maxHeight,
        quality: quality ?? ImageCompressService.quality,
        keepExif: false,
        format: CompressFormat.jpeg,
      );

      if (compressedFile == null) {
        return null;
      }

      return compressedFile.path;
    } catch (e) {
      return null;
    }
  }

  /// 压缩图片字节数据
  /// 
  /// [imagePath] 图片路径
  /// [maxWidth] 最大宽度
  /// [maxHeight] 最大高度
  /// [quality] 压缩质量
  /// 
  /// 返回压缩后的字节数据
  static Future<List<int>?> compressToBytes(
    String imagePath, {
    int? maxWidth,
    int? maxHeight,
    int? quality,
  }) async {
    try {
      final result = await FlutterImageCompress.compressWithFile(
        imagePath,
        minWidth: maxWidth ?? ImageCompressService.maxWidth,
        minHeight: maxHeight ?? ImageCompressService.maxHeight,
        quality: quality ?? ImageCompressService.quality,
        format: CompressFormat.jpeg,
      );

      return result?.toList();
    } catch (e) {
      return null;
    }
  }

  /// 获取图片压缩后的预估大小
  /// 
  /// [originalSize] 原始文件大小（字节）
  /// 
  /// 返回预估压缩后大小（字节）
  static int estimateCompressedSize(int originalSize) {
    // 通常压缩后大小为原始大小的10%-30%
    return (originalSize * 0.2).round();
  }

  /// 检查图片是否需要压缩
  /// 
  /// [file] 图片文件
  /// [sizeThreshold] 大小阈值（字节），默认500KB
  /// 
  /// 返回是否需要压缩
  static Future<bool> needsCompression(
    File file, {
    int sizeThreshold = 500 * 1024,
  }) async {
    final stat = await file.stat();
    return stat.size > sizeThreshold;
  }
}
