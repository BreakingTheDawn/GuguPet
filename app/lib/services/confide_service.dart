import '../data/models/interaction.dart';
import '../data/models/job_event.dart';
import 'intent_engine.dart';
import 'pet_responder.dart';

class ConfideService {
  final IntentEngine _intentEngine;
  final PetResponder _petResponder;
  final Function(Interaction)? onSaveLocal;
  final Function(JobEvent)? onCreateJobEvent;

  ConfideService({
    IntentEngine? intentEngine,
    PetResponder? petResponder,
    this.onSaveLocal,
    this.onCreateJobEvent,
  })  : _intentEngine = intentEngine ?? IntentEngine(),
        _petResponder = petResponder ?? PetResponder();

  Future<ConfideResult> submitConfide({
    required String userId,
    required String content,
  }) async {
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

    if (_shouldCreateJobEvent(intent.actionType)) {
      final jobEvent = JobEvent(
        id: _generateId(),
        userId: userId,
        eventType: _mapActionToEventType(intent.actionType),
        eventContent: content,
        eventTime: DateTime.now(),
      );
      onCreateJobEvent?.call(jobEvent);
    }

    return ConfideResult(
      interaction: interaction,
      petResponse: petResponse,
      intent: intent,
    );
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
