class CropFertilizerProfile {
  final String name;
  final String emoji;
  final double nPerTon;
  final double pPerTon;
  final double kPerTon;
  final double avgYield;
  final String category;

  const CropFertilizerProfile({
    required this.name,
    required this.emoji,
    required this.nPerTon,
    required this.pPerTon,
    required this.kPerTon,
    required this.avgYield,
    required this.category,
  });
}

class SoilTestResult {
  final double availableN;
  final double availableP;
  final double availableK;
  final double ph;

  const SoilTestResult({
    required this.availableN,
    required this.availableP,
    required this.availableK,
    required this.ph,
  });
}

class FertilizerRecommendation {
  final double requiredN;
  final double requiredP;
  final double requiredK;
  final double urea;
  final double dap;
  final double mop;
  final double npk;
  final String remarks;

  const FertilizerRecommendation({
    required this.requiredN,
    required this.requiredP,
    required this.requiredK,
    required this.urea,
    required this.dap,
    required this.mop,
    required this.npk,
    required this.remarks,
  });
}
