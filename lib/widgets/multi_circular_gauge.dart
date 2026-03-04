import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';
import '../models/device_info.dart';

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

  // حساب استهلاك الأجهزة ديناميكياً
  List<DeviceInfo> _calculateDevices() {
    List<DeviceInfo> devices = [];

    // الشاحن: يستهلك 5-20W (إذا شغال)
    double chargerConsumption = 0;
    bool chargerActive = false;

    // الإضاءة: تستهلك من 30W فما فوق
    double lightConsumption = 0;
    bool lightActive = false;

    if (power > 0) {
      // لو القدرة قليلة (0-25W) = شاحن فقط
      if (power <= 25) {
        chargerConsumption = power;
        chargerActive = true;
      }
      // لو القدرة متوسطة (25-50W) = إضاءة خفيفة فقط
      else if (power <= 50) {
        lightConsumption = power;
        lightActive = true;
      }
      // لو القدرة عالية = الاثنين شغالين
      else {
        chargerConsumption = 20; // الشاحن يستهلك تقريباً 20W
        lightConsumption = power - chargerConsumption;
        chargerActive = true;
        lightActive = true;
      }
    }
    devices.add(
      DeviceInfo(
        name: 'الإضاءة',
        icon: '💡',
        consumption: lightConsumption,
        isActive: lightActive,
        color: const Color(0xFFfbbf24),
      ),
    );
    devices.add(
      DeviceInfo(
        name: 'الشاحن',
        icon: '🔌',
        consumption: chargerConsumption,
        isActive: chargerActive,
        color: const Color(0xFF34d399),
      ),
    );

    return devices;
  }

  @override
  Widget build(BuildContext context) {
    final devices = _calculateDevices();
    final powerPercentage = (power / 5000 * 100).clamp(0, 100).toDouble();
    final energyPercentage = (energy / 50 * 100).clamp(0, 100).toDouble();
    final co2Percentage = (co2 / 100 * 100).clamp(0, 100).toDouble();

    // حساب نسبة كل جهاز من الإجمالي
    final lightPercentage = power > 0
        ? (devices[0].consumption / power * 100).clamp(0, 100).toDouble()
        : 0.0;
    final chargerPercentage = power > 0
        ? (devices[1].consumption / power * 100).clamp(0, 100).toDouble()
        : 0.0;

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
                // الدائرة الخارجية - CO₂ (أخضر داكن)
                RadialAxis(
                  minimum: 0,
                  maximum: 100,
                  showLabels: false,
                  showTicks: false,
                  radiusFactor: 1.0,
                  axisLineStyle: AxisLineStyle(
                    thickness: 0.08,
                    color: Colors.white.withValues(alpha: 0.1),
                    thicknessUnit: GaugeSizeUnit.factor,
                  ),
                  pointers: <GaugePointer>[
                    RangePointer(
                      value: co2Percentage,
                      width: 0.08,
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
                  minimum: 0,
                  maximum: 100,
                  showLabels: false,
                  showTicks: false,
                  radiusFactor: 0.85,
                  axisLineStyle: AxisLineStyle(
                    thickness: 0.09,
                    color: Colors.white.withValues(alpha: 0.1),
                    thicknessUnit: GaugeSizeUnit.factor,
                  ),
                  pointers: <GaugePointer>[
                    RangePointer(
                      value: energyPercentage,
                      width: 0.09,
                      sizeUnit: GaugeSizeUnit.factor,
                      gradient: const SweepGradient(
                        colors: [Color(0xFF3b82f6), Color(0xFF2563eb)],
                        stops: [0.25, 0.75],
                      ),
                      cornerStyle: CornerStyle.bothCurve,
                    ),
                  ],
                ),

                // الدائرة الداخلية - القدرة الإجمالية (برتقالي)
                RadialAxis(
                  minimum: 0,
                  maximum: 100,
                  showLabels: false,
                  showTicks: false,
                  radiusFactor: 0.70,
                  axisLineStyle: AxisLineStyle(
                    thickness: 0.1,
                    color: Colors.white.withValues(alpha: 0.1),
                    thicknessUnit: GaugeSizeUnit.factor,
                  ),
                  pointers: <GaugePointer>[
                    RangePointer(
                      value: powerPercentage,
                      width: 0.1,
                      sizeUnit: GaugeSizeUnit.factor,
                      gradient: const SweepGradient(
                        colors: [Color(0xFFf97316), Color(0xFFea580c)],
                        stops: [0.25, 0.75],
                      ),
                      cornerStyle: CornerStyle.bothCurve,
                    ),
                  ],
                ),

                // دائرة الأجهزة - الإضاءة والشاحن (دائرة داخلية مقسمة)
                RadialAxis(
                  minimum: 0,
                  maximum: 100,
                  showLabels: false,
                  showTicks: false,
                  radiusFactor: 0.50,
                  startAngle: 270,
                  endAngle: 270,
                  axisLineStyle: const AxisLineStyle(thickness: 0),
                  pointers: <GaugePointer>[
                    // الإضاءة
                    RangePointer(
                      value: lightPercentage,
                      width: 0.25,
                      sizeUnit: GaugeSizeUnit.factor,
                      color: devices[0].color.withValues(alpha: 0.8),
                      cornerStyle: CornerStyle.bothCurve,
                    ),
                  ],
                ),

                RadialAxis(
                  minimum: 0,
                  maximum: 100,
                  showLabels: false,
                  showTicks: false,
                  radiusFactor: 0.50,
                  startAngle: 270 + (lightPercentage * 3.6),
                  endAngle: 270 + (lightPercentage * 3.6),
                  axisLineStyle: const AxisLineStyle(thickness: 0),
                  pointers: <GaugePointer>[
                    // الشاحن
                    RangePointer(
                      value: chargerPercentage,
                      width: 0.25,
                      sizeUnit: GaugeSizeUnit.factor,
                      color: devices[1].color.withValues(alpha: 0.8),
                      cornerStyle: CornerStyle.bothCurve,
                    ),
                  ],
                  annotations: <GaugeAnnotation>[
                    GaugeAnnotation(
                      widget: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.power,
                            color: Colors.yellow,
                            size: 35,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            power > 0 ? 'نشط' : 'متوقف',
                            style: TextStyle(
                              fontSize: 14,
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

          // البيانات التفصيلية للاستهلاك العام
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

          const SizedBox(height: 20),

          // قسم الأجهزة المتصلة
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.1),
                width: 1,
              ),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.devices, color: Colors.cyan, size: 20),
                    const SizedBox(width: 8),
                    const Text(
                      'الأجهزة المتصلة',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: devices
                      .map((device) => _buildDeviceItem(device))
                      .toList(),
                ),
              ],
            ),
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

  Widget _buildDeviceItem(DeviceInfo device) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: device.isActive
              ? device.color.withValues(alpha: 0.15)
              : Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: device.isActive
                ? device.color.withValues(alpha: 0.4)
                : Colors.white.withValues(alpha: 0.1),
            width: 2,
          ),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(device.icon, style: const TextStyle(fontSize: 24)),
                const SizedBox(width: 4),
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: device.isActive ? Colors.green : Colors.red,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              device.name,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.9),
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${device.consumption.toStringAsFixed(1)} W',
              style: TextStyle(
                color: device.color,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              device.isActive ? 'شغال' : 'مطفي',
              style: TextStyle(
                color: device.isActive
                    ? Colors.green.withValues(alpha: 0.8)
                    : Colors.red.withValues(alpha: 0.8),
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
