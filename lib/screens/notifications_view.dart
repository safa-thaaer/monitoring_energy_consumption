import 'package:flutter/material.dart';
import '../models/notification_item.dart';
import '../widgets/notification_card.dart';

class NotificationsView extends StatelessWidget {
  final List<NotificationItem> notifications;

  const NotificationsView({
    super.key,
    required this.notifications,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.notifications, color: Colors.yellow, size: 30),
                SizedBox(width: 12),
                Text(
                  'التنبيهات والإشعارات',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            if (notifications.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(40),
                  child: Text(
                    'لا توجد تنبيهات حالياً',
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                ),
              )
            else
              ...notifications.map(
                (notif) => NotificationCard(notification: notif),
              ),
          ],
        ),
      ),
    );
  }
}
