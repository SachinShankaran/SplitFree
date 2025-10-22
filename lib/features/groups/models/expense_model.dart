import 'package:cloud_firestore/cloud_firestore.dart';

class ExpenseModel {
  final String id;
  final String description;
  final double amount;
  final String paidBy;
  final Timestamp paidAt;
  final List<String> splitAmong;

  ExpenseModel({
    required this.id,
    required this.description,
    required this.amount,
    required this.paidBy,
    required this.paidAt,
    required this.splitAmong,
  });

  factory ExpenseModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return ExpenseModel(
      id: doc.id,
      description: data['description'] ?? '',
      amount: (data['amount'] ?? 0.0).toDouble(),
      paidBy: data['paidBy'] ?? '',
      paidAt: data['paidAt'] ?? Timestamp.now(),
      splitAmong: List<String>.from(data['splitAmong'] ?? []),
    );
  }
}