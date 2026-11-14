import 'package:cloud_firestore/cloud_firestore.dart';

enum TxType { income, expense, transfer }

class Transaction {
  final String id;
  final String accountId;
  final TxType type;
  final double amount; // всегда положительное, знак задаётся типом
  final String categoryId;
  final String note;
  final DateTime date;
  final String createdBy;

  Transaction({
    required this.id,
    required this.accountId,
    required this.type,
    required this.amount,
    required this.categoryId,
    required this.note,
    required this.date,
    required this.createdBy,
  });

  Map<String, dynamic> toMap() => {
        'accountId': accountId,
        'type': type.name,
        'amount': amount,
        'categoryId': categoryId,
        'note': note,
        'date': Timestamp.fromDate(date),
        'createdBy': createdBy,
      };
}
