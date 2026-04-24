class IrrigationSchedule {
  final int id;
  final String startTime;
  final List<String> days;
  final bool isActive;

  IrrigationSchedule({
    required this.id,
    required this.startTime,
    required this.days,
    required this.isActive,
  });

  factory IrrigationSchedule.fromJson(Map<String, dynamic> json) {
    List<String> parsedDays = [];
    if (json['days'] != null) {
      if (json['days'] is String) {
        // sometimes Laravel casts JSON as string
        // handle or fallback, but ideally it's an array
        parsedDays = [json['days']];
      } else if (json['days'] is List) {
        parsedDays = List<String>.from(json['days']);
      }
    }

    return IrrigationSchedule(
      id: json['id'] as int? ?? 0,
      startTime: json['start_time'] as String? ?? '00:00',
      days: parsedDays,
      isActive: json['is_active'] == true || json['is_active'] == 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'start_time': startTime,
      'days': days,
      'is_active': isActive,
    };
  }
}
