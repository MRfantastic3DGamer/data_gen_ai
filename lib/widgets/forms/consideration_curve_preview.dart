import 'package:data_gen_ai/services/consideration_curve_math.dart';
import 'package:flutter/material.dart';

/// Curve preview similar to Unity's ConsiderationFunctionConfig inspector graph.
class ConsiderationCurvePreview extends StatelessWidget {
  const ConsiderationCurvePreview({
    super.key,
    required this.config,
    this.height = 150,
  });

  final Map<String, dynamic> config;
  final double height;

  @override
  Widget build(BuildContext context) {
    final invert = config['InvertResult'] == true ||
        config['InvertResult'] == 1;
    final curveColor = invert ? const Color(0xFFFF6666) : Colors.green;

    return SizedBox(
      height: height,
      width: double.infinity,
      child: CustomPaint(
        painter: _ConsiderationCurvePainter(
          config: config,
          curveColor: curveColor,
          gridColor: Colors.white.withValues(alpha: 0.1),
          axisColor: Colors.white.withValues(alpha: 0.5),
          backgroundColor: const Color(0xFF1A1A1A),
        ),
      ),
    );
  }
}

class _ConsiderationCurvePainter extends CustomPainter {
  _ConsiderationCurvePainter({
    required this.config,
    required this.curveColor,
    required this.gridColor,
    required this.axisColor,
    required this.backgroundColor,
  });

  final Map<String, dynamic> config;
  final Color curveColor;
  final Color gridColor;
  final Color axisColor;
  final Color backgroundColor;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas.drawRect(rect, Paint()..color = backgroundColor);

    const divisions = 4;
    final gridPaint = Paint()
      ..color = gridColor
      ..strokeWidth = 1;

    for (var i = 0; i <= divisions; i++) {
      final t = i / divisions;
      final x = rect.left + rect.width * t;
      canvas.drawLine(Offset(x, rect.top), Offset(x, rect.bottom), gridPaint);
      final y = rect.bottom - rect.height * t;
      canvas.drawLine(Offset(rect.left, y), Offset(rect.right, y), gridPaint);
    }

    final axisPaint = Paint()
      ..color = axisColor
      ..strokeWidth = 1;
    canvas.drawLine(
      Offset(rect.left, rect.bottom),
      Offset(rect.right, rect.bottom),
      axisPaint,
    );
    canvas.drawLine(
      Offset(rect.left, rect.top),
      Offset(rect.left, rect.bottom),
      axisPaint,
    );

    const sampleCount = 150;
    final curvePath = Path();
    for (var i = 0; i < sampleCount; i++) {
      final t = i / (sampleCount - 1);
      final y = ConsiderationCurveMath.evaluate(config, t);
      final px = rect.left + t * rect.width;
      final py = rect.bottom - y.clamp(0.0, 1.0) * rect.height;
      if (i == 0) {
        curvePath.moveTo(px, py);
      } else {
        curvePath.lineTo(px, py);
      }
    }

    canvas.drawPath(
      curvePath,
      Paint()
        ..color = curveColor
        ..strokeWidth = 2.5
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );

    final labelStyle = TextStyle(
      color: Colors.grey.shade500,
      fontSize: 10,
    );
    _drawLabel(canvas, '1.0', Offset(rect.left + 4, rect.top + 2), labelStyle);
    _drawLabel(
      canvas,
      '0.0',
      Offset(rect.left + 4, rect.bottom - 14),
      labelStyle,
    );
  }

  void _drawLabel(
    Canvas canvas,
    String text,
    Offset offset,
    TextStyle style,
  ) {
    final painter = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
    )..layout();
    painter.paint(canvas, offset);
  }

  @override
  bool shouldRepaint(covariant _ConsiderationCurvePainter oldDelegate) {
    return oldDelegate.config != config ||
        oldDelegate.curveColor != curveColor;
  }
}
