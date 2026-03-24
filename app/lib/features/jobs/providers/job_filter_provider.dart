import 'package:flutter/foundation.dart';

/// 职位筛选状态管理
/// 负责管理职位筛选条件、筛选结果和状态
class JobFilterProvider extends ChangeNotifier {
  // ═══════════════════════════════════════════════════════════
  // 筛选选项常量定义
  // ═══════════════════════════════════════════════════════════

  /// 薪资范围选项
  static const List<String> salaryOptions = [
    '面议',
    '5k以下',
    '5-10k',
    '10-15k',
    '15-20k',
    '20-30k',
    '30k以上',
  ];

  /// 工作城市选项
  static const List<String> cityOptions = [
    '北京',
    '上海',
    '广州',
    '深圳',
    '杭州',
    '成都',
    '武汉',
    '西安',
    '南京',
    '苏州',
  ];

  /// 工作经验选项
  static const List<String> experienceOptions = [
    '不限',
    '应届生',
    '1-3年',
    '3-5年',
    '5-10年',
    '10年以上',
  ];

  /// 学历要求选项
  static const List<String> educationOptions = [
    '不限',
    '大专',
    '本科',
    '硕士',
    '博士',
  ];

  /// 公司规模选项
  static const List<String> companySizeOptions = [
    '不限',
    '0-20人',
    '20-99人',
    '100-499人',
    '500-999人',
    '1000人以上',
  ];

  /// 融资阶段选项
  static const List<String> fundingStageOptions = [
    '不限',
    '未融资',
    '天使轮',
    'A轮',
    'B轮',
    'C轮',
    '已上市',
  ];

  // ═══════════════════════════════════════════════════════════
  // 状态变量
  // ═══════════════════════════════════════════════════════════

  /// 选中的薪资范围（多选）
  final Set<String> _selectedSalaries = {};

  /// 选中的工作城市（多选）
  final Set<String> _selectedCities = {};

  /// 选中的工作经验（单选）
  String? _selectedExperience;

  /// 选中的学历要求（单选）
  String? _selectedEducation;

  /// 选中的公司规模（单选）
  String? _selectedCompanySize;

  /// 选中的融资阶段（单选）
  String? _selectedFundingStage;

  // ═══════════════════════════════════════════════════════════
  // Getter方法
  // ═══════════════════════════════════════════════════════════

  /// 获取选中的薪资范围
  Set<String> get selectedSalaries => Set.unmodifiable(_selectedSalaries);

  /// 获取选中的工作城市
  Set<String> get selectedCities => Set.unmodifiable(_selectedCities);

  /// 获取选中的工作经验
  String? get selectedExperience => _selectedExperience;

  /// 获取选中的学历要求
  String? get selectedEducation => _selectedEducation;

  /// 获取选中的公司规模
  String? get selectedCompanySize => _selectedCompanySize;

  /// 获取选中的融资阶段
  String? get selectedFundingStage => _selectedFundingStage;

  /// 是否有任何筛选条件
  bool get hasAnyFilter {
    return _selectedSalaries.isNotEmpty ||
        _selectedCities.isNotEmpty ||
        _selectedExperience != null ||
        _selectedEducation != null ||
        _selectedCompanySize != null ||
        _selectedFundingStage != null;
  }

  /// 获取筛选条件数量
  int get filterCount {
    int count = 0;
    count += _selectedSalaries.length;
    count += _selectedCities.length;
    if (_selectedExperience != null) count++;
    if (_selectedEducation != null) count++;
    if (_selectedCompanySize != null) count++;
    if (_selectedFundingStage != null) count++;
    return count;
  }

  /// 获取所有选中的筛选标签
  List<String> get activeFilterTags {
    final tags = <String>[];
    tags.addAll(_selectedSalaries);
    tags.addAll(_selectedCities);
    if (_selectedExperience != null) tags.add(_selectedExperience!);
    if (_selectedEducation != null) tags.add(_selectedEducation!);
    if (_selectedCompanySize != null) tags.add(_selectedCompanySize!);
    if (_selectedFundingStage != null) tags.add(_selectedFundingStage!);
    return tags;
  }

  // ═══════════════════════════════════════════════════════════
  // 筛选操作方法
  // ═══════════════════════════════════════════════════════════

  /// 切换薪资范围选择（多选）
  /// [salary] 薪资范围选项
  void toggleSalary(String salary) {
    if (_selectedSalaries.contains(salary)) {
      _selectedSalaries.remove(salary);
    } else {
      _selectedSalaries.add(salary);
    }
    notifyListeners();
  }

  /// 切换工作城市选择（多选）
  /// [city] 城市选项
  void toggleCity(String city) {
    if (_selectedCities.contains(city)) {
      _selectedCities.remove(city);
    } else {
      _selectedCities.add(city);
    }
    notifyListeners();
  }

  /// 设置工作经验（单选）
  /// [experience] 工作经验选项，传null表示取消选择
  void setExperience(String? experience) {
    if (_selectedExperience == experience) {
      _selectedExperience = null;
    } else {
      _selectedExperience = experience;
    }
    notifyListeners();
  }

