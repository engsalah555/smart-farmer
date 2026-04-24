import '../../../core/models/crop_model.dart';

/// Extension methods for crop calculations.
/// Keeps all math out of the UI layer.
extension CropCalculator on Crop {
  /// Calculate actual N/P/K quantities (kg) for a given farm area (hectares).
  /// Returns null if the crop has no CareGuide or if amounts are not set.
  NpkResult? calculateNpkForArea(double areaHectares) {
    final guide = careGuide;
    if (guide == null) return null;
    if (guide.nAmount == null && guide.pAmount == null && guide.kAmount == null) {
      return null;
    }

    return NpkResult(
      nitrogen: _roundKg(guide.nAmount, areaHectares),
      phosphorus: _roundKg(guide.pAmount, areaHectares),
      potassium: _roundKg(guide.kAmount, areaHectares),
    );
  }

  double? _roundKg(double? perHectare, double area) {
    if (perHectare == null) return null;
    // Round to 1 decimal place to avoid long floating-point numbers
    return double.parse((perHectare * area).toStringAsFixed(1));
  }

  /// Formatted temperature range string.
  String get temperatureRange {
    final guide = careGuide;
    if (guide == null) return '—';
    final min = guide.minTemp;
    final max = guide.maxTemp;
    if (min == null && max == null) return '—';
    return '${min?.toStringAsFixed(0) ?? "?"}°C – ${max?.toStringAsFixed(0) ?? "?"}°C';
  }

  /// Formatted humidity range string.
  String get humidityRange {
    final guide = careGuide;
    if (guide == null) return '—';
    final min = guide.minHumidity;
    final max = guide.maxHumidity;
    if (min == null && max == null) return '—';
    return '${min?.toStringAsFixed(0) ?? "?"}% – ${max?.toStringAsFixed(0) ?? "?"}%';
  }

  /// Formatted pH range string.
  String get phRange {
    final guide = careGuide;
    if (guide == null) return '—';
    final min = guide.minPh;
    final max = guide.maxPh;
    if (min == null && max == null) return '—';
    return '${min ?? "?"} – ${max ?? "?"}';
  }
}

/// Result of NPK calculation for a given area.
class NpkResult {
  final double? nitrogen;
  final double? phosphorus;
  final double? potassium;

  const NpkResult({this.nitrogen, this.phosphorus, this.potassium});

  bool get isEmpty =>
      nitrogen == null && phosphorus == null && potassium == null;
}
