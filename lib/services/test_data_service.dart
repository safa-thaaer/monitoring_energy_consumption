import 'package:firebase_database/firebase_database.dart';
import 'dart:math';
import 'dart:developer' as developer;

/// خدمة لإضافة بيانات تجريبية للاختبار
/// استخدم هذه الخدمة فقط للاختبار عندما ESP32 غير متاح
class TestDataService {
  final DatabaseReference _database = FirebaseDatabase.instance.ref();

  /// إضافة بيانات تجريبية واحدة
  Future<void> addSingleTestReading() async {
    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      final random = Random();

      // بيانات تجريبية واقعية
      final voltage = 220.0 + (random.nextDouble() * 10 - 5); // 215-225V
      final current = 5.0 + (random.nextDouble() * 3); // 5-8A
      final power = voltage * current; // حساب القدرة
      final energy = power / 1000.0 * 0.001; // تقريبي
      final co2 = energy * 0.4;

      final data = {
        'power_W': power,
        'voltage_V': voltage,
        'current_A': current,
        'energy_kWh': energy,
        'co2_kg': co2,
      };

      await _database.child('readings').child(timestamp).set(data);

      developer.log(
        '✅ تم إضافة بيانات تجريبية: $data',
        name: 'TestDataService',
      );
    } catch (e) {
      developer.log(
        '❌ خطأ في إضافة البيانات التجريبية: $e',
        name: 'TestDataService',
      );
    }
  }

  /// إضافة عدة قراءات تجريبية (للساعات السابقة)
  Future<void> addMultipleTestReadings({int count = 24}) async {
    try {
      developer.log(
        '🔄 جاري إضافة $count قراءة تجريبية...',
        name: 'TestDataService',
      );

      final now = DateTime.now();
      final random = Random();

      for (int i = 0; i < count; i++) {
        // قراءات كل ساعة للـ 24 ساعة الماضية
        final timestamp = now
            .subtract(Duration(hours: count - i))
            .millisecondsSinceEpoch
            .toString();

        // توليد بيانات واقعية مع تنوع
        final baseLoad = 1200.0; // حمل أساسي
        final variation = random.nextDouble() * 800; // تنوع 0-800W
        final power = baseLoad + variation;

        final voltage = 220.0 + (random.nextDouble() * 10 - 5);
        final current = power / voltage;
        final energy = power / 1000.0 * 0.01; // تقريبي لكل ساعة
        final co2 = energy * 0.4;

        final data = {
          'power_W': power,
          'voltage_V': voltage,
          'current_A': current,
          'energy_kWh': energy,
          'co2_kg': co2,
        };

        await _database.child('readings').child(timestamp).set(data);

        // تأخير بسيط لتجنب الضغط على Firebase
        await Future.delayed(const Duration(milliseconds: 100));
      }

      developer.log(
        '✅ تم إضافة $count قراءة تجريبية بنجاح!',
        name: 'TestDataService',
      );
    } catch (e) {
      developer.log(
        '❌ خطأ في إضافة البيانات المتعددة: $e',
        name: 'TestDataService',
      );
    }
  }

  /// مسح جميع البيانات (استخدم بحذر!)
  Future<void> clearAllReadings() async {
    try {
      developer.log('⚠️ جاري مسح جميع البيانات...', name: 'TestDataService');

      await _database.child('readings').remove();

      developer.log('✅ تم مسح جميع البيانات', name: 'TestDataService');
    } catch (e) {
      developer.log('❌ خطأ في مسح البيانات: $e', name: 'TestDataService');
    }
  }
}
