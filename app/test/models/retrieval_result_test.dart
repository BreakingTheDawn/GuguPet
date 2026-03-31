import 'package:flutter_test/flutter_test.dart';
import 'package:jobpet/features/pet/data/models/vector_memory.dart';
import 'package:jobpet/features/pet/data/models/retrieval_result.dart';

void main() {
  group('RetrievalResult', () {
    test('should create retrieval result with memories and scores', () {
      final memories = [
        VectorMemory(
          id: 'mem_001',
          petId: 'pet_001',
          type: MemoryType.keyEvent,
          category: MemoryCategory.job,
          content: '明天面试',
          embedding: [],
          createdAt: DateTime.now(),
        ),
      ];

      final result = RetrievalResult(
        memories: memories,
        scores: [0.95],
        totalTokens: 100,
      );

      expect(result.memories.length, 1);
      expect(result.scores.first, 0.95);
      expect(result.totalTokens, 100);
    });

    test('should return empty result', () {
      final result = RetrievalResult.empty();

      expect(result.memories, isEmpty);
      expect(result.scores, isEmpty);
      expect(result.totalTokens, 0);
    });

    test('should check if has results', () {
      final emptyResult = RetrievalResult.empty();
      final nonEmptyResult = RetrievalResult(
        memories: [
          VectorMemory(
            id: 'mem_001',
            petId: 'pet_001',
            type: MemoryType.keyEvent,
            category: MemoryCategory.job,
            content: 'test',
            embedding: [],
            createdAt: DateTime.now(),
          ),
        ],
        scores: [0.9],
        totalTokens: 50,
      );

      expect(emptyResult.hasResults, false);
      expect(nonEmptyResult.hasResults, true);
    });
  });
}
