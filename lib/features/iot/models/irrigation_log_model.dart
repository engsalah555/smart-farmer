class IrrigationLog {
  final int id;
  final String action;
  final int duration;
  final double waterUsed;
  final DateTime createdAt;

  IrrigationLog({
    required this.id,
    required this.action,
    required this.duration,
    required this.waterUsed,
    required this.createdAt,
  });

  factory IrrigationLog.fromJson(Map<String, dynamic> json) {
    return IrrigationLog(
      id: json['id'] as int? ?? 0,
      action: json['action'] as String? ?? 'unknown',
      duration: json['duration'] as int? ?? 0,
      waterUsed: (json['water_used'] as num?)?.toDouble() ?? 0.0,
      createdAt: json['created_at'] != null 
        ? DateTime.parse(json['created_at'])
        : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'action': action,
      'duration': duration,
      'water_used': waterUsed,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
