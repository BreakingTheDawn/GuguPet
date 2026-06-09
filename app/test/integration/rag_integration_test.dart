import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:jobpet/features/pet/services/rag_service_manager.dart';
import 'package:jobpet/features/pet/data/models/vector_memory.dart';

void main() {
  late Database database;
  late RAGServiceManager manager;

  setUpAll(() async {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;

    database = await openDatabase(
      inMemoryDatabasePath,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE pets (
            id TEXT PRIMARY KEY,
            user_id TEXT NOT NULL UNIQUE,
            name TEXT DEFAULT '咕咕',
            current_emotion TEXT DEFAULT 'normal',
            emotion_value INTEGER DEFAULT 50,
            bond_level INTEGER DEFAULT 1,
            bond_exp REAL DEFAULT 0,
            created_at TEXT NOT NULL,
            updated_at TEXT NOT NULL
          )
        ''');

        await db.execute('''
          CREATE TABLE vector_memories (
            id TEXT PRIMARY KEY,
            pet_id TEXT NOT NULL,
            type TEXT NOT NULL,
            category TEXT NOT NULL,
            content TEXT NOT NULL,
            embedding BLOB,
            importance REAL DEFAULT 0.5,
            created_at TEXT NOT NULL,
            expires_at TEXT,
            metadata TEXT,
            FOREIGN KEY (pet_id) REFERENCES pets(id)
          )
        ''');

        await db.insert('pets', {
          'id': 'pet_test_001',
          'user_id': 'user_test_001',
          'name': '测试咕咕',
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        });
      },
    );

    manager = RAGServiceManager();
    await manager.initialize(database: database);
  });

  tearDownAll(() async {
    await database.close();
  });

  group('RAG服务集成测试', () {
    test('RAG服务管理器应该正确初始化', () async {
      expect(manager.isInitialized, true);
      expect(manager.embeddingService, isNotNull);
      expect(manager.retrievalService, isNotNull);
      expect(manager.datasource, isNotNull);
      expect(manager.currentProvider, 'ollama');
      expect(manager.embeddingService!.providerName, 'Ollama');
    });

    test('RAG服务应该能够存储和检索记忆', () async {
      final success = await manager.storeMemory(
        petId: 'pet_test_001',
        content: '明天下午三点有面试',
        type: MemoryType.keyEvent,
        category: MemoryCategory.job,
        importance: 1.0,
      );

      expect(success, true);

      final result = await manager.search(
        query: '面试',
        petId: 'pet_test_001',
        topK: 5,
        threshold: 0.0,
      );

      expect(result.hasResults, true);
      expect(result.length, greaterThanOrEqualTo(1));
    });

    test('RAG服务应该能够处理多条记忆', () async {
      await manager.storeMemory(
        petId: 'pet_test_001',
        content: '我喜欢喝咖啡测试',
        type: MemoryType.preference,
        category: MemoryCategory.preference,
        importance: 0.8,
      );

      await manager.storeMemory(
        petId: 'pet_test_001',
        content: '明天有技术面试',
        type: MemoryType.keyEvent,
        category: MemoryCategory.job,
        importance: 1.0,
      );

      await manager.storeMemory(
        petId: 'pet_test_001',
        content: '今天心情不错测试',
        type: MemoryType.shortTerm,
        category: MemoryCategory.emotion,
        importance: 0.5,
      );

      final result = await manager.search(
        query: '面试安排',
        petId: 'pet_test_001',
        topK: 10,
        threshold: 0.0,
      );

      expect(result.hasResults, true);
    });

    test('RAG服务应该能够清理过期记忆', () async {
      await manager.cleanExpiredMemories('pet_test_001');

      final memories = await manager.datasource!.getMemoriesByPetId(
        'pet_test_001',
      );
      for (final memory in memories) {
        expect(memory.isExpired, false);
      }
    });

    test('本地嵌入服务应该能够生成向量', () async {
      final embedding = await manager.embeddingService!.embed('测试文本');

      expect(embedding, isNotEmpty);
      expect(embedding.length, greaterThan(0));
    });
  });

  group('RAG服务单例行为测试', () {
    test('单例实例应该在整个应用中保持一致', () {
      final manager1 = RAGServiceManager();
      final manager2 = RAGServiceManager();

      expect(identical(manager1, manager2), true);
    });
  });
}
