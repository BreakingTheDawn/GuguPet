import 'package:flutter/foundation.dart';
import '../data/models/pet_model.dart';
import '../data/models/pet_emotion.dart';
import '../data/models/pet_memory.dart';
import '../data/models/pet_interaction.dart';
import '../data/datasources/pet_local_datasource.dart';
import '../services/pet_state_machine.dart';
import '../services/pet_growth_service.dart';
import '../services/pet_memory_service.dart';
import '../services/pet_interaction_service.dart';
import '../services/pet_response_generator.dart';
import '../../../core/services/llm_service.dart';

/// 宠物状态管理Provider
/// 整合所有宠物相关服务和状态
class PetProvider extends ChangeNotifier {
  final PetLocalDatasource _localDatasource;
  final PetStateMachine _stateMachine;
  final PetGrowthService _growthService;
  final PetMemoryService _memoryService;
  final PetInteractionService _interactionService;
  final PetResponseGenerator _responseGenerator;

  PetModel? _pet;
  List<PetMemoryModel> _memories = [];
  bool _isLoading = false;
  String? _error;

  PetProvider({
    PetLocalDatasource? localDatasource,
    PetStateMachine? stateMachine,
    PetGrowthService? growthService,
    PetMemoryService? memoryService,
    PetInteractionService? interactionService,
    PetResponseGenerator? responseGenerator,
    LLMService? llmService,
  })  : _localDatasource = localDatasource ?? PetLocalDatasource(),
        _stateMachine = stateMachine ?? PetStateMachine(),
        _growthService = growthService ?? PetGrowthService(),
        _memoryService = memoryService ?? PetMemoryService(),
        _interactionService = interactionService ?? PetInteractionService(),
        _responseGenerator = responseGenerator ?? PetResponseGenerator(llmService: llmService);

  // Getters
  PetModel? get pet => _pet;
  List<PetMemoryModel> get memories => _memories;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  // 便捷Getters
  PetEmotionType get currentEmotion => _pet?.currentEmotion ?? PetEmotionType.normal;
  int get bondLevel => _pet?.bondLevel ?? 1;
  double get bondExp => _pet?.bondExp ?? 0;
  String get bondTitle => _growthService.getLevelConfig(bondLevel).title;
  double get bondProgress => _growthService.getLevelProgress(bondExp, bondLevel);

