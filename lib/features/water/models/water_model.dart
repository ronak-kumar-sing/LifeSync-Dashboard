import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class WaterModel {
  final String id;
  final double amount; // in liters
  final DateTime date;
  final DateTime createdAt;

  WaterModel({
    required this.id,
    required this.amount,
    required this.date,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'amount': amount,
        'date': date.toIso8601String(),
        'createdAt': createdAt.toIso8601String(),
      };

  factory WaterModel.fromJson(Map<String, dynamic> json) => WaterModel(
        id: json['id'] as String,
        amount: (json['amount'] as num).toDouble(),
        date: DateTime.parse(json['date'] as String),
        createdAt: DateTime.parse(json['createdAt'] as String),
      );
}
