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
import 'dart:async'; // ✅ FIXED: مضاف

class EnergyMonitorHome extends StatefulWidget {
  const EnergyMonitorHome({super.key});

  @override
  State<EnergyMonitorHome> createState() => _EnergyMonitorHomeState();
}

class _EnergyMonitorHomeState extends State<EnergyMonitorHome> {
  int _selectedIndex = 0;
  final FirebaseService _firebaseService = FirebaseService();
  final TestDataService _testDataService = TestDataService();

  // ✅ FIXED: StreamSubscriptions لإدارة الـ streams
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
    _listenToConnectionStatus(); // ✅ FIXED: بدل _testFirebaseConnection
    _setupFirebaseListener();
  }

  // ✅ FIXED: dispose لإلغاء الـ streams عند إغلاق الشاشة
  @override
  void dispose() {
    _connectionSubscription?.cancel();
    _dataSubscription?.cancel();
    super.dispose();
  }

  // ✅ FIXED: دالة جديدة تستمع باستمرار لحالة الاتصال
  void _listenToConnectionStatus() {
    developer.log('📡 بدء الاستماع المستمر لحالة الاتصال...', name: 'HomeScreen');

    _connectionSubscription = _firebaseService.connectionStream.listen(
      (connected) {
        developer.log(
          '🔌 حالة الاتصال: ${connected ? "✅ متصل" : "❌ غير متصل"}',
          name: 'HomeScreen',
        );
        if (mounted) {
          setState(() {
            isConnected = connected;
          });
        }
      },
      onError: (error) {
        developer.log('❌ خطأ في stream الاتصال: $error', name: 'HomeScreen');
        if (mounted) {
          setState(() {
            isConnected = false;
          });
        }
      },
    );
  }

  void _setupFirebaseListener() {
    developer.log('👂 بدء الاستماع لتحديثات Firebase...', name: 'HomeScreen');

    // ✅ FIXED: نحفظ الـ subscription
    _dataSubscription = _firebaseService.dataStream.listen(
      (event) {
        try {
          developer.log('📥 تم استلام حدث من Firebase', name: 'HomeScreen');

          if (event.snapshot.value == null) {
            developer.log(
              '⚠️ البيانات المستلمة فارغة (null)',
              name: 'HomeScreen',
            );
            // ✅ FIXED: حذفنا isConnected = false من هنا
            return;
          }

          developer.log(
            '📊 نوع البيانات: ${event.snapshot.value.runtimeType}',
            name: 'HomeScreen',
          );
          developer.log(
            '📋 البيانات الخام: ${event.snapshot.value}',
            name: 'HomeScreen',
          );

          final data = event.snapshot.value as Map<dynamic, dynamic>;
          final timestamps = data.keys.toList()..sort((a, b) => b.compareTo(a));

          developer.log(
            '🕒 عدد الطوابع الزمنية: ${timestamps.length}',
            name: 'HomeScreen',
          );

          if (timestamps.isNotEmpty) {
            final latestTimestamp = timestamps[0];
            developer.log(
              '⏰ أحدث طابع زمني: $latestTimestamp',
              name: 'HomeScreen',
            );

            final latestData = data[latestTimestamp] as Map<dynamic, dynamic>;
            developer.log(
              '✅ البيانات الأخيرة: $latestData',
              name: 'HomeScreen',
            );

            _updateDashboard(latestData);
            _storeHistoricalData(latestTimestamp.toString(), latestData);
            _checkForAnomalies(latestData);

            // ✅ FIXED: حذفنا isConnected = true من هنا، connectionStream يتكفل بها

            developer.log('🎉 تم تحديث الواجهة بنجاح!', name: 'HomeScreen');
          } else {
            developer.log(
              '⚠️ لا توجد طوابع زمنية في البيانات',
              name: 'HomeScreen',
            );
          }
        } catch (e, stackTrace) {
          developer.log(
            '❌ خطأ في معالجة البيانات: $e',
            name: 'HomeScreen',
            error: e,
            stackTrace: stackTrace,
          );
          // ✅ FIXED: حذفنا isConnected = false من هنا
        }
      },
      onError: (error) {
        developer.log(
          '❌ خطأ في الاستماع لـ Firebase: $error',
          name: 'HomeScreen',
          error: error,
        );
        // ✅ FIXED: حذفنا isConnected = false من هنا
      },
      onDone: () {
        developer.log('⚠️ انتهى الاستماع لـ Firebase', name: 'HomeScreen');
      },
    );
  }

  void _updateDashboard(Map<dynamic, dynamic> data) {
    developer.log(
      '📦 البيانات الكاملة المستلمة: $data',
      name: 'UpdateDashboard',
    );

    developer.log(
      '⚡ power_W = ${data['power_W']} (نوع: ${data['power_W']?.runtimeType})',
      name: 'UpdateDashboard',
    );
    developer.log(
      '🔋 energy_kWh = ${data['energy_kWh']} (نوع: ${data['energy_kWh']?.runtimeType})',
      name: 'UpdateDashboard',
    );
    developer.log(
      '⚡ voltage_V = ${data['voltage_V']} (نوع: ${data['voltage_V']?.runtimeType})',
      name: 'UpdateDashboard',
    );
    developer.log(
      '🔌 current_A = ${data['current_A']} (نوع: ${data['current_A']?.runtimeType})',
      name: 'UpdateDashboard',
    );
    developer.log(
      '🌍 co2_kg = ${data['co2_kg']} (نوع: ${data['co2_kg']?.runtimeType})',
      name: 'UpdateDashboard',
    );

    setState(() {
      power = (data['power_W'] ?? 0.0).toDouble();
      energy = (data['energy_kWh'] ?? 0.0).toDouble();
      co2 = (data['co2_kg'] ?? energy * 0.4).toDouble();
      voltage = (data['voltage_V'] ?? 0.0).toDouble();
      current = (data['current_A'] ?? 0.0).toDouble();

      developer.log(
        '✅ القيم النهائية - Power: $power W, Energy: $energy kWh, Voltage: $voltage V, Current: $current A',
        name: 'UpdateDashboard',
      );

      if (power == 0.0 && energy == 0.0 && voltage == 0.0 && current == 0.0) {
        developer.log(
          '⚠️ جميع القيم المستلمة = 0! تحقق من اتصال المستشعرات مع ESP32',
          name: 'HomeScreen',
        );
        developer.log(
          '💡 نصيحة: اضغط زر الاختبار 🧪 لإضافة بيانات تجريبية',
          name: 'HomeScreen',
        );
      }

      lastUpdate = DateFormat('HH:mm:ss').format(DateTime.now());
    });
  }

  void _storeHistoricalData(String timestamp, Map<dynamic, dynamic> data) {
    try {
      // ✅ FIXED: معالجة timestamps بالثواني أو الميلي ثانية
      int tsInt = int.tryParse(timestamp) ?? 0;
      DateTime dateTime;
      if (tsInt > 1000000000000) {
        dateTime = DateTime.fromMillisecondsSinceEpoch(tsInt);
      } else {
        dateTime = DateTime.fromMillisecondsSinceEpoch(tsInt * 1000);
      }

      // ✅ FIXED: تجنب تكرار نفس الـ timestamp
      if (historicalData.any((e) => e.timestamp == timestamp)) return;

      final energyData = EnergyData(
        timestamp: timestamp,
        dateTime: dateTime,
        power: (data['power_W'] ?? 0.0).toDouble(),
        energy: (data['energy_kWh'] ?? 0.0).toDouble(),
        voltage: (data['voltage_V'] ?? 0.0).toDouble(),
        current: (data['current_A'] ?? 0.0).toDouble(),
      );

      setState(() {
        historicalData.add(energyData);

        final sevenDaysAgo = DateTime.now().subtract(const Duration(days: 7));
        historicalData.removeWhere((d) => d.dateTime.isBefore(sevenDaysAgo));

        historicalData.sort((a, b) => a.dateTime.compareTo(b.dateTime));

        _updateStatistics();
      });
    } catch (e) {
      developer.log('❌ خطأ في تخزين البيانات التاريخية: $e', name: 'HomeScreen');
    }
  }

  void _updateStatistics() {
    if (historicalData.isEmpty) return;

    final energyValues = historicalData.map((d) => d.energy).toList();
    final sum = energyValues.reduce((a, b) => a + b);

    setState(() {
      avgDaily = sum / energyValues.length;
      minConsumption = energyValues.reduce((a, b) => a < b ? a : b);
      maxConsumption = energyValues.reduce((a, b) => a > b ? a : b);
      weeklyTotal = sum;
    });
  }

  void _checkForAnomalies(Map<dynamic, dynamic> data) {
    final powerValue = (data['power_W'] ?? 0.0).toDouble();
    final voltageValue = (data['voltage_V'] ?? 0.0).toDouble();

    if (powerValue > 4000) {
      _addNotification(
        'danger',
        'تحذير! حمل زائد',
        'القدرة الحالية ${powerValue.toStringAsFixed(1)} W تجاوزت الحد الآمن',
      );
    }

    if (voltageValue > 240 || voltageValue < 200) {
      _addNotification(
        'warning',
        'تحذير الفولتية',
        'الفولتية ${voltageValue.toStringAsFixed(1)} V خارج النطاق الطبيعي',
      );
    }
  }

  void _addNotification(String type, String title, String message) {
    final existing = notifications
        .where((n) => n.title == title && n.message == message)
        .firstOrNull;

    if (existing != null) return;

    setState(() {
      notifications.insert(
        0,
        NotificationItem(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          type: type,
          title: title,
          message: message,
          time: DateFormat('HH:mm:ss').format(DateTime.now()),
          date: DateFormat('yyyy-MM-dd').format(DateTime.now()),
        ),
      );

      if (notifications.length > 10) {
        notifications = notifications.sublist(0, 10);
      }
    });
  }

  List<FlSpot> _getDailyChartData() {
    if (historicalData.isEmpty) {
      return List.generate(24, (i) => FlSpot(i.toDouble(), 0.0));
    }

    final last24Hours = historicalData.where((d) {
      return d.dateTime.isAfter(
        DateTime.now().subtract(const Duration(hours: 24)),
      );
    }).toList();

    final Map<int, List<double>> hourlyData = {};

    for (var d in last24Hours) {
      final hour = d.dateTime.hour;
      if (!hourlyData.containsKey(hour)) {
        hourlyData[hour] = [];
      }
      hourlyData[hour]!.add(d.energy);
    }

    List<FlSpot> spots = [];
    for (int i = 0; i < 24; i++) {
      final values = hourlyData[i];
      final avg = values != null && values.isNotEmpty
          ? values.reduce((a, b) => a + b) / values.length
          : 0.0;
      spots.add(FlSpot(i.toDouble(), avg));
    }

    final hasData = spots.any((spot) => spot.y > 0);
    if (!hasData && power > 0) {
      final currentHour = DateTime.now().hour;
      spots[currentHour] = FlSpot(currentHour.toDouble(), energy);
    }

    return spots;
  }

  List<FlSpot> _getWeeklyCO2ChartData() {
    if (historicalData.isEmpty) {
      return List.generate(7, (i) => FlSpot(i.toDouble(), 0.0));
    }

    final last7Days = historicalData.where((d) {
      return d.dateTime.isAfter(
        DateTime.now().subtract(const Duration(days: 7)),
      );
    }).toList();

    final Map<int, List<double>> dailyData = {};

    for (var d in last7Days) {
      final dayOfWeek = d.dateTime.weekday;
      if (!dailyData.containsKey(dayOfWeek)) {
        dailyData[dayOfWeek] = [];
      }
      final co2Value = d.energy * 0.4;
      dailyData[dayOfWeek]!.add(co2Value);
    }

    List<FlSpot> spots = [];
    final daysOrder = [6, 7, 1, 2, 3, 4, 5];

    for (int i = 0; i < 7; i++) {
      final dayOfWeek = daysOrder[i];
      final values = dailyData[dayOfWeek];
      final total = values != null && values.isNotEmpty
          ? values.reduce((a, b) => a + b)
          : 0.0;
      spots.add(FlSpot(i.toDouble(), total));
    }

    return spots;
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
                  developer.log(
                    '🧪 إضافة بيانات تجريبية للاختبار...',
                    name: 'HomeScreen',
                  );
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