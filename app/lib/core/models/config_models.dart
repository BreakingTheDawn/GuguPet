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
  
  /// 收藏模块文本
  final FavoriteStrings favorites;
  
  /// 通知模块文本
  final NotificationStrings notifications;
  
  /// 专栏模块文本
  final ColumnStrings columns;
  
  /// 公园模块文本
  final ParkStrings park;
  
  /// 倾诉模块文本
  final ConfideStrings confide;
  
  /// 统计模块文本
  final StatsStrings stats;
  
  /// 错误提示文本
  final ErrorStrings errors;
  
  /// 时间格式文本
  final TimeStrings time;
  
  UIStringsConfig({
    required this.common,
    required this.jobs,
    required this.settings,
    required this.profile,
    required this.favorites,
    required this.notifications,
    required this.columns,
    required this.park,
    required this.confide,
    required this.stats,
    required this.errors,
    required this.time,
  });
  
  factory UIStringsConfig.fromJson(Map<String, dynamic> json) {
    return UIStringsConfig(
      common: CommonStrings.fromJson(json['common'] as Map<String, dynamic>),
      jobs: JobStrings.fromJson(json['jobs'] as Map<String, dynamic>),
      settings: SettingsStrings.fromJson(json['settings'] as Map<String, dynamic>),
      profile: ProfileStrings.fromJson(json['profile'] as Map<String, dynamic>),
      favorites: FavoriteStrings.fromJson(json['favorites'] as Map<String, dynamic>),
      notifications: NotificationStrings.fromJson(json['notifications'] as Map<String, dynamic>),
      columns: ColumnStrings.fromJson(json['columns'] as Map<String, dynamic>),
      park: ParkStrings.fromJson(json['park'] as Map<String, dynamic>),
      confide: ConfideStrings.fromJson(json['confide'] as Map<String, dynamic>),
      stats: StatsStrings.fromJson(json['stats'] as Map<String, dynamic>),
      errors: ErrorStrings.fromJson(json['errors'] as Map<String, dynamic>),
      time: TimeStrings.fromJson(json['time'] as Map<String, dynamic>),
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
  final String success;
  final String failed;
  final String dataCleared;
  
  CommonStrings({
    required this.loading,
    required this.loadFailed,
    required this.retry,
    required this.confirm,
    required this.cancel,
    required this.save,
    required this.delete,
    required this.success,
    required this.failed,
    required this.dataCleared,
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
      success: json['success'] as String,
      failed: json['failed'] as String,
      dataCleared: json['dataCleared'] as String,
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
  final String clearAll;
  final String searchPlaceholder;
  final String selectedForYou;
  final String newToday;
  final String jobsCount;
  final String jobDetail;
  final String jobDescription;
  final String noDescription;
  final String viewOnBoss;
  final String submitted;
  final String addedToFavorite;
  final String removedFromFavorite;
  final String cannotOpenLink;
  final String communicateNow;
  final String submitResume;
  final String submitConfirm;
  final String submitConfirmMessage;
  final String submitSuccess;
  final String shareDeveloping;
  final String communicateDeveloping;
  final String workLocation;
  
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
    required this.clearAll,
    required this.searchPlaceholder,
    required this.selectedForYou,
    required this.newToday,
    required this.jobsCount,
    required this.jobDetail,
    required this.jobDescription,
    required this.noDescription,
    required this.viewOnBoss,
    required this.submitted,
    required this.addedToFavorite,
    required this.removedFromFavorite,
    required this.cannotOpenLink,
    required this.communicateNow,
    required this.submitResume,
    required this.submitConfirm,
    required this.submitConfirmMessage,
    required this.submitSuccess,
    required this.shareDeveloping,
    required this.communicateDeveloping,
    required this.workLocation,
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
      clearAll: json['clearAll'] as String,
      searchPlaceholder: json['searchPlaceholder'] as String,
      selectedForYou: json['selectedForYou'] as String,
      newToday: json['newToday'] as String,
      jobsCount: json['jobsCount'] as String,
      jobDetail: json['jobDetail'] as String,
      jobDescription: json['jobDescription'] as String,
      noDescription: json['noDescription'] as String,
      viewOnBoss: json['viewOnBoss'] as String,
      submitted: json['submitted'] as String,
      addedToFavorite: json['addedToFavorite'] as String,
      removedFromFavorite: json['removedFromFavorite'] as String,
      cannotOpenLink: json['cannotOpenLink'] as String,
      communicateNow: json['communicateNow'] as String,
      submitResume: json['submitResume'] as String,
      submitConfirm: json['submitConfirm'] as String,
      submitConfirmMessage: json['submitConfirmMessage'] as String,
      submitSuccess: json['submitSuccess'] as String,
      shareDeveloping: json['shareDeveloping'] as String,
      communicateDeveloping: json['communicateDeveloping'] as String,
      workLocation: json['workLocation'] as String,
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
  final String notificationSettings;
  final String jobReminder;
  final String jobReminderDesc;
  final String interviewReminder;
  final String interviewReminderDesc;
  final String petInteractionReminder;
  final String petInteractionReminderDesc;
  final String systemNotification;
  final String systemNotificationDesc;
  final String privacySettings;
  final String resumePublic;
  final String resumePublicDesc;
  final String contactVisible;
  final String contactVisibleDesc;
  final String about;
  final String versionInfo;
  final String userAgreement;
  final String privacyPolicy;
  final String aboutUs;
  
  SettingsStrings({
    required this.title,
    required this.clearData,
    required this.clearDataConfirm,
    required this.logout,
    required this.logoutConfirm,
    required this.deleteAccount,
    required this.deleteAccountConfirm,
    required this.notificationSettings,
    required this.jobReminder,
    required this.jobReminderDesc,
    required this.interviewReminder,
    required this.interviewReminderDesc,
    required this.petInteractionReminder,
    required this.petInteractionReminderDesc,
    required this.systemNotification,
    required this.systemNotificationDesc,
    required this.privacySettings,
    required this.resumePublic,
    required this.resumePublicDesc,
    required this.contactVisible,
    required this.contactVisibleDesc,
    required this.about,
    required this.versionInfo,
    required this.userAgreement,
    required this.privacyPolicy,
    required this.aboutUs,
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
      notificationSettings: json['notificationSettings'] as String,
      jobReminder: json['jobReminder'] as String,
      jobReminderDesc: json['jobReminderDesc'] as String,
      interviewReminder: json['interviewReminder'] as String,
      interviewReminderDesc: json['interviewReminderDesc'] as String,
      petInteractionReminder: json['petInteractionReminder'] as String,
      petInteractionReminderDesc: json['petInteractionReminderDesc'] as String,
      systemNotification: json['systemNotification'] as String,
      systemNotificationDesc: json['systemNotificationDesc'] as String,
      privacySettings: json['privacySettings'] as String,
      resumePublic: json['resumePublic'] as String,
      resumePublicDesc: json['resumePublicDesc'] as String,
      contactVisible: json['contactVisible'] as String,
      contactVisibleDesc: json['contactVisibleDesc'] as String,
      about: json['about'] as String,
      versionInfo: json['versionInfo'] as String,
      userAgreement: json['userAgreement'] as String,
      privacyPolicy: json['privacyPolicy'] as String,
      aboutUs: json['aboutUs'] as String,
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
  final String functionEntries;
  final String submissionRecords;
  final String favoriteJobs;
  final String settings;
  
  ProfileStrings({
    required this.title,
    required this.editProfile,
    required this.jobIntention,
    required this.vipStatus,
    required this.upgrade,
    required this.functionEntries,
    required this.submissionRecords,
    required this.favoriteJobs,
    required this.settings,
  });
  
  factory ProfileStrings.fromJson(Map<String, dynamic> json) {
    return ProfileStrings(
      title: json['title'] as String,
      editProfile: json['editProfile'] as String,
      jobIntention: json['jobIntention'] as String,
      vipStatus: json['vipStatus'] as String,
      upgrade: json['upgrade'] as String,
      functionEntries: json['functionEntries'] as String,
      submissionRecords: json['submissionRecords'] as String,
      favoriteJobs: json['favoriteJobs'] as String,
      settings: json['settings'] as String,
    );
  }
}

/// 收藏模块文本
class FavoriteStrings {
  final String title;
  final String noFavorites;
  final String goDiscover;
  final String goDiscoverButton;
  final String removeFavorite;
  final String removeConfirm;
  final String removeConfirmMessage;
  final String removed;
  final String operationFailed;
  final String reload;
  final String favoriteTime;
  final String unknownJob;
  
  FavoriteStrings({
    required this.title,
    required this.noFavorites,
    required this.goDiscover,
    required this.goDiscoverButton,
    required this.removeFavorite,
    required this.removeConfirm,
    required this.removeConfirmMessage,
    required this.removed,
    required this.operationFailed,
    required this.reload,
    required this.favoriteTime,
    required this.unknownJob,
  });
  
  factory FavoriteStrings.fromJson(Map<String, dynamic> json) {
    return FavoriteStrings(
      title: json['title'] as String,
      noFavorites: json['noFavorites'] as String,
      goDiscover: json['goDiscover'] as String,
      goDiscoverButton: json['goDiscoverButton'] as String,
      removeFavorite: json['removeFavorite'] as String,
      removeConfirm: json['removeConfirm'] as String,
      removeConfirmMessage: json['removeConfirmMessage'] as String,
      removed: json['removed'] as String,
      operationFailed: json['operationFailed'] as String,
      reload: json['reload'] as String,
      favoriteTime: json['favoriteTime'] as String,
      unknownJob: json['unknownJob'] as String,
    );
  }
}

/// 通知模块文本
class NotificationStrings {
  final String title;
  final String noNotifications;
  final String markAllRead;
  final String noUnreadNotifications;
  final String markAllReadConfirm;
  final String markedAllRead;
  final String operationFailed;
  final String activityDeveloping;
  final String gotIt;
  final String settingsTitle;
  final String pushNotification;
  final String pushNotificationDesc;
  final String notificationTypes;
  final String interviewReminder;
  final String jobStatusUpdate;
  final String columnUpdate;
  final String vipExpireReminder;
  final String activityNotification;
  final String systemAnnouncement;
  final String quietHours;
  final String enableQuietHours;
  final String startTime;
  final String endTime;
  final String settingsSaved;
  
  NotificationStrings({
    required this.title,
    required this.noNotifications,
    required this.markAllRead,
    required this.noUnreadNotifications,
    required this.markAllReadConfirm,
    required this.markedAllRead,
    required this.operationFailed,
    required this.activityDeveloping,
    required this.gotIt,
    required this.settingsTitle,
    required this.pushNotification,
    required this.pushNotificationDesc,
    required this.notificationTypes,
    required this.interviewReminder,
    required this.jobStatusUpdate,
    required this.columnUpdate,
    required this.vipExpireReminder,
    required this.activityNotification,
    required this.systemAnnouncement,
    required this.quietHours,
    required this.enableQuietHours,
    required this.startTime,
    required this.endTime,
    required this.settingsSaved,
  });
  
  factory NotificationStrings.fromJson(Map<String, dynamic> json) {
    return NotificationStrings(
      title: json['title'] as String,
      noNotifications: json['noNotifications'] as String,
      markAllRead: json['markAllRead'] as String,
      noUnreadNotifications: json['noUnreadNotifications'] as String,
      markAllReadConfirm: json['markAllReadConfirm'] as String,
      markedAllRead: json['markedAllRead'] as String,
      operationFailed: json['operationFailed'] as String,
      activityDeveloping: json['activityDeveloping'] as String,
      gotIt: json['gotIt'] as String,
      settingsTitle: json['settingsTitle'] as String,
      pushNotification: json['pushNotification'] as String,
      pushNotificationDesc: json['pushNotificationDesc'] as String,
      notificationTypes: json['notificationTypes'] as String,
      interviewReminder: json['interviewReminder'] as String,
      jobStatusUpdate: json['jobStatusUpdate'] as String,
      columnUpdate: json['columnUpdate'] as String,
      vipExpireReminder: json['vipExpireReminder'] as String,
      activityNotification: json['activityNotification'] as String,
      systemAnnouncement: json['systemAnnouncement'] as String,
      quietHours: json['quietHours'] as String,
      enableQuietHours: json['enableQuietHours'] as String,
      startTime: json['startTime'] as String,
      endTime: json['endTime'] as String,
      settingsSaved: json['settingsSaved'] as String,
    );
  }
}

/// 错误提示文本
class ErrorStrings {
  final String networkError;
  final String saveFailed;
  final String loadFailed;
  final String operationFailed;
  final String operationFailedWithReason;
  
  ErrorStrings({
    required this.networkError,
    required this.saveFailed,
    required this.loadFailed,
    required this.operationFailed,
    required this.operationFailedWithReason,
  });
  
  factory ErrorStrings.fromJson(Map<String, dynamic> json) {
    return ErrorStrings(
      networkError: json['networkError'] as String,
      saveFailed: json['saveFailed'] as String,
      loadFailed: json['loadFailed'] as String,
      operationFailed: json['operationFailed'] as String,
      operationFailedWithReason: json['operationFailedWithReason'] as String,
    );
  }
}

/// 时间格式文本
class TimeStrings {
  final String minutesAgo;
  final String hoursAgo;
  final String daysAgo;
  final String monthDay;
  final String justNow;
  final String yesterday;
  final String thisYear;
  
  TimeStrings({
    required this.minutesAgo,
    required this.hoursAgo,
    required this.daysAgo,
    required this.monthDay,
    required this.justNow,
    required this.yesterday,
    required this.thisYear,
  });
  
  factory TimeStrings.fromJson(Map<String, dynamic> json) {
    return TimeStrings(
      minutesAgo: json['minutesAgo'] as String,
      hoursAgo: json['hoursAgo'] as String,
      daysAgo: json['daysAgo'] as String,
      monthDay: json['monthDay'] as String,
      justNow: json['justNow'] as String,
      yesterday: json['yesterday'] as String,
      thisYear: json['thisYear'] as String,
    );
  }
}

/// 专栏模块文本
class ColumnStrings {
  final String title;
  final String free;
  final String continueReading;
  final String singlePurchase;
  final String buyNow;
  final String purchaseSuccess;
  final String purchaseFailed;
  final String favorited;
  final String unfavorited;
  final String operationFailed;
  final String columnNotFound;
  final String columnRemoved;
  final String columnRemovedTitle;
  final String noFavorites;
  final String goExplore;
  final String goExploreButton;
  final String contentPreview;
  final String previewHint;
  final String unlockContent;
  final String unlockHint;
  final String purchaseHint;
  final String sharePrefix;
  final String unfavoriteConfirm;
  final String unfavoriteConfirmMessage;
  final String myFavorites;
  final String archiveTitle;
  final String archiveSubtitle;
  final String bannerBadge;
  final String bannerTitle;
  final String bannerSubtitle;
  
  ColumnStrings({
    required this.title,
    required this.free,
    required this.continueReading,
    required this.singlePurchase,
    required this.buyNow,
    required this.purchaseSuccess,
    required this.purchaseFailed,
    required this.favorited,
    required this.unfavorited,
    required this.operationFailed,
    required this.columnNotFound,
    required this.columnRemoved,
    required this.columnRemovedTitle,
    required this.noFavorites,
    required this.goExplore,
    required this.goExploreButton,
    required this.contentPreview,
    required this.previewHint,
    required this.unlockContent,
    required this.unlockHint,
    required this.purchaseHint,
    required this.sharePrefix,
    required this.unfavoriteConfirm,
    required this.unfavoriteConfirmMessage,
    required this.myFavorites,
    required this.archiveTitle,
    required this.archiveSubtitle,
    required this.bannerBadge,
    required this.bannerTitle,
    required this.bannerSubtitle,
  });
  
  factory ColumnStrings.fromJson(Map<String, dynamic> json) {
    return ColumnStrings(
      title: json['title'] as String,
      free: json['free'] as String,
      continueReading: json['continueReading'] as String,
      singlePurchase: json['singlePurchase'] as String,
      buyNow: json['buyNow'] as String,
      purchaseSuccess: json['purchaseSuccess'] as String,
      purchaseFailed: json['purchaseFailed'] as String,
      favorited: json['favorited'] as String,
      unfavorited: json['unfavorited'] as String,
      operationFailed: json['operationFailed'] as String,
      columnNotFound: json['columnNotFound'] as String,
      columnRemoved: json['columnRemoved'] as String,
      columnRemovedTitle: json['columnRemovedTitle'] as String,
      noFavorites: json['noFavorites'] as String,
      goExplore: json['goExplore'] as String,
      goExploreButton: json['goExploreButton'] as String,
      contentPreview: json['contentPreview'] as String,
      previewHint: json['previewHint'] as String,
      unlockContent: json['unlockContent'] as String,
      unlockHint: json['unlockHint'] as String,
      purchaseHint: json['purchaseHint'] as String,
      sharePrefix: json['sharePrefix'] as String,
      unfavoriteConfirm: json['unfavoriteConfirm'] as String,
      unfavoriteConfirmMessage: json['unfavoriteConfirmMessage'] as String,
      myFavorites: json['myFavorites'] as String,
      archiveTitle: json['archiveTitle'] as String,
      archiveSubtitle: json['archiveSubtitle'] as String,
      bannerBadge: json['bannerBadge'] as String,
      bannerTitle: json['bannerTitle'] as String,
      bannerSubtitle: json['bannerSubtitle'] as String,
    );
  }
}

/// 公园模块文本
class ParkStrings {
  final String title;
  final String nearbyUsers;
  final String noUsers;
  final String noUsersInZone;
  final String usersWalking;
  final String viewProfile;
  final String sayHello;
  final String sendGift;
  final String friendList;
  final String noFriends;
  final String addFriend;
  final String removeFriend;
  final String removeFriendConfirm;
  final String friendRequestSent;
  final String friendRequestFailed;
  final String postFeed;
  final String noPosts;
  final String publishPost;
  final String like;
  final String comment;
  final String share;
  final String commentHint;
  final String sendComment;
  final String postDetail;
  final String noComments;
  final String beTheFirst;
  final String interactionSuccess;
  final String interactionFailed;
  final String helloSent;
  final String giftSent;
  final String friendAdded;
  final String friendRemoved;
  final String petAction;
  final String greetAction;
  final String giftAction;
  final String likeAction;
  final String viewUserPosts;
  final String youAction;
  
  ParkStrings({
    required this.title,
    required this.nearbyUsers,
    required this.noUsers,
    required this.noUsersInZone,
    required this.usersWalking,
    required this.viewProfile,
    required this.sayHello,
    required this.sendGift,
    required this.friendList,
    required this.noFriends,
    required this.addFriend,
    required this.removeFriend,
    required this.removeFriendConfirm,
    required this.friendRequestSent,
    required this.friendRequestFailed,
    required this.postFeed,
    required this.noPosts,
    required this.publishPost,
    required this.like,
    required this.comment,
    required this.share,
    required this.commentHint,
    required this.sendComment,
    required this.postDetail,
    required this.noComments,
    required this.beTheFirst,
    required this.interactionSuccess,
    required this.interactionFailed,
    required this.helloSent,
    required this.giftSent,
    required this.friendAdded,
    required this.friendRemoved,
    required this.petAction,
    required this.greetAction,
    required this.giftAction,
    required this.likeAction,
    required this.viewUserPosts,
    required this.youAction,
  });
  
  factory ParkStrings.fromJson(Map<String, dynamic> json) {
    return ParkStrings(
      title: json['title'] as String,
      nearbyUsers: json['nearbyUsers'] as String,
      noUsers: json['noUsers'] as String,
      noUsersInZone: json['noUsersInZone'] as String,
      usersWalking: json['usersWalking'] as String,
      viewProfile: json['viewProfile'] as String,
      sayHello: json['sayHello'] as String,
      sendGift: json['sendGift'] as String,
      friendList: json['friendList'] as String,
      noFriends: json['noFriends'] as String,
      addFriend: json['addFriend'] as String,
      removeFriend: json['removeFriend'] as String,
      removeFriendConfirm: json['removeFriendConfirm'] as String,
      friendRequestSent: json['friendRequestSent'] as String,
      friendRequestFailed: json['friendRequestFailed'] as String,
      postFeed: json['postFeed'] as String,
      noPosts: json['noPosts'] as String,
      publishPost: json['publishPost'] as String,
      like: json['like'] as String,
      comment: json['comment'] as String,
      share: json['share'] as String,
      commentHint: json['commentHint'] as String,
      sendComment: json['sendComment'] as String,
      postDetail: json['postDetail'] as String,
      noComments: json['noComments'] as String,
      beTheFirst: json['beTheFirst'] as String,
      interactionSuccess: json['interactionSuccess'] as String,
      interactionFailed: json['interactionFailed'] as String,
      helloSent: json['helloSent'] as String,
      giftSent: json['giftSent'] as String,
      friendAdded: json['friendAdded'] as String,
      friendRemoved: json['friendRemoved'] as String,
      petAction: json['petAction'] as String,
      greetAction: json['greetAction'] as String,
      giftAction: json['giftAction'] as String,
      likeAction: json['likeAction'] as String,
      viewUserPosts: json['viewUserPosts'] as String,
      youAction: json['youAction'] as String,
    );
  }
}

/// 倾诉模块文本
class ConfideStrings {
  final String title;
  final String waitingHint;
  final String messageCountHint;
  final String petInteraction;
  final String petTickle;
  final String inputPlaceholder;
  final String inputHint;
  final String responseTired;
  final String responseInterview;
  final String responseRejected;
  final String responseHappy;
  final String responseLost;
  final String responseDefault1;
  final String responseDefault2;
  final String responseDefault3;
  final String responseDefault4;
  
  ConfideStrings({
    required this.title,
    required this.waitingHint,
    required this.messageCountHint,
    required this.petInteraction,
    required this.petTickle,
    required this.inputPlaceholder,
    required this.inputHint,
    required this.responseTired,
    required this.responseInterview,
    required this.responseRejected,
    required this.responseHappy,
    required this.responseLost,
    required this.responseDefault1,
    required this.responseDefault2,
    required this.responseDefault3,
    required this.responseDefault4,
  });
  
  factory ConfideStrings.fromJson(Map<String, dynamic> json) {
    return ConfideStrings(
      title: json['title'] as String,
      waitingHint: json['waitingHint'] as String,
      messageCountHint: json['messageCountHint'] as String,
      petInteraction: json['petInteraction'] as String,
      petTickle: json['petTickle'] as String,
      inputPlaceholder: json['inputPlaceholder'] as String,
      inputHint: json['inputHint'] as String,
      responseTired: json['responseTired'] as String,
      responseInterview: json['responseInterview'] as String,
      responseRejected: json['responseRejected'] as String,
      responseHappy: json['responseHappy'] as String,
      responseLost: json['responseLost'] as String,
      responseDefault1: json['responseDefault1'] as String,
      responseDefault2: json['responseDefault2'] as String,
      responseDefault3: json['responseDefault3'] as String,
      responseDefault4: json['responseDefault4'] as String,
    );
  }
}

/// 统计模块文本
class StatsStrings {
  final String title;
  final String featureName;
  final String loadFailed;
  final String weeklyTitle;
  final String weeklySubtitle;
  final String weeklySubmissions;
  final String viewed;
  final String interested;
  final String unchanged;
  final String interviewInvites;
  final String newAdd;
  final String none;
  final String weeklyTrend;
  final String achievementBadges;
  final String dayMon;
  final String dayTue;
  final String dayWed;
  final String dayThu;
  final String dayFri;
  final String daySat;
  final String daySun;
  final String badgeFirst;
  final String badgeFirstDesc;
  final String badgeGrowing;
  final String badgeGrowingDesc;
  final String badgeFlourishing;
  final String badgeFlourishingDesc;
  final String badgeDaily;
  final String badgeDailyDesc;
  final String badgePersistent;
  final String badgePersistentDesc;
  final String badgeOffer;
  final String badgeOfferDesc;
  
  StatsStrings({
    required this.title,
    required this.featureName,
    required this.loadFailed,
    required this.weeklyTitle,
    required this.weeklySubtitle,
    required this.weeklySubmissions,
    required this.viewed,
    required this.interested,
    required this.unchanged,
    required this.interviewInvites,
    required this.newAdd,
    required this.none,
    required this.weeklyTrend,
    required this.achievementBadges,
    required this.dayMon,
    required this.dayTue,
    required this.dayWed,
    required this.dayThu,
    required this.dayFri,
    required this.daySat,
    required this.daySun,
    required this.badgeFirst,
    required this.badgeFirstDesc,
    required this.badgeGrowing,
    required this.badgeGrowingDesc,
    required this.badgeFlourishing,
    required this.badgeFlourishingDesc,
    required this.badgeDaily,
    required this.badgeDailyDesc,
    required this.badgePersistent,
    required this.badgePersistentDesc,
    required this.badgeOffer,
    required this.badgeOfferDesc,
  });
  
  factory StatsStrings.fromJson(Map<String, dynamic> json) {
    return StatsStrings(
      title: json['title'] as String,
      featureName: json['featureName'] as String,
      loadFailed: json['loadFailed'] as String,
      weeklyTitle: json['weeklyTitle'] as String,
      weeklySubtitle: json['weeklySubtitle'] as String,
      weeklySubmissions: json['weeklySubmissions'] as String,
      viewed: json['viewed'] as String,
      interested: json['interested'] as String,
      unchanged: json['unchanged'] as String,
      interviewInvites: json['interviewInvites'] as String,
      newAdd: json['newAdd'] as String,
      none: json['none'] as String,
      weeklyTrend: json['weeklyTrend'] as String,
      achievementBadges: json['achievementBadges'] as String,
      dayMon: json['dayMon'] as String,
      dayTue: json['dayTue'] as String,
      dayWed: json['dayWed'] as String,
      dayThu: json['dayThu'] as String,
      dayFri: json['dayFri'] as String,
      daySat: json['daySat'] as String,
      daySun: json['daySun'] as String,
      badgeFirst: json['badgeFirst'] as String,
      badgeFirstDesc: json['badgeFirstDesc'] as String,
      badgeGrowing: json['badgeGrowing'] as String,
      badgeGrowingDesc: json['badgeGrowingDesc'] as String,
      badgeFlourishing: json['badgeFlourishing'] as String,
      badgeFlourishingDesc: json['badgeFlourishingDesc'] as String,
      badgeDaily: json['badgeDaily'] as String,
      badgeDailyDesc: json['badgeDailyDesc'] as String,
      badgePersistent: json['badgePersistent'] as String,
      badgePersistentDesc: json['badgePersistentDesc'] as String,
      badgeOffer: json['badgeOffer'] as String,
      badgeOfferDesc: json['badgeOfferDesc'] as String,
    );
  }
}
