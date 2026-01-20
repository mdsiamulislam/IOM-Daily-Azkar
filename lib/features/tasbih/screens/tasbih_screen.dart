import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/tasbih_controller.dart';

class TasbihScreen extends StatelessWidget {
  final TasbihController controller = Get.put(TasbihController());

  TasbihScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("তসবিহ গণনা"),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(height: 20),

                    // Tasbih Beads Visualization
                    Obx(() => _TasbihBeads(
                      currentCount: controller.count.value,
                      targetCount: controller.targetCount.value,
                      animatedBeads: controller.beadAnimation,
                    )),

                    SizedBox(height: 40),

                    // Main Counter with Celebration Animation
                    Obx(() => Stack(
                      alignment: Alignment.center,
                      children: [
                        AnimatedContainer(
                          duration: Duration(milliseconds: 300),
                          width: controller.isAnimating.value ? 220 : 200,
                          height: controller.isAnimating.value ? 220 : 200,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.green.withOpacity(0.3),
                                blurRadius: controller.isAnimating.value ? 40 : 20,
                                spreadRadius: controller.isAnimating.value ? 10 : 5,
                              ),
                            ],
                            gradient: LinearGradient(
                              colors: [
                                Colors.green.shade100,
                                Colors.white,
                                Colors.green.shade50,
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              controller.count.value.toString(),
                              style: TextStyle(
                                fontSize: 64,
                                fontWeight: FontWeight.bold,
                                foreground: Paint()
                                  ..shader = LinearGradient(
                                    colors: [
                                      Colors.green.shade800,
                                      Colors.green.shade600,
                                    ],
                                  ).createShader(
                                    Rect.fromLTWH(0, 0, 200, 70),
                                  ),
                              ),
                            ),
                          ),
                        ),

                        // Celebration animation
                        if (controller.isAnimating.value)
                          Positioned.fill(
                            child: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: RadialGradient(
                                  colors: [
                                    Colors.amber.withOpacity(0.3),
                                    Colors.transparent,
                                  ],
                                  stops: [0.1, 1.0],
                                ),
                              ),
                            ),
                          ),
                      ],
                    )),

                    SizedBox(height: 16),

                    // Target Counter
                    Obx(() => GestureDetector(
                      onTap: controller.changeTarget,
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.green.shade300),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.flag, color: Colors.green.shade700, size: 16),
                            SizedBox(width: 8),
                            Text(
                              "লক্ষ্য: ${controller.targetCount.value}",
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.green.shade800,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(width: 4),
                            Icon(Icons.refresh, color: Colors.green.shade700, size: 16),
                          ],
                        ),
                      ),
                    )),

                    SizedBox(height: 40),

                    // Main Count Button
                    Obx(() => GestureDetector(
                      onTapDown: (_) => controller.increment(),
                      child: AnimatedContainer(
                        duration: Duration(milliseconds: 200),
                        width: 140,
                        height: 140,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.green.shade600,
                              Colors.green.shade800,
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.green.shade900.withOpacity(0.4),
                              blurRadius: 20,
                              spreadRadius: 5,
                              offset: Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // Pulse animation
                            if (controller.beadAnimation.isNotEmpty)
                              Positioned.fill(
                                child: AnimatedContainer(
                                  duration: Duration(milliseconds: 300),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.white.withOpacity(0.2),
                                  ),
                                ),
                              ),

                            Icon(
                              Icons.add,
                              size: 70,
                              color: Colors.white,
                            ),

                            Positioned(
                              bottom: 20,
                              child: Text(
                                "ট্যাপ করুন",
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )),

                    SizedBox(height: 30),

                    // Reset Button
                    ElevatedButton.icon(
                      onPressed: controller.reset,
                      icon: Icon(Icons.restart_alt_rounded),
                      label: Text("রিসেট করুন"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.red.shade700,
                        padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                          side: BorderSide(color: Colors.red.shade200, width: 2),
                        ),
                        elevation: 5,
                        shadowColor: Colors.red.withOpacity(0.3),
                      ),
                    ),

                    SizedBox(height: 20),

                    // Stats Card
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 20),
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.green.withOpacity(0.1),
                            blurRadius: 10,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _StatItem(
                            icon: Icons.history,
                            value: controller.count.value.toString(),
                            label: "মোট গণনা",
                          ),
                          Container(
                            height: 40,
                            width: 1,
                            color: Colors.grey.shade300,
                          ),
                          Obx(() => _StatItem(
                            icon: Icons.flag,
                            value: "${((controller.count.value / controller.targetCount.value) * 100).toStringAsFixed(1)}%",
                            label: "সম্পন্ন",
                          )),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Tasbih Beads Visualization Widget
class _TasbihBeads extends StatelessWidget {
  final int currentCount;
  final int targetCount;
  final List<int> animatedBeads;

  const _TasbihBeads({
    required this.currentCount,
    required this.targetCount,
    required this.animatedBeads,
  });

  @override
  Widget build(BuildContext context) {
    final beadsPerRow = 10;
    final rows = (targetCount / beadsPerRow).ceil();

    return Container(
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.3),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        children: List.generate(rows, (rowIndex) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(beadsPerRow, (colIndex) {
              final beadNumber = rowIndex * beadsPerRow + colIndex + 1;
              final isCompleted = beadNumber <= currentCount;
              final isAnimating = animatedBeads.contains(beadNumber);

              return Container(
                margin: EdgeInsets.all(4),
                child: AnimatedContainer(
                  duration: Duration(milliseconds: 300),
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: isCompleted ? Colors.green.shade600 : Colors.grey.shade300,
                    shape: BoxShape.circle,
                    boxShadow: isAnimating
                        ? [
                      BoxShadow(
                        color: Colors.green.shade600.withOpacity(0.8),
                        blurRadius: 10,
                        spreadRadius: 3,
                      ),
                    ]
                        : [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 3,
                        spreadRadius: 1,
                      ),
                    ],
                    gradient: isCompleted
                        ? LinearGradient(
                      colors: [
                        Colors.green.shade700,
                        Colors.green.shade500,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                        : null,
                  ),
                ),
              );
            }),
          );
        }),
      ),
    );
  }
}

// Stat Item Widget
class _StatItem extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _StatItem({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: Colors.green.shade700, size: 24),
        SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.green.shade800,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }
}

// Islamic Pattern Painter for Background
class _IslamicPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.green.withOpacity(0.05)
      ..style = PaintingStyle.fill;

    const double spacing = 50;
    const double radius = 2;

    for (double i = spacing; i < size.width; i += spacing) {
      for (double j = spacing; j < size.height; j += spacing) {
        final center = Offset(i, j);
        canvas.drawCircle(center, radius, paint);

        // Draw small connecting lines
        final linePaint = Paint()
          ..color = Colors.green.withOpacity(0.03)
          ..strokeWidth = 1;

        if (i + spacing < size.width) {
          canvas.drawLine(center, Offset(i + spacing, j), linePaint);
        }
        if (j + spacing < size.height) {
          canvas.drawLine(center, Offset(i, j + spacing), linePaint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}