/// UI文本配置模型
class UIStringsConfig {
  /// 通用文本
  final CommonStrings common;
  
  /// 职位模块文本
  final JobStrings jobs;
  
  /// 设置模块文本
  final SettingsStrings settings;
  
  /// 个人中心文本
  final ProfileStrings profile;
  
  /// 通知模块文本
  final NotificationStrings notifications;
  
  /// 错误提示文本
  final ErrorStrings errors;
  
  UIStringsConfig({
    required this.common,
    required this.jobs,
    required this.settings,
    required this.profile,
    required this.notifications,
    required this.errors,
  });
  
  factory UIStringsConfig.fromJson(Map<String, dynamic> json) {
    return UIStringsConfig(
      common: CommonStrings.fromJson(json['common'] as Map<String, dynamic>),
      jobs: JobStrings.fromJson(json['jobs'] as Map<String, dynamic>),
      settings: SettingsStrings.fromJson(json['settings'] as Map<String, dynamic>),
      profile: ProfileStrings.fromJson(json['profile'] as Map<String, dynamic>),
      notifications: NotificationStrings.fromJson(json['notifications'] as Map<String, dynamic>),
      errors: ErrorStrings.fromJson(json['errors'] as Map<String, dynamic>),
    );
  }
}

/// 通用文本
class CommonStrings {
  final String loading;
  final String loadFailed;
  final String retry;
  final String confirm;
  final String cancel;
  final String save;
  final String delete;
  
  CommonStrings({
    required this.loading,
    required this.loadFailed,
    required this.retry,
    required this.confirm,
    required this.cancel,
    required this.save,
    required this.delete,
  });
  
  factory CommonStrings.fromJson(Map<String, dynamic> json) {
    return CommonStrings(
      loading: json['loading'] as String,
      loadFailed: json['loadFailed'] as String,
      retry: json['retry'] as String,
      confirm: json['confirm'] as String,
      cancel: json['cancel'] as String,
      save: json['save'] as String,
      delete: json['delete'] as String,
    );
  }
}

/// 职位模块文本
class JobStrings {
  final String title;
  final String noJobs;
  final String applyNow;
  final String applied;
  final String favorite;
  final String favorited;
  final String filter;
  final String advancedFilter;
  final String reset;
  
  JobStrings({
    required this.title,
    required this.noJobs,
    required this.applyNow,
    required this.applied,
    required this.favorite,
    required this.favorited,
    required this.filter,
    required this.advancedFilter,
    required this.reset,
  });
  
  factory JobStrings.fromJson(Map<String, dynamic> json) {
    return JobStrings(
      title: json['title'] as String,
      noJobs: json['noJobs'] as String,
      applyNow: json['applyNow'] as String,
      applied: json['applied'] as String,
      favorite: json['favorite'] as String,
      favorited: json['favorited'] as String,
      filter: json['filter'] as String,
      advancedFilter: json['advancedFilter'] as String,
      reset: json['reset'] as String,
    );
  }
}

/// 设置模块文本
class SettingsStrings {
  final String title;
  final String clearData;
  final String clearDataConfirm;
  final String logout;
  final String logoutConfirm;
  final String deleteAccount;
  final String deleteAccountConfirm;
  
  SettingsStrings({
    required this.title,
    required this.clearData,
    required this.clearDataConfirm,
    required this.logout,
    required this.logoutConfirm,
    required this.deleteAccount,
    required this.deleteAccountConfirm,
  });
  
  factory SettingsStrings.fromJson(Map<String, dynamic> json) {
    return SettingsStrings(
      title: json['title'] as String,
      clearData: json['clearData'] as String,
      clearDataConfirm: json['clearDataConfirm'] as String,
      logout: json['logout'] as String,
      logoutConfirm: json['logoutConfirm'] as String,
      deleteAccount: json['deleteAccount'] as String,
      deleteAccountConfirm: json['deleteAccountConfirm'] as String,
    );
  }
}

/// 个人中心文本
class ProfileStrings {
  final String title;
  final String editProfile;
  final String jobIntention;
  final String vipStatus;
  final String upgrade;
  
  ProfileStrings({
    required this.title,
    required this.editProfile,
    required this.jobIntention,
    required this.vipStatus,
    required this.upgrade,
  });
  
  factory ProfileStrings.fromJson(Map<String, dynamic> json) {
    return ProfileStrings(
      title: json['title'] as String,
      editProfile: json['editProfile'] as String,
      jobIntention: json['jobIntention'] as String,
      vipStatus: json['vipStatus'] as String,
      upgrade: json['upgrade'] as String,
    );
  }
}

/// 通知模块文本
class NotificationStrings {
  final String title;
  final String noNotifications;
  final String markAllRead;
  
  NotificationStrings({
    required this.title,
    required this.noNotifications,
    required this.markAllRead,
  });
  
  factory NotificationStrings.fromJson(Map<String, dynamic> json) {
    return NotificationStrings(
      title: json['title'] as String,
      noNotifications: json['noNotifications'] as String,
      markAllRead: json['markAllRead'] as String,
    );
  }
}

/// 错误提示文本
class ErrorStrings {
  final String networkError;
  final String saveFailed;
  final String loadFailed;
  final String operationFailed;
  
  ErrorStrings({
    required this.networkError,
    required this.saveFailed,
    required this.loadFailed,
    required this.operationFailed,
  });
  
  factory ErrorStrings.fromJson(Map<String, dynamic> json) {
    return ErrorStrings(
      networkError: json['networkError'] as String,
      saveFailed: json['saveFailed'] as String,
      loadFailed: json['loadFailed'] as String,
      operationFailed: json['operationFailed'] as String,
    );
  }
}
