import '../data/models/interaction.dart';
import '../data/models/job_event.dart';
import '../core/errors/exceptions.dart';
import '../core/errors/error_handler.dart';
import '../core/utils/logger_service.dart';
import 'intent_engine.dart';
import 'pet_responder.dart';

class ConfideService {
  final IntentEngine _intentEngine;
  final PetResponder _petResponder;
  final Function(Interaction)? onSaveLocal;
  final Function(JobEvent)? onCreateJobEvent;
  
  /// 宠物系统回调 - 当倾诉发生时通知宠物系统
  final Function(String content, String actionType, String emotionType)? onPetInteraction;
  
  /// 公园解锁回调 - 当获得Offer时触发公园解锁检查
  final Function(String userId)? onOfferReceived;

  ConfideService({
    IntentEngine? intentEngine,
    PetResponder? petResponder,
    this.onSaveLocal,
    this.onCreateJobEvent,
    this.onPetInteraction,
    this.onOfferReceived,
  })  : _intentEngine = intentEngine ?? IntentEngine(),
        _petResponder = petResponder ?? PetResponder();

  Future<ConfideResult> submitConfide({
    required String userId,
    required String content,
  }) async {
    AppLogger.info('Submitting confide for user: $userId');
    try {
      final intent = await _intentEngine.analyze(content);
      final petResponse = await _petResponder.respond(intent);

      final interaction = Interaction(
        id: _generateId(),
        userId: userId,
        content: content,
        actionType: intent.actionType,
        emotionType: intent.emotionType,
        petAction: petResponse.action.id,
        petBubble: petResponse.bubble,
        createdAt: DateTime.now(),
      );

      onSaveLocal?.call(interaction);

      // 通知宠物系统
      onPetInteraction?.call(content, intent.actionType, intent.emotionType);

      if (_shouldCreateJobEvent(intent.actionType)) {
        final jobEvent = JobEvent(
          id: _generateId(),
          userId: userId,
          eventType: _mapActionToEventType(intent.actionType),
          eventContent: content,
          eventTime: DateTime.now(),
        );
        onCreateJobEvent?.call(jobEvent);
        
        // 检查是否获得Offer，触发公园解锁
        if (intent.actionType == 'offer_received') {
          AppLogger.info('检测到Offer事件，触发公园解锁检查');
          onOfferReceived?.call(userId);
        }
      }

      AppLogger.info('Confide submitted successfully');
      return ConfideResult(
        interaction: interaction,
        petResponse: petResponse,
        intent: intent,
      );
    } on Exception catch (e) {
      final message = ErrorHandler.handleException(e);
      AppLogger.error('Failed to submit confide', e);
      throw BusinessException(message: message);
    }
  }

  bool _shouldCreateJobEvent(String actionType) {
    return [
      'resume_submit',
      'interview_received',
      'job_rejected',
      'offer_received',
    ].contains(actionType);
  }

  String _mapActionToEventType(String actionType) {
    final mapping = {
      'resume_submit': '投递',
      'interview_received': '面试',
      'job_rejected': '拒信',
      'offer_received': 'Offer',
    };
    return mapping[actionType] ?? '其他';
  }

  String _generateId() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }
}

class ConfideResult {
  final Interaction interaction;
  final PetResponse petResponse;
  final IntentResult intent;

  ConfideResult({
    required this.interaction,
    required this.petResponse,
    required this.intent,
  });
}
