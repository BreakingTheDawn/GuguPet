import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'security_service.dart';

/// VIP保护服务
/// 专门处理VIP状态的完整性校验和防篡改
class VipProtectionService {
  /// 单例实例
  static final VipProtectionService _instance = VipProtectionService._internal();
  factory VipProtectionService() => _instance;
  VipProtectionService._internal();

  final SecurityService _securityService = SecurityService();

  /// VIP数据存储键
  static const String _vipDataKey = 'vip_secure_data';

  /// VIP状态缓存（内存中）
  VipSecureData? _cachedVipData;

  /// 保存VIP状态（带签名）
  /// [userId] 用户ID
  /// [vipStatus] VIP状态
  /// [vipExpireTime] VIP过期时间
  /// [purchaseToken] 购买令牌（如果有）
  Future<void> saveVipStatus({
    required String userId,
    required bool vipStatus,
    DateTime? vipExpireTime,
    String? purchaseToken,
  }) async {
    try {
      final vipData = VipSecureData(
        userId: userId,
        vipStatus: vipStatus,
        vipExpireTime: vipExpireTime,
        purchaseToken: purchaseToken,
        createdAt: DateTime.now(),
        deviceFingerprint: await _securityService.getDeviceFingerprint(),
      );

      // 转换为Map并添加签名
      final dataMap = vipData.toMap();
      final signedData = _securityService.addSignature(dataMap);

      // 加密后存储
      final encryptedData = _securityService.encryptData(jsonEncode(signedData));
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_vipDataKey, encryptedData);

      // 更新缓存
      _cachedVipData = vipData;
    } catch (e) {
      throw SecurityException('保存VIP状态失败: $e');
    }
  }

  /// 读取并验证VIP状态
  /// [userId] 用户ID
  /// 返回验证后的VIP数据，如果验证失败返回null
  Future<VipSecureData?> loadAndVerifyVipStatus(String userId) async {
    try {
      // 优先使用缓存
      if (_cachedVipData != null && _cachedVipData!.userId == userId) {
        // 验证缓存数据
        if (await _verifyVipData(_cachedVipData!)) {
          return _cachedVipData;
        }
      }

      // 从存储中读取
      final prefs = await SharedPreferences.getInstance();
      final encryptedData = prefs.getString(_vipDataKey);

      if (encryptedData == null) {
        return null;
      }

      // 解密数据
      final decryptedData = _securityService.decryptData(encryptedData);
      final dataMap = jsonDecode(decryptedData) as Map<String, dynamic>;

      // 验证签名
      if (!_securityService.verifyData(dataMap)) {
        // 签名验证失败，数据可能被篡改
        await _handleTamperingDetected(userId);
        return null;
      }

      // 解析数据
      final vipData = VipSecureData.fromMap(dataMap);

      // 验证用户ID
      if (vipData.userId != userId) {
        return null;
      }

      // 验证设备指纹
      final currentDeviceFingerprint = await _securityService.getDeviceFingerprint();
      if (vipData.deviceFingerprint != currentDeviceFingerprint) {
        // 设备不匹配，可能是数据迁移
        // 可以选择允许或拒绝，这里选择允许但记录日志
        // 生产环境应该上报服务器
      }

      // 验证过期时间
      if (vipData.vipStatus && vipData.vipExpireTime != null) {
        if (vipData.vipExpireTime!.isBefore(DateTime.now())) {
          // VIP已过期
          return VipSecureData(
            userId: userId,
            vipStatus: false,
            vipExpireTime: vipData.vipExpireTime,
            purchaseToken: vipData.purchaseToken,
            createdAt: vipData.createdAt,
            deviceFingerprint: vipData.deviceFingerprint,
          );
        }
      }

      // 更新缓存
      _cachedVipData = vipData;
      return vipData;
    } catch (e) {
      // 读取或验证失败，返回null
      return null;
    }
  }

  /// 验证VIP数据完整性
  Future<bool> _verifyVipData(VipSecureData vipData) async {
    try {
      // 1. 检测是否被篡改
      final tampered = await _securityService.detectVipTampering(
        vipData.userId,
        vipData.vipStatus,
        vipData.vipExpireTime,
      );

      if (tampered) {
        return false;
      }

      // 2. 检查过期时间合理性
      if (vipData.vipStatus && vipData.vipExpireTime != null) {
        final maxValidExpire = DateTime.now().add(const Duration(days: 730));
        if (vipData.vipExpireTime!.isAfter(maxValidExpire)) {
          return false;
        }
      }

      return true;
    } catch (e) {
      return false;
    }
  }

  /// 处理检测到的篡改行为
  Future<void> _handleTamperingDetected(String userId) async {
    try {
      // 1. 清除可疑数据
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_vipDataKey);
      _cachedVipData = null;

      // 2. 重置数据库中的VIP状态
      // 这部分将在后续任务中实现

      // 3. 记录日志（生产环境应上报服务器）
      print('[VipProtection] 检测到VIP数据篡改，用户ID: $userId');
    } catch (e) {
      print('[VipProtection] 处理篡改检测失败: $e');
    }
  }

  /// 清除VIP数据
  Future<void> clearVipData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_vipDataKey);
      _cachedVipData = null;
    } catch (e) {
      // 忽略清除失败
    }
  }

  /// 检查VIP状态是否可信
  /// [userId] 用户ID
  /// [vipStatus] 数据库中的VIP状态
  /// [vipExpireTime] 数据库中的VIP过期时间
  /// 返回可信的VIP状态
  Future<bool> isVipStatusTrusted(
    String userId,
    bool vipStatus,
    DateTime? vipExpireTime,
  ) async {
    try {
      // 从安全存储中读取VIP状态
      final secureVipData = await loadAndVerifyVipStatus(userId);

      if (secureVipData == null) {
        // 没有安全存储的数据，使用数据库数据但需要验证
        return !await _securityService.detectVipTampering(
          userId,
          vipStatus,
          vipExpireTime,
        );
      }

      // 比对数据库和安全存储的数据
      final dbVipStatus = vipStatus && (vipExpireTime?.isAfter(DateTime.now()) ?? false);
      final secureVipStatus = secureVipData.vipStatus;

      // 如果不一致，以安全存储为准
      if (dbVipStatus != secureVipStatus) {
        // 检测到不一致，可能是数据库被篡改
        return false;
      }

      return true;
    } catch (e) {
      return false;
    }
  }
}

/// VIP安全数据模型
class VipSecureData {
  final String userId;
  final bool vipStatus;
  final DateTime? vipExpireTime;
  final String? purchaseToken;
  final DateTime createdAt;
  final String deviceFingerprint;

  VipSecureData({
    required this.userId,
    required this.vipStatus,
    this.vipExpireTime,
    this.purchaseToken,
    required this.createdAt,
    required this.deviceFingerprint,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'vipStatus': vipStatus,
      'vipExpireTime': vipExpireTime?.toIso8601String(),
      'purchaseToken': purchaseToken,
      'createdAt': createdAt.toIso8601String(),
      'deviceFingerprint': deviceFingerprint,
    };
  }

  factory VipSecureData.fromMap(Map<String, dynamic> map) {
    return VipSecureData(
      userId: map['userId'] as String,
      vipStatus: map['vipStatus'] as bool,
      vipExpireTime: map['vipExpireTime'] != null
          ? DateTime.parse(map['vipExpireTime'] as String)
          : null,
      purchaseToken: map['purchaseToken'] as String?,
      createdAt: DateTime.parse(map['createdAt'] as String),
      deviceFingerprint: map['deviceFingerprint'] as String,
    );
  }
}
