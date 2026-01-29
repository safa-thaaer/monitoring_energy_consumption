import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

class MultiCircularGauge extends StatelessWidget {
  final double power;
  final double energy;
  final double co2;

  const MultiCircularGauge({
    super.key,
    required this.power,
    required this.energy,
    required this.co2,
  });

  double _percentage(double value, double max) {
    return ((value / max) * 100.0).clamp(0.0, 100.0).toDouble();
  }

  @override
  Widget build(BuildContext context) {
    final double powerPercentage = _percentage(power, 5000.0);
    final double energyPercentage = _percentage(energy, 50.0);
    final double co2Percentage = _percentage(co2, 100.0);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white.withValues(alpha: 0.1),
            Colors.white.withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.2),
          width: 2,
        ),
      ),
      child: Column(
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.speed, color: Colors.yellow, size: 30),
              SizedBox(width: 12),
              Text(
                'عداد الاستهلاك المباشر',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // العداد الدائري الرئيسي
          SizedBox(
            height: 300,
            child: SfRadialGauge(
              axes: <RadialAxis>[
                // الدائرة الخارجية - CO₂ (أخضر)
                RadialAxis(
                  minimum: 0.0,
                  maximum: 100.0,
                  showLabels: false,
                  showTicks: false,
                  radiusFactor: 1.0,
                  axisLineStyle: AxisLineStyle(
                    thickness: 0.1,
                    color: Colors.white.withValues(alpha: 0.1),
                    thicknessUnit: GaugeSizeUnit.factor,
                  ),
                  pointers: <GaugePointer>[
                    RangePointer(
                      value: co2Percentage,
                      width: 0.1,
                      sizeUnit: GaugeSizeUnit.factor,
                      gradient: const SweepGradient(
                        colors: [Color(0xFF10b981), Color(0xFF059669)],
                        stops: [0.25, 0.75],
                      ),
                      cornerStyle: CornerStyle.bothCurve,
                    ),
                  ],
                ),

                // الدائرة الوسطى - الطاقة (أزرق)
                RadialAxis(
                  minimum: 0.0,
                  maximum: 100.0,
                  showLabels: false,
                  showTicks: false,
                  radiusFactor: 0.75,
                  axisLineStyle: AxisLineStyle(
                    thickness: 0.12,
                    color: Colors.white.withValues(alpha: 0.1),
                    thicknessUnit: GaugeSizeUnit.factor,
                  ),
                  pointers: <GaugePointer>[
                    RangePointer(
                      value: energyPercentage,
                      width: 0.12,
                      sizeUnit: GaugeSizeUnit.factor,
                      gradient: const SweepGradient(
                        colors: [Color(0xFF3b82f6), Color(0xFF2563eb)],
                        stops: [0.25, 0.75],
                      ),
                      cornerStyle: CornerStyle.bothCurve,
                    ),
                  ],
                ),

                // الدائرة الداخلية - القدرة (برتقالي)
                RadialAxis(
                  minimum: 0.0,
                  maximum: 100.0,
                  showLabels: false,
                  showTicks: false,
                  radiusFactor: 0.5,
                  axisLineStyle: AxisLineStyle(
                    thickness: 0.15,
                    color: Colors.white.withValues(alpha: 0.1),
                    thicknessUnit: GaugeSizeUnit.factor,
                  ),
                  pointers: <GaugePointer>[
                    RangePointer(
                      value: powerPercentage,
                      width: 0.15,
                      sizeUnit: GaugeSizeUnit.factor,
                      gradient: const SweepGradient(
                        colors: [Color(0xFFf97316), Color(0xFFea580c)],
                        stops: [0.25, 0.75],
                      ),
                      cornerStyle: CornerStyle.bothCurve,
                    ),
                  ],
                  annotations: <GaugeAnnotation>[
                    GaugeAnnotation(
                      widget: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.bolt,
                            color: Colors.yellow,
                            size: 40,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'نشط',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white.withValues(alpha: 0.8),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      angle: 90,
                      positionFactor: 0.1,
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // البيانات التفصيلية
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildLegendItem(
                icon: Icons.bolt,
                color: Colors.orange,
                label: 'القدرة',
                value: power.toStringAsFixed(1),
                unit: 'W',
                percentage: powerPercentage,
              ),
              Container(
                width: 1,
                height: 60,
                color: Colors.white.withValues(alpha: 0.2),
              ),
              _buildLegendItem(
                icon: Icons.show_chart,
                color: Colors.blue,
                label: 'الطاقة',
                value: energy.toStringAsFixed(2),
                unit: 'kWh',
                percentage: energyPercentage,
              ),
              Container(
                width: 1,
                height: 60,
                color: Colors.white.withValues(alpha: 0.2),
              ),
              _buildLegendItem(
                icon: Icons.eco,
                color: Colors.green,
                label: 'CO₂',
                value: co2.toStringAsFixed(1),
                unit: 'kg',
                percentage: co2Percentage,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem({
    required IconData icon,
    required Color color,
    required String label,
    required String value,
    required String unit,
    required double percentage,
  }) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.7),
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            unit,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.6),
              fontSize: 10,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${percentage.toStringAsFixed(0)}%',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.5),
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
