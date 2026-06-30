class SessionHistoryModel {
  final String id;
  final String title;
  final String sessionType;
  final DateTime? startedAt;
  final DateTime? endedAt;

  SessionHistoryModel({
    required this.id,
    required this.title,
    required this.sessionType,
    required this.startedAt,
    required this.endedAt,
  });

  factory SessionHistoryModel.fromJson(Map<String, dynamic> json) {
    return SessionHistoryModel(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? 'Learning session',
      sessionType: json['sessionType']?.toString() ?? '',
      startedAt: DateTime.tryParse(json['startedAt']?.toString() ?? ''),
      endedAt: DateTime.tryParse(json['endedAt']?.toString() ?? ''),
    );
  }
}