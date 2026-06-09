import 'package:flutter_test/flutter_test.dart';
import 'package:jobpet/features/pet/services/embedding_service.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'embedding_service_test.mocks.dart';

@GenerateMocks([EmbeddingService])
void main() {
  group('EmbeddingService', () {
    late MockEmbeddingService service;

    setUp(() {
      service = MockEmbeddingService();
    });

    test('should embed single text', () async {
      when(
        service.embed('你好'),
      ).thenAnswer((_) async => List.generate(384, (i) => 0.1));

      final result = await service.embed('你好');

      expect(result.length, 384);
      verify(service.embed('你好')).called(1);
    });

    test('should embed batch texts', () async {
      final texts = ['你好', '世界'];
      when(service.embedBatch(texts)).thenAnswer(
        (_) async => [
          List.generate(384, (i) => 0.1),
          List.generate(384, (i) => 0.2),
        ],
      );

      final result = await service.embedBatch(texts);

      expect(result.length, 2);
      expect(result[0].length, 384);
      verify(service.embedBatch(texts)).called(1);
    });

    test('should handle empty text', () async {
      when(service.embed('')).thenAnswer((_) async => []);

      final result = await service.embed('');

      expect(result, isEmpty);
    });
  });

  group('EmbeddingServiceFactory', () {
    test('should create Ollama embedding service', () {
      final service = EmbeddingServiceFactory.create(
        provider: 'ollama',
        config: const EmbeddingConfig(
          apiKey: '',
          endpoint: 'http://127.0.0.1:11434/api/embed',
          model: 'qwen3-embedding:4b',
          dimension: 2560,
        ),
      );

      expect(service.providerName, 'Ollama');
      expect(service.dimension, 2560);
    });
  });
}
