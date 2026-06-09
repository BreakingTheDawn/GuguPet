import 'package:flutter_test/flutter_test.dart';
import 'package:jobpet/features/confide/data/datasources/chat_local_datasource.dart';
import 'package:jobpet/features/confide/data/models/chat_message.dart';
import 'package:jobpet/features/confide/data/models/chat_session.dart';
import 'package:jobpet/features/confide/services/ai_config_service.dart';
import 'package:jobpet/features/confide/services/chat_service.dart';

void main() {
  test(
    'initializeSession uses memory session when local persistence is off',
    () async {
      final service = ChatService(
        configService: AIConfigService(),
        localDatasource: _ThrowingChatLocalDatasource(),
        localPersistenceEnabled: false,
      );

      await service.initializeSession('guest_user');

      expect(service.currentSession?.userId, 'guest_user');
    },
  );
}

class _ThrowingChatLocalDatasource extends ChatLocalDatasource {
  @override
  Future<ChatSession?> getActiveSession(String userId) {
    throw StateError('local datasource should not be called');
  }

  @override
  Future<ChatSession> createSession(String userId) {
    throw StateError('local datasource should not be called');
  }

  @override
  Future<void> addMessage(String sessionId, ChatMessage message) {
    throw StateError('local datasource should not be called');
  }
}
