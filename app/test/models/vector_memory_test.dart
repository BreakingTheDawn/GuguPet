import 'package:flutter_test/flutter_test.dart';
import 'package:jobpet/features/pet/data/models/vector_memory.dart';

void main() {
  group('VectorMemory', () {
    test('should create vector memory with all fields', () {
      final memory = VectorMemory(
        id: 'mem_001',
        petId: 'pet_001',
        type: MemoryType.keyEvent,
        category: MemoryCategory.job,
        content: '明天下午3点有面试',
        embedding: List.generate(384, (i) => 0.1),
        importance: 1.0,
        createdAt: DateTime(2026, 3, 30, 10, 0),
      );

      expect(memory.id, 'mem_001');
      expect(memory.type, MemoryType.keyEvent);
      expect(memory.embedding.length, 384);
      expect(memory.isExpired, false);
    });

    test('should detect expired short term memory', () {
      final memory = VectorMemory(
        id: 'mem_002',
        petId: 'pet_001',
        type: MemoryType.shortTerm,
        category: MemoryCategory.emotion,
        content: '今天心情不错',
        embedding: [],
        importance: 0.5,
        createdAt: DateTime.now().subtract(const Duration(hours: 25)),
        expiresAt: DateTime.now().subtract(const Duration(hours: 1)),
      );

      expect(memory.isExpired, true);
    });

    test('should serialize to JSON correctly', () {
      final memory = VectorMemory(
        id: 'mem_003',
        petId: 'pet_001',
        type: MemoryType.preference,
        category: MemoryCategory.preference,
        content: '喜欢远程工作',
        embedding: [0.1, 0.2, 0.3],
        importance: 0.8,
        createdAt: DateTime(2026, 3, 30),
      );

      final json = memory.toJson();

      expect(json['id'], 'mem_003');
      expect(json['type'], 'preference');
      expect(json['embedding'], isA<String>());
    });

    test('should deserialize from JSON correctly', () {
      final originalMemory = VectorMemory(
        id: 'mem_004',
        petId: 'pet_001',
        type: MemoryType.keyEvent,
        category: MemoryCategory.job,
        content: '收到offer了',
        embedding: [1.0, 2.0, 3.0],
        importance: 1.0,
        createdAt: DateTime(2026, 3, 30, 10, 0),
      );

      final json = originalMemory.toJson();
      final memory = VectorMemory.fromJson(json);

      expect(memory.id, 'mem_004');
      expect(memory.type, MemoryType.keyEvent);
      expect(memory.embedding.length, 3);
      expect(memory.embedding[0], closeTo(1.0, 0.001));
    });
  });
}
