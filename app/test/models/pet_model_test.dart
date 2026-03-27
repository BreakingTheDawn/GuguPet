import 'package:flutter_test/flutter_test.dart';
import 'package:jobpet/features/pet/data/models/pet_model.dart';
import 'package:jobpet/features/pet/data/models/pet_emotion.dart';
import '../helpers/mock_factories.dart';

/// PetModel 模型单元测试
void main() {
  group('PetModel Model Tests', () {

    group('构造函数测试', () {
      test('应该正确创建PetModel实例', () {
        final pet = MockFactories.createTestPetModel(
          petId: 'pet_001',
          userId: 'user_001',
          name: '咕咕',
          currentEmotion: PetEmotionType.happy,
          emotionValue: 80,
          bondLevel: 2,
          bondExp: 50.5,
        );

        expect(pet.petId, equals('pet_001'));
        expect(pet.userId, equals('user_001'));
        expect(pet.name, equals('咕咕'));
        expect(pet.currentEmotion, equals(PetEmotionType.happy));
        expect(pet.emotionValue, equals(80));
        expect(pet.bondLevel, equals(2));
        expect(pet.bondExp, equals(50.5));
      });

      test('应该使用默认值创建PetModel', () {
        final now = DateTime.now();
        final pet = PetModel(
          petId: 'test_pet',
          userId: 'test_user',
          lastInteractionTime: now,
          createdAt: now,
          updatedAt: now,
        );

        expect(pet.name, equals('咕咕'));
        expect(pet.currentEmotion, equals(PetEmotionType.normal));
        expect(pet.emotionValue, equals(50));
        expect(pet.bondLevel, equals(1));
        expect(pet.bondExp, equals(0));
        expect(pet.stats, isEmpty);
      });
    });

    group('toJson序列化测试', () {
      test('应该正确序列化为JSON', () {
        final pet = MockFactories.createTestPetModel(
          petId: 'pet_json',
          userId: 'user_json',
          name: '小黄',
          currentEmotion: PetEmotionType.excited,
          emotionValue: 90,
          bondLevel: 3,
          bondExp: 120.0,
        );

        final json = pet.toJson();

        expect(json['petId'], equals('pet_json'));
        expect(json['userId'], equals('user_json'));
        expect(json['name'], equals('小黄'));
        expect(json['currentEmotion'], equals('excited'));
        expect(json['emotionValue'], equals(90));
        expect(json['bondLevel'], equals(3));
        expect(json['bondExp'], equals(120.0));
      });

      test('情绪类型应该正确序列化为字符串', () {
        final emotions = [
          PetEmotionType.happy,
          PetEmotionType.sad,
          PetEmotionType.angry,
          PetEmotionType.normal,
          PetEmotionType.excited,
        ];

        for (final emotion in emotions) {
          final pet = MockFactories.createTestPetModel(currentEmotion: emotion);
          final json = pet.toJson();

          expect(json['currentEmotion'], equals(emotion.name));
        }
      });

      test('时间字段应该正确序列化', () {
        final pet = MockFactories.createTestPetModel();

        final json = pet.toJson();

        expect(json['lastInteractionTime'], isNotNull);
        expect(json['createdAt'], isNotNull);
        expect(json['updatedAt'], isNotNull);
        
        expect(
          DateTime.parse(json['lastInteractionTime'] as String),
          isA<DateTime>(),
        );
      });

      test('stats应该正确序列化', () {
        final pet = MockFactories.createTestPetModel(
          stats: {
            'feedCount': 10,
            'playCount': 5,
          },
        );

        final json = pet.toJson();

        expect(json['stats'], isA<Map>());
        expect(json['stats']['feedCount'], equals(10));
        expect(json['stats']['playCount'], equals(5));
      });
    });

    group('fromJson反序列化测试', () {
      test('应该正确从JSON反序列化', () {
        final json = MockFactories.createTestPetModelJson(
          petId: 'pet_from_json',
          userId: 'user_from_json',
          name: '小白',
          currentEmotion: 'happy',
          emotionValue: 75,
          bondLevel: 2,
          bondExp: 30.5,
        );

        final pet = PetModel.fromJson(json);

        expect(pet.petId, equals('pet_from_json'));
        expect(pet.userId, equals('user_from_json'));
        expect(pet.name, equals('小白'));
        expect(pet.currentEmotion, equals(PetEmotionType.happy));
        expect(pet.emotionValue, equals(75));
        expect(pet.bondLevel, equals(2));
        expect(pet.bondExp, equals(30.5));
      });

      test('无效情绪类型应该使用默认值', () {
        final json = MockFactories.createTestPetModelJson(
          currentEmotion: 'invalid_emotion',
        );

        final pet = PetModel.fromJson(json);

        expect(pet.currentEmotion, equals(PetEmotionType.normal));
      });

      test('缺失字段应该使用默认值', () {
        final now = DateTime.now().toIso8601String();
        final json = {
          'petId': 'minimal_pet',
          'userId': 'minimal_user',
          'lastInteractionTime': now,
          'createdAt': now,
          'updatedAt': now,
        };

        final pet = PetModel.fromJson(json);

        expect(pet.name, equals('咕咕'));
        expect(pet.currentEmotion, equals(PetEmotionType.normal));
        expect(pet.emotionValue, equals(50));
        expect(pet.bondLevel, equals(1));
        expect(pet.bondExp, equals(0));
      });
    });

    group('copyWith测试', () {
      test('应该正确复制并更新字段', () {
        final original = MockFactories.createTestPetModel(
          petId: 'original_pet',
          name: '原名',
          emotionValue: 50,
        );

        final copied = original.copyWith(
          name: '新名',
          emotionValue: 80,
        );

        expect(copied.petId, equals('original_pet'));
        expect(copied.name, equals('新名'));
        expect(copied.emotionValue, equals(80));
        expect(copied.userId, equals(original.userId));
      });

      test('应该能更新情绪状态', () {
        final original = MockFactories.createTestPetModel(
          currentEmotion: PetEmotionType.normal,
        );

        final copied = original.copyWith(
          currentEmotion: PetEmotionType.happy,
        );

        expect(copied.currentEmotion, equals(PetEmotionType.happy));
      });

      test('应该能更新羁绊等级和经验', () {
        final original = MockFactories.createTestPetModel(
          bondLevel: 1,
          bondExp: 0,
        );

        final copied = original.copyWith(
          bondLevel: 5,
          bondExp: 250.0,
        );

        expect(copied.bondLevel, equals(5));
        expect(copied.bondExp, equals(250.0));
      });
    });

    group('createDefault工厂方法测试', () {
      test('应该创建默认宠物', () {
        final pet = PetModel.createDefault('user_default');

        expect(pet.userId, equals('user_default'));
        expect(pet.name, equals('咕咕'));
        expect(pet.currentEmotion, equals(PetEmotionType.normal));
        expect(pet.emotionValue, equals(50));
        expect(pet.bondLevel, equals(1));
        expect(pet.bondExp, equals(0));
        expect(pet.petId, contains('user_default'));
      });

      test('petId应该包含时间戳', () {
        final beforeTime = DateTime.now().millisecondsSinceEpoch;
        final pet = PetModel.createDefault('user_ts');
        final afterTime = DateTime.now().millisecondsSinceEpoch;

        final timestampPart = int.parse(pet.petId.split('_').last);
        expect(timestampPart, greaterThanOrEqualTo(beforeTime));
        expect(timestampPart, lessThanOrEqualTo(afterTime));
      });
    });

    group('序列化往返测试', () {
      test('toJson和fromJson应该互逆', () {
        final original = MockFactories.createTestPetModel(
          petId: 'round_trip_pet',
          userId: 'round_trip_user',
          name: '往返测试宠物',
          currentEmotion: PetEmotionType.excited,
          emotionValue: 95,
          bondLevel: 10,
          bondExp: 500.0,
          stats: {'testKey': 'testValue'},
        );

        final json = original.toJson();
        final restored = PetModel.fromJson(json);

        expect(restored.petId, equals(original.petId));
        expect(restored.userId, equals(original.userId));
        expect(restored.name, equals(original.name));
        expect(restored.currentEmotion, equals(original.currentEmotion));
        expect(restored.emotionValue, equals(original.emotionValue));
        expect(restored.bondLevel, equals(original.bondLevel));
        expect(restored.bondExp, equals(original.bondExp));
      });
    });

    group('PetEmotionType枚举测试', () {
      test('应该包含所有预期的情绪类型', () {
        expect(PetEmotionType.values, contains(PetEmotionType.happy));
        expect(PetEmotionType.values, contains(PetEmotionType.sad));
        expect(PetEmotionType.values, contains(PetEmotionType.angry));
        expect(PetEmotionType.values, contains(PetEmotionType.normal));
        expect(PetEmotionType.values, contains(PetEmotionType.excited));
      });

      test('情绪类型name属性应该正确', () {
        expect(PetEmotionType.happy.name, equals('happy'));
        expect(PetEmotionType.sad.name, equals('sad'));
        expect(PetEmotionType.angry.name, equals('angry'));
        expect(PetEmotionType.normal.name, equals('normal'));
        expect(PetEmotionType.excited.name, equals('excited'));
      });
    });

    group('边界条件测试', () {
      test('情绪值为0应该正确处理', () {
        final pet = MockFactories.createTestPetModel(emotionValue: 0);

        expect(pet.emotionValue, equals(0));

        final json = pet.toJson();
        final restored = PetModel.fromJson(json);

        expect(restored.emotionValue, equals(0));
      });

      test('情绪值为100应该正确处理', () {
        final pet = MockFactories.createTestPetModel(emotionValue: 100);

        expect(pet.emotionValue, equals(100));
      });

      test('羁绊经验为小数应该正确处理', () {
        final pet = MockFactories.createTestPetModel(bondExp: 99.99);

        final json = pet.toJson();
        final restored = PetModel.fromJson(json);

        expect(restored.bondExp, closeTo(99.99, 0.001));
      });
    });
  });
}
