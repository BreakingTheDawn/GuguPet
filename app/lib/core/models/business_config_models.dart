/// 业务配置数据模型
/// 包含职位筛选、宠物回复、城市分组等业务配置
class BusinessConfig {
  /// 职位筛选选项
  final JobFiltersConfig jobFilters;
  
  /// 宠物回复模板
  final PetResponsesConfig petResponses;
  
  /// 城市分组
  final CityGroupsConfig cityGroups;
  
  /// LLM触发场景列表
  final List<String> llmTriggerScenes;
  
  BusinessConfig({
    required this.jobFilters,
    required this.petResponses,
    required this.cityGroups,
    required this.llmTriggerScenes,
  });
  
  factory BusinessConfig.fromJson(Map<String, dynamic> json) {
    return BusinessConfig(
      jobFilters: JobFiltersConfig.fromJson(json['jobFilters'] as Map<String, dynamic>),
      petResponses: PetResponsesConfig.fromJson(json['petResponses'] as Map<String, dynamic>),
      cityGroups: CityGroupsConfig.fromJson(json['cityGroups'] as Map<String, dynamic>),
      llmTriggerScenes: List<String>.from(json['llmTriggerScenes'] as List),
    );
  }
}

/// 职位筛选选项配置
class JobFiltersConfig {
  /// 薪资范围选项
  final List<String> salaries;
  
  /// 工作城市选项
  final List<String> cities;
  
  /// 工作经验选项
  final List<String> experiences;
  
  /// 学历要求选项
  final List<String> educations;
  
  /// 公司规模选项
  final List<String> companySizes;
  
  /// 融资阶段选项
  final List<String> fundingStages;
  
  JobFiltersConfig({
    required this.salaries,
    required this.cities,
    required this.experiences,
    required this.educations,
    required this.companySizes,
    required this.fundingStages,
  });
  
  factory JobFiltersConfig.fromJson(Map<String, dynamic> json) {
    return JobFiltersConfig(
      salaries: List<String>.from(json['salaries'] as List),
      cities: List<String>.from(json['cities'] as List),
      experiences: List<String>.from(json['experiences'] as List),
      educations: List<String>.from(json['educations'] as List),
      companySizes: List<String>.from(json['companySizes'] as List),
      fundingStages: List<String>.from(json['fundingStages'] as List),
    );
  }
}

/// 宠物回复模板配置
class PetResponsesConfig {
  /// 投喂回复
  final PetActionResponses feed;
  
  /// 玩耍回复
  final PetActionResponses play;
  
  /// 抚摸回复
  final PetActionResponses pet;
  
  /// 积极倾诉回复
  final PetActionResponses? confidePositive;
  
  /// 消极倾诉回复
  final PetActionResponses? confideNegative;
  
  /// 问候回复
  final PetActionResponses? greeting;
  
  PetResponsesConfig({
    required this.feed,
    required this.play,
    required this.pet,
    this.confidePositive,
    this.confideNegative,
    this.greeting,
  });
  
  factory PetResponsesConfig.fromJson(Map<String, dynamic> json) {
    return PetResponsesConfig(
      feed: PetActionResponses.fromJson(json['feed'] as Map<String, dynamic>),
      play: PetActionResponses.fromJson(json['play'] as Map<String, dynamic>),
      pet: PetActionResponses.fromJson(json['pet'] as Map<String, dynamic>),
      confidePositive: json['confide_positive'] != null 
          ? PetActionResponses.fromJson(json['confide_positive'] as Map<String, dynamic>) 
          : null,
      confideNegative: json['confide_negative'] != null 
          ? PetActionResponses.fromJson(json['confide_negative'] as Map<String, dynamic>) 
          : null,
      greeting: json['greeting'] != null 
          ? PetActionResponses.fromJson(json['greeting'] as Map<String, dynamic>) 
          : null,
    );
  }
  
  /// 根据场景名称获取回复模板
  PetActionResponses? getResponsesForScene(String scene) {
    return switch (scene) {
      'feed' => feed,
      'play' => play,
      'pet' => pet,
      'confide_positive' => confidePositive,
      'confide_negative' => confideNegative,
      'greeting' => greeting,
      _ => null,
    };
  }
}

/// 宠物动作回复
class PetActionResponses {
  /// 开心状态回复
  final List<String> happy;
  
  /// 普通状态回复
  final List<String> normal;
  
  /// 兴奋状态回复（可选）
  final List<String>? excited;
  
  /// 难过状态回复（可选）
  final List<String>? sad;
  
  /// 生气状态回复（可选）
  final List<String>? angry;
  
  PetActionResponses({
    required this.happy,
    required this.normal,
    this.excited,
    this.sad,
    this.angry,
  });
  
  factory PetActionResponses.fromJson(Map<String, dynamic> json) {
    return PetActionResponses(
      happy: List<String>.from(json['happy'] as List),
      normal: List<String>.from(json['normal'] as List),
      excited: json['excited'] != null ? List<String>.from(json['excited'] as List) : null,
      sad: json['sad'] != null ? List<String>.from(json['sad'] as List) : null,
      angry: json['angry'] != null ? List<String>.from(json['angry'] as List) : null,
    );
  }
  
  /// 根据情感类型获取回复列表
  List<String>? getResponsesForEmotion(String emotion) {
    return switch (emotion) {
      'happy' => happy,
      'normal' => normal,
      'excited' => excited,
      'sad' => sad,
      'angry' => angry,
      _ => normal,
    };
  }
}

/// 城市分组配置
class CityGroupsConfig {
  /// 热门城市
  final List<String> hot;
  
  /// 一线城市
  final List<String> firstTier;
  
  /// 新一线城市
  final List<String> newFirstTier;
  
  /// 二线城市
  final List<String>? secondTier;
  
  CityGroupsConfig({
    required this.hot,
    required this.firstTier,
    required this.newFirstTier,
    this.secondTier,
  });
  
  factory CityGroupsConfig.fromJson(Map<String, dynamic> json) {
    return CityGroupsConfig(
      hot: List<String>.from(json['hot'] as List),
      firstTier: List<String>.from(json['firstTier'] as List),
      newFirstTier: List<String>.from(json['newFirstTier'] as List),
      secondTier: json['secondTier'] != null 
          ? List<String>.from(json['secondTier'] as List) 
          : null,
    );
  }
  
  /// 获取所有城市（去重）
  List<String> get allCities {
    final cities = <String>{};
    cities.addAll(hot);
    cities.addAll(firstTier);
    cities.addAll(newFirstTier);
    if (secondTier != null) {
      cities.addAll(secondTier!);
    }
    return cities.toList();
  }
  
  /// 获取分组名称和对应城市列表
  Map<String, List<String>> get groupedCities {
    final result = <String, List<String>>{
      '热门城市': hot,
      '一线城市': firstTier,
      '新一线城市': newFirstTier,
    };
    if (secondTier != null && secondTier!.isNotEmpty) {
      result['二线城市'] = secondTier!;
    }
    return result;
  }
}
