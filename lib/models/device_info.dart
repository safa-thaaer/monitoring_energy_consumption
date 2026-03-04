import 'package:flutter/material.dart';

class DeviceInfo {
  final String name;
  final String icon;
  final double consumption;
  final bool isActive;
  final Color color;

  DeviceInfo({
    required this.name,
    required this.icon,
    required this.consumption,
    required this.isActive,
    required this.color,
  });
}