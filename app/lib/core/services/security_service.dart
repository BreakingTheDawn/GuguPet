import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:device_info_plus/device_info_plus.dart';

/// 安全服务
/// 提供数据加密、完整性校验、防篡改检测等功能
class SecurityService {
  /// 单例实例
  static final SecurityService _instance = SecurityService._internal();
  factory SecurityService() => _instance;
  SecurityService._internal();

  /// 安全存储实例
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );

  /// 应用签名密钥（实际应用中应从服务器获取或编译时注入）
  /// 注意：这是一个示例密钥，生产环境应使用更安全的密钥管理方案
  static const String _signingSecret = 'gugupet_secure_signing_key_2024';

  /// 设备信息
  DeviceInfoPlugin? _deviceInfo;
  bool? _isRooted;

  /// 初始化安全服务
  Future<void> initialize() async {
    _deviceInfo = DeviceInfoPlugin();
    await _checkDeviceSecurity();
  }

  /// 检查设备安全性（Root/越狱检测）
  Future<bool> isDeviceSecure() async {
    if (_isRooted == null) {
      await _checkDeviceSecurity();
    }
    return !(_isRooted ?? false);
  }

  /// 检测设备是否Root/越狱
  Future<void> _checkDeviceSecurity() async {
    try {
      if (Platform.isAndroid) {
        _isRooted = await _checkAndroidRoot();
      } else if (Platform.isIOS) {
        _isRooted = await _checkIOSJailbreak();
      } else {
        _isRooted = false;
      }
    } catch (e) {
      // 检测失败时假设设备安全
      _isRooted = false;
    }
  }

  /// Android Root检测
  Future<bool> _checkAndroidRoot() async {
    try {
      // 检查常见的Root文件路径
      final rootPaths = [
        '/system/app/Superuser.apk',
        '/sbin/su',
        '/system/bin/su',
        '/system/xbin/su',
        '/data/local/xbin/su',
        '/data/local/bin/su',
        '/system/sd/xbin/su',
        '/system/bin/failsafe/su',
        '/data/local/su',
        '/su/bin/su',
      ];

      for (final path in rootPaths) {
        final file = File(path);
        if (await file.exists()) {
          return true;
        }
      }

      // 检查su命令是否可用
      try {
        final result = await Process.run('which', ['su']);
        if (result.exitCode == 0) {
          return true;
        }
      } catch (e) {
        // which命令不可用，忽略
      }

      return false;
    } catch (e) {
      return false;
    }
  }

  /// iOS越狱检测
  Future<bool> _checkIOSJailbreak() async {
    try {
      // 检查常见的越狱文件路径
      final jailbreakPaths = [
        '/Applications/Cydia.app',
        '/Library/MobileSubstrate/MobileSubstrate.dylib',
        '/bin/bash',
        '/usr/sbin/sshd',
        '/etc/apt',
        '/private/var/lib/apt/',
      ];

      for (final path in jailbreakPaths) {
        final file = File(path);
        if (await file.exists()) {
          return true;
        }
      }

      // 检查是否能访问沙盒外的路径
      try {
        final file = File('/private/jailbreak_test.txt');
        await file.writeAsString('test');
        await file.delete();
        return true;
      } catch (e) {
        // 无法写入，设备安全
      }

      return false;
    } catch (e) {
      return false;
    }
  }

  // ==================== 数据签名与验证 ====================

  /// 为数据生成HMAC签名
  /// [data] 需要签名的数据（Map格式）
  /// 返回签名字符串
  String signData(Map<String, dynamic> data) {
    try {
      // 移除已有的签名字段
      final dataToSign = Map<String, dynamic>.from(data);
      dataToSign.remove('_signature');
      dataToSign.remove('_signature_timestamp');

      // 按键排序并序列化
      final sortedJson = _sortAndSerialize(dataToSign);
      
      // 生成HMAC签名
      final key = utf8.encode(_signingSecret);
      final bytes = utf8.encode(sortedJson);
      final hmac = Hmac(sha256, key);
      final digest = hmac.convert(bytes);
      
      return digest.toString();
    } catch (e) {
      throw SecurityException('数据签名失败: $e');
    }
  }

  /// 验证数据签名
  /// [data] 包含签名的数据（Map格式）
  /// 返回签名是否有效
  bool verifyData(Map<String, dynamic> data) {
    try {
      final signature = data['_signature'] as String?;
      if (signature == null) {
        return false;
      }

      // 重新生成签名并比对
      final expectedSignature = signData(data);
      return signature == expectedSignature;
    } catch (e) {
      return false;
    }
  }

  /// 为数据添加签名和时间戳
  /// [data] 需要签名的数据
  /// 返回带签名的数据
  Map<String, dynamic> addSignature(Map<String, dynamic> data) {
    final signedData = Map<String, dynamic>.from(data);
    signedData['_signature_timestamp'] = DateTime.now().millisecondsSinceEpoch;
    signedData['_signature'] = signData(signedData);
    return signedData;
  }

  /// 排序并序列化数据（用于签名）
  String _sortAndSerialize(Map<String, dynamic> data) {
    final sortedKeys = data.keys.toList()..sort();
    final buffer = StringBuffer();
    
    for (final key in sortedKeys) {
      final value = data[key];
      buffer.write('$key=');
      
      if (value is Map<String, dynamic>) {
        buffer.write(_sortAndSerialize(value));
      } else if (value is List) {
        buffer.write(jsonEncode(value));
      } else {
        buffer.write(value?.toString() ?? '');
      }
      buffer.write('&');
    }
    
    return buffer.toString();
  }

  // ==================== 安全存储 ====================

  /// 安全存储敏感数据
  /// [key] 存储键
  /// [value] 存储值
  Future<void> secureWrite(String key, String value) async {
    try {
      await _secureStorage.write(key: key, value: value);
    } catch (e) {
      throw SecurityException('安全存储失败: $e');
    }
  }

  /// 安全读取敏感数据
  /// [key] 存储键
  /// 返回存储的值，不存在返回null
  Future<String?> secureRead(String key) async {
    try {
      return await _secureStorage.read(key: key);
    } catch (e) {
      throw SecurityException('安全读取失败: $e');
    }
  }

  /// 删除安全存储的数据
  /// [key] 存储键
  Future<void> secureDelete(String key) async {
    try {
      await _secureStorage.delete(key: key);
    } catch (e) {
      throw SecurityException('安全删除失败: $e');
    }
  }

  // ==================== 数据加密与解密 ====================

  /// 加密字符串数据
  /// [plainText] 明文
  /// 返回加密后的Base64字符串
  String encryptData(String plainText) {
    try {
      final key = utf8.encode(_signingSecret);
      final bytes = utf8.encode(plainText);
      
      // 使用简单的XOR加密（生产环境应使用AES等强加密算法）
      final encrypted = <int>[];
      for (var i = 0; i < bytes.length; i++) {
        encrypted.add(bytes[i] ^ key[i % key.length]);
      }
      
      return base64Encode(encrypted);
    } catch (e) {
      throw SecurityException('数据加密失败: $e');
    }
  }

  /// 解密字符串数据
  /// [encryptedText] 加密的Base64字符串
  /// 返回解密后的明文
  String decryptData(String encryptedText) {
    try {
      final key = utf8.encode(_signingSecret);
      final bytes = base64Decode(encryptedText);
      
      // 使用简单的XOR解密
      final decrypted = <int>[];
      for (var i = 0; i < bytes.length; i++) {
        decrypted.add(bytes[i] ^ key[i % key.length]);
      }
      
      return utf8.decode(decrypted);
    } catch (e) {
      throw SecurityException('数据解密失败: $e');
    }
  }

  // ==================== 异常检测 ====================

  /// 检测VIP状态是否被篡改
  /// [userId] 用户ID
  /// [vipStatus] VIP状态
  /// [vipExpireTime] VIP过期时间
  /// 返回是否检测到异常
  Future<bool> detectVipTampering(
    String userId,
    bool vipStatus,
    DateTime? vipExpireTime,
  ) async {
    try {
      // 1. 检查设备是否Root
      if (!await isDeviceSecure()) {
        // Root设备上的VIP状态不可信
        // 可以选择记录日志或上报服务器
        return true;
      }

      // 2. 检查VIP状态的合理性
      if (vipStatus && vipExpireTime != null) {
        // VIP过期时间在未来太远（超过2年）可能是篡改
        final maxValidExpire = DateTime.now().add(const Duration(days: 730));
        if (vipExpireTime.isAfter(maxValidExpire)) {
          return true;
        }

        // 检查是否有对应的购买记录（如果有服务器端验证）
        // 这里暂时跳过，后续可以添加服务器验证
      }

      return false;
    } catch (e) {
      // 检测失败时假设数据正常
      return false;
    }
  }

  /// 获取设备唯一标识（用于数据绑定）
  /// 返回设备指纹
  Future<String> getDeviceFingerprint() async {
    try {
      final buffer = StringBuffer();

      if (Platform.isAndroid && _deviceInfo != null) {
        final info = await _deviceInfo!.androidInfo;
        buffer.write(info.brand);
        buffer.write(info.manufacturer);
        buffer.write(info.model);
        buffer.write(info.device);
        buffer.write(info.hardware);
      } else if (Platform.isIOS && _deviceInfo != null) {
        final info = await _deviceInfo!.iosInfo;
        buffer.write(info.name);
        buffer.write(info.model);
        buffer.write(info.systemName);
        buffer.write(info.systemVersion);
      }

      // 生成指纹哈希
      final bytes = utf8.encode(buffer.toString());
      final digest = sha256.convert(bytes);
      return digest.toString().substring(0, 16);
    } catch (e) {
      // 获取失败时返回默认值
      return 'unknown_device';
    }
  }
}

/// 安全异常
class SecurityException implements Exception {
  final String message;
  SecurityException(this.message);

  @override
  String toString() => 'SecurityException: $message';
}
