/// Optional 包装器类
/// 用于区分"不传参数"和"传null值"两种情况
class Optional<T> {
  final T? value;
  const Optional(this.value);
  
  /// 创建一个包含 null 值的 Optional
  static Optional<T> nullValue<T>() => Optional<T>(null);
}

class UserProfile {
  final String userId;
  final String userName;
  final String? jobIntention;
  final String? city;
  final String? salaryExpect;
  final List<PetMemory> petMemory;
  final bool vipStatus;
  final DateTime? vipExpireTime;
  final bool isOnboarded;
  final String? industryTag;
  final String? onboardingReport;
  
  /// 公园是否已解锁
  final bool isParkUnlocked;
  
  /// 公园解锁时间
  final DateTime? parkUnlockedAt;
  
  /// 公园解锁来源（offer, manual, pro_vip）
  final String? parkUnlockSource;

  UserProfile({
    required this.userId,
    required this.userName,
    this.jobIntention,
    this.city,
    this.salaryExpect,
    this.petMemory = const [],
    this.vipStatus = false,
    this.vipExpireTime,
    this.isOnboarded = false,
    this.industryTag,
    this.onboardingReport,
    this.isParkUnlocked = false,
    this.parkUnlockedAt,
    this.parkUnlockSource,
  });

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'userName': userName,
      'jobIntention': jobIntention,
      'city': city,
      'salaryExpect': salaryExpect,
      'petMemory': petMemory.map((m) => m.toJson()).toList(),
      'vipStatus': vipStatus,
      'vipExpireTime': vipExpireTime?.toIso8601String(),
      'isOnboarded': isOnboarded,
      'industryTag': industryTag,
      'onboardingReport': onboardingReport,
      'isParkUnlocked': isParkUnlocked,
      'parkUnlockedAt': parkUnlockedAt?.toIso8601String(),
      'parkUnlockSource': parkUnlockSource,
    };
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      userId: json['userId'] as String,
      userName: json['userName'] as String,
      jobIntention: json['jobIntention'] as String?,
      city: json['city'] as String?,
      salaryExpect: json['salaryExpect'] as String?,
      petMemory: (json['petMemory'] as List<dynamic>?)
              ?.map((m) => PetMemory.fromJson(m as Map<String, dynamic>))
              .toList() ??
          [],
      vipStatus: json['vipStatus'] as bool? ?? false,
      vipExpireTime: json['vipExpireTime'] != null
          ? DateTime.parse(json['vipExpireTime'] as String)
          : null,
      isOnboarded: json['isOnboarded'] as bool? ?? false,
      industryTag: json['industryTag'] as String?,
      onboardingReport: json['onboardingReport'] as String?,
      isParkUnlocked: json['isParkUnlocked'] as bool? ?? false,
      parkUnlockedAt: json['parkUnlockedAt'] != null
          ? DateTime.parse(json['parkUnlockedAt'] as String)
          : null,
      parkUnlockSource: json['parkUnlockSource'] as String?,
    );
  }

  factory UserProfile.createDefault(String userId, String userName) {
    return UserProfile(
      userId: userId,
      userName: userName,
      isOnboarded: false,
      vipStatus: false,
      petMemory: [],
      isParkUnlocked: false,
    );
  }

  /// 复制并更新部分字段
  /// 使用 Optional 包装器支持将字段设置为 null
  UserProfile copyWith({
    String? userId,
    String? userName,
    String? jobIntention,
    String? city,
    String? salaryExpect,
    List<PetMemory>? petMemory,
    bool? vipStatus,
    Optional<DateTime>? vipExpireTime,
    bool? isOnboarded,
    String? industryTag,
    String? onboardingReport,
    bool? isParkUnlocked,
    Optional<DateTime>? parkUnlockedAt,
    String? parkUnlockSource,
  }) {
    return UserProfile(
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      jobIntention: jobIntention ?? this.jobIntention,
      city: city ?? this.city,
      salaryExpect: salaryExpect ?? this.salaryExpect,
      petMemory: petMemory ?? this.petMemory,
      vipStatus: vipStatus ?? this.vipStatus,
      vipExpireTime: vipExpireTime != null 
          ? vipExpireTime.value 
          : this.vipExpireTime,
      isOnboarded: isOnboarded ?? this.isOnboarded,
      industryTag: industryTag ?? this.industryTag,
      onboardingReport: onboardingReport ?? this.onboardingReport,
      isParkUnlocked: isParkUnlocked ?? this.isParkUnlocked,
      parkUnlockedAt: parkUnlockedAt != null
          ? parkUnlockedAt.value
          : this.parkUnlockedAt,
      parkUnlockSource: parkUnlockSource ?? this.parkUnlockSource,
    );
  }

  /// 检查VIP是否有效
  /// VIP状态为true且过期时间大于当前时间
  bool get isVipValid {
    if (!vipStatus) return false;
    if (vipExpireTime == null) return false;
    return vipExpireTime!.isAfter(DateTime.now());
  }

  /// 获取VIP剩余天数
  /// 如果VIP无效返回0
  int get vipRemainingDays {
    if (!isVipValid) return 0;
    return vipExpireTime!.difference(DateTime.now()).inDays;
  }
}

class PetMemory {
  final String type;
  final String key;
  final String value;
  final String source;
  final DateTime createdAt;

  PetMemory({
    required this.type,
    required this.key,
    required this.value,
    required this.source,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'key': key,
      'value': value,
      'source': source,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory PetMemory.fromJson(Map<String, dynamic> json) {
    return PetMemory(
      type: json['type'] as String,
      key: json['key'] as String,
      value: json['value'] as String,
      source: json['source'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}
