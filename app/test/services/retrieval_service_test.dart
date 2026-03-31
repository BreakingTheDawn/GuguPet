import 'package:flutter_test/flutter_test.dart';
import 'package:jobpet/features/pet/services/retrieval_service.dart';
import 'package:jobpet/features/pet/services/embedding_service.dart';
import 'package:jobpet/features/pet/data/models/vector_memory.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'retrieval_service_test.mocks.dart';

@GenerateMocks([EmbeddingService, VectorMemoryDatasource])
void main() {
  group('RetrievalService', () {
    late MockEmbeddingService mockEmbeddingService;
    late MockVectorMemoryDatasource mockDatasource;
    late RetrievalService service;

    setUp(() {
      mockEmbeddingService = MockEmbeddingService();
      mockDatasource = MockVectorMemoryDatasource();
      service = RetrievalServiceImpl(
        embeddingService: mockEmbeddingService,
        datasource: mockDatasource,
      );
    });

    test('should search memories by similarity', () async {
      final queryEmbedding = List.generate(384, (i) => 0.5);
      final memories = [
        VectorMemory(
          id: 'mem_001',
          petId: 'pet_001',
          type: MemoryType.keyEvent,
          category: MemoryCategory.job,
          content: '明天面试',
          embedding: List.generate(384, (i) => 0.6),
          createdAt: DateTime.now(),
        ),
      ];

      when(mockEmbeddingService.embed('面试')).thenAnswer((_) async => queryEmbedding);
      when(mockEmbeddingService.dimension).thenReturn(384);
      when(mockDatasource.getMemoriesByPetId('pet_001')).thenAnswer((_) async => memories);

      final result = await service.search(
        query: '面试',
        petId: 'pet_001',
        topK: 5,
      );

      expect(result.hasResults, true);
      verify(mockEmbeddingService.embed('面试')).called(1);
    });

    test('should return empty result when no memories', () async {
      when(mockEmbeddingService.embed('测试')).thenAnswer((_) async => List.generate(384, (i) => 0.1));
      when(mockEmbeddingService.dimension).thenReturn(384);
      when(mockDatasource.getMemoriesByPetId('pet_001')).thenAnswer((_) async => []);

      final result = await service.search(
        query: '测试',
        petId: 'pet_001',
        topK: 5,
      );

      expect(result.hasResults, false);
    });

    test('should filter by threshold', () async {
      final queryEmbedding = List.generate(384, (i) => 0.5);
      final memories = [
        VectorMemory(
          id: 'mem_001',
          petId: 'pet_001',
          type: MemoryType.keyEvent,
          category: MemoryCategory.job,
          content: '高相似度',
          embedding: List.generate(384, (i) => 0.5),
          createdAt: DateTime.now(),
        ),
        VectorMemory(
          id: 'mem_002',
          petId: 'pet_001',
          type: MemoryType.shortTerm,
          category: MemoryCategory.emotion,
          content: '低相似度',
          embedding: List.generate(384, (i) => -0.5),
          createdAt: DateTime.now(),
        ),
      ];

      when(mockEmbeddingService.embed('测试')).thenAnswer((_) async => queryEmbedding);
      when(mockEmbeddingService.dimension).thenReturn(384);
      when(mockDatasource.getMemoriesByPetId('pet_001')).thenAnswer((_) async => memories);

      final result = await service.search(
        query: '测试',
        petId: 'pet_001',
        topK: 5,
        threshold: 0.7,
      );

      expect(result.length, 1);
      expect(result.memories.first.content, '高相似度');
    });
  });
}
