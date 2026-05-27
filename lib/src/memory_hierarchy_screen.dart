import 'dart:async';
import 'package:flutter/material.dart';
import 'diagram/memory_diagram.dart';
import 'memory_definitions_screen.dart';

class MemoryHierarchyScreen extends StatefulWidget {
  const MemoryHierarchyScreen({super.key});

  @override
  State<MemoryHierarchyScreen> createState() => _MemoryHierarchyScreenState();
}

class _MemoryHierarchyScreenState extends State<MemoryHierarchyScreen>
    with TickerProviderStateMixin {
  late final AnimationController pulse;
  late final AnimationController flow;

  String target = '';
  String activeNode = '';
  String resultNode = '';
  int activeSegment = -1;
  int step = 0;
  bool running = false;

  String currentTitle = 'Ready to simulate';
  String currentMessage =
      'Choose a simulation button. The diagram will animate the path the CPU follows to find the data.';

  // centers map kept for compatibility (not used by pyramid diagram visually)
  final Map<String, Offset> centers = const {
    'CPU':       Offset(0.11, 0.44),
    'REGISTERS': Offset(0.50, 0.17),
    'CACHE':     Offset(0.50, 0.36),
    'RAM':       Offset(0.50, 0.55),
    'SSD':       Offset(0.50, 0.72),
    'RESULT':    Offset(0.89, 0.44),
  };

  @override
  void initState() {
    super.initState();
    pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 950),
    )..repeat(reverse: true);
    flow = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 850),
    );
  }

  @override
  void dispose() {
    pulse.dispose();
    flow.dispose();
    super.dispose();
  }

  Future<void> runSimulation(String selected) async {
    if (running) return;
    setState(() {
      target = selected;
      resultNode = '';
      activeSegment = -1;
      activeNode = 'CPU';
      running = true;
      step = 1;
      currentTitle = 'Step 1: CPU requests data';
      currentMessage =
          'The CPU starts by asking for the data needed to run an instruction.';
    });
    await Future.delayed(const Duration(milliseconds: 700));

    // Always check Registers first (fastest)
    await travelTo('REGISTERS', 0, 'Step 2: Checking REGISTERS...',
        'Registers are checked first — they are the fastest and closest memory to the CPU.');
    if (selected == 'REGISTERS') {
      await found('REGISTERS', 'Data Found in REGISTERS!',
          'Shortest path: CPU → Registers → Result. Data was already in the CPU registers!');
      return;
    }

    await waitStep('REGISTER MISS',
        'Data not in Registers. Moving to Cache next.');
    await travelTo('CACHE', 1, 'Step 3: Checking CACHE...',
        'Cache is checked next because it is the fastest memory after Registers.');
    if (selected == 'CACHE') {
      await found('CACHE', 'Data Found in CACHE!',
          'Path: CPU → Registers → Cache → Result. This is a cache hit!');
      return;
    }

    await waitStep('CACHE MISS',
        'The data was not in Cache, so the CPU continues to RAM.');
    await travelTo('RAM', 2, 'Step 4: Checking RAM...',
        'RAM is slower than Cache but much faster than SSD/storage.');
    if (selected == 'RAM') {
      await found('RAM', 'Data Found in RAM!',
          'Path: CPU → Registers → Cache → RAM → Result.');
      return;
    }

    await waitStep('RAM MISS',
        'The data was not in RAM, so the system checks SSD/storage last.');
    await travelTo('SSD', 3, 'Step 5: Checking SSD...',
        'SSD/storage is checked last because it has the longest access time.');
    await found('SSD', 'Data Found in SSD!',
        'Longest path: CPU → Registers → Cache → RAM → SSD → Result.');
  }

  Future<void> travelTo(
      String node, int segment, String title, String message) async {
    setState(() {
      activeSegment = segment;
      currentTitle = title;
      currentMessage = message;
      step++;
    });
    await flow.forward(from: 0);
    setState(() => activeNode = node);
    await Future.delayed(const Duration(milliseconds: 500));
  }

  Future<void> waitStep(String title, String message) async {
    setState(() {
      currentTitle = title;
      currentMessage = message;
      step++;
    });
    await Future.delayed(const Duration(milliseconds: 750));
  }

  Future<void> found(String node, String title, String message) async {
    setState(() {
      resultNode = node;
      activeNode = node;
      activeSegment = 4;
      currentTitle = title;
      currentMessage = message;
      step++;
    });
    await flow.forward(from: 0);
    await Future.delayed(const Duration(milliseconds: 500));
    setState(() {
      activeSegment = -1;
      running = false;
    });
  }

  void reset() {
    setState(() {
      target = '';
      activeNode = '';
      resultNode = '';
      activeSegment = -1;
      running = false;
      step = 0;
      currentTitle = 'Ready to simulate';
      currentMessage =
          'Choose a simulation button. The diagram will animate the path the CPU follows to find the data.';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff06101f),
      body: SafeArea(
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xff06101f), Color(0xff0c1b31), Color(0xff06101f)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: LayoutBuilder(
            builder: (context, box) {
              final wide = box.maxWidth >= 900;
              return Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  children: [
                    header(),
                    const SizedBox(height: 16),
                    Expanded(
                      child: wide
                          ? Row(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Expanded(
                                    flex: 7,
                                    child: MemoryDiagram(
                                      centers: centers,
                                      pulse: pulse,
                                      flow: flow,
                                      activeSegment: activeSegment,
                                      activeNode: activeNode,
                                      resultNode: resultNode,
                                      target: target,
                                    )),
                                const SizedBox(width: 18),
                                SizedBox(width: 455, child: rightPanel()),
                              ],
                            )
                          : ListView(
                              children: [
                                SizedBox(
                                    height: 620,
                                    child: MemoryDiagram(
                                      centers: centers,
                                      pulse: pulse,
                                      flow: flow,
                                      activeSegment: activeSegment,
                                      activeNode: activeNode,
                                      resultNode: resultNode,
                                      target: target,
                                    )),
                                const SizedBox(height: 18),
                                rightPanel(),
                              ],
                            ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget header() {
    return Row(
      children: [
        neonIcon(Icons.memory, Colors.cyanAccent, big: true),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Memory Hierarchy Visualizer',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.w900)),
              const SizedBox(height: 4),
              const Text(
                  'Visualize how CPU searches data from fastest to slowest memory',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: Colors.white70, fontSize: 15)),
            ],
          ),
        ),
        const SizedBox(width: 12),
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const MemoryDefinitionsScreen(),
              ),
            );
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.indigoAccent.withOpacity(0.12),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: Colors.indigoAccent.withOpacity(0.45)),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline,
                    color: Colors.indigoAccent, size: 19),
                const SizedBox(width: 8),
                const Text('DEFINITIONS',
                    style: TextStyle(
                        color: Colors.indigoAccent,
                        fontWeight: FontWeight.w900)),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.greenAccent.withOpacity(0.08),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: Colors.greenAccent.withOpacity(0.45)),
          ),
          child: Row(
            children: [
              Icon(running ? Icons.sync : Icons.check_circle_outline,
                  color: running ? Colors.amberAccent : Colors.greenAccent,
                  size: 19),
              const SizedBox(width: 8),
              Text(running ? 'RUNNING' : 'READY',
                  style: TextStyle(
                      color: running ? Colors.amberAccent : Colors.greenAccent,
                      fontWeight: FontWeight.w900)),
            ],
          ),
        ),
      ],
    );
  }

  Widget rightPanel() {
    return SingleChildScrollView(
      child: Column(
        children: [
          controls(),
          const SizedBox(height: 14),
          currentStep(),
          const SizedBox(height: 14),
          speedPanel(),
        ],
      ),
    );
  }

  Widget controls() {
    return glass(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Row(
            children: [
              Icon(Icons.sports_esports, color: Colors.blueAccent),
              SizedBox(width: 10),
              Text('SIMULATION CONTROLS',
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 18)),
            ],
          ),
          const SizedBox(height: 16),
          controlButton(
              'Data is in REGISTERS',
              'Fastest: CPU → Registers',
              Icons.developer_board,
              Colors.cyanAccent,
              () => runSimulation('REGISTERS')),
          controlButton('Data is in CACHE', 'Fast: CPU → Registers → Cache',
              Icons.bolt, Colors.amberAccent, () => runSimulation('CACHE')),
          controlButton(
              'Data is in RAM',
              'Medium: CPU → ... → RAM',
              Icons.view_module,
              Colors.greenAccent,
              () => runSimulation('RAM')),
          controlButton(
              'Data is in SSD',
              'Slowest: CPU → ... → SSD',
              Icons.sd_storage,
              Colors.purpleAccent,
              () => runSimulation('SSD')),
          const SizedBox(height: 8),
          SizedBox(
            height: 54,
            child: OutlinedButton.icon(
              onPressed: reset,
              icon: const Icon(Icons.restart_alt),
              label: const Text('Reset Simulation',
                  style: TextStyle(fontWeight: FontWeight.w900)),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white,
                side: BorderSide(color: Colors.white.withOpacity(0.22)),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget controlButton(String label, String sub, IconData icon, Color color,
      VoidCallback onTap) {
    final selected = target.isNotEmpty &&
        (label.toUpperCase().contains(target) ||
            (target == 'REGISTERS' && label.contains('REGISTERS')));
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: running ? null : onTap,
        borderRadius: BorderRadius.circular(18),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          height: 72,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: selected
                ? color.withOpacity(0.16)
                : Colors.white.withOpacity(0.055),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
                color: selected ? color : Colors.white.withOpacity(0.12),
                width: selected ? 2 : 1),
          ),
          child: Row(
            children: [
              neonIcon(icon, color),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            color: color,
                            fontWeight: FontWeight.w900,
                            fontSize: 14)),
                    const SizedBox(height: 4),
                    Text(sub,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            color: Colors.white70, fontSize: 12)),
                  ],
                ),
              ),
              Icon(Icons.play_arrow_rounded, color: color, size: 26),
            ],
          ),
        ),
      ),
    );
  }

  Widget currentStep() {
    return glass(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.bubble_chart, color: Colors.cyanAccent),
              SizedBox(width: 10),
              Text('CURRENT STEP',
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 18)),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.18),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.white.withOpacity(0.08)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(currentTitle,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              color: Colors.amberAccent,
                              fontWeight: FontWeight.w900,
                              fontSize: 15)),
                      const SizedBox(height: 8),
                      Text(currentMessage,
                          style: const TextStyle(
                              color: Colors.white,
                              height: 1.35,
                              fontSize: 13.5)),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                SizedBox(
                    width: 42,
                    height: 42,
                    child: running
                        ? const CircularProgressIndicator(strokeWidth: 4)
                        : const Icon(Icons.check_circle_outline,
                            color: Colors.greenAccent, size: 38)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget speedPanel() {
    return glass(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.timer_outlined, color: Colors.white70),
              SizedBox(width: 10),
              Text('MEMORY SPEED',
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 18)),
              SizedBox(width: 6),
              Expanded(
                  child: Text('(Access Time)',
                      style: TextStyle(
                          color: Colors.white70, fontWeight: FontWeight.bold))),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              speedCard('REG', '< 1 ns', 'Fastest', Icons.developer_board,
                  Colors.cyanAccent),
              const SizedBox(width: 6),
              speedCard('CACHE', '~1 ns', 'Very Fast', Icons.bolt,
                  Colors.amberAccent),
              const SizedBox(width: 6),
              speedCard('RAM', '~10 ns', 'Fast', Icons.view_module,
                  Colors.greenAccent),
              const SizedBox(width: 6),
              speedCard('SSD', '~100µs', 'Slowest', Icons.sd_storage,
                  Colors.purpleAccent),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.04),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Text(
                'Order: Registers → Cache → RAM → SSD (Fastest to Slowest)',
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Colors.white70, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget speedCard(
      String name, String time, String label, IconData icon, Color color) {
    return Expanded(
      child: Container(
        height: 120,
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.09),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.55)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Text(name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w900,
                    fontSize: 11)),
            Icon(icon, color: color, size: 20),
            FittedBox(
              child: Text(time,
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 11)),
            ),
            Text(label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Colors.white70, fontSize: 10)),
          ],
        ),
      ),
    );
  }

  Widget glass(
      {required Widget child,
      EdgeInsets padding = const EdgeInsets.all(18)}) {
    return Container(
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

  Widget neonIcon(IconData icon, Color color, {bool big = false}) {
    return Container(
      width: big ? 62 : 52,
      height: big ? 62 : 52,
      decoration: BoxDecoration(
        color: color.withOpacity(0.10),
        borderRadius: BorderRadius.circular(big ? 18 : 14),
        border: Border.all(color: color.withOpacity(0.32)),
        boxShadow: [BoxShadow(color: color.withOpacity(0.10), blurRadius: 18)],
      ),
      child: Icon(icon, color: color, size: big ? 34 : 28),
    );
  }
}