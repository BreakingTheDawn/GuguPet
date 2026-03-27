import 'package:flutter_test/flutter_test.dart';
import 'package:jobpet/data/models/user_profile.dart';

/// VIP功能单元测试
void main() {
  group('UserProfile VIP状态测试', () {
    group('VIP有效性检查', () {
      test('非VIP用户应该返回无效', () {
        final user = UserProfile(
          userId: 'normal_user',
          userName: '普通用户',
          vipStatus: false,
        );

        expect(user.isVipValid, isFalse);
      });

      test('VIP用户且未过期应该返回有效', () {
        final user = UserProfile(
          userId: 'vip_user',
          userName: 'VIP用户',
          vipStatus: true,
          vipExpireTime: DateTime.now().add(Duration(days: 30)),
        );

        expect(user.isVipValid, isTrue);
      });

      test('VIP用户但已过期应该返回无效', () {
        final user = UserProfile(
          userId: 'expired_vip_user',
          userName: '过期VIP用户',
          vipStatus: true,
          vipExpireTime: DateTime.now().subtract(Duration(days: 1)),
        );

        expect(user.isVipValid, isFalse);
      });

      test('VIP状态为true但无过期时间应该返回无效', () {
        final user = UserProfile(
          userId: 'invalid_vip_user',
          userName: '无效VIP用户',
          vipStatus: true,
          vipExpireTime: null,
        );

        expect(user.isVipValid, isFalse);
      });

      test('VIP刚好今天过期应该返回无效', () {
        final user = UserProfile(
          userId: 'today_expire_user',
          userName: '今天过期用户',
          vipStatus: true,
          vipExpireTime: DateTime.now().subtract(Duration(seconds: 1)),
        );

        expect(user.isVipValid, isFalse);
      });
    });

    group('VIP剩余天数计算', () {
      test('非VIP用户剩余天数应该为0', () {
        final user = UserProfile(
          userId: 'normal_user',
          userName: '普通用户',
          vipStatus: false,
        );

        expect(user.vipRemainingDays, equals(0));
      });

      test('VIP用户剩余30天应该返回30', () {
        final user = UserProfile(
          userId: 'vip_30_days',
          userName: 'VIP用户30天',
          vipStatus: true,
          vipExpireTime: DateTime.now().add(Duration(days: 30)),
        );

        expect(user.vipRemainingDays, closeTo(30, 1));
      });

      test('VIP用户剩余365天应该返回365', () {
        final user = UserProfile(
          userId: 'vip_365_days',
          userName: 'VIP用户365天',
          vipStatus: true,
          vipExpireTime: DateTime.now().add(Duration(days: 365)),
        );

        expect(user.vipRemainingDays, closeTo(365, 1));
      });

      test('过期VIP用户剩余天数应该为0', () {
        final user = UserProfile(
          userId: 'expired_vip',
          userName: '过期VIP用户',
          vipStatus: true,
          vipExpireTime: DateTime.now().subtract(Duration(days: 10)),
        );

        expect(user.vipRemainingDays, equals(0));
      });

      test('VIP剩余1天应该返回1', () {
        final user = UserProfile(
          userId: 'vip_1_day',
          userName: 'VIP用户1天',
          vipStatus: true,
          vipExpireTime: DateTime.now().add(Duration(hours: 25)),
        );

        expect(user.vipRemainingDays, greaterThanOrEqualTo(1));
      });
    });

    group('VIP状态更新', () {
      test('copyWith应该正确更新VIP状态', () {
        final original = UserProfile(
          userId: 'user_001',
          userName: '测试用户',
          vipStatus: false,
        );

        final updated = original.copyWith(
          vipStatus: true,
          vipExpireTime: Optional(DateTime.now().add(Duration(days: 30))),
        );

        expect(original.vipStatus, isFalse); // 原对象不变
        expect(updated.vipStatus, isTrue);
        expect(updated.vipExpireTime, isNotNull);
      });

      test('copyWith应该正确清除VIP状态', () {
        final original = UserProfile(
          userId: 'user_002',
          userName: 'VIP用户',
          vipStatus: true,
          vipExpireTime: DateTime.now().add(Duration(days: 30)),
        );

        final updated = original.copyWith(
          vipStatus: false,
          vipExpireTime: Optional.nullValue(),
        );

        expect(updated.vipStatus, isFalse);
        expect(updated.vipExpireTime, isNull);
        expect(updated.isVipValid, isFalse);
      });

      test('copyWith不传VIP参数应该保持原值', () {
        final original = UserProfile(
          userId: 'user_003',
          userName: 'VIP用户',
          vipStatus: true,
          vipExpireTime: DateTime.now().add(Duration(days: 30)),
        );

        final updated = original.copyWith(userName: '新用户名');

        expect(updated.vipStatus, isTrue);
        expect(updated.vipExpireTime, isNotNull);
      });
    });

    group('VIP序列化测试', () {
      test('VIP用户应该正确序列化', () {
        final vipExpireTime = DateTime.now().add(Duration(days: 100));
        final user = UserProfile(
          userId: 'vip_serial_user',
          userName: 'VIP序列化测试',
          vipStatus: true,
          vipExpireTime: vipExpireTime,
        );

        final json = user.toJson();

        expect(json['vipStatus'], isTrue);
        expect(json['vipExpireTime'], isNotNull);
        
        final restored = UserProfile.fromJson(json);
        expect(restored.vipStatus, isTrue);
        expect(restored.vipExpireTime, isNotNull);
      });

      test('非VIP用户应该正确序列化', () {
        final user = UserProfile(
          userId: 'normal_serial_user',
          userName: '普通序列化测试',
          vipStatus: false,
        );

        final json = user.toJson();
        final restored = UserProfile.fromJson(json);

        expect(restored.vipStatus, isFalse);
        expect(restored.vipExpireTime, isNull);
      });

      test('缺失VIP字段应该使用默认值', () {
        final json = {
          'userId': 'default_vip_user',
          'userName': '默认VIP测试',
        };

        final user = UserProfile.fromJson(json);

        expect(user.vipStatus, isFalse);
        expect(user.vipExpireTime, isNull);
        expect(user.isVipValid, isFalse);
      });
    });

    group('VIP边界条件测试', () {
      test('VIP过期时间为当前时间应该返回无效', () {
        final now = DateTime.now();
        final user = UserProfile(
          userId: 'edge_vip_user',
          userName: '边界VIP用户',
          vipStatus: true,
          vipExpireTime: now,
        );

        // 过期时间等于当前时间，已经过期
        expect(user.isVipValid, isFalse);
      });

      test('VIP过期时间为未来1秒应该返回有效', () {
        final user = UserProfile(
          userId: 'future_vip_user',
          userName: '未来VIP用户',
          vipStatus: true,
          vipExpireTime: DateTime.now().add(Duration(seconds: 1)),
        );

        expect(user.isVipValid, isTrue);
      });

      test('超长VIP期限应该正确处理', () {
        final user = UserProfile(
          userId: 'long_vip_user',
          userName: '长期VIP用户',
          vipStatus: true,
          vipExpireTime: DateTime.now().add(Duration(days: 36500)), // 100年
        );

        expect(user.isVipValid, isTrue);
        expect(user.vipRemainingDays, greaterThan(36000));
      });
    });
  });
}