  /// 设置学历要求（单选）
  /// [education] 学历选项，传null表示取消选择
  void setEducation(String? education) {
    if (_selectedEducation == education) {
      _selectedEducation = null;
    } else {
      _selectedEducation = education;
    }
    notifyListeners();
  }

  /// 设置公司规模（单选）
  /// [companySize] 公司规模选项，传null表示取消选择
  void setCompanySize(String? companySize) {
    if (_selectedCompanySize == companySize) {
      _selectedCompanySize = null;
    } else {
      _selectedCompanySize = companySize;
    }
    notifyListeners();
  }

  /// 设置融资阶段（单选）
  /// [fundingStage] 融资阶段选项，传null表示取消选择
  void setFundingStage(String? fundingStage) {
    if (_selectedFundingStage == fundingStage) {
      _selectedFundingStage = null;
    } else {
      _selectedFundingStage = fundingStage;
    }
    notifyListeners();
  }

  /// 重置所有筛选条件
  void resetAll() {
    _selectedSalaries.clear();
    _selectedCities.clear();
    _selectedExperience = null;
    _selectedEducation = null;
    _selectedCompanySize = null;
    _selectedFundingStage = null;
    notifyListeners();
  }

  /// 移除指定筛选标签
  /// [tag] 要移除的标签
  void removeFilterTag(String tag) {
    // 检查薪资范围
    if (_selectedSalaries.contains(tag)) {
      _selectedSalaries.remove(tag);
    }
    // 检查城市
    else if (_selectedCities.contains(tag)) {
      _selectedCities.remove(tag);
    }
    // 检查工作经验
    else if (_selectedExperience == tag) {
      _selectedExperience = null;
    }
    // 检查学历要求
    else if (_selectedEducation == tag) {
      _selectedEducation = null;
    }
    // 检查公司规模
    else if (_selectedCompanySize == tag) {
      _selectedCompanySize = null;
    }
    // 检查融资阶段
    else if (_selectedFundingStage == tag) {
      _selectedFundingStage = null;
    }
    notifyListeners();
  }

  /// 检查职位是否符合当前筛选条件
  /// [job] 职位数据Map
  /// 返回true表示符合筛选条件
  bool matchesFilter(Map<String, dynamic> job) {
    // 如果没有筛选条件，直接返回true
    if (!hasAnyFilter) return true;

    // 检查薪资范围（如果有选中）
    if (_selectedSalaries.isNotEmpty) {
      final salary = job['salary'] as String?;
      if (salary == null || !_selectedSalaries.any((s) => _salaryMatches(s, salary))) {
        return false;
      }
    }

    // 检查城市（如果有选中）
    if (_selectedCities.isNotEmpty) {
      final location = job['location'] as String?;
      if (location == null || !_selectedCities.any((c) => location.contains(c))) {
        return false;
      }
    }

    // 检查工作经验（如果有选中）
    if (_selectedExperience != null && _selectedExperience != '不限') {
      final experience = job['experience'] as String?;
      if (experience == null || experience != _selectedExperience) {
        return false;
      }
    }

    // 检查学历要求（如果有选中）
    if (_selectedEducation != null && _selectedEducation != '不限') {
      final education = job['education'] as String?;
      if (education == null || education != _selectedEducation) {
        return false;
      }
    }

    // 检查公司规模（如果有选中）
    if (_selectedCompanySize != null && _selectedCompanySize != '不限') {
      final companySize = job['companySize'] as String?;
      if (companySize == null || companySize != _selectedCompanySize) {
        return false;
      }
    }

    // 检查融资阶段（如果有选中）
    if (_selectedFundingStage != null && _selectedFundingStage != '不限') {
      final fundingStage = job['fundingStage'] as String?;
      if (fundingStage == null || fundingStage != _selectedFundingStage) {
        return false;
      }
    }

    return true;
  }

  /// 检查薪资是否匹配
  /// [filterSalary] 筛选条件中的薪资
  /// [jobSalary] 职位薪资字符串
  bool _salaryMatches(String filterSalary, String jobSalary) {
    // 简单的字符串包含匹配
    // 实际项目中可能需要更复杂的薪资范围解析
    return jobSalary.contains(filterSalary.replaceAll('k', '').replaceAll('K', '')) ||
        jobSalary.contains(filterSalary);
  }

  /// 从另一个Provider复制筛选条件
  /// [other] 源Provider
  void copyFrom(JobFilterProvider other) {
    _selectedSalaries.clear();
    _selectedSalaries.addAll(other._selectedSalaries);
    _selectedCities.clear();
    _selectedCities.addAll(other._selectedCities);
    _selectedExperience = other._selectedExperience;
    _selectedEducation = other._selectedEducation;
    _selectedCompanySize = other._selectedCompanySize;
    _selectedFundingStage = other._selectedFundingStage;
    notifyListeners();
  }

  /// 清除所有数据
  void clear() {
    resetAll();
  }
}
