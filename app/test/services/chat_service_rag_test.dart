import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:jobpet/features/pet/services/retrieval_service.dart';
import 'package:jobpet/features/pet/data/models/retrieval_result.dart';
import 'package:jobpet/features/pet/data/models/vector_memory.dart';

import 'chat_service_rag_test.mocks.dart';

@GenerateMocks([RetrievalService])
void main() {
  group('ChatService RAG Integration', () {
    late MockRetrievalService mockRetrievalService;

    setUp(() {
      mockRetrievalService = MockRetrievalService();
    });

    test('should retrieve relevant memories before generating response', () async {
      final memories = RetrievalResult(
        memories: [
          VectorMemory(
            id: 'mem_001',
            petId: 'pet_001',
            type: MemoryType.keyEvent,
            category: MemoryCategory.job,
            content: '明天有面试',
            embedding: [],
            createdAt: DateTime.now(),
          ),
        ],
        scores: [0.95],
        totalTokens: 10,
      );

      when(mockRetrievalService.search(
        query: '面试准备',
        petId: 'pet_001',
        topK: 5,
        threshold: 0.6,
      )).thenAnswer((_) async => memories);

      final result = await mockRetrievalService.search(
        query: '面试准备',
        petId: 'pet_001',
        topK: 5,
        threshold: 0.6,
      );

      expect(result.hasResults, true);
      expect(result.length, 1);
      expect(result.memories.first.content, '明天有面试');
      expect(result.scores.first, 0.95);
    });

    test('should return empty result when no memories found', () async {
      when(mockRetrievalService.search(
        query: '测试查询',
        petId: 'pet_001',
        topK: 5,
        threshold: 0.6,
      )).thenAnswer((_) async => RetrievalResult.empty());

      final result = await mockRetrievalService.search(
        query: '测试查询',
        petId: 'pet_001',
        topK: 5,
        threshold: 0.6,
      );

      expect(result.hasResults, false);
      expect(result.length, 0);
    });

    test('should filter results by threshold', () async {
      final memories = RetrievalResult(
        memories: [
          VectorMemory(
            id: 'mem_001',
            petId: 'pet_001',
            type: MemoryType.keyEvent,
            category: MemoryCategory.job,
            content: '高相似度记忆',
            embedding: [],
            createdAt: DateTime.now(),
          ),
          VectorMemory(
            id: 'mem_002',
            petId: 'pet_001',
            type: MemoryType.shortTerm,
            category: MemoryCategory.emotion,
            content: '低相似度记忆',
            embedding: [],
            createdAt: DateTime.now(),
          ),
        ],
        scores: [0.95, 0.3],
        totalTokens: 10,
      );

      when(mockRetrievalService.search(
        query: '测试',
        petId: 'pet_001',
        topK: 5,
        threshold: 0.6,
      )).thenAnswer((_) async => memories.filterByThreshold(0.6));

      final result = await mockRetrievalService.search(
        query: '测试',
        petId: 'pet_001',
        topK: 5,
        threshold: 0.6,
      );

      expect(result.length, 1);
      expect(result.memories.first.content, '高相似度记忆');
    });

    test('should convert memories to content list', () async {
      final memories = RetrievalResult(
        memories: [
          VectorMemory(
            id: 'mem_001',
            petId: 'pet_001',
            type: MemoryType.keyEvent,
            category: MemoryCategory.job,
            content: '第一条记忆',
            embedding: [],
            createdAt: DateTime.now(),
          ),
          VectorMemory(
            id: 'mem_002',
            petId: 'pet_001',
            type: MemoryType.preference,
            category: MemoryCategory.preference,
            content: '第二条记忆',
            embedding: [],
            createdAt: DateTime.now(),
          ),
        ],
        scores: [0.9, 0.8],
        totalTokens: 10,
      );

      final contentList = memories.toContentList();

      expect(contentList.length, 2);
      expect(contentList[0], '第一条记忆');
      expect(contentList[1], '第二条记忆');
    });
  });
}
