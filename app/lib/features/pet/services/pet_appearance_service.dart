import 'dart:convert';
import '../data/models/pet_model.dart';
import '../data/models/pet_appearance.dart';
import '../data/datasources/pet_local_datasource.dart';

/// 宠物外观服务
/// 管理宠物皮肤和配饰的切换、解锁等功能
class PetAppearanceService {
  /// 宠物本地数据源
  final PetLocalDatasource _localDatasource;

  PetAppearanceService({
    PetLocalDatasource? localDatasource,
  }) : _localDatasource = localDatasource ?? PetLocalDatasource();

  /// 获取所有皮肤配置
  List<PetSkin> getAllSkins() {
    return PetAppearanceConfig.allSkins;
  }

  /// 获取所有配饰配置
  List<PetAccessory> getAllAccessories() {
    return PetAppearanceConfig.allAccessories;
  }

  /// 获取可用的皮肤列表（根据VIP状态）
  List<PetSkin> getAvailableSkins(bool isVip) {
    return PetAppearanceConfig.allSkins
        .where((skin) => !skin.isVipOnly || isVip)
        .toList();
  }

  /// 获取可用的配饰列表（根据VIP状态）
  List<PetAccessory> getAvailableAccessories(bool isVip) {
    return PetAppearanceConfig.allAccessories
        .where((accessory) => !accessory.isVipOnly || isVip)
        .toList();
  }

  /// 更新宠物皮肤
  /// [pet] 当前宠物数据
  /// [skinId] 新皮肤ID
  /// [isVip] 是否为VIP用户
  /// 返回更新后的宠物数据，如果皮肤不可用则返回null
  Future<PetModel?> updateSkin(PetModel pet, String skinId, bool isVip) async {
    // 检查皮肤是否可用
    if (!PetAppearanceConfig.isSkinAvailable(skinId, isVip)) {
      return null;
    }

    // 更新已解锁皮肤列表
    final unlockedSkins = List<String>.from(pet.unlockedSkins);
    if (!unlockedSkins.contains(skinId)) {
      unlockedSkins.add(skinId);
    }

    // 创建更新后的宠物数据
    final updatedPet = pet.copyWith(
      skinId: skinId,
      unlockedSkins: unlockedSkins,
      updatedAt: DateTime.now(),
    );

    // 保存到数据库
    await _localDatasource.updatePet(updatedPet);

    return updatedPet;
  }

  /// 更新宠物配饰
  /// [pet] 当前宠物数据
  /// [accessoryId] 新配饰ID
  /// [isVip] 是否为VIP用户
  /// 返回更新后的宠物数据，如果配饰不可用则返回null
  Future<PetModel?> updateAccessory(PetModel pet, String accessoryId, bool isVip) async {
    // 检查配饰是否可用
    if (!PetAppearanceConfig.isAccessoryAvailable(accessoryId, isVip)) {
      return null;
    }

    // 更新已解锁配饰列表
    final unlockedAccessories = List<String>.from(pet.unlockedAccessories);
    if (!unlockedAccessories.contains(accessoryId)) {
      unlockedAccessories.add(accessoryId);
    }

    // 创建更新后的宠物数据
    final updatedPet = pet.copyWith(
      accessoryId: accessoryId,
      unlockedAccessories: unlockedAccessories,
      updatedAt: DateTime.now(),
    );

    // 保存到数据库
    await _localDatasource.updatePet(updatedPet);

    return updatedPet;
  }

  /// 为VIP用户解锁所有皮肤和配饰
  /// [pet] 当前宠物数据
  /// 返回更新后的宠物数据
  Future<PetModel> unlockVipItems(PetModel pet) async {
    // 获取所有VIP皮肤ID
    final vipSkinIds = PetAppearanceConfig.getVipSkins()
        .map((skin) => skin.id)
        .toList();

    // 获取所有VIP配饰ID
    final vipAccessoryIds = PetAppearanceConfig.getVipAccessories()
        .map((accessory) => accessory.id)
        .toList();

    // 合并已解锁列表
    final unlockedSkins = List<String>.from(pet.unlockedSkins);
    for (final skinId in vipSkinIds) {
      if (!unlockedSkins.contains(skinId)) {
        unlockedSkins.add(skinId);
      }
    }

    final unlockedAccessories = List<String>.from(pet.unlockedAccessories);
    for (final accessoryId in vipAccessoryIds) {
      if (!unlockedAccessories.contains(accessoryId)) {
        unlockedAccessories.add(accessoryId);
      }
    }

    // 创建更新后的宠物数据
    final updatedPet = pet.copyWith(
      unlockedSkins: unlockedSkins,
      unlockedAccessories: unlockedAccessories,
      updatedAt: DateTime.now(),
    );

    // 保存到数据库
    await _localDatasource.updatePet(updatedPet);

    return updatedPet;
  }

  /// 获取当前皮肤配置
  /// [pet] 宠物数据
  /// 返回当前皮肤配置，如果不存在则返回默认皮肤
  PetSkin getCurrentSkin(PetModel pet) {
    return PetAppearanceConfig.getSkinById(pet.skinId) ??
        PetAppearanceConfig.getSkinById(PetAppearanceConfig.defaultSkinId)!;
  }

  /// 获取当前配饰配置
  /// [pet] 宠物数据
  /// 返回当前配饰配置，如果不存在则返回无配饰
  PetAccessory? getCurrentAccessory(PetModel pet) {
    if (pet.accessoryId == PetAppearanceConfig.noAccessoryId) {
      return null;
    }
    return PetAppearanceConfig.getAccessoryById(pet.accessoryId);
  }

  /// 检查用户是否拥有指定皮肤
  /// [pet] 宠物数据
  /// [skinId] 皮肤ID
  bool hasSkin(PetModel pet, String skinId) {
    return pet.unlockedSkins.contains(skinId);
  }

  /// 检查用户是否拥有指定配饰
  /// [pet] 宠物数据
  /// [accessoryId] 配饰ID
  bool hasAccessory(PetModel pet, String accessoryId) {
    return pet.unlockedAccessories.contains(accessoryId);
  }

  /// 从JSON字符串解析已解锁列表
  List<String> parseUnlockedList(String? jsonString) {
    if (jsonString == null || jsonString.isEmpty) {
      return [];
    }
    try {
      final List<dynamic> list = jsonDecode(jsonString);
      return list.map((e) => e.toString()).toList();
    } catch (e) {
      return [];
    }
  }

  /// 将已解锁列表转换为JSON字符串
  String stringifyUnlockedList(List<String> list) {
    return jsonEncode(list);
  }
}
