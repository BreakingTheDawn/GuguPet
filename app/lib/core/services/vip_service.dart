import '../../data/models/user_profile.dart';
import '../../features/pet/data/models/pet_appearance.dart';

/// VIP服务
/// 统一管理VIP状态判断和特权功能
class VipService {
  /// 单例实例
  static final VipService _instance = VipService._internal();
  factory VipService() => _instance;
  VipService._internal();

  /// 检查用户是否为有效VIP
  /// [profile] 用户资料
  /// 返回是否为有效VIP用户
  bool isVip(UserProfile? profile) {
    if (profile == null) return false;
    if (!profile.vipStatus) return false;
    if (profile.vipExpireTime == null) return false;
    return profile.vipExpireTime!.isAfter(DateTime.now());
  }

  /// 获取羁绊经验加成倍率
  /// [isVip] 是否为VIP用户
  /// 返回经验加成倍率（VIP: 1.5, 普通: 1.0）
  double getBondExpMultiplier(bool isVip) {
    return isVip ? 1.5 : 1.0;
  }

  /// 获取冷却时间倍率
  /// [isVip] 是否为VIP用户
  /// 返回冷却时间倍率（VIP: 0.5, 普通: 1.0）
  double getCooldownMultiplier(bool isVip) {
    return isVip ? 0.5 : 1.0;
  }

  /// 获取可用的皮肤列表
  /// [isVip] 是否为VIP用户
  /// 返回可用皮肤列表
  List<PetSkin> getAvailableSkins(bool isVip) {
    if (isVip) {
      return PetAppearanceConfig.allSkins;
    }
    return PetAppearanceConfig.getFreeSkins();
  }

  /// 获取可用的配饰列表
  /// [isVip] 是否为VIP用户
  /// 返回可用配饰列表
  List<PetAccessory> getAvailableAccessories(bool isVip) {
    if (isVip) {
      return PetAppearanceConfig.allAccessories;
    }
    return PetAppearanceConfig.getFreeAccessories();
  }

  /// 检查皮肤是否可用
  /// [skinId] 皮肤ID
  /// [isVip] 是否为VIP用户
  /// 返回是否可用
  bool isSkinAvailable(String skinId, bool isVip) {
    return PetAppearanceConfig.isSkinAvailable(skinId, isVip);
  }

  /// 检查配饰是否可用
  /// [accessoryId] 配饰ID
  /// [isVip] 是否为VIP用户
  /// 返回是否可用
  bool isAccessoryAvailable(String accessoryId, bool isVip) {
    return PetAppearanceConfig.isAccessoryAvailable(accessoryId, isVip);
  }

  /// 获取皮肤配置
  /// [skinId] 皮肤ID
  /// 返回皮肤配置，不存在则返回null
  PetSkin? getSkinById(String skinId) {
    return PetAppearanceConfig.getSkinById(skinId);
  }

  /// 获取配饰配置
  /// [accessoryId] 配饰ID
  /// 返回配饰配置，不存在则返回null
  PetAccessory? getAccessoryById(String accessoryId) {
    return PetAppearanceConfig.getAccessoryById(accessoryId);
  }

  /// 计算实际羁绊经验值
  /// [baseGain] 基础经验值
  /// [isVip] 是否为VIP用户
  /// 返回实际获得的经验值
  double calculateActualBondExp(double baseGain, bool isVip) {
    return baseGain * getBondExpMultiplier(isVip);
  }

  /// 计算实际冷却时间
  /// [baseCooldownMs] 基础冷却时间（毫秒）
  /// [isVip] 是否为VIP用户
  /// 返回实际冷却时间（毫秒）
  int calculateActualCooldown(int baseCooldownMs, bool isVip) {
    return (baseCooldownMs * getCooldownMultiplier(isVip)).toInt();
  }

  /// 获取VIP状态描述
  /// [profile] 用户资料
  /// 返回VIP状态描述文本
  String getVipStatusDescription(UserProfile? profile) {
    if (!isVip(profile)) {
      return '未开通VIP';
    }

    final expireTime = profile!.vipExpireTime!;
    final now = DateTime.now();
    final difference = expireTime.difference(now).inDays;

    if (difference <= 0) {
      return 'VIP已过期';
    } else if (difference <= 7) {
      return 'VIP还剩 $difference 天到期';
    } else {
      return 'VIP有效期至 ${expireTime.year}-${expireTime.month.toString().padLeft(2, '0')}-${expireTime.day.toString().padLeft(2, '0')}';
    }
  }
}
