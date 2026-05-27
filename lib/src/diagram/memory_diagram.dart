import 'package:flutter/material.dart';
import '../painters/circuit_painter.dart';

class MemoryDiagram extends StatelessWidget {
  final Map<String, Offset> centers;
  final Animation<double> pulse;
  final Animation<double> flow;
  final int activeSegment;
  final String activeNode;
  final String resultNode;
  final String target;

  const MemoryDiagram({
    required this.centers,
    required this.pulse,
    required this.flow,
    required this.activeSegment,
    required this.activeNode,
    required this.resultNode,
    required this.target,
    super.key,
  });

  static const List<Map<String, dynamic>> layers = [
    {
      'key': 'REGISTERS',
      'title': 'REGISTERS',
      'subtitle': 'Fastest / Smallest',
      'icon': Icons.developer_board,
      'color': Color(0xff00e5ff),
    },
    {
      'key': 'CACHE',
      'title': 'CACHE',
      'subtitle': 'L1/L2 · Very Fast',
      'icon': Icons.bolt,
      'color': Color(0xffffd600),
    },
    {
      'key': 'RAM',
      'title': 'RAM',
      'subtitle': 'Main Memory · Fast',
      'icon': Icons.view_module,
      'color': Color(0xff00e676),
    },
    {
      'key': 'SSD',
      'title': 'SSD',
      'subtitle': 'Secondary · Slow',
      'icon': Icons.sd_storage,
      'color': Color(0xffce93d8),
    },
  ];

  @override
  Widget build(BuildContext context) {
    return glass(
      padding: EdgeInsets.zero,
      child: AnimatedBuilder(
        animation: Listenable.merge([pulse, flow]),
        builder: (context, _) => Stack(
          children: [
            // Wires behind everything
            Positioned.fill(
              child: CustomPaint(
                painter: CircuitPainter(
                  centers: centers,
                  pulse: pulse.value,
                  flow: flow.value,
                  activeSegment: activeSegment,
                  activeNode: activeNode,
                  resultNode: resultNode,
                ),
              ),
            ),
            Positioned(
              left: 24,
              top: 24,
              child: sectionLabel('DATA SEARCH PATH', Icons.hub),
            ),
            _cpuNode(),
            _pyramidNodes(),
            _resultNode(),
            Positioned(
              left: 24,
              right: 24,
              bottom: 28,
              child: _pathTaken(),
            ),
          ],
        ),
      ),
    );
  }

