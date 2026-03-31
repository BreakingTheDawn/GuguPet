import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:device_info_plus/device_info_plus.dart';
import '../data/models/user_feedback.dart';
import '../data/datasources/feedback_local_datasource.dart';

/// 反馈请求
class FeedbackRequest {
  /// 用户ID
  final String userId;
  
  /// 反馈类型
  final FeedbackType type;
  
  /// 标题
  final String title;
  
  /// 内容（必填)
  final String content;
  
  /// 评分
  final int? rating;
  
  /// 图片路径列表
  final List<String>? imagePaths;
  
  /// 是否包含设备信息
  final bool includeDeviceInfo;
  
  /// 是否包含错误日志
  final bool includeErrorLog;
  
  /// 错误数据
  final Map<String, dynamic>? errorData;

  const FeedbackRequest({
    required this.userId,
    required this.type,
    required this.title,
    required this.content,
    this.rating,
    this.imagePaths,
    this.includeDeviceInfo = true,
    this.includeErrorLog = false,
    this.errorData,
  });

  /// 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'type': type.name,
      'title': title,
      'content': content,
      'rating': rating,
      'include_device_info': includeDeviceInfo,
      'include_error_log': includeErrorLog,
      'error_data': errorData,
    };
  }
}

/// 反馈提交结果
class FeedbackResult {
  /// 是否成功
  final bool success;
  
  /// 反馈ID
  final String? feedbackId;
  
  /// 错误消息
  final String? errorMessage;

  const FeedbackResult({
    required this.success,
    this.feedbackId,
    this.errorMessage,
  });

  factory FeedbackResult.success(String feedbackId) {
    return FeedbackResult(success: true, feedbackId: feedbackId);
  }

  factory FeedbackResult.failure(String message) {
    return FeedbackResult(success: false, errorMessage: message);
  }
}

/// 反馈服务接口
abstract class FeedbackService {
  /// 提交反馈
  Future<FeedbackResult> submit(FeedbackRequest request);

  /// 上传图片
  Future<String?> uploadImage(String filePath);

  /// 获取用户反馈历史
  Future<List<UserFeedback>> getUserFeedbacks(String userId, {int page, int size});
}

/// 本地反馈服务实现
/// 将反馈存储在本地SQLite数据库中
class LocalFeedbackService implements FeedbackService {
  final FeedbackLocalDatasource _localDatasource;
  final DeviceInfoPlugin _deviceInfoPlugin;

  LocalFeedbackService({
    required FeedbackLocalDatasource localDatasource,
  })  : _localDatasource = localDatasource,
        _deviceInfoPlugin = DeviceInfoPlugin();

  @override
  Future<FeedbackResult> submit(FeedbackRequest request) async {
    try {
      // 收集设备信息
      DeviceInfo? deviceInfo;
      if (request.includeDeviceInfo) {
        deviceInfo = await _collectDeviceInfo();
      }

      // 创建反馈ID
      final feedbackId = 'fb_${DateTime.now().millisecondsSinceEpoch}';

      // 创建反馈对象
      final feedback = UserFeedback(
        id: feedbackId,
        userId: request.userId,
        type: request.type,
        title: request.title,
        content: request.content,
        rating: request.rating ?? 0,
        imageUrls: request.imagePaths ?? [],
        deviceInfo: deviceInfo,
        appInfo: AppInfo(
          version: '1.0.0', // TODO: 从package_info获取
          buildNumber: '1',
          errorLog: request.includeErrorLog ? request.errorData?.toString() : null,
        ),
        status: FeedbackStatus.pending,
        createdAt: DateTime.now(),
      );

      // 存储到本地数据库
      await _localDatasource.insertFeedback(feedback);

      debugPrint('📝 反馈已保存到本地: $feedbackId');
      return FeedbackResult.success(feedbackId);
    } catch (e) {
      debugPrint('❌ 保存反馈失败: $e');
      return FeedbackResult.failure(e.toString());
    }
  }

  @override
  Future<String?> uploadImage(String filePath) async {
    // 本地存储模式：返回本地文件路径
    try {
      final file = File(filePath);
      if (!await file.exists()) return null;
      return filePath; // 返回本地路径
    } catch (e) {
      debugPrint('上传图片失败: $e');
      return null;
    }
  }

  @override
  Future<List<UserFeedback>> getUserFeedbacks(String userId, {int page = 1, int size = 10}) async {
    return await _localDatasource.getFeedbacksByUserId(userId, page: page, size: size);
  }

