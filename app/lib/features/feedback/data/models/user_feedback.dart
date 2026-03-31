/// 反馈类型枚举
enum FeedbackType {
  /// Bug报告
  bug,
  /// 功能建议
  suggestion,
  /// 投诉
  complaint,
  /// 表扬
  praise,
  /// 其他
  other,
}

/// 反馈状态枚举
enum FeedbackStatus {
  /// 待处理
  pending,
  /// 处理中
  processing,
  /// 已解决
  resolved,
  /// 已关闭
  closed,
}

/// 用户反馈模型
class UserFeedback {
  /// 唯一标识符
  final String id;
  
  /// 用户ID
  final String userId;
  
  /// 反馈类型
  final FeedbackType type;
  
  /// 标题
  final String title;
  
  /// 内容（必填）
  final String content;
  
  /// 评分（1-5星）
  final int rating;
  
  /// 图片URL列表
  final List<String> imageUrls;
  
  /// 设备信息
  final DeviceInfo? deviceInfo;
  
  /// 应用信息
  final AppInfo? appInfo;
  
  /// 反馈状态
  final FeedbackStatus status;
  
  /// 管理员回复
  final String? adminReply;
  
  /// 创建时间
  final DateTime createdAt;
  
  /// 更新时间
  final DateTime? updatedAt;

  UserFeedback({
    required this.id,
    required this.userId,
    required this.type,
    required this.title,
    required this.content,
    this.rating = 0,
    this.imageUrls = const [],
    this.deviceInfo,
    this.appInfo,
    this.status = FeedbackStatus.pending,
    this.adminReply,
    required this.createdAt,
    this.updatedAt,
  });

  /// 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'type': type.name,
      'title': title,
      'content': content,
      'rating': rating,
      'image_urls': imageUrls,
      'device_info': deviceInfo?.toJson(),
      'app_info': appInfo?.toJson(),
      'status': status.name,
      'admin_reply': adminReply,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  /// 从JSON创建
  factory UserFeedback.fromJson(Map<String, dynamic> json) {
    return UserFeedback(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      type: FeedbackType.values.firstWhere((e) => e.name == json['type']),
      title: json['title'] as String,
      content: json['content'] as String,
      rating: json['rating'] as int? ?? 0,
      imageUrls: (json['image_urls'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ?? [],
      deviceInfo: json['device_info'] != null
          ? DeviceInfo.fromJson(json['device_info'] as Map<String, dynamic>)
          : null,
      appInfo: json['app_info'] != null
          ? AppInfo.fromJson(json['app_info'] as Map<String, dynamic>)
          : null,
      status: FeedbackStatus.values.firstWhere((e) => e.name == json['status']),
      adminReply: json['admin_reply'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  /// 复制并更新
  UserFeedback copyWith({
    String? id,
    String? userId,
    FeedbackType? type,
    String? title,
    String? content,
    int? rating,
    List<String>? imageUrls,
    DeviceInfo? deviceInfo,
    AppInfo? appInfo,
    FeedbackStatus? status,
    String? adminReply,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserFeedback(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      title: title ?? this.title,
      content: content ?? this.content,
      rating: rating ?? this.rating,
      imageUrls: imageUrls ?? this.imageUrls,
      deviceInfo: deviceInfo ?? this.deviceInfo,
      appInfo: appInfo ?? this.appInfo,
      status: status ?? this.status,
      adminReply: adminReply ?? this.adminReply,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// 获取反馈类型显示名称
  String get typeDisplayName {
    switch (type) {
      case FeedbackType.bug:
        return 'Bug报告';
      case FeedbackType.suggestion:
        return '功能建议';
      case FeedbackType.complaint:
        return '投诉';
      case FeedbackType.praise:
        return '表扬';
      case FeedbackType.other:
        return '其他';
    }
  }

  /// 获取状态显示名称
  String get statusDisplayName {
    switch (status) {
      case FeedbackStatus.pending:
        return '待处理';
      case FeedbackStatus.processing:
        return '处理中';
      case FeedbackStatus.resolved:
        return '已解决';
      case FeedbackStatus.closed:
        return '已关闭';
    }
  }
}

/// 设备信息模型
class DeviceInfo {
  /// 平台（android/ios）
  final String platform;
  
  /// 操作系统版本
  final String osVersion;
  
  /// 设备型号
  final String deviceModel;
  
  /// 应用版本
  final String appVersion;
  
  /// 网络类型
  final String? networkType;
  
  /// 是否Root/越狱
  final bool? isRooted;

  DeviceInfo({
    required this.platform,
    required this.osVersion,
    required this.deviceModel,
    required this.appVersion,
    this.networkType,
    this.isRooted,
  });

  Map<String, dynamic> toJson() {
    return {
      'platform': platform,
      'os_version': osVersion,
      'device_model': deviceModel,
      'app_version': appVersion,
      'network_type': networkType,
      'is_rooted': isRooted,
    };
  }

  factory DeviceInfo.fromJson(Map<String, dynamic> json) {
    return DeviceInfo(
      platform: json['platform'] as String,
      osVersion: json['os_version'] as String,
      deviceModel: json['device_model'] as String,
      appVersion: json['app_version'] as String,
      networkType: json['network_type'] as String?,
      isRooted: json['is_rooted'] as bool?,
    );
  }
}

/// 应用信息模型
class AppInfo {
  /// 应用版本
  final String version;
  
  /// 构建号
  final String buildNumber;
  
  /// 最后访问的页面
  final String? lastScreen;
  
  /// 错误日志
  final String? errorLog;

  AppInfo({
    required this.version,
    required this.buildNumber,
    this.lastScreen,
    this.errorLog,
  });

  Map<String, dynamic> toJson() {
    return {
      'version': version,
      'build_number': buildNumber,
      'last_screen': lastScreen,
      'error_log': errorLog,
    };
  }

  factory AppInfo.fromJson(Map<String, dynamic> json) {
    return AppInfo(
      version: json['version'] as String,
      buildNumber: json['build_number'] as String,
      lastScreen: json['last_screen'] as String?,
      errorLog: json['error_log'] as String?,
    );
  }
}
