import 'dart:math' as math;

import 'package:data_gen_ai/core/enums/consideration_type.dart';

/// Mirrors Unity [ConsiderationFunctionData.CurveMaths] for curve preview.
abstract final class ConsiderationCurveMath {
  static double evaluate(Map<String, dynamic> config, double x) {
    final type = (config['Type'] ?? 0) as int;
    final invert = _boolFrom(config, 'InvertResult');
    final raw = _curveMaths(config, type, x);
    final result = invert ? 1.0 - raw : raw;
    return result.clamp(0.0, 1.0);
  }

  static double _curveMaths(
    Map<String, dynamic> config,
    int type,
    double x,
  ) {
    final m = _dbl(config, 'Slope', 1);
    final k = _dbl(config, 'Exponent', config['LogBase'] ?? 2);
    final bx = _dbl(config, 'OffsetX');
    final by = _dbl(config, 'OffsetY');

    switch (ConsiderationType.values.firstWhere(
      (e) => e.value == type,
      orElse: () => ConsiderationType.linear,
    )) {
      case ConsiderationType.linear:
        return (x + bx) * m + by;
      case ConsiderationType.square:
        return math.pow(x + bx, k).toDouble() * m + by;
      case ConsiderationType.inverse:
        return 1.0 - (((x + bx) * m) + by);
      case ConsiderationType.step:
        final threshold = _dbl(config, 'Threshold', 0.5);
        return (x + bx) > threshold ? 1 : 0;
      case ConsiderationType.sigmoid:
        final steepness = _dbl(config, 'SigmoidSteepness', 10);
        final midpoint = _dbl(config, 'SigmoidMidpoint', 0.5);
        final e = math.exp(-steepness * (x - midpoint));
        return (1 / (1 + e)) * m + by;
      case ConsiderationType.logit:
        final logBase = _dbl(config, 'LogBase', 2);
        final v = math.max(0.0001, x + bx);
        return (math.log(v) / math.log(logBase)) * m + by;
      case ConsiderationType.exponential:
        return m * math.pow((x + bx).abs(), k) + by;
      case ConsiderationType.normal:
        final peak = _dbl(config, 'PeakPosition', 0.5);
        final width = math.max(0.0001, _dbl(config, 'BellWidth', 0.1));
        final height = _dbl(config, 'PeakHeight', 1);
        final num = x - peak;
        final power = -0.5 * math.pow(num / width, 2);
        return math.exp(power) * height + by;
      case ConsiderationType.sine:
        final freq = _dbl(config, 'Frequency', 10);
        final phase = _dbl(config, 'Phase');
        return (math.sin(x * freq + phase) * 0.5 + 0.5) * m + by;
      case ConsiderationType.bounce:
        final freq = _dbl(config, 'Frequency', 10);
        final phase = _dbl(config, 'Phase');
        return (math.sin(x * freq + phase).abs()) * m + by;
    }
  }

  static double _dbl(
    Map<String, dynamic> config,
    String key, [
    double fallback = 0,
  ]) {
    return (config[key] ?? fallback).toDouble();
  }

  static bool _boolFrom(Map<String, dynamic> config, String key) {
    final v = config[key];
    if (v is bool) return v;
    if (v is int) return v != 0;
    return false;
  }
}
