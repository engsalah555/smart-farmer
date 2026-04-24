class CareGuide {
  final double? minTemp;
  final double? maxTemp;
  final String? lightType;
  final String? rainfall;
  final double? minHumidity;
  final double? maxHumidity;
  final String? irrigationLevel;
  final String? lifeCycle;
  final String? cultivationMethod;
  final String? plantingDepth;
  final String? soilTexture;
  final double? minPh;
  final double? maxPh;
  final String? seedRate;
  final double? nAmount;
  final double? pAmount;
  final double? kAmount;
  final List<String>? companionPlants;
  final List<String>? combativePlants;
  final String? managementTips;
  final List<String>? succeedingCrops;
  final List<String>? forbiddenCrops;
  final String? rotationRecommendation;
  final String? wateringSchedule;
  final String? sunlightRequirement;
  final String? temperature;
  final String? humidity;
  final String? pestsAndDiseases;
  final String? harvestingAndStorage;

  CareGuide({
    this.minTemp,
    this.maxTemp,
    this.lightType,
    this.rainfall,
    this.minHumidity,
    this.maxHumidity,
    this.irrigationLevel,
    this.lifeCycle,
    this.cultivationMethod,
    this.plantingDepth,
    this.soilTexture,
    this.minPh,
    this.maxPh,
    this.seedRate,
    this.nAmount,
    this.pAmount,
    this.kAmount,
    this.companionPlants,
    this.combativePlants,
    this.managementTips,
    this.succeedingCrops,
    this.forbiddenCrops,
    this.rotationRecommendation,
    this.wateringSchedule,
    this.sunlightRequirement,
    this.temperature,
    this.humidity,
    this.pestsAndDiseases,
    this.harvestingAndStorage,
  });

  factory CareGuide.fromJson(Map<String, dynamic> json) {
    return CareGuide(
      minTemp: _toDouble(json['min_temp']),
      maxTemp: _toDouble(json['max_temp']),
      lightType: json['light_type'],
      rainfall: json['rainfall'],
      minHumidity: _toDouble(json['min_humidity']),
      maxHumidity: _toDouble(json['max_humidity']),
      irrigationLevel: json['irrigation_level'],
      lifeCycle: json['life_cycle'],
      cultivationMethod: json['cultivation_method'],
      plantingDepth: json['planting_depth'],
      soilTexture: json['soil_texture'],
      minPh: _toDouble(json['min_ph']),
      maxPh: _toDouble(json['max_ph']),
      seedRate: json['seed_rate'],
      nAmount: _toDouble(json['n_amount']),
      pAmount: _toDouble(json['p_amount']),
      kAmount: _toDouble(json['k_amount']),
      companionPlants: _toList(json['companion_plants']),
      combativePlants: _toList(json['combative_plants']),
      managementTips: json['management_tips'],
      succeedingCrops: _toList(json['succeeding_crops']),
      forbiddenCrops: _toList(json['forbidden_crops']),
      rotationRecommendation: json['rotation_recommendation'],
      wateringSchedule: json['watering_schedule'],
      sunlightRequirement: json['sunlight_requirement'],
      temperature: json['temperature'],
      humidity: json['humidity'],
      pestsAndDiseases: json['pests_and_diseases'],
      harvestingAndStorage: json['harvesting_and_storage'],
    );
  }

  static double? _toDouble(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  static List<String>? _toList(dynamic value) {
    if (value == null) return null;
    if (value is List) return value.map((e) => e.toString()).toList();
    if (value is String) {
      if (value.startsWith('[') && value.endsWith(']')) {
        return value
            .replaceAll('[', '')
            .replaceAll(']', '')
            .split(',')
            .map((e) => e.trim().replaceAll('"', '').replaceAll("'", ""))
            .where((e) => e.isNotEmpty)
            .toList();
      }
      return value.split('،').length > 1 
          ? value.split('،').map((e) => e.trim()).where((e) => e.isNotEmpty).toList()
          : value.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
    }
    return null;
  }
}
