import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../widgets/chart_widget.dart';
import '../widgets/stat_card.dart';

class AnalyticsView extends StatelessWidget {
  final List<FlSpot> chartData;
  final double avgDaily;
  final double minConsumption;
  final double maxConsumption;
  final double weeklyTotal;

  const AnalyticsView({
    super.key,
    required this.chartData,
    required this.avgDaily,
    required this.minConsumption,
    required this.maxConsumption,
    required this.weeklyTotal,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          ChartWidget(chartData: chartData),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: StatCard(
                  label: 'متوسط يومي',
                  value: '${avgDaily.toStringAsFixed(2)} kWh',
                  color: Colors.blue,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: StatCard(
                  label: 'أقل استهلاك',
                  value: '${minConsumption.toStringAsFixed(2)} kWh',
                  color: Colors.green,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: StatCard(
                  label: 'أعلى استهلاك',
                  value: '${maxConsumption.toStringAsFixed(2)} kWh',
                  color: Colors.red,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: StatCard(
                  label: 'إجمالي أسبوعي',
                  value: '${weeklyTotal.toStringAsFixed(2)} kWh',
                  color: Colors.purple,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
