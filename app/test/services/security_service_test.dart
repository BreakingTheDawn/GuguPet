import 'package:flutter_test/flutter_test.dart';
import 'package:jobpet/core/services/security_service.dart';

void main() {
  group('SecurityService 测试', () {
    late SecurityService securityService;

    setUp(() {
      securityService = SecurityService();
    });

    test('数据签名和验证应该成功', () {
      // 准备测试数据
      final data = {
        'userId': 'user_123',
        'vipStatus': true,
        'vipExpireTime': DateTime.now().add(const Duration(days: 30)).toIso8601String(),
      };

      // 添加签名
      final signedData = securityService.addSignature(data);

      // 验证签名
      final isValid = securityService.verifyData(signedData);

      // 断言
      expect(isValid, isTrue);
      expect(signedData.containsKey('_signature'), isTrue);
      expect(signedData.containsKey('_signature_timestamp'), isTrue);
      
      print('✅ 数据签名验证成功');
    });

    test('篡改数据后签名验证应该失败', () {
      // 准备测试数据
      final data = {
        'userId': 'user_123',
        'vipStatus': true,
      };

      // 添加签名
      final signedData = securityService.addSignature(data);

      // 篡改数据
      signedData['vipStatus'] = false;

      // 验证签名
      final isValid = securityService.verifyData(signedData);

      // 断言
      expect(isValid, isFalse);
      
      print('✅ 篡改检测成功');
    });

    test('加密和解密应该成功', () {
      // 准备测试数据
      const plainText = 'my_secret_api_key_12345';

      // 加密
      final encrypted = securityService.encryptData(plainText);

      // 解密
      final decrypted = securityService.decryptData(encrypted);

      // 断言
      expect(decrypted, equals(plainText));
      expect(encrypted, isNot(equals(plainText)));
      
      print('✅ 加密解密成功');
      print('原文: $plainText');
      print('密文: $encrypted');
      print('解密: $decrypted');
    });

    test('不同的数据应该生成不同的签名', () {
      // 准备两组不同的数据
      final data1 = {'userId': 'user_1', 'vipStatus': true};
      final data2 = {'userId': 'user_2', 'vipStatus': true};

      // 生成签名
      final signedData1 = securityService.addSignature(data1);
      final signedData2 = securityService.addSignature(data2);

      // 断言
      expect(
        signedData1['_signature'],
        isNot(equals(signedData2['_signature'])),
      );
      
      print('✅ 不同数据生成不同签名');
    });

    test('VIP状态篡改检测应该正常工作', () async {
      // 测试正常VIP状态
      final normalVip = await securityService.detectVipTampering(
        'user_123',
        true,
        DateTime.now().add(const Duration(days: 30)),
      );
      expect(normalVip, isFalse);
      
      print('✅ 正常VIP状态检测通过');

      // 测试异常VIP状态（过期时间太远）
      final abnormalVip = await securityService.detectVipTampering(
        'user_456',
        true,
        DateTime.now().add(const Duration(days: 1000)), // 超过2年
      );
      expect(abnormalVip, isTrue);
      
      print('✅ 异常VIP状态检测成功');
    });

    test('设备指纹生成应该成功', () async {
      // 生成设备指纹
      final fingerprint1 = await securityService.getDeviceFingerprint();
      final fingerprint2 = await securityService.getDeviceFingerprint();

      // 断言
      expect(fingerprint1, isNotEmpty);
      expect(fingerprint1, equals(fingerprint2)); // 同一设备应该生成相同的指纹
      
      print('✅ 设备指纹生成成功');
      print('设备指纹: $fingerprint1');
    });
  });

  group('SecurityService 边界测试', () {
    late SecurityService securityService;

    setUp(() {
      securityService = SecurityService();
    });

    test('空数据签名应该成功', () {
      final data = <String, dynamic>{};
      
      final signedData = securityService.addSignature(data);
      final isValid = securityService.verifyData(signedData);
      
      expect(isValid, isTrue);
      print('✅ 空数据签名验证成功');
    });

    test('复杂嵌套数据签名应该成功', () {
      final data = {
        'user': {
          'id': '123',
          'name': 'Test User',
          'vip': {
            'status': true,
            'level': 2,
          },
        },
        'items': ['item1', 'item2', 'item3'],
      };
      
      final signedData = securityService.addSignature(data);
      final isValid = securityService.verifyData(signedData);
      
      expect(isValid, isTrue);
      print('✅ 复杂嵌套数据签名验证成功');
    });

    test('长文本加密解密应该成功', () {
      // 生成一个长文本
      final plainText = 'A' * 10000;
      
      final encrypted = securityService.encryptData(plainText);
      final decrypted = securityService.decryptData(encrypted);
      
      expect(decrypted, equals(plainText));
      print('✅ 长文本加密解密成功 (长度: ${plainText.length})');
    });

    test('特殊字符加密解密应该成功', () {
      const plainText = '特殊字符测试: 中文、emoji😀、符号!@#¥%……&*()';
      
      final encrypted = securityService.encryptData(plainText);
      final decrypted = securityService.decryptData(encrypted);
      
      expect(decrypted, equals(plainText));
      print('✅ 特殊字符加密解密成功');
      print('原文: $plainText');
    });
  });
}
