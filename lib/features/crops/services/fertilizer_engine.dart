import 'dart:math' as math;
import '../models/fertilizer_models.dart';

class FertilizerEngine {
  static FertilizerRecommendation calculate({
    required CropFertilizerProfile crop,
    required double areaHa,
    required double targetYieldTonHa,
    required SoilTestResult soil,
  }) {
    final totalN = crop.nPerTon * targetYieldTonHa;
    final totalP = crop.pPerTon * targetYieldTonHa * 2.29;
    final totalK = crop.kPerTon * targetYieldTonHa * 1.20;

    final netN = math.max(0.0, totalN - soil.availableN * 0.70);
    final netP = math.max(0.0, totalP - soil.availableP * 2.29 * 0.25);
    final netK = math.max(0.0, totalK - soil.availableK * 1.20 * 0.50);

    final dapKgHa = netP / 0.46;
    final nFromDap = dapKgHa * 0.18;
    final ureaKgHa = math.max(0.0, netN - nFromDap) / 0.46;
    final mopKgHa = netK / 0.60;

    final npkKgHa = math.max(
      dapKgHa,
      math.max(ureaKgHa + dapKgHa * 0.3, mopKgHa),
    );

    String remarks;
    if (soil.ph < 6.0) {
      remarks = '⚠️ التربة حامضية — أضف الجير الزراعي قبل التسميد.';
    } else if (soil.ph > 8.0) {
      remarks = '⚠️ التربة قلوية — استخدم الكبريت وتجنب اليوريا.';
    } else {
      remarks = '✅ pH مناسب — التربة جاهزة للتسميد.';
    }

    return FertilizerRecommendation(
      requiredN: netN * areaHa,
      requiredP: netP * areaHa,
      requiredK: netK * areaHa,
      urea: ureaKgHa * areaHa,
      dap: dapKgHa * areaHa,
      mop: mopKgHa * areaHa,
      npk: npkKgHa * areaHa,
      remarks: remarks,
    );
  }
}
