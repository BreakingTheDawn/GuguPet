/// 业务配置数据模型
class BusinessConfig {
  /// 职位筛选选项
  final JobFiltersConfig jobFilters;
  
  /// 宠物回复模板
  final PetResponsesConfig petResponses;
  
  /// 城市分组
  final CityGroupsConfig cityGroups;
  
  BusinessConfig({
    required this.jobFilters,
    required this.petResponses,
    required this.cityGroups,
  });
  
  factory BusinessConfig.fromJson(Map<String, dynamic> json) {
    return BusinessConfig(
      jobFilters: JobFiltersConfig.fromJson(json['jobFilters'] as Map<String, dynamic>),
      petResponses: PetResponsesConfig.fromJson(json['petResponses'] as Map<String, dynamic>),
      cityGroups: CityGroupsConfig.fromJson(json['cityGroups'] as Map<String, dynamic>),
    );
  }
}

/// 职位筛选选项配置
class JobFiltersConfig {
  final List<String> salaries;
  final List<String> cities;
  final List<String> experiences;
  final List<String> educations;
  final List<String> companySizes;
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
  final PetActionResponses feed;
  final PetActionResponses play;
  final PetActionResponses pet;
  
  PetResponsesConfig({
    required this.feed,
    required this.play,
    required this.pet,
  });
  
  factory PetResponsesConfig.fromJson(Map<String, dynamic> json) {
    return PetResponsesConfig(
      feed: PetActionResponses.fromJson(json['feed'] as Map<String, dynamic>),
      play: PetActionResponses.fromJson(json['play'] as Map<String, dynamic>),
      pet: PetActionResponses.fromJson(json['pet'] as Map<String, dynamic>),
    );
  }
}

/// 宠物动作回复
class PetActionResponses {
  final List<String> happy;
  final List<String> normal;
  
  PetActionResponses({
    required this.happy,
    required this.normal,
  });
  
  factory PetActionResponses.fromJson(Map<String, dynamic> json) {
    return PetActionResponses(
      happy: List<String>.from(json['happy'] as List),
      normal: List<String>.from(json['normal'] as List),
    );
  }
}

/// 城市分组配置
class CityGroupsConfig {
  final List<String> hot;
  final List<String> firstTier;
  final List<String> newFirstTier;
  
  CityGroupsConfig({
    required this.hot,
    required this.firstTier,
    required this.newFirstTier,
  });
  
  factory CityGroupsConfig.fromJson(Map<String, dynamic> json) {
    return CityGroupsConfig(
      hot: List<String>.from(json['hot'] as List),
      firstTier: List<String>.from(json['firstTier'] as List),
      newFirstTier: List<String>.from(json['newFirstTier'] as List),
    );
  }
}
