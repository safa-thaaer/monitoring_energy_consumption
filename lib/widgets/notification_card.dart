import 'package:flutter/material.dart';
import '../models/notification_item.dart';

class NotificationCard extends StatelessWidget {
  final NotificationItem notification;

  const NotificationCard({
    super.key,
    required this.notification,
  });

  @override
  Widget build(BuildContext context) {
    Color borderColor;
    Color bgColor;
    IconData icon;

    switch (notification.type) {
      case 'danger':
        borderColor = Colors.red;
        bgColor = Colors.red.withValues(alpha: 0.2);
        icon = Icons.warning;
        break;
      case 'warning':
        borderColor = Colors.orange;
        bgColor = Colors.orange.withValues(alpha: 0.2);
        icon = Icons.error_outline;
        break;
      default:
        borderColor = Colors.blue;
        bgColor = Colors.blue.withValues(alpha: 0.2);
        icon = Icons.info_outline;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border(right: BorderSide(color: borderColor, width: 4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: borderColor, size: 24),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  notification.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            notification.message,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.8),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${notification.date} • ${notification.time}',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.6),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
