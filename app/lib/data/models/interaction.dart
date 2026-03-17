class Interaction {
  final String id;
  final String userId;
  final String content;
  final String actionType;
  final String emotionType;
  final String petAction;
  final String petBubble;
  final DateTime createdAt;
  final DateTime? updatedAt;

  Interaction({
    required this.id,
    required this.userId,
    required this.content,
    required this.actionType,
    required this.emotionType,
    required this.petAction,
    required this.petBubble,
    required this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'content': content,
      'actionType': actionType,
      'emotionType': emotionType,
      'petAction': petAction,
      'petBubble': petBubble,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  factory Interaction.fromJson(Map<String, dynamic> json) {
    return Interaction(
      id: json['id'] as String,
      userId: json['userId'] as String,
      content: json['content'] as String,
      actionType: json['actionType'] as String,
      emotionType: json['emotionType'] as String,
      petAction: json['petAction'] as String,
      petBubble: json['petBubble'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
    );
  }
}
