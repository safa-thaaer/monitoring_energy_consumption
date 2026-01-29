import 'package:flutter/material.dart';
import '../widgets/energy_card.dart';
import '../widgets/multi_circular_gauge.dart';

class DashboardView extends StatelessWidget {
  final bool isConnected;
  final String lastUpdate;
  final double power;
  final double energy;
  final double co2;

  const DashboardView({
    super.key,
    required this.isConnected,
    required this.lastUpdate,
    required this.power,
    required this.energy,
    required this.co2,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // حالة الاتصال
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: isConnected ? Colors.green : Colors.red,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      isConnected ? 'متصل بـ Firebase' : 'غير متصل',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Text(
                  'آخر تحديث: $lastUpdate',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.7),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 20),
          
          // العداد الدائري الموحد
          MultiCircularGauge(
            power: power,
            energy: energy,
            co2: co2,
          ),
          
          const SizedBox(height: 20),
          
          // البطاقات التفصيلية
          EnergyCard(
            title: 'القدرة الحالية',
            subtitle: 'Power',
            value: power.toStringAsFixed(2),
            unit: 'واط (W)',
            color: Colors.orange,
            icon: Icons.bolt,
            progress: power / 5000,
          ),
          const SizedBox(height: 16),
          EnergyCard(
            title: 'الطاقة المستهلكة',
            subtitle: 'Energy',
            value: energy.toStringAsFixed(3),
            unit: 'كيلوواط/ساعة (kWh)',
            color: Colors.blue,
            icon: Icons.show_chart,
            progress: energy / 50,
          ),
          const SizedBox(height: 16),
          EnergyCard(
            title: 'انبعاثات CO₂',
            subtitle: 'Carbon Emissions',
            value: co2.toStringAsFixed(2),
            unit: 'كيلوغرام (kg)',
            color: Colors.green,
            icon: Icons.eco,
            progress: co2 / 100,
          ),
        ],
      ),
    );
  }
}