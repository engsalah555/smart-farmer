import 'crop_model.dart';

class UserCropData {
  final String id;
  final String userId;
  final Crop plant;
  final DateTime datePlanted;
  final String growthStage;
  final String? notes;
  final DateTime? wateredAt;
  final DateTime? nextWatering;
  final bool isActive;

  UserCropData({
    required this.id,
    required this.userId,
    required this.plant,
    required this.datePlanted,
    required this.growthStage,
    this.notes,
    this.wateredAt,
    this.nextWatering,
    required this.isActive,
  });

  factory UserCropData.fromJson(Map<String, dynamic> json) {
    // If the plant is nested (likely)
    final plantJson = json['crop_guide'] ?? json['plant'] ?? json;
    final matchedPlant = Crop.fromJson(plantJson);

    return UserCropData(
      id: json['id']?.toString() ?? '',
      userId: json['user_id']?.toString() ?? json['userId']?.toString() ?? '',
      plant: matchedPlant,
      datePlanted: json['plantation_date'] != null
          ? DateTime.tryParse(json['plantation_date']) ?? DateTime.now()
          : DateTime.now(),
      growthStage: json['growth_stage'] ?? 'بذور',
      notes: json['notes'],
      wateredAt: json['last_irrigation'] != null
          ? DateTime.tryParse(json['last_irrigation'])
          : null,
      nextWatering:
          json['needs_irrigation'] == 1 || json['needs_irrigation'] == true
          ? DateTime.now()
          : null,
      isActive: true,
    );
  }
}
