import 'package:flutter/material.dart';

/// 宠物皮肤配置模型
/// 定义宠物可用的皮肤样式
class PetSkin {
  /// 皮肤唯一标识
  final String id;

  /// 皮肤名称
  final String name;

  /// 主色调
  final Color primaryColor;

  /// 次色调（用于渐变或高光）
  final Color secondaryColor;

  /// 是否为VIP专属
  final bool isVipOnly;

  /// 皮肤描述
  final String description;

  const PetSkin({
    required this.id,
    required this.name,
    required this.primaryColor,
    required this.secondaryColor,
    this.isVipOnly = false,
    this.description = '',
  });
}

/// 宠物配饰配置模型
/// 定义宠物可佩戴的配饰
class PetAccessory {
  /// 配饰唯一标识
  final String id;

  /// 配饰名称
  final String name;

  /// 配饰图标（emoji或图标名称）
  final String icon;

  /// 配饰位置：head（头部）、neck（颈部）、back（背部）
  final String position;

  /// 是否为VIP专属
  final bool isVipOnly;

  /// 配饰描述
  final String description;

  const PetAccessory({
    required this.id,
    required this.name,
    required this.icon,
    required this.position,
    this.isVipOnly = false,
    this.description = '',
  });
}

/// 宠物外观配置
/// 包含所有可用的皮肤和配饰配置
class PetAppearanceConfig {
  PetAppearanceConfig._();

  /// 默认皮肤ID
  static const String defaultSkinId = 'default';

  /// 无配饰ID
  static const String noAccessoryId = 'none';

  /// 所有可用皮肤配置
  /// 包含免费皮肤和VIP专属皮肤
  static const List<PetSkin> allSkins = [
    // 免费皮肤
    PetSkin(
      id: 'default',
      name: '经典咕咕',
      primaryColor: Color(0xFF6B7280),
      secondaryColor: Color(0xFF9CA3AF),
      isVipOnly: false,
      description: '默认的灰色咕咕，朴实无华',
    ),

    // VIP专属皮肤
    PetSkin(
      id: 'golden',
      name: '金色咕咕',
      primaryColor: Color(0xFFF59E0B),
      secondaryColor: Color(0xFFFBBF24),
      isVipOnly: true,
      description: '闪耀的金色，彰显尊贵身份',
    ),
    PetSkin(
      id: 'pink',
      name: '粉色咕咕',
      primaryColor: Color(0xFFEC4899),
      secondaryColor: Color(0xFFF472B6),
      isVipOnly: true,
      description: '温柔的粉色，可爱又治愈',
    ),
    PetSkin(
      id: 'blue',
      name: '蓝色咕咕',
      primaryColor: Color(0xFF3B82F6),
      secondaryColor: Color(0xFF60A5FA),
      isVipOnly: true,
      description: '清新的蓝色，如天空般纯净',
    ),
    PetSkin(
      id: 'green',
      name: '绿色咕咕',
      primaryColor: Color(0xFF10B981),
      secondaryColor: Color(0xFF34D399),
      isVipOnly: true,
      description: '生机勃勃的绿色，充满活力',
    ),
    PetSkin(
      id: 'purple',
      name: '紫色咕咕',
      primaryColor: Color(0xFF8B5CF6),
      secondaryColor: Color(0xFFA78BFA),
      isVipOnly: true,
      description: '神秘的紫色，优雅又迷人',
    ),
    PetSkin(
      id: 'rainbow',
      name: '彩虹咕咕',
      primaryColor: Color(0xFFEC4899),
      secondaryColor: Color(0xFF8B5CF6),
      isVipOnly: true,
      description: '七彩渐变，独一无二的存在',
    ),
  ];

  /// 所有可用配饰配置
  /// 包含免费配饰和VIP专属配饰
  static const List<PetAccessory> allAccessories = [
    // 无配饰（默认）
    PetAccessory(
      id: 'none',
      name: '无配饰',
      icon: '',
      position: '',
      isVipOnly: false,
      description: '不佩戴任何配饰',
    ),

    // VIP专属配饰 - 头部
    PetAccessory(
      id: 'bow',
      name: '蝴蝶结',
      icon: '🎀',
      position: 'head',
      isVipOnly: true,
      description: '可爱的蝴蝶结，增添俏皮感',
    ),
    PetAccessory(
      id: 'hat',
      name: '小帽子',
      icon: '🎩',
      position: 'head',
      isVipOnly: true,
      description: '绅士的小礼帽，优雅又帅气',
    ),
    PetAccessory(
      id: 'crown',
      name: '小皇冠',
      icon: '👑',
      position: 'head',
      isVipOnly: true,
      description: '王者之冠，彰显尊贵',
    ),

    // VIP专属配饰 - 颈部
    PetAccessory(
      id: 'scarf',
      name: '小围巾',
      icon: '🧣',
      position: 'neck',
      isVipOnly: true,
      description: '温暖的小围巾，冬日必备',
    ),
    PetAccessory(
      id: 'bowtie',
      name: '领结',
      icon: '🎀',
      position: 'neck',
      isVipOnly: true,
      description: '精致的领结，正式场合首选',
    ),

    // VIP专属配饰 - 背部
    PetAccessory(
      id: 'wings',
      name: '小翅膀',
      icon: '🦋',
      position: 'back',
      isVipOnly: true,
      description: '梦幻的小翅膀，仿佛能飞翔',
    ),
    PetAccessory(
      id: 'cape',
      name: '小披风',
      icon: '🦸',
      position: 'back',
      isVipOnly: true,
      description: '英雄的小披风，充满力量',
    ),
  ];

  /// 根据ID获取皮肤配置
  static PetSkin? getSkinById(String id) {
    try {
      return allSkins.firstWhere((skin) => skin.id == id);
    } catch (e) {
      return null;
    }
  }

  /// 根据ID获取配饰配置
  static PetAccessory? getAccessoryById(String id) {
    try {
      return allAccessories.firstWhere((accessory) => accessory.id == id);
    } catch (e) {
      return null;
    }
  }

  /// 获取免费皮肤列表
  static List<PetSkin> getFreeSkins() {
    return allSkins.where((skin) => !skin.isVipOnly).toList();
  }

  /// 获取VIP专属皮肤列表
  static List<PetSkin> getVipSkins() {
    return allSkins.where((skin) => skin.isVipOnly).toList();
  }

  /// 获取免费配饰列表
  static List<PetAccessory> getFreeAccessories() {
    return allAccessories.where((accessory) => !accessory.isVipOnly).toList();
  }

  /// 获取VIP专属配饰列表
  static List<PetAccessory> getVipAccessories() {
    return allAccessories.where((accessory) => accessory.isVipOnly).toList();
  }

  /// 获取指定位置的配饰列表
  static List<PetAccessory> getAccessoriesByPosition(String position) {
    return allAccessories.where((accessory) => accessory.position == position).toList();
  }

  /// 检查皮肤是否可用（考虑VIP状态）
  static bool isSkinAvailable(String skinId, bool isVip) {
    final skin = getSkinById(skinId);
    if (skin == null) return false;
    return !skin.isVipOnly || isVip;
  }

  /// 检查配饰是否可用（考虑VIP状态）
  static bool isAccessoryAvailable(String accessoryId, bool isVip) {
    final accessory = getAccessoryById(accessoryId);
    if (accessory == null) return false;
    return !accessory.isVipOnly || isVip;
  }
}
