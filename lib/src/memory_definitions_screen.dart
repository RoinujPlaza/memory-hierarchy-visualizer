import 'package:flutter/material.dart';

class MemoryDefinitionsScreen extends StatelessWidget {
  const MemoryDefinitionsScreen({super.key});

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
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                children: [
                  // Header with back button
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.065),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                                color: Colors.white.withOpacity(0.10)),
                            boxShadow: [
                              BoxShadow(
                                  color: Colors.black.withOpacity(0.28),
                                  blurRadius: 24,
                                  offset: const Offset(0, 12))
                            ],
                          ),
                          child: const Icon(Icons.arrow_back,
                              color: Colors.cyanAccent),
                        ),
                      ),
                      const SizedBox(width: 14),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Memory Components',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 28,
                                    fontWeight: FontWeight.w900)),
                            SizedBox(height: 4),
                            Text(
                                'Definitions, Speed & Clearing Methods',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                    color: Colors.white70, fontSize: 15)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // CPU Definition Card
                  definitionCard(
                    title: 'CPU (Central Processing Unit)',
                    icon: Icons.computer,
                    color: Colors.blueAccent,
                    definition:
                        'The brain of the computer that processes instructions and manages data flow.',
                    speed: 'Generates requests',
                    clearMethod:
                        'Reset the system or reboot the computer to clear all active processes.',
                  ),
                  const SizedBox(height: 14),
                  // Register Definition Card
                  definitionCard(
                    title: 'REGISTERS',
                    icon: Icons.developer_board,
                    color: Colors.cyanAccent,
                    definition:
                        'Ultra-fast memory storage located directly on the CPU. Stores data currently being processed.',
                    speed: '< 1 ns (nanosecond)',
                    clearMethod:
                        'Registers clear automatically when CPU operations complete. No manual clearing possible.',
                  ),
                  const SizedBox(height: 14),
                  // Cache Definition Card
                  definitionCard(
                    title: 'CACHE (L1, L2, L3)',
                    icon: Icons.bolt,
                    color: Colors.amberAccent,
                    definition:
                        'Fast memory between CPU and RAM. Stores frequently used data to speed up access times.',
                    speed: '~1-4 ns (nanoseconds)',
                    clearMethod:
                        'Use system utilities or command: "wmic logicaldisk where name=\"C:\" call clearCache" (Windows)',
                  ),
                  const SizedBox(height: 14),
                  // RAM Definition Card
                  definitionCard(
                    title: 'RAM (Random Access Memory)',
                    icon: Icons.view_module,
                    color: Colors.greenAccent,
                    definition:
                        'Main memory used by running programs. Fast but volatile (loses data when powered off).',
                    speed: '~10 ns (nanoseconds)',
                    clearMethod:
                        'Close unused applications, restart the computer, or use system memory cleaner tools.',
                  ),
                  const SizedBox(height: 14),
                  // SSD Definition Card
                  definitionCard(
                    title: 'SSD (Solid State Drive)',
                    icon: Icons.sd_storage,
                    color: Colors.purpleAccent,
                    definition:
                        'Permanent storage for files and programs. Faster than HDD but slower than RAM.',
                    speed: '~100 microseconds (µs)',
                    clearMethod:
                        'Delete files, use Disk Cleanup (Windows), or run system optimization tools.',
                  ),
                  const SizedBox(height: 24),
                  // Speed Comparison Chart
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.speed, color: Colors.cyanAccent),
                            SizedBox(width: 10),
                            Text('MEMORY HIERARCHY ORDER',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w900,
                                    fontSize: 18)),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            Expanded(
                              child: speedComparisonItem('1. Registers', '< 1 ns',
                                  Colors.cyanAccent, 'Fastest'),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: speedComparisonItem('2. Cache', '~1-4 ns',
                                  Colors.amberAccent, 'Very Fast'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: speedComparisonItem('3. RAM', '~10 ns',
                                  Colors.greenAccent, 'Fast'),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: speedComparisonItem('4. SSD', '~100 µs',
                                  Colors.purpleAccent, 'Slowest'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget definitionCard({
    required String title,
    required IconData icon,
    required Color color,
    required String definition,
    required String speed,
    required String clearMethod,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: color.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.28),
              blurRadius: 24,
              offset: const Offset(0, 12))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: color.withOpacity(0.32)),
                  boxShadow: [
                    BoxShadow(
                        color: color.withOpacity(0.10), blurRadius: 18)
                  ],
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                      color: color,
                      fontSize: 18,
                      fontWeight: FontWeight.w900),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          infoRow('Definition', definition, Colors.cyanAccent),
          const SizedBox(height: 10),
          infoRow('Memory Speed', speed, Colors.amberAccent),
          const SizedBox(height: 10),
          infoRow('Clear Method', clearMethod, Colors.greenAccent),
        ],
      ),
    );
  }

  Widget infoRow(String label, String value, Color labelColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
              color: labelColor, fontWeight: FontWeight.w900, fontSize: 12),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(
              color: Colors.white, fontSize: 13, height: 1.4),
        ),
      ],
    );
  }

  Widget speedComparisonItem(
      String label, String time, Color color, String description) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.09),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.55)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
                color: color, fontWeight: FontWeight.w900, fontSize: 12),
          ),
          const SizedBox(height: 6),
          FittedBox(
            child: Text(
              time,
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 14),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: const TextStyle(color: Colors.white70, fontSize: 11),
          ),
        ],
      ),
    );
  }
}
