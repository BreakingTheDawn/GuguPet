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
    );
  }

  factory UserProfile.createDefault(String userId, String userName) {
    return UserProfile(
      userId: userId,
      userName: userName,
      isOnboarded: false,
      vipStatus: false,
      petMemory: [],
    );
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
