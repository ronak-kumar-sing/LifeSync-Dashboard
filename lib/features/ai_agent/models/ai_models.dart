import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class AIMessage {
  final String role; // 'user' or 'assistant'
  final String content;
  final List<FlSpot>? chartData;
  final DateTime timestamp;

  AIMessage({
    required this.role,
    required this.content,
    this.chartData,
    required this.timestamp,
  });
}
