/// 购买记录模型
/// 用于存储用户购买专栏的历史记录信息
class PurchasedColumn {
  /// 记录唯一标识ID
  final String id;

  /// 用户ID
  final String userId;

  /// 专栏ID
  final String columnId;

  /// 购买类型（'vip' 表示VIP免费领取，'single' 表示单独购买）
  final String purchaseType;

  /// 购买价格（VIP领取时可能为null）
  final double? purchasePrice;

  /// 购买时间
  final DateTime purchasedAt;

  PurchasedColumn({
    required this.id,
    required this.userId,
    required this.columnId,
    required this.purchaseType,
    this.purchasePrice,
    required this.purchasedAt,
  });

  /// 将模型转换为JSON格式
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'columnId': columnId,
      'purchaseType': purchaseType,
      'purchasePrice': purchasePrice,
      'purchasedAt': purchasedAt.toIso8601String(),
    };
  }

  /// 从JSON数据创建模型实例
  factory PurchasedColumn.fromJson(Map<String, dynamic> json) {
    return PurchasedColumn(
      id: json['id'] as String,
      userId: json['userId'] as String,
      columnId: json['columnId'] as String,
      purchaseType: json['purchaseType'] as String,
      purchasePrice: json['purchasePrice'] != null
          ? (json['purchasePrice'] as num).toDouble()
          : null,
      purchasedAt: DateTime.parse(json['purchasedAt'] as String),
    );
  }

  /// 复制并修改模型属性
  PurchasedColumn copyWith({
    String? id,
    String? userId,
    String? columnId,
    String? purchaseType,
    double? purchasePrice,
    DateTime? purchasedAt,
  }) {
    return PurchasedColumn(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      columnId: columnId ?? this.columnId,
      purchaseType: purchaseType ?? this.purchaseType,
      purchasePrice: purchasePrice ?? this.purchasePrice,
      purchasedAt: purchasedAt ?? this.purchasedAt,
    );
  }
}