  // ── CPU ─────────────────────────────────────────────────────────────────────
  Widget _cpuNode() {
    final c = centers['CPU']!;
    final isActive = activeNode == 'CPU';
    const color = Color(0xff00e5ff);
    return Positioned.fill(
      child: LayoutBuilder(builder: (_, box) {
        const w = 130.0, h = 100.0;
        return Stack(children: [
          Positioned(
            left: box.maxWidth * c.dx - w / 2,
            top: box.maxHeight * c.dy - h / 2,
            width: w,
            height: h,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isActive
                    ? color.withOpacity(0.18)
                    : Colors.white.withOpacity(0.07),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isActive ? color : Colors.white.withOpacity(0.18),
                  width: isActive ? 2.2 : 1.5,
                ),
                boxShadow: isActive
                    ? [
                        BoxShadow(
                            color: color.withOpacity(0.38 + pulse.value * .2),
                            blurRadius: 28,
                            spreadRadius: 2)
                      ]
                    : [],
              ),
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    neonIcon(Icons.memory, color, small: true),
                    const SizedBox(height: 4),
                    Text('CPU',
                        style: TextStyle(
                            color: color,
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                            height: 1.0)),
                    const Text('Requests Data',
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            color: Colors.white60, fontSize: 9, height: 1.0)),
                  ]),
            ),
          ),
        ]);
      }),
    );
  }

  // ── Pyramid Nodes ────────────────────────────────────────────────────────────
  Widget _pyramidNodes() {
    return Positioned.fill(
      child: LayoutBuilder(builder: (_, box) {
        // Center column: between CPU (left 22%) and RESULT (right 22%)
        final leftEdge = box.maxWidth * 0.22;
        final rightEdge = box.maxWidth * 0.78;
        final topEdge = box.maxHeight * 0.08;
        final botEdge = box.maxHeight * 0.80;

        final centerX = (leftEdge + rightEdge) / 2;
        final availH = botEdge - topEdge;
        final layerH = (availH / layers.length).clamp(0.0, 110.0);
        final maxW = rightEdge - leftEdge;
        const minFrac = 0.35;

        return Stack(children: [
          for (int i = 0; i < layers.length; i++)
            () {
              final layer = layers[i];
              final String key = layer['key'] as String;
              final Color color = layer['color'] as Color;
              final double frac =
                  minFrac + (1.0 - minFrac) * (i / (layers.length - 1));
              final double w = maxW * frac;
              final double left = centerX - w / 2;
              final double top = topEdge + i * layerH;
              final bool isActive = activeNode == key || resultNode == key;
              final bool isResult = resultNode == key;

              return Positioned(
                left: left,
                top: top,
                width: w,
                height: layerH - 4,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  decoration: BoxDecoration(
                    color: isActive
                        ? color.withOpacity(0.16)
                        : Colors.white.withOpacity(0.055),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(i == 0 ? 20 : 6),
                      topRight: Radius.circular(i == 0 ? 20 : 6),
                      bottomLeft:
                          Radius.circular(i == layers.length - 1 ? 16 : 6),
                      bottomRight:
                          Radius.circular(i == layers.length - 1 ? 16 : 6),
                    ),
                    border: Border.all(
                      color: isActive ? color : Colors.white.withOpacity(0.12),
                      width: isActive ? 2.2 : 1,
                    ),
                    boxShadow: isActive
                        ? [
                            BoxShadow(
                                color: color
                                    .withOpacity(0.30 + pulse.value * 0.22),
                                blurRadius: 28,
                                spreadRadius: 2)
                          ]
                        : [],
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  child: Row(children: [
                    neonIcon(layer['icon'] as IconData, color, small: true),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(children: [
                            Flexible(
                              child: Text(layer['title'] as String,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                      color: color,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w900)),
                            ),
                            if (isResult) ...[
                              const SizedBox(width: 6),
                              const Icon(Icons.check_circle,
                                  color: Colors.greenAccent, size: 15),
                            ],
                          ]),
                          Text(layer['subtitle'] as String,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                  color: Colors.white54, fontSize: 10)),
                        ],
                      ),
                    ),
                  ]),
                ),
              );
            }(),
        ]);
      }),
    );
  }

  // ── RESULT ──────────────────────────────────────────────────────────────────
  Widget _resultNode() {
    final c = centers['RESULT']!;
    final hasResult = resultNode.isNotEmpty;
    return Positioned.fill(
      child: LayoutBuilder(builder: (_, box) {
        const w = 130.0, h = 140.0;
        return Stack(children: [
          Positioned(
            left: box.maxWidth * c.dx - w / 2,
            top: box.maxHeight * c.dy - h / 2,
            width: w,
            height: h,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: hasResult
                    ? Colors.greenAccent.withOpacity(0.14)
                    : Colors.white.withOpacity(0.045),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: hasResult
                      ? Colors.greenAccent
                      : Colors.white.withOpacity(0.12),
                  width: hasResult ? 2.2 : 1,
                ),
                boxShadow: hasResult
                    ? [
                        BoxShadow(
                            color: Colors.greenAccent.withOpacity(0.28),
                            blurRadius: 26,
                            spreadRadius: 2)
                      ]
                    : [],
              ),
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      hasResult ? Icons.check_circle : Icons.hourglass_bottom,
                      color: hasResult ? Colors.greenAccent : Colors.white38,
                      size: 36,
                    ),
                    const SizedBox(height: 6),
                    Text('RESULT',
                        style: TextStyle(
                            color:
                                hasResult ? Colors.greenAccent : Colors.white54,
                            fontWeight: FontWeight.w900,
                            fontSize: 15)),
                    const SizedBox(height: 4),
                    Text(
                        hasResult
                            ? 'Found in\n$resultNode'
                            : 'Waiting\nfor data',
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 10.5,
                            height: 1.3)),
                  ]),
            ),
          ),
        ]);
      }),
    );
  }

  // ── Path Taken ──────────────────────────────────────────────────────────────
  Widget _pathTaken() {
    final pieces = target.isEmpty
        ? ['CPU', 'REG', 'CACHE', 'RAM', 'SSD', 'RESULT']
        : target == 'REGISTERS'
            ? ['CPU', 'REGISTERS', 'RESULT']
            : target == 'CACHE'
                ? ['CPU', 'REG MISS', 'CACHE', 'RESULT']
                : target == 'RAM'
                    ? ['CPU', 'REG MISS', 'CACHE MISS', 'RAM', 'RESULT']
                    : [
                        'CPU',
                        'REG MISS',
                        'CACHE MISS',
                        'RAM MISS',
                        'SSD',
                        'RESULT'
                      ];

    return Container(
      height: 74,
      padding: const EdgeInsets.symmetric(horizontal: 18),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.25),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withOpacity(0.10)),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(children: [
          const Icon(Icons.route, color: Colors.cyanAccent),
          const SizedBox(width: 12),
          const Text('Path Taken:',
              style: TextStyle(
                  color: Colors.cyanAccent, fontWeight: FontWeight.w900)),
          const SizedBox(width: 16),
          for (int i = 0; i < pieces.length; i++) ...[
            chip(pieces[i]),
            if (i != pieces.length - 1)
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 10),
                child:
                    Icon(Icons.arrow_forward, color: Colors.white70, size: 18),
              ),
          ],
        ]),
      ),
    );
  }

  // ── Helpers ─────────────────────────────────────────────────────────────────
  Widget sectionLabel(String text, IconData icon) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.cyanAccent, size: 24),
          const SizedBox(width: 10),
          Text(text,
              style: const TextStyle(
                  color: Colors.cyanAccent,
                  fontWeight: FontWeight.w900,
                  fontSize: 18)),
        ],
      );

  Widget neonIcon(IconData icon, Color color, {bool small = false}) {
    final sz = small ? 36.0 : 52.0;
    final ic = small ? 20.0 : 28.0;
    final r = small ? 10.0 : 14.0;
    return Container(
      width: sz,
      height: sz,
      decoration: BoxDecoration(
        color: color.withOpacity(0.10),
        borderRadius: BorderRadius.circular(r),
        border: Border.all(color: color.withOpacity(0.32)),
        boxShadow: [BoxShadow(color: color.withOpacity(0.10), blurRadius: 14)],
      ),
      child: Icon(icon, color: color, size: ic),
    );
  }

  Widget chip(String text) {
    Color color = Colors.cyanAccent;
    if (text.contains('REGISTER') || text.contains('REG'))
      color = const Color(0xff00e5ff);
    if (text.contains('CACHE')) color = Colors.amberAccent;
    if (text.contains('RAM')) color = Colors.greenAccent;
    if (text.contains('SSD')) color = Colors.purpleAccent;
    if (text.contains('RESULT')) color = Colors.greenAccent;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
      decoration: BoxDecoration(
        color: color.withOpacity(0.10),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.35)),
      ),
      child: Text(text,
          style: TextStyle(
              color: color, fontWeight: FontWeight.w900, fontSize: 13)),
    );
  }

  Widget glass(
          {required Widget child,
          EdgeInsets padding = const EdgeInsets.all(18)}) =>
      Container(
        width: double.infinity,
        padding: padding,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.065),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white.withOpacity(0.10)),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.28),
                blurRadius: 24,
                offset: const Offset(0, 12))
          ],
        ),
        child: child,
      );
}
