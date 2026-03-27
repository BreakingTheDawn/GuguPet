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
import '../services/pet_appearance_service.dart';
import '../../../core/services/llm_service.dart';
import '../../../core/services/vip_service.dart';
import '../../../data/models/user_profile.dart';

/// 宠物状态管理Provider
/// 整合所有宠物相关服务和状态
/// 支持VIP用户的羁绊加速、互动加速和外观功能
class PetProvider extends ChangeNotifier {
  /// 宠物本地数据源
  final PetLocalDatasource _localDatasource;

  /// 情感状态机
  final PetStateMachine _stateMachine;

  /// 羁绊成长服务
  final PetGrowthService _growthService;

  /// 宠物记忆服务
  final PetMemoryService _memoryService;

  /// 宠物互动服务
  final PetInteractionService _interactionService;

  /// 宠物回复生成器
  final PetResponseGenerator _responseGenerator;

  /// VIP服务
  final VipService _vipService;

  /// 宠物外观服务
  final PetAppearanceService _appearanceService;

  /// 当前宠物数据
  PetModel? _pet;

  /// 宠物记忆列表
  List<PetMemoryModel> _memories = [];

  /// 是否正在加载
  bool _isLoading = false;

  /// 错误信息
  String? _error;

  /// 用户资料（用于判断VIP状态）
  UserProfile? _userProfile;

  PetProvider({
    PetLocalDatasource? localDatasource,
    PetStateMachine? stateMachine,
    PetGrowthService? growthService,
    PetMemoryService? memoryService,
    PetInteractionService? interactionService,
    PetResponseGenerator? responseGenerator,
    VipService? vipService,
    PetAppearanceService? appearanceService,
    LLMService? llmService,
  })  : _localDatasource = localDatasource ?? PetLocalDatasource(),
        _stateMachine = stateMachine ?? PetStateMachine(),
        _growthService = growthService ?? PetGrowthService(),
        _memoryService = memoryService ?? PetMemoryService(),
        _interactionService = interactionService ?? PetInteractionService(),
        _responseGenerator = responseGenerator ?? PetResponseGenerator(llmService: llmService),
        _vipService = vipService ?? VipService(),
        _appearanceService = appearanceService ?? PetAppearanceService();

  // ==================== Getters ====================

  /// 当前宠物数据
  PetModel? get pet => _pet;

  /// 宠物记忆列表
  List<PetMemoryModel> get memories => _memories;

  /// 是否正在加载
  bool get isLoading => _isLoading;

  /// 错误信息
  String? get error => _error;

  /// 当前情感类型
  PetEmotionType get currentEmotion => _pet?.currentEmotion ?? PetEmotionType.normal;

  /// 羁绊等级
  int get bondLevel => _pet?.bondLevel ?? 1;

  /// 羁绊经验值
  double get bondExp => _pet?.bondExp ?? 0;

  /// 羁绊称号
  String get bondTitle => _growthService.getLevelConfig(bondLevel).title;

  /// 羁绊进度
  double get bondProgress => _growthService.getLevelProgress(bondExp, bondLevel);

  /// 是否为VIP用户
  bool get isVip => _vipService.isVip(_userProfile);

  /// 羁绊经验加成倍率
  double get bondExpMultiplier => _vipService.getBondExpMultiplier(isVip);

  /// 冷却时间倍率
  double get cooldownMultiplier => _vipService.getCooldownMultiplier(isVip);

  /// 当前皮肤ID
  String get skinId => _pet?.skinId ?? 'default';

  /// 当前配饰ID
  String get accessoryId => _pet?.accessoryId ?? 'none';

  /// 已解锁皮肤列表
  List<String> get unlockedSkins => _pet?.unlockedSkins ?? ['default'];

  /// 已解锁配饰列表
  List<String> get unlockedAccessories => _pet?.unlockedAccessories ?? ['none'];

  // ==================== 初始化 ====================

  /// 初始化宠物数据
  /// [userId] 用户ID
  /// [userProfile] 用户资料（用于判断VIP状态）
  Future<void> initialize(String userId, {UserProfile? userProfile}) async {
    _isLoading = true;
    _error = null;
    _userProfile = userProfile;
    notifyListeners();

    try {
      // 获取或创建宠物
      _pet = await _localDatasource.getPetByUserId(userId);

      if (_pet == null) {
        // 创建新宠物
        _pet = PetModel.createDefault(userId);
        await _localDatasource.insertPet(_pet!);
      }

      // 如果是VIP用户，解锁所有VIP外观
      if (isVip && _pet != null) {
        _pet = await _appearanceService.unlockVipItems(_pet!);
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

  /// 更新用户资料（用于更新VIP状态）
  void updateUserProfile(UserProfile? userProfile) {
    _userProfile = userProfile;
    notifyListeners();
  }

  // ==================== 互动功能 ====================

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

    // 增加羁绊值（VIP用户经验值+50%）
    final growthResult = _growthService.addBondExp(
      currentExp: _pet!.bondExp,
      currentLevel: _pet!.bondLevel,
      gain: 10,
      actionType: 'confide',
      isVip: isVip,
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

  /// 执行互动（内部方法）
  Future<InteractionResult?> _performInteraction(InteractionType type) async {
    if (_pet == null) return null;

    try {
      // 传递VIP状态给互动服务
      final result = await _interactionService.performInteraction(
        pet: _pet!,
        interactionType: type,
        isVip: isVip,
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
  /// 自动应用VIP冷却缩短
  InteractionCooldown getCooldown(String interactionType) {
    if (_pet == null) {
      return InteractionCooldown(
        interactionType: interactionType,
        lastUsed: DateTime.now(),
        cooldownDuration: Duration.zero,
        isReady: true,
      );
    }
    // 传递VIP状态获取冷却信息
    return _interactionService.getCooldownInfo(_pet!, interactionType, isVip);
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

  // ==================== 外观功能 ====================

  /// 获取可用的皮肤列表
  List<dynamic> getAvailableSkins() {
    return _appearanceService.getAvailableSkins(isVip);
  }

  /// 获取可用的配饰列表
  List<dynamic> getAvailableAccessories() {
    return _appearanceService.getAvailableAccessories(isVip);
  }

  /// 更新宠物皮肤
  /// [skinId] 皮肤ID
  /// 返回是否成功
  Future<bool> updatePetSkin(String skinId) async {
    if (_pet == null) return false;

    try {
      final updatedPet = await _appearanceService.updateSkin(
        _pet!,
        skinId,
        isVip,
      );

      if (updatedPet != null) {
        _pet = updatedPet;
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// 更新宠物配饰
  /// [accessoryId] 配饰ID
  /// 返回是否成功
  Future<bool> updatePetAccessory(String accessoryId) async {
    if (_pet == null) return false;

    try {
      final updatedPet = await _appearanceService.updateAccessory(
        _pet!,
        accessoryId,
        isVip,
      );

      if (updatedPet != null) {
        _pet = updatedPet;
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// 获取当前皮肤配置
  dynamic getCurrentSkin() {
    if (_pet == null) return null;
    return _appearanceService.getCurrentSkin(_pet!);
  }

  /// 获取当前配饰配置
  dynamic getCurrentAccessory() {
    if (_pet == null) return null;
    return _appearanceService.getCurrentAccessory(_pet!);
  }

  // ==================== VIP特权信息 ====================

  /// 获取VIP状态描述
  String getVipStatusDescription() {
    return _vipService.getVipStatusDescription(_userProfile);
  }

  /// 获取羁绊加成描述
  String getBondExpBonusDescription() {
    if (isVip) {
      return '羁绊值获取 +50%';
    }
    return '开通VIP可享羁绊值+50%加成';
  }

  /// 获取冷却加成描述
  String getCooldownBonusDescription() {
    if (isVip) {
      return '互动冷却时间 -50%';
    }
    return '开通VIP可享互动冷却-50%';
  }
}
