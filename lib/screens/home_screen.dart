import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:firebase_database/firebase_database.dart';
import '../services/firebase_service.dart';
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

  StreamSubscription? _connectionSubscription;
  StreamSubscription? _dataSubscription;

  double power = 0.0;
  double energy = 0.0;
  double co2 = 0.0;
  double voltage = 0.0;
  double current = 0.0;
  bool isConnected = false;
  String lastUpdate = '--';

  List<EnergyData> historicalData = [];
  List<NotificationItem> notifications = [];

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
    _connectionSubscription = _firebaseService.connectionStream.listen((
      connected,
    ) {
      if (mounted && isConnected != connected) {
        setState(() => isConnected = connected);
      }
    });
  }

  void _setupFirebaseListener() {
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final ref = FirebaseDatabase.instance.ref('readings/$today');

    _dataSubscription = ref.onValue.listen((event) {
      if (!mounted) return;
      if (event.snapshot.value == null) return;

      try {
        final data = event.snapshot.value as Map<dynamic, dynamic>;
        if (data.isEmpty) return;

        int latestKey = 0;
        Map<dynamic, dynamic>? latestData;

        data.forEach((key, value) {
          if (value == null || value is! Map) return;

          final keyStr = key.toString();
          final keyInt = int.tryParse(keyStr) ?? 0;

          // ناخذ فقط timestamp مال ESP32 بالثواني، ونتجاهل التجريبي الطويل
          if (keyStr.length != 10) return;

          // نتأكد القراءة كاملة مو بس voltage
          final hasAllFields =
              value.containsKey('voltage_V') &&
              value.containsKey('current_A') &&
              value.containsKey('power_W') &&
              value.containsKey('energy_kWh');

          if (!hasAllFields) return;

          if (keyInt > latestKey) {
            latestKey = keyInt;
            latestData = Map<dynamic, dynamic>.from(value);
          }
        });

        if (latestKey == 0 || latestData == null) {
          developer.log(
            '⚠️ لم يتم العثور على قراءة كاملة وصحيحة',
            name: 'HomeScreen',
          );
          return;
        }

        developer.log('📊 آخر مفتاح صحيح: $latestKey', name: 'HomeScreen');
        developer.log('📊 البيانات: $latestData', name: 'HomeScreen');

        final newPower = _toDouble(latestData!['power_W']);
        final newEnergy = _toDouble(latestData!['energy_kWh']);
        final newVoltage = _toDouble(latestData!['voltage_V']);
        final newCurrent = _toDouble(latestData!['current_A']);
        final newCo2 = _toDouble(latestData!['co2_kg']) > 0
            ? _toDouble(latestData!['co2_kg'])
            : newEnergy * 0.4;

        developer.log(
          '✅ Power: $newPower | Voltage: $newVoltage | Current: $newCurrent | Energy: $newEnergy',
          name: 'HomeScreen',
        );

        final exists = historicalData.any(
          (e) => e.timestamp == latestKey.toString(),
        );

        List<EnergyData> newHistorical = List.from(historicalData);

        if (!exists) {
          newHistorical.add(
            EnergyData.fromFirebase(latestKey.toString(), latestData!),
          );

          if (newHistorical.length > 200) {
            newHistorical = newHistorical.sublist(newHistorical.length - 200);
          }
        }

        double newAvg = 0, newMin = 0, newMax = 0, newTotal = 0;

        if (newHistorical.isNotEmpty) {
          final vals = newHistorical.map((d) => d.energy).toList();
          newTotal = vals.reduce((a, b) => a + b);
          newAvg = newTotal / vals.length;
          newMin = vals.reduce((a, b) => a < b ? a : b);
          newMax = vals.reduce((a, b) => a > b ? a : b);
        }

        final newNotifications = List<NotificationItem>.from(notifications);

        if (newPower > 4000) {
          _addAlert(
            newNotifications,
            'danger',
            'تحذير! حمل زائد',
            'القدرة الحالية ${newPower.toStringAsFixed(1)} W',
          );
        }

        if (newVoltage > 240 || (newVoltage > 0 && newVoltage < 200)) {
          _addAlert(
            newNotifications,
            'warning',
            'تحذير الفولتية',
            'الفولتية ${newVoltage.toStringAsFixed(1)} V',
          );
        }

        setState(() {
          power = newPower;
          energy = newEnergy;
          co2 = newCo2;
          voltage = newVoltage;
          current = newCurrent;
          lastUpdate = DateFormat('HH:mm:ss').format(DateTime.now());
          historicalData = newHistorical;
          notifications = newNotifications;
          avgDaily = newAvg;
          minConsumption = newMin;
          maxConsumption = newMax;
          weeklyTotal = newTotal;
        });
      } catch (e) {
        developer.log('❌ خطأ: $e', name: 'HomeScreen');
      }
    }, onError: (e) => developer.log('❌ خطأ Firebase: $e', name: 'HomeScreen'));
  }

  double _toDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  void _addAlert(
    List<NotificationItem> list,
    String type,
    String title,
    String msg,
  ) {
    if (list.any((n) => n.title == title && n.message == msg)) return;

    list.insert(
      0,
      NotificationItem(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        type: type,
        title: title,
        message: msg,
        time: DateFormat('HH:mm:ss').format(DateTime.now()),
        date: DateFormat('yyyy-MM-dd').format(DateTime.now()),
      ),
    );

    if (list.length > 10) list.removeRange(10, list.length);
  }

  List<FlSpot> _getDailyChartData() {
    if (historicalData.isEmpty) {
      return List.generate(24, (i) => FlSpot(i.toDouble(), 0.0));
    }

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
    if (historicalData.isEmpty) {
      return List.generate(7, (i) => FlSpot(i.toDouble(), 0.0));
    }

    final cutoff = DateTime.now().subtract(const Duration(days: 7));
    final Map<int, double> daily = {};

    for (var d in historicalData.where((d) => d.dateTime.isAfter(cutoff))) {
      daily[d.dateTime.weekday] =
          (daily[d.dateTime.weekday] ?? 0) + d.energy * 0.4;
    }

    final daysOrder = [6, 7, 1, 2, 3, 4, 5];

    return List.generate(
      7,
      (i) => FlSpot(i.toDouble(), daily[daysOrder[i]] ?? 0.0),
    );
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
          const Row(
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
          const SizedBox(height: 20),
          Row(
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
            color: isSelected
                ? Colors.white
                : Colors.white.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: isSelected ? const Color(0xFF2563eb) : Colors.white,
                size: 20,
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  label,
                  style: TextStyle(
                    color: isSelected ? const Color(0xFF2563eb) : Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (index == 2 && notifications.isNotEmpty)
                Container(
                  margin: const EdgeInsets.only(right: 4),
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '${notifications.length}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
