import 'package:cloud_firestore/cloud_firestore.dart';

class Settlement {
  final String id;
  final String from;
  final String to;
  final double amount;
  final DateTime settledAt;

  Settlement({
    required this.id,
    required this.from,
    required this.to,
    required this.amount,
    required this.settledAt,
  });

  factory Settlement.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Settlement(
      id: doc.id,
      from: data['from'] ?? '',
      to: data['to'] ?? '',
      amount: (data['amount'] ?? 0.0).toDouble(),
      settledAt: (data['settledAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'from': from,
      'to': to,
      'amount': amount,
      'settledAt': Timestamp.fromDate(settledAt),
    };
  }
}