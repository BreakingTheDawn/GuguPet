import 'package:flutter_test/flutter_test.dart';
import 'package:jobpet/data/models/user_profile.dart';
import '../helpers/mock_factories.dart';

/// UserProfile 模型单元测试
void main() {
  group('UserProfile Model Tests', () {
    
    group('构造函数测试', () {
      test('应该正确创建UserProfile实例', () {
        final profile = MockFactories.createTestUserProfile();

        expect(profile.userId, equals('test_user_001'));
        expect(profile.userName, equals('测试用户'));
        expect(profile.jobIntention, equals('产品经理'));
        expect(profile.city, equals('北京'));
        expect(profile.salaryExpect, equals('15k-25k'));
        expect(profile.vipStatus, isFalse);
        expect(profile.isOnboarded, isTrue);
        expect(profile.industryTag, equals('互联网'));
      });

      test('应该使用默认值创建UserProfile', () {
        final profile = UserProfile(
          userId: 'test_id',
          userName: '测试',
        );

        expect(profile.vipStatus, isFalse);
        expect(profile.vipExpireTime, isNull);
        expect(profile.isOnboarded, isFalse);
        expect(profile.petMemory, isEmpty);
      });

      test('应该正确创建VIP用户', () {
        final vipProfile = MockFactories.createVipUserProfile(vipDays: 365);

        expect(vipProfile.vipStatus, isTrue);
        expect(vipProfile.vipExpireTime, isNotNull);
        
        final daysRemaining = vipProfile.vipExpireTime!.difference(DateTime.now()).inDays;
        expect(daysRemaining, closeTo(365, 1));
      });
    });

    group('toJson序列化测试', () {
      test('应该正确序列化为JSON', () {
        final profile = MockFactories.createTestUserProfile(
          userId: 'user_123',
          userName: '张三',
          jobIntention: '前端开发',
          city: '上海',
          salaryExpect: '20k-30k',
        );

        final json = profile.toJson();

        expect(json['userId'], equals('user_123'));
        expect(json['userName'], equals('张三'));
        expect(json['jobIntention'], equals('前端开发'));
        expect(json['city'], equals('上海'));
        expect(json['salaryExpect'], equals('20k-30k'));
        expect(json['vipStatus'], isFalse);
        expect(json['isOnboarded'], isTrue);
      });

      test('VIP用户应该正确序列化VIP信息', () {
        final vipProfile = MockFactories.createVipUserProfile();
        final json = vipProfile.toJson();

        expect(json['vipStatus'], isTrue);
        expect(json['vipExpireTime'], isNotNull);
      });

      test('空值字段应该正确序列化', () {
        final profile = UserProfile(
          userId: 'test',
          userName: '测试',
        );

        final json = profile.toJson();

        expect(json['jobIntention'], isNull);
        expect(json['city'], isNull);
        expect(json['salaryExpect'], isNull);
        expect(json['vipExpireTime'], isNull);
      });
    });

    group('fromJson反序列化测试', () {
      test('应该正确从JSON反序列化', () {
        final json = MockFactories.createTestUserProfileJson(
          userId: 'user_456',
          userName: '李四',
        );

        final profile = UserProfile.fromJson(json);

        expect(profile.userId, equals('user_456'));
        expect(profile.userName, equals('李四'));
        expect(profile.jobIntention, equals('产品经理'));
        expect(profile.city, equals('北京'));
      });

      test('VIP状态应该正确反序列化', () {
        final vipExpireTime = DateTime.now().add(Duration(days: 100));
        final json = {
          'userId': 'vip_user',
          'userName': 'VIP用户',
          'vipStatus': true,
          'vipExpireTime': vipExpireTime.toIso8601String(),
          'petMemory': <dynamic>[],
        };

        final profile = UserProfile.fromJson(json);

        expect(profile.vipStatus, isTrue);
        expect(profile.vipExpireTime, isNotNull);
      });

      test('缺失字段应该使用默认值', () {
        final json = {
          'userId': 'test_user',
          'userName': '测试',
        };

        final profile = UserProfile.fromJson(json);

        expect(profile.vipStatus, isFalse);
        expect(profile.isOnboarded, isFalse);
        expect(profile.petMemory, isEmpty);
      });
    });

    group('createDefault工厂方法测试', () {
      test('应该创建默认用户档案', () {
        final profile = UserProfile.createDefault('new_user', '新用户');

        expect(profile.userId, equals('new_user'));
        expect(profile.userName, equals('新用户'));
        expect(profile.vipStatus, isFalse);
        expect(profile.isOnboarded, isFalse);
        expect(profile.petMemory, isEmpty);
      });
    });

    group('PetMemory测试', () {
      test('应该正确序列化PetMemory列表', () {
        final memory = PetMemory(
          type: 'interaction',
          key: 'favorite_food',
          value: '小鱼干',
          source: 'user_input',
          createdAt: DateTime.now(),
        );

        final profile = UserProfile(
          userId: 'test',
          userName: '测试',
          petMemory: [memory],
        );

        final json = profile.toJson();
        expect(json['petMemory'], isA<List>());
        expect((json['petMemory'] as List).length, equals(1));
      });

      test('应该正确反序列化PetMemory', () {
        final now = DateTime.now().toIso8601String();
        final json = {
          'userId': 'test',
          'userName': '测试',
          'petMemory': [
            {
              'type': 'interaction',
              'key': 'favorite_food',
              'value': '小鱼干',
              'source': 'user_input',
              'createdAt': now,
            }
          ],
        };

        final profile = UserProfile.fromJson(json);

        expect(profile.petMemory.length, equals(1));
        expect(profile.petMemory[0].type, equals('interaction'));
        expect(profile.petMemory[0].key, equals('favorite_food'));
        expect(profile.petMemory[0].value, equals('小鱼干'));
      });
    });

    group('边界条件测试', () {
      test('空字符串应该正确处理', () {
        final profile = UserProfile(
          userId: '',
          userName: '',
          jobIntention: '',
          city: '',
        );

        expect(profile.userId, isEmpty);
        expect(profile.userName, isEmpty);
      });

      test('特殊字符应该正确处理', () {
        final profile = UserProfile(
          userId: 'user_测试_123',
          userName: '用户<>&"\'特殊字符',
          jobIntention: '产品经理/设计师',
        );

        final json = profile.toJson();
        final decoded = UserProfile.fromJson(json);

        expect(decoded.userId, equals('user_测试_123'));
        expect(decoded.userName, equals('用户<>&"\'特殊字符'));
        expect(decoded.jobIntention, equals('产品经理/设计师'));
      });
    });
  });
}
