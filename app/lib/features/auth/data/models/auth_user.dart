/// 认证用户模型
/// 用于存储用户登录相关的信息
class AuthUser {
  /// 用户唯一标识
  final String userId;
  
  /// 登录账号
  final String account;
  
  /// 用户昵称
  final String userName;
  
  /// 是否已登录
  final bool isLoggedIn;
  
  /// 创建时间
  final DateTime? createdAt;
  
  const AuthUser({
    required this.userId,
    required this.account,
    required this.userName,
    this.isLoggedIn = false,
    this.createdAt,
  });
  
  /// 从数据库Map创建实例
  factory AuthUser.fromDatabase(Map<String, dynamic> map) {
    return AuthUser(
      userId: map['user_id'] as String,
      account: map['account'] as String,
      userName: map['user_name'] as String,
      isLoggedIn: (map['is_logged_in'] as int?) == 1,
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'] as String)
          : null,
    );
  }
  
  /// 转换为数据库Map
  Map<String, dynamic> toDatabaseMap() {
    return {
      'user_id': userId,
      'account': account,
      'user_name': userName,
      'is_logged_in': isLoggedIn ? 1 : 0,
      'created_at': createdAt?.toIso8601String(),
    };
  }
  
  /// 复制并更新字段
  AuthUser copyWith({
    String? userId,
    String? account,
    String? userName,
    bool? isLoggedIn,
    DateTime? createdAt,
  }) {
    return AuthUser(
      userId: userId ?? this.userId,
      account: account ?? this.account,
      userName: userName ?? this.userName,
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
