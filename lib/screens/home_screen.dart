import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart' hide TextDirection;
import '../services/firebase_service.dart';
import '../services/test_data_service.dart';
import '../models/energy_data.dart';
import '../models/notification_item.dart';
import 'dashboard_view.dart';
import 'analytics_view.dart';
import 'notifications_view.dart';
import 'dart:developer' as developer;
import 'dart:async';

class EnergyMonitorHome extends StatefulWidget {
  const EnergyMonitorHome({super.key});

  @override
  State<EnergyMonitorHome> createState() => _EnergyMonitorHomeState();
}

class _EnergyMonitorHomeState extends State<EnergyMonitorHome> {
  int _selectedIndex = 0;
  final FirebaseService _firebaseService = FirebaseService();
  final TestDataService _testDataService = TestDataService();

  StreamSubscription? _connectionSubscription;
  StreamSubscription? _dataSubscription;

  // Live Data
  double power = 0.0;
  double energy = 0.0;
  double co2 = 0.0;
  double voltage = 0.0;
  double current = 0.0;
  bool isConnected = false;
  String lastUpdate = '--';

  // Historical Data
  List<EnergyData> historicalData = [];
  List<NotificationItem> notifications = [];

  // Statistics
  double avgDaily = 0.0;
  double minConsumption = 0.0;
  double maxConsumption = 0.0;
  double weeklyTotal = 0.0;

  @override
  void initState() {
    super.initState();
    _listenToConnectionStatus();
    _setupFirebaseListener();
  }

  @override
  void dispose() {
    _connectionSubscription?.cancel();
    _dataSubscription?.cancel();
    super.dispose();
  }

  void _listenToConnectionStatus() {
    _connectionSubscription = _firebaseService.connectionStream.listen(
      (connected) {
        if (mounted && isConnected != connected) {
          setState(() => isConnected = connected);
        }
      },
      onError: (_) {
        if (mounted) {
          setState(() => isConnected = false);
        }
      },
    );
  }

  void _setupFirebaseListener() {
    _dataSubscription = _firebaseService.dataStream.listen(
      (event) {
        if (!mounted) return;
        if (event.snapshot.value == null) return;

        try {
          final data = event.snapshot.value as Map<dynamic, dynamic>;

          // ✅ ترتيب يشتغل مع أي نوع مفتاح (نص أو رقم)
          final timestamps = data.keys.toList()
            ..sort((a, b) => b.toString().compareTo(a.toString()));

          if (timestamps.isEmpty) return;

          final latestTimestamp = timestamps[0];
          final latestData = data[latestTimestamp] as Map<dynamic, dynamic>;

          // القراءات
          final newPower   = (latestData['power_W']    ?? 0.0).toDouble();
          final newEnergy  = (latestData['energy_kWh'] ?? 0.0).toDouble();
          final newCo2     = (latestData['co2_kg']     ?? newEnergy * 0.4).toDouble();
          final newVoltage = (latestData['voltage_V']  ?? 0.0).toDouble();
          final newCurrent = (latestData['current_A']  ?? 0.0).toDouble();
          final newTime    = DateFormat('HH:mm:ss').format(DateTime.now());

          // ✅ تحويل الـ timestamp — يشتغل مع Unix رقم أو تاريخ نص "2026-05-01"
          DateTime dt;
          try {
            final tsInt = int.parse(latestTimestamp.toString());
            dt = tsInt > 1000000000000
                ? DateTime.fromMillisecondsSinceEpoch(tsInt)
                : DateTime.fromMillisecondsSinceEpoch(tsInt * 1000);
          } catch (_) {
            dt = DateTime.tryParse(latestTimestamp.toString()) ?? DateTime.now();
          }

          // البيانات التاريخية
          final alreadyExists = historicalData.any(
            (e) => e.timestamp == latestTimestamp.toString(),
          );

          List<EnergyData> newHistorical = List.from(historicalData);
          if (!alreadyExists) {
            newHistorical.add(EnergyData(
              timestamp: latestTimestamp.toString(),
              dateTime: dt,
              power: newPower,
              energy: newEnergy,
              voltage: newVoltage,
              current: newCurrent,
            ));
            final cutoff = DateTime.now().subtract(const Duration(days: 7));
            newHistorical.removeWhere((e) => e.dateTime.isBefore(cutoff));
            if (newHistorical.length > 500) {
              newHistorical = newHistorical.sublist(newHistorical.length - 500);
            }
            newHistorical.sort((a, b) => a.dateTime.compareTo(b.dateTime));
          }

          // الإحصائيات
          double newAvg = 0, newMin = 0, newMax = 0, newTotal = 0;
          if (newHistorical.isNotEmpty) {
            final vals = newHistorical.map((d) => d.energy).toList();
            newTotal = vals.reduce((a, b) => a + b);
            newAvg   = newTotal / vals.length;
            newMin   = vals.reduce((a, b) => a < b ? a : b);
            newMax   = vals.reduce((a, b) => a > b ? a : b);
          }

          // الإشعارات
          final newNotifications = List<NotificationItem>.from(notifications);
          void addAlert(String type, String title, String msg) {
            final dup = newNotifications.any((n) => n.title == title && n.message == msg);
            if (dup) return;
            newNotifications.insert(0, NotificationItem(
              id: DateTime.now().millisecondsSinceEpoch.toString(),
              type: type, title: title, message: msg,
              time: DateFormat('HH:mm:ss').format(DateTime.now()),
              date: DateFormat('yyyy-MM-dd').format(DateTime.now()),
            ));
            if (newNotifications.length > 10) {
              newNotifications.removeRange(10, newNotifications.length);
            }
          }
          if (newPower > 4000) {
            addAlert('danger', 'تحذير! حمل زائد',
                'القدرة الحالية ${newPower.toStringAsFixed(1)} W تجاوزت الحد الآمن');
          }
          if (newVoltage > 240 || (newVoltage > 0 && newVoltage < 200)) {
            addAlert('warning', 'تحذير الفولتية',
                'الفولتية ${newVoltage.toStringAsFixed(1)} V خارج النطاق الطبيعي');
          }

          // setState مرة وحدة فقط
          setState(() {
            power          = newPower;
            energy         = newEnergy;
            co2            = newCo2;
            voltage        = newVoltage;
            current        = newCurrent;
            lastUpdate     = newTime;
            historicalData = newHistorical;
            notifications  = newNotifications;
            avgDaily       = newAvg;
            minConsumption = newMin;
            maxConsumption = newMax;
            weeklyTotal    = newTotal;
          });

          developer.log('✅ تحديث: $newPower W | $newVoltage V | $newCurrent A', name: 'HomeScreen');
        } catch (e) {
          developer.log('❌ خطأ: $e', name: 'HomeScreen');
        }
      },
      onError: (e) => developer.log('❌ خطأ Firebase: $e', name: 'HomeScreen'),
    );
  }

