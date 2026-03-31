import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite/sqflite.dart';
import 'package:jobpet/features/pet/data/datasources/vector_memory_datasource.dart';
import 'package:jobpet/features/pet/data/models/vector_memory.dart';

void main() {
  late Database database;
  late VectorMemoryDatasourceImpl datasource;

  setUpAll(() async {
    // 初始化 sqflite_ffi
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  setUp(() async {
    // 创建内存数据库
    database = await openDatabase(
      inMemoryDatabasePath,
      version: 1,
      onCreate: (db, version) async {
        // 创建宠物表（外键依赖）
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

        // 创建向量记忆表
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

        // 插入测试宠物
        await db.insert('pets', {
          'id': 'pet_001',
          'user_id': 'user_001',
          'name': '咕咕',
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        });
      },
    );
    datasource = VectorMemoryDatasourceImpl(database);
  });

  tearDown(() async {
    await database.close();
  });

  group('VectorMemoryDatasource', () {
    test('should insert and retrieve memory', () async {
      final memory = VectorMemory(
        id: 'mem_001',
        petId: 'pet_001',
        type: MemoryType.keyEvent,
        category: MemoryCategory.job,
        content: '测试记忆',
        embedding: [0.1, 0.2, 0.3],
        importance: 1.0,
        createdAt: DateTime.now(),
      );

      await datasource.insertMemory(memory);
      final memories = await datasource.getMemoriesByPetId('pet_001');

      expect(memories.length, 1);
      expect(memories.first.content, '测试记忆');
      expect(memories.first.type, MemoryType.keyEvent);
      expect(memories.first.embedding.length, 3);
    });

    test('should delete memory', () async {
      final memory = VectorMemory(
        id: 'mem_002',
        petId: 'pet_001',
        type: MemoryType.shortTerm,
        category: MemoryCategory.emotion,
        content: '临时记忆',
        embedding: [],
        createdAt: DateTime.now(),
      );

      await datasource.insertMemory(memory);
      await datasource.deleteMemory('mem_002');
      final memories = await datasource.getMemoriesByPetId('pet_001');

      expect(memories, isEmpty);
    });

    test('should clean expired memories', () async {
      final expiredMemory = VectorMemory(
        id: 'mem_003',
        petId: 'pet_001',
        type: MemoryType.shortTerm,
        category: MemoryCategory.emotion,
        content: '过期记忆',
        embedding: [],
        createdAt: DateTime.now().subtract(const Duration(hours: 25)),
        expiresAt: DateTime.now().subtract(const Duration(hours: 1)),
      );

      await datasource.insertMemory(expiredMemory);
      await datasource.cleanExpiredMemories('pet_001');
      final memories = await datasource.getMemoriesByPetId('pet_001');

      expect(memories, isEmpty);
    });

    test('should not delete permanent memories when cleaning', () async {
      final permanentMemory = VectorMemory(
        id: 'mem_004',
        petId: 'pet_001',
        type: MemoryType.keyEvent,
        category: MemoryCategory.job,
        content: '重要事件',
        embedding: [],
        importance: 1.0,
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
      );

      await datasource.insertMemory(permanentMemory);
      await datasource.cleanExpiredMemories('pet_001');
      final memories = await datasource.getMemoriesByPetId('pet_001');

      expect(memories.length, 1);
      expect(memories.first.content, '重要事件');
    });

    test('should get memories by type', () async {
      await datasource.insertMemory(VectorMemory(
        id: 'mem_005',
        petId: 'pet_001',
        type: MemoryType.keyEvent,
        category: MemoryCategory.job,
        content: '关键事件',
        embedding: [],
        createdAt: DateTime.now(),
      ));

      await datasource.insertMemory(VectorMemory(
        id: 'mem_006',
        petId: 'pet_001',
        type: MemoryType.preference,
        category: MemoryCategory.preference,
        content: '用户偏好',
        embedding: [],
        createdAt: DateTime.now(),
      ));

      final keyEvents = await datasource.getMemoriesByType('pet_001', MemoryType.keyEvent);
      expect(keyEvents.length, 1);
      expect(keyEvents.first.content, '关键事件');

      final preferences = await datasource.getMemoriesByType('pet_001', MemoryType.preference);
      expect(preferences.length, 1);
      expect(preferences.first.content, '用户偏好');
    });

    test('should get memory count', () async {
      for (var i = 0; i < 5; i++) {
        await datasource.insertMemory(VectorMemory(
          id: 'mem_count_$i',
          petId: 'pet_001',
          type: MemoryType.shortTerm,
          category: MemoryCategory.emotion,
          content: '记忆 $i',
          embedding: [],
          createdAt: DateTime.now(),
        ));
      }

      final count = await datasource.getMemoryCount('pet_001');
      expect(count, 5);
    });

    test('should batch insert memories', () async {
      final memories = List.generate(3, (i) => VectorMemory(
        id: 'mem_batch_$i',
        petId: 'pet_001',
        type: MemoryType.shortTerm,
        category: MemoryCategory.emotion,
        content: '批量记忆 $i',
        embedding: [],
        createdAt: DateTime.now(),
      ));

      await datasource.insertMemoriesBatch(memories);
      final count = await datasource.getMemoryCount('pet_001');
      expect(count, 3);
    });

    test('should get memory by id', () async {
      await datasource.insertMemory(VectorMemory(
        id: 'mem_by_id',
        petId: 'pet_001',
        type: MemoryType.keyEvent,
        category: MemoryCategory.job,
        content: '按ID查询',
        embedding: [0.5, 0.6],
        createdAt: DateTime.now(),
      ));

      final memory = await datasource.getMemoryById('mem_by_id');
      expect(memory, isNotNull);
      expect(memory!.content, '按ID查询');
      expect(memory.embedding.length, 2);
    });

    test('should return null for non-existent memory', () async {
      final memory = await datasource.getMemoryById('non_existent');
      expect(memory, isNull);
    });

    test('should search by content keyword', () async {
      await datasource.insertMemory(VectorMemory(
        id: 'mem_search_1',
        petId: 'pet_001',
        type: MemoryType.keyEvent,
        category: MemoryCategory.job,
        content: '明天下午三点面试',
        embedding: [],
        createdAt: DateTime.now(),
      ));

      await datasource.insertMemory(VectorMemory(
        id: 'mem_search_2',
        petId: 'pet_001',
        type: MemoryType.keyEvent,
        category: MemoryCategory.job,
        content: '收到offer了',
        embedding: [],
        createdAt: DateTime.now(),
      ));

      final results = await datasource.searchByContent('pet_001', '面试');
      expect(results.length, 1);
      expect(results.first.content, contains('面试'));
    });
  });
}