  /// 初始化宠物数据
  Future<void> initialize(String userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // 获取或创建宠物
      _pet = await _localDatasource.getPetByUserId(userId);
      
      if (_pet == null) {
        // 创建新宠物
        _pet = PetModel.createDefault(userId);
        await _localDatasource.insertPet(_pet!);
      }

      // 加载记忆
      final memoryResult = await _memoryService.getAllMemories(_pet!.petId);
      _memories = memoryResult.all;

      // 处理长时间未互动
      await _processLongTimeNoSee();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 执行喂食互动
  Future<InteractionResult?> feed() async {
    if (_pet == null) return null;
    return await _performInteraction(InteractionType.feed);
  }

  /// 执行玩耍互动
  Future<InteractionResult?> play() async {
    if (_pet == null) return null;
    return await _performInteraction(InteractionType.play);
  }

  /// 执行抚摸互动
  Future<InteractionResult?> petAnimal() async {
    if (_pet == null) return null;
    return await _performInteraction(InteractionType.pet);
  }

  /// 执行倾诉互动（从ConfideService调用）
  Future<void> onConfide({
    required String content,
    required String actionType,
    required String emotionType,
  }) async {
    if (_pet == null) return;

    // 添加短期记忆
    await _memoryService.addShortTermMemory(
      petId: _pet!.petId,
      category: MemoryCategory.emotion,
      key: actionType,
      value: content,
      importance: emotionType == 'negative' ? 0.8 : 0.5,
    );

    // 如果是关键事件，添加关键事件记忆
    if (_isKeyEvent(actionType)) {
      await _memoryService.addKeyEventMemory(
        petId: _pet!.petId,
        key: actionType,
        value: content,
        emotionalWeight: emotionType == 'positive' ? 1.0 : -0.5,
      );
    }

    // 更新情感状态
    final trigger = emotionType == 'positive'
        ? EmotionTrigger.positiveEvent
        : EmotionTrigger.negativeEvent;

    final emotionResult = _stateMachine.transition(
      currentEmotion: _pet!.currentEmotion,
      currentEmotionValue: _pet!.emotionValue,
      trigger: trigger,
    );

    // 增加羁绊值
    final growthResult = _growthService.addBondExp(
      currentExp: _pet!.bondExp,
      currentLevel: _pet!.bondLevel,
      gain: 10,
      actionType: 'confide',
    );

    // 更新宠物数据
    _pet = _pet!.copyWith(
      currentEmotion: emotionResult.newEmotion,
      emotionValue: emotionResult.newEmotionValue,
      bondLevel: growthResult.newLevel,
      bondExp: growthResult.newExp,
      lastInteractionTime: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    await _localDatasource.updatePet(_pet!);

    // 刷新记忆
    final memoryResult = await _memoryService.getAllMemories(_pet!.petId);
    _memories = memoryResult.all;

    notifyListeners();
  }

  /// 执行互动
  Future<InteractionResult?> _performInteraction(InteractionType type) async {
    if (_pet == null) return null;

    try {
      final result = await _interactionService.performInteraction(
        pet: _pet!,
        interactionType: type,
      );

      _pet = result.updatedPet;

      // 刷新记忆
      final memoryResult = await _memoryService.getAllMemories(_pet!.petId);
      _memories = memoryResult.all;

      notifyListeners();
      return result;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return null;
    }
  }

  /// 处理长时间未互动
  Future<void> _processLongTimeNoSee() async {
    if (_pet == null) return;

    if (_stateMachine.shouldProcessLongTimeNoSee(_pet!.lastInteractionTime)) {
      final trigger = _stateMachine.getLongTimeTrigger(_pet!.lastInteractionTime);
      
      final emotionResult = _stateMachine.transition(
        currentEmotion: _pet!.currentEmotion,
        currentEmotionValue: _pet!.emotionValue,
        trigger: trigger,
      );

      // 减少羁绊值
      final growthResult = _growthService.reduceBondExp(
        currentExp: _pet!.bondExp,
        currentLevel: _pet!.bondLevel,
        loss: trigger == EmotionTrigger.longTimeNoSee ? 10 : 5,
      );

      _pet = _pet!.copyWith(
        currentEmotion: emotionResult.newEmotion,
        emotionValue: emotionResult.newEmotionValue,
        bondLevel: growthResult.newLevel,
        bondExp: growthResult.newExp,
        updatedAt: DateTime.now(),
      );

      await _localDatasource.updatePet(_pet!);
    }
  }

  /// 判断是否为关键事件
  bool _isKeyEvent(String actionType) {
    return ['offer_received', 'interview_received', 'job_rejected'].contains(actionType);
  }

  /// 获取互动冷却信息
  InteractionCooldown getCooldown(String interactionType) {
    if (_pet == null) {
      return InteractionCooldown(
        interactionType: interactionType,
        lastUsed: DateTime.now(),
        cooldownDuration: Duration.zero,
        isReady: true,
      );
    }
    return _interactionService.getCooldownInfo(_pet!, interactionType);
  }

  /// 生成回复（混合模式：本地模板 + 大模型）
  Future<String> generateResponse({
    required String scene,
    String? userMessage,
  }) async {
    if (_pet == null) return '咕咕~';

    final result = await _responseGenerator.generate(
      scene: scene,
      emotion: _pet!.currentEmotion,
      bondLevel: _pet!.bondLevel,
      memories: _memories,
      userMessage: userMessage,
    );

    return result.content;
  }
}