  List<FlSpot> _getDailyChartData() {
    if (historicalData.isEmpty) return List.generate(24, (i) => FlSpot(i.toDouble(), 0.0));

    final cutoff = DateTime.now().subtract(const Duration(hours: 24));
    final Map<int, List<double>> hourly = {};
    for (var d in historicalData.where((d) => d.dateTime.isAfter(cutoff))) {
      hourly.putIfAbsent(d.dateTime.hour, () => []).add(d.energy);
    }

    return List.generate(24, (i) {
      final vals = hourly[i];
      final avg = (vals != null && vals.isNotEmpty)
          ? vals.reduce((a, b) => a + b) / vals.length
          : 0.0;
      return FlSpot(i.toDouble(), avg);
    });
  }

  List<FlSpot> _getWeeklyCO2ChartData() {
    if (historicalData.isEmpty) return List.generate(7, (i) => FlSpot(i.toDouble(), 0.0));

    final cutoff = DateTime.now().subtract(const Duration(days: 7));
    final Map<int, double> daily = {};
    for (var d in historicalData.where((d) => d.dateTime.isAfter(cutoff))) {
      daily[d.dateTime.weekday] = (daily[d.dateTime.weekday] ?? 0) + d.energy * 0.4;
    }

    final daysOrder = [6, 7, 1, 2, 3, 4, 5];
    return List.generate(7, (i) => FlSpot(i.toDouble(), daily[daysOrder[i]] ?? 0.0));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0f172a),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0f172a), Color(0xFF1e3a8a), Color(0xFF0f172a)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: IndexedStack(
                  index: _selectedIndex,
                  children: [
                    DashboardView(
                      isConnected: isConnected,
                      lastUpdate: lastUpdate,
                      power: power,
                      energy: energy,
                      co2: co2,
                    ),
                    AnalyticsView(
                      dailyChartData: _getDailyChartData(),
                      weeklyChartData: _getWeeklyCO2ChartData(),
                      avgDaily: avgDaily,
                      minConsumption: minConsumption,
                      maxConsumption: maxConsumption,
                      weeklyTotal: weeklyTotal,
                    ),
                    NotificationsView(notifications: notifications),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2563eb), Color(0xFF4f46e5)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.bolt, color: Colors.yellow, size: 40),
                    SizedBox(width: 12),
                    Flexible(
                      child: Text(
                        'نظام مراقبة استهلاك الطاقة',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () async {
                  await _testDataService.addMultipleTestReadings(count: 24);
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('✅ تم إضافة 24 قراءة تجريبية!'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  }
                },
                icon: const Icon(Icons.science, color: Colors.white70),
                tooltip: 'إضافة بيانات تجريبية للاختبار',
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildNavButton(0, Icons.bolt, 'الاستهلاك اللحظي'),
              const SizedBox(width: 12),
              _buildNavButton(1, Icons.trending_up, 'التحليل'),
              const SizedBox(width: 12),
              _buildNavButton(2, Icons.notifications, 'التنبيهات'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNavButton(int index, IconData icon, String label) {
    final isSelected = _selectedIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedIndex = index),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.white.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon,
                  color: isSelected ? const Color(0xFF2563eb) : Colors.white,
                  size: 20),
              const SizedBox(width: 6),
              Flexible(
                child: Text(label,
                    style: TextStyle(
                      color: isSelected ? const Color(0xFF2563eb) : Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                    overflow: TextOverflow.ellipsis),
              ),
              if (index == 2 && notifications.isNotEmpty)
                Container(
                  margin: const EdgeInsets.only(right: 4),
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                      color: Colors.red, shape: BoxShape.circle),
                  child: Text('${notifications.length}',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold)),
                ),
            ],
          ),
        ),
      ),
    );
  }
}