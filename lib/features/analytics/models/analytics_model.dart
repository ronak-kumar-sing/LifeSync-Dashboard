import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class AnalyticsModel {
  final String id;
  final String metricName;
  final double value;
  final DateTime date;
  final DateTime createdAt;

  AnalyticsModel({
    required this.id,
    required this.metricName,
    required this.value,
    required this.date,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'metricName': metricName,
        'value': value,
        'date': date.toIso8601String(),
        'createdAt': createdAt.toIso8601String(),
      };

  factory AnalyticsModel.fromJson(Map<String, dynamic> json) => AnalyticsModel(
        id: json['id'] as String,
        metricName: json['metricName'] as String,
        value: (json['value'] as num).toDouble(),
        date: DateTime.parse(json['date'] as String),
        createdAt: DateTime.parse(json['createdAt'] as String),
      );
}