  /// 收集设备信息
  Future<DeviceInfo?> _collectDeviceInfo() async {
    try {
      if (defaultTargetPlatform == TargetPlatform.android) {
        final info = await _deviceInfoPlugin.androidInfo;
        return DeviceInfo(
          platform: 'android',
          osVersion: info.version.release,
          deviceModel: '${info.brand} ${info.model}',
          appVersion: '', // 需要从package_info获取
        );
      } else if (defaultTargetPlatform == TargetPlatform.iOS) {
        final info = await _deviceInfoPlugin.iosInfo;
        return DeviceInfo(
          platform: 'ios',
          osVersion: info.systemVersion,
          deviceModel: info.model,
          appVersion: '',
        );
      }
    } catch (e) {
      debugPrint('收集设备信息失败: $e');
    }
    return null;
  }
}

/// 云端反馈服务实现（备用）
/// 当配置了后端服务器时使用
class CloudFeedbackService implements FeedbackService {
  final Dio _dio;
  final String _baseUrl;
  final DeviceInfoPlugin _deviceInfoPlugin;

  CloudFeedbackService({
    required Dio dio,
    required String baseUrl,
  })  : _dio = dio,
        _baseUrl = baseUrl,
        _deviceInfoPlugin = DeviceInfoPlugin();

  @override
  Future<FeedbackResult> submit(FeedbackRequest request) async {
    try {
      // 上传图片（如果有）
      List<String> imageUrls = [];
      if (request.imagePaths != null && request.imagePaths!.isNotEmpty) {
        for (final path in request.imagePaths!) {
          final url = await uploadImage(path);
          if (url != null) {
            imageUrls.add(url);
          }
        }
      }

      // 收集设备信息
      DeviceInfo? deviceInfo;
      if (request.includeDeviceInfo) {
        deviceInfo = await _collectDeviceInfo();
      }

      // 构建请求数据
      final data = {
        ...request.toJson(),
        'image_urls': imageUrls,
        'device_info': deviceInfo?.toJson(),
      };

      // 发送请求
      final response = await _dio.post<dynamic>(
        '$_baseUrl/api/v1/feedbacks',
        data: data,
        options: Options(
          headers: {'Content-Type': 'application/json'},
        ),
      );

      if (response.statusCode == 200 && response.data != null) {
        final responseData = response.data as Map<String, dynamic>;
        final code = responseData['code'] as int?;
        if (code == 200) {
          final feedbackId = responseData['data']?['feedbackId'] as String?;
          return FeedbackResult.success(feedbackId ?? '');
        }
      }

      return FeedbackResult.failure('提交失败');
    } on DioException catch (e) {
        debugPrint('提交反馈失败: ${e.message}');
        return FeedbackResult.failure(e.message ?? '网络错误');
    } catch (e) {
      debugPrint('提交反馈失败: $e');
      return FeedbackResult.failure(e.toString());
    }
  }

  @override
  Future<String?> uploadImage(String filePath) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) return null;

      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(filePath),
      });

      final response = await _dio.post<Map<String, dynamic>>(
        '$_baseUrl/api/v1/feedbacks/upload',
        data: formData,
      );

      if (response.statusCode == 200 && response.data != null) {
        return response.data!['data']?['url'] as String?;
      }
      return null;
    } catch (e) {
      debugPrint('上传图片失败: $e');
      return null;
    }
  }

  @override
  Future<List<UserFeedback>> getUserFeedbacks(String userId, {int page = 1, int size = 10}) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '$_baseUrl/api/v1/feedbacks',
        queryParameters: {
          'userId': userId,
          'page': page,
          'size': size,
        },
      );

      if (response.statusCode == 200 && response.data != null) {
        final items = response.data!['data']?['items'] as List<dynamic>?;
        if (items != null) {
          return items
              .map((e) => UserFeedback.fromJson(e as Map<String, dynamic>))
              .toList();
        }
      }
      return [];
    } catch (e) {
      debugPrint('获取反馈历史失败: $e');
      return [];
    }
  }

  /// 收集设备信息
  Future<DeviceInfo?> _collectDeviceInfo() async {
    try {
      if (defaultTargetPlatform == TargetPlatform.android) {
        final info = await _deviceInfoPlugin.androidInfo;
        return DeviceInfo(
          platform: 'android',
          osVersion: info.version.release,
          deviceModel: '${info.brand} ${info.model}',
          appVersion: '',
        );
      } else if (defaultTargetPlatform == TargetPlatform.iOS) {
        final info = await _deviceInfoPlugin.iosInfo;
        return DeviceInfo(
          platform: 'ios',
          osVersion: info.systemVersion,
          deviceModel: info.model,
          appVersion: '',
        );
      }
    } catch (e) {
      debugPrint('收集设备信息失败: $e');
    }
    return null;
  }
}
