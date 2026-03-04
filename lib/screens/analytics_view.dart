import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../widgets/stat_card.dart';

class AnalyticsView extends StatefulWidget {
  final List<FlSpot> dailyChartData;
  final List<FlSpot> weeklyChartData;
  final double avgDaily;
  final double minConsumption;
  final double maxConsumption;
  final double weeklyTotal;

  const AnalyticsView({
    super.key,
    required this.dailyChartData,
    required this.weeklyChartData,
    required this.avgDaily,
    required this.minConsumption,
    required this.maxConsumption,
    required this.weeklyTotal,
  });

  @override
  State<AnalyticsView> createState() => _AnalyticsViewState();
}

class _AnalyticsViewState extends State<AnalyticsView> {
  bool showWeekly = false; // false = يومي, true = أسبوعي

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // زر التبديل بين اليومي والأسبوعي
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => showWeekly = false),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: !showWeekly
                            ? Colors.blue
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        'يومي (24 ساعة)',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: !showWeekly
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => showWeekly = true),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: showWeekly
                            ? Colors.green
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        'أسبوعي (CO₂)',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: showWeekly
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 20),
          
          // الرسم البياني
          _buildChart(),
          
          const SizedBox(height: 20),
          
          // الإحصائيات
          Row(
            children: [
              Expanded(
                child: StatCard(
                  label: 'متوسط يومي',
                  value: '${widget.avgDaily.toStringAsFixed(2)} kWh',
                  color: Colors.blue,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: StatCard(
                  label: 'أقل استهلاك',
                  value: '${widget.minConsumption.toStringAsFixed(2)} kWh',
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
                  value: '${widget.maxConsumption.toStringAsFixed(2)} kWh',
                  color: Colors.red,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: StatCard(
                  label: 'إجمالي أسبوعي',
                  value: '${widget.weeklyTotal.toStringAsFixed(2)} kWh',
                  color: Colors.purple,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChart() {
    final chartData = showWeekly ? widget.weeklyChartData : widget.dailyChartData;
    final title = showWeekly ? 'انبعاثات CO₂ الأسبوعية' : 'الاستهلاك اليومي (24 ساعة)';
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                showWeekly ? Icons.eco : Icons.show_chart,
                color: showWeekly ? Colors.green : Colors.yellow,
                size: 30,
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 250,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: Colors.white.withValues(alpha: 0.1),
                    strokeWidth: 1,
                  ),
                ),
                titlesData: FlTitlesData(
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) => Text(
                        value.toStringAsFixed(0),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: showWeekly ? 1 : 4,
                      getTitlesWidget: (value, meta) {
                        if (showWeekly) {
                          final days = ['سبت', 'أحد', 'اثنين', 'ثلاثاء', 'أربعاء', 'خميس', 'جمعة'];
                          if (value.toInt() >= 0 && value.toInt() < days.length) {
                            return Text(
                              days[value.toInt()],
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                              ),
                            );
                          }
                        } else {
                          return Text(
                            '${value.toInt()}:00',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                            ),
                          );
                        }
                        return const Text('');
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: chartData,
                    isCurved: true,
                    color: showWeekly ? Colors.green : Colors.yellow,
                    barWidth: 3,
                    dotData: const FlDotData(show: true),
                    belowBarData: BarAreaData(
                      show: true,
                      color: showWeekly 
                          ? Colors.green.withValues(alpha: 0.1)
                          : Colors.yellow.withValues(alpha: 0.1),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}