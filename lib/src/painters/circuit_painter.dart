import 'package:flutter/material.dart';

class CircuitPainter extends CustomPainter {
  final Map<String, Offset> centers;
  final double pulse;
  final double flow;
  final int activeSegment;
  final String activeNode;
  final String resultNode;

  CircuitPainter({
    required this.centers,
    required this.pulse,
    required this.flow,
    required this.activeSegment,
    required this.activeNode,
    required this.resultNode,
  });

  @override
  void paint(Canvas canvas, Size size) {
    drawGrid(canvas, size);

    final cpu      = p('CPU', size);
    final reg      = p('REGISTERS', size);
    final cache    = p('CACHE', size);
    final ram      = p('RAM', size);
    final ssd      = p('SSD', size);
    final result   = p('RESULT', size);

    final base = Paint()
      ..color = Colors.white.withOpacity(0.12)
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final active = Paint()
      ..shader =
          const LinearGradient(colors: [Colors.cyanAccent, Colors.greenAccent])
              .createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..strokeWidth = 6
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Base wires: CPU → each memory level → RESULT
    drawWire(canvas, base, cpu, reg);
    drawWire(canvas, base, reg, cache);
    drawWire(canvas, base, cache, ram);
    drawWire(canvas, base, ram, ssd);
    drawWire(canvas, base, reg, result);
    drawWire(canvas, base, cache, result);
    drawWire(canvas, base, ram, result);
    drawWire(canvas, base, ssd, result);

    // Animated segments:
    // 0 = CPU → REGISTERS
    // 1 = REGISTERS → CACHE
    // 2 = CACHE → RAM
    // 3 = RAM → SSD
    // 4 = [found node] → RESULT
    final segments = <List<Offset>>[
      [cpu, reg],
      [reg, cache],
      [cache, ram],
      [ram, ssd],
      [resultStart(size), result],
    ];

    if (activeSegment >= 0 && activeSegment < segments.length) {
      final s = segments[activeSegment];
      drawWire(canvas, active, s[0], s[1]);
      drawPacket(canvas, s[0], s[1]);
    }

    // Junction dots at every node center
    for (final point in [cpu, reg, cache, ram, ssd, result]) {
      canvas.drawCircle(point, 5, Paint()..color = Colors.white.withOpacity(0.22));
    }
  }

  Offset p(String key, Size s) =>
      Offset(centers[key]!.dx * s.width, centers[key]!.dy * s.height);

  Offset resultStart(Size s) {
    if (resultNode == 'REGISTERS' || activeNode == 'REGISTERS') return p('REGISTERS', s);
    if (resultNode == 'CACHE'     || activeNode == 'CACHE')     return p('CACHE', s);
    if (resultNode == 'RAM'       || activeNode == 'RAM')       return p('RAM', s);
    if (resultNode == 'SSD'       || activeNode == 'SSD')       return p('SSD', s);
    return p('CPU', s);
  }

  void drawGrid(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.035)
      ..strokeWidth = 1;
    for (double x = 0; x < size.width; x += 34) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += 34) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  void drawWire(Canvas canvas, Paint paint, Offset a, Offset b) {
    final midX = (a.dx + b.dx) / 2;
    final path = Path()
      ..moveTo(a.dx, a.dy)
      ..lineTo(midX, a.dy)
      ..lineTo(midX, b.dy)
      ..lineTo(b.dx, b.dy);
    canvas.drawPath(path, paint);
  }

  void drawPacket(Canvas canvas, Offset a, Offset b) {
    final midX = (a.dx + b.dx) / 2;
    final points = [a, Offset(midX, a.dy), Offset(midX, b.dy), b];
    final distances = <double>[];
    double total = 0;
    for (int i = 0; i < 3; i++) {
      final d = (points[i + 1] - points[i]).distance;
      distances.add(d);
      total += d;
    }
    double remain = flow * total;
    Offset pos = a;
    for (int i = 0; i < 3; i++) {
      if (remain <= distances[i]) {
        pos = Offset.lerp(points[i], points[i + 1], remain / distances[i])!;
        break;
      }
      remain -= distances[i];
      pos = points[i + 1];
    }
    canvas.drawCircle(pos, 18 + pulse * 7,
        Paint()..color = Colors.cyanAccent.withOpacity(0.18));
    canvas.drawCircle(pos, 11, Paint()..color = Colors.cyanAccent);
    canvas.drawCircle(pos, 5, Paint()..color = Colors.white);
  }

  @override
  bool shouldRepaint(covariant CircuitPainter oldDelegate) => true;
}