import 'package:hive/hive.dart';
import 'package:equatable/equatable.dart';

class IncomeEntry extends Equatable {
  final String id;
  final double amount;
  final String label;
  final String category;
  final DateTime date;
  final bool isIncome; // true = income, false = expense
  final DateTime createdAt;

  const IncomeEntry({
    required this.id,
    required this.amount,
    required this.label,
    required this.category,
    required this.date,
    required this.isIncome,
    required this.createdAt,
  });

  double get signedAmount => isIncome ? amount : -amount;

  Map<String, dynamic> toJson() => {
        'id': id,
        'amount': amount,
        'label': label,
        'category': category,
        'date': date.toIso8601String(),
        'isIncome': isIncome,
        'createdAt': createdAt.toIso8601String(),
        'timestamp': createdAt.millisecondsSinceEpoch,
      };

  factory IncomeEntry.fromJson(Map<String, dynamic> json) {
    return IncomeEntry(
      id: json['id'] as String,
      amount: (json['amount'] as num).toDouble(),
      label: json['label'] as String,
      category: json['category'] as String? ?? 'General',
      date: DateTime.parse(json['date'] as String),
      isIncome: json['isIncome'] as bool? ?? true,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  IncomeEntry copyWith({
    String? id,
    double? amount,
    String? label,
    String? category,
    DateTime? date,
    bool? isIncome,
    DateTime? createdAt,
  }) {
    return IncomeEntry(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      label: label ?? this.label,
      category: category ?? this.category,
      date: date ?? this.date,
      isIncome: isIncome ?? this.isIncome,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [id, amount, label, category, date, isIncome, createdAt];
}
