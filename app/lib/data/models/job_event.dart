class JobEvent {
  final String id;
  final String userId;
  final String eventType;
  final String eventContent;
  final DateTime eventTime;

  JobEvent({
    required this.id,
    required this.userId,
    required this.eventType,
    required this.eventContent,
    required this.eventTime,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'eventType': eventType,
      'eventContent': eventContent,
      'eventTime': eventTime.toIso8601String(),
    };
  }

  factory JobEvent.fromJson(Map<String, dynamic> json) {
    return JobEvent(
      id: json['id'] as String,
      userId: json['userId'] as String,
      eventType: json['eventType'] as String,
      eventContent: json['eventContent'] as String,
      eventTime: DateTime.parse(json['eventTime'] as String),
    );
  }
}
