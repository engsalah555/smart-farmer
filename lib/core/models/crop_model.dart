import '../../core/constants.dart';
import 'care_guide_model.dart';

class Crop {
  final String id;
  final String name;
  final String? scientificName;
  final String category;
  final String imageUrl;
  final String description;
  final String? benefits;
  final String? growthGuide;
  final String? scientificDefinition;
  final String? growingConditions;
  final String? soilAndPh;
  final String? uses;
  final String? pestsAndDiseases;
  final String? harvestingAndStorage;
  final String plantingSeason;
  final String waterNeeds;
  final String? fertilizerNeeds;
  final String? difficultyLevel;
  final String harvestTime;
  final CareGuide? careGuide;
  
  // Getters for UI compatibility
  String? get temperature {
    if (careGuide == null) return null;
    if (careGuide!.minTemp == null && careGuide!.maxTemp == null) return null;
    return "${careGuide!.minTemp ?? '?'}°C - ${careGuide!.maxTemp ?? '?'}°C";
  }

  String? get sunlightRequirement => careGuide?.lightType;

  const Crop({
    required this.id,
    required this.name,
    this.scientificName,
    required this.category,
    required this.imageUrl,
    required this.description,
    this.benefits,
    this.growthGuide,
    this.scientificDefinition,
    this.growingConditions,
    this.soilAndPh,
    this.uses,
    this.pestsAndDiseases,
    this.harvestingAndStorage,
    required this.plantingSeason,
    required this.waterNeeds,
    this.fertilizerNeeds,
    this.difficultyLevel,
    required this.harvestTime,
    this.careGuide,
  });

  static String _formatImageUrl(String? url) {
    if (url == null || url.isEmpty) return '';
    if (url.startsWith('http')) return url;
    if (url.startsWith('assets/')) return url;
    if (url.startsWith('/storage/')) return '${AppConstants.apiBaseUrl}$url';
    if (url.startsWith('storage/')) return '${AppConstants.apiBaseUrl}/$url';
    return '${AppConstants.apiBaseUrl}/storage/$url';
  }

  factory Crop.fromJson(Map<String, dynamic> json) {
    return Crop(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? json['common_name'] ?? '',
      scientificName: json['scientific_name'] ?? json['scientificName'],
      category: json['category'] is Map ? (json['category']['name'] ?? 'عام') : (json['category'] ?? 'عام'),
      imageUrl: _formatImageUrl(json['image_url'] ?? json['imageUrl']),
      description: json['description'] ?? '',
      benefits: json['benefits'],
      growthGuide: json['growth_guide'] ?? json['growthGuide'],
      scientificDefinition: json['scientific_definition'],
      growingConditions: json['growing_conditions'],
      soilAndPh: json['soil_and_ph'],
      uses: json['uses'],
      pestsAndDiseases: json['pests_and_diseases'],
      harvestingAndStorage: json['harvesting_and_storage'],
      plantingSeason: json['planting_season'] ?? 'غير محدد',
      waterNeeds: json['water_needs'] ?? 'غير محدد',
      fertilizerNeeds: json['fertilizer_needs'],
      difficultyLevel: json['difficulty_level'] ?? json['difficultyLevel'],
      harvestTime: json['harvest_time'] ?? 'غير محدد',
      careGuide: json['care_guide'] != null ? CareGuide.fromJson(json['care_guide']) : null,
    );
  }

  /// Serialization for offline cache (Hive).
  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'scientific_name': scientificName,
        'category': category,
        'image_url': imageUrl,
        'description': description,
        'benefits': benefits,
        'growth_guide': growthGuide,
        'scientific_definition': scientificDefinition,
        'growing_conditions': growingConditions,
        'soil_and_ph': soilAndPh,
        'uses': uses,
        'pests_and_diseases': pestsAndDiseases,
        'harvesting_and_storage': harvestingAndStorage,
        'planting_season': plantingSeason,
        'water_needs': waterNeeds,
        'fertilizer_needs': fertilizerNeeds,
        'difficulty_level': difficultyLevel,
        'harvest_time': harvestTime,
        'care_guide': careGuide != null ? _careGuideToJson(careGuide!) : null,
      };

  static Map<String, dynamic> _careGuideToJson(CareGuide g) => {
        'min_temp': g.minTemp,
        'max_temp': g.maxTemp,
        'light_type': g.lightType,
        'rainfall': g.rainfall,
        'min_humidity': g.minHumidity,
        'max_humidity': g.maxHumidity,
        'irrigation_level': g.irrigationLevel,
        'life_cycle': g.lifeCycle,
        'cultivation_method': g.cultivationMethod,
        'planting_depth': g.plantingDepth,
        'soil_texture': g.soilTexture,
        'min_ph': g.minPh,
        'max_ph': g.maxPh,
        'seed_rate': g.seedRate,
        'n_amount': g.nAmount,
        'p_amount': g.pAmount,
        'k_amount': g.kAmount,
        'companion_plants': g.companionPlants,
        'combative_plants': g.combativePlants,
        'management_tips': g.managementTips,
        'succeeding_crops': g.succeedingCrops,
        'forbidden_crops': g.forbiddenCrops,
        'rotation_recommendation': g.rotationRecommendation,
        'watering_schedule': g.wateringSchedule,
        'sunlight_requirement': g.sunlightRequirement,
        'temperature': g.temperature,
        'humidity': g.humidity,
        'pests_and_diseases': g.pestsAndDiseases,
        'harvesting_and_storage': g.harvestingAndStorage,
      };
}
