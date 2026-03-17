import 'package:lottie/lottie.dart';

import 'intent_engine.dart';

class PetAction {
  final String id;
  final String name;
  final String animationPath;
  final int durationMs;
  final bool loop;

  PetAction({
    required this.id,
    required this.name,
    required this.animationPath,
    this.durationMs = 2000,
    this.loop = false,
  });
}

class PetResponse {
  final PetAction action;
  final String bubble;
  final LottieComposition? animation;

  PetResponse({
    required this.action,
    required this.bubble,
    this.animation,
  });
}

class PetResponder {
  final Map<String, PetAction> _actionMap;
  final Map<String, String> _bubbleMap;
  final Map<String, LottieComposition> _animationCache;

  PetResponder({
    Map<String, PetAction>? actionMap,
    Map<String, String>? bubbleMap,
  })  : _actionMap = actionMap ?? _defaultActionMap,
        _bubbleMap = bubbleMap ?? _defaultBubbleMap,
        _animationCache = {};

  static final Map<String, PetAction> _defaultActionMap = {
    'resume_submit': PetAction(
      id: 'resume_submit',
      name: '投递简历',
      animationPath: 'assets/animations/pet_submit.json',
    ),
    'interview_received': PetAction(
      id: 'interview_received',
      name: '收到面试',
      animationPath: 'assets/animations/pet_interview.json',
    ),
    'job_rejected': PetAction(
      id: 'job_rejected',
      name: '求职被拒',
      animationPath: 'assets/animations/pet_rejected.json',
    ),
    'offer_received': PetAction(
      id: 'offer_received',
      name: '拿到Offer',
      animationPath: 'assets/animations/pet_offer.json',
    ),
    'slacking': PetAction(
      id: 'slacking',
      name: '摆烂休息',
      animationPath: 'assets/animations/pet_slacking.json',
    ),
    'anxiety': PetAction(
      id: 'anxiety',
      name: '焦虑低落',
      animationPath: 'assets/animations/pet_anxiety.json',
    ),
    'unknown': PetAction(
      id: 'unknown',
      name: '默认',
      animationPath: 'assets/animations/pet_default.json',
    ),
  };

  static const Map<String, String> _defaultBubbleMap = {
    'resume_submit': '嗯！',
    'interview_received': '！！',
    'job_rejected': '呜…',
    'offer_received': '♡♡♡',
    'slacking': '…',
    'anxiety': '🫂',
    'unknown': '…',
  };

  Future<PetResponse> respond(IntentResult intent) async {
    final action = _getAction(intent.actionType);
    final bubble = _getBubble(intent.actionType);
    final animation = await _loadAnimation(action.animationPath);

    return PetResponse(
      action: action,
      bubble: bubble,
      animation: animation,
    );
  }

  PetAction _getAction(String actionType) {
    return _actionMap[actionType] ?? _actionMap['unknown']!;
  }

  String _getBubble(String actionType) {
    return _bubbleMap[actionType] ?? '…';
  }

  Future<LottieComposition?> _loadAnimation(String path) async {
    if (_animationCache.containsKey(path)) {
      return _animationCache[path];
    }
    return null;
  }
}
