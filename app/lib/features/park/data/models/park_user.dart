import 'package:flutter/material.dart';

/// 公园用户模型
/// 用于展示公园内的用户信息
class ParkUser {
  /// 用户ID
  final String id;
  
  /// 用户昵称
  final String name;
  
  /// 用户头像URL（预留后端对接）
  final String? avatar;
  
  /// 职位标签
  final String? title;
  
  /// 所在区域ID
  final String zoneId;
  
  /// 最后活跃时间
  final DateTime? lastActiveAt;
  
  /// 宠物颜色
  final Color petColor;
  
  /// 宠物配饰类型
  final String petAccessory;

  /// 构造函数
  const ParkUser({
    required this.id,
    required this.name,
    this.avatar,
    this.title,
    required this.zoneId,
    this.lastActiveAt,
    required this.petColor,
    this.petAccessory = 'none',
  });

  /// 从JSON Map创建模型实例
  factory ParkUser.fromJson(Map<String, dynamic> json) {
    return ParkUser(
      id: json['id'] as String,
      name: json['name'] as String,
      avatar: json['avatar'] as String?,
      title: json['title'] as String?,
      zoneId: json['zoneId'] as String,
      lastActiveAt: json['lastActiveAt'] != null
          ? DateTime.parse(json['lastActiveAt'] as String)
          : null,
      petColor: Color(json['petColor'] as int),
      petAccessory: json['petAccessory'] as String? ?? 'none',
    );
  }

  /// 从数据库Map创建模型实例
  factory ParkUser.fromDatabase(Map<String, dynamic> map) {
    return ParkUser(
      id: map['id'] as String,
      name: map['name'] as String,
      avatar: map['avatar'] as String?,
      title: map['title'] as String?,
      zoneId: map['zone_id'] as String,
      lastActiveAt: map['last_active_at'] != null
          ? DateTime.parse(map['last_active_at'] as String)
          : null,
      petColor: Color(map['pet_color'] as int),
      petAccessory: map['pet_accessory'] as String? ?? 'none',
    );
  }

  /// 将模型转换为JSON Map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'avatar': avatar,
      'title': title,
      'zoneId': zoneId,
      'lastActiveAt': lastActiveAt?.toIso8601String(),
      'petColor': petColor.value,
      'petAccessory': petAccessory,
    };
  }

  /// 将模型转换为数据库Map
  Map<String, dynamic> toDatabaseMap() {
    return {
      'id': id,
      'name': name,
      'avatar': avatar,
      'title': title,
      'zone_id': zoneId,
      'last_active_at': lastActiveAt?.toIso8601String(),
      'pet_color': petColor.value,
      'pet_accessory': petAccessory,
    };
  }

  /// 复制并修改部分字段
  ParkUser copyWith({
    String? id,
    String? name,
    String? avatar,
    String? title,
    String? zoneId,
    DateTime? lastActiveAt,
    Color? petColor,
    String? petAccessory,
  }) {
    return ParkUser(
      id: id ?? this.id,
      name: name ?? this.name,
      avatar: avatar ?? this.avatar,
      title: title ?? this.title,
      zoneId: zoneId ?? this.zoneId,
      lastActiveAt: lastActiveAt ?? this.lastActiveAt,
      petColor: petColor ?? this.petColor,
      petAccessory: petAccessory ?? this.petAccessory,
    );
  }

  @override
  String toString() {
    return 'ParkUser(id: $id, name: $name, zoneId: $zoneId)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ParkUser && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
