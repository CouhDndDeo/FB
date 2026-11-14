import 'package:cloud_firestore/cloud_firestore.dart';

enum AccountType { card, cash, savings, other }

class Account {
  final String id;
  final String name;
  final AccountType type;
  final double balance; // в рублях
  final String ownerId;  // uid владельца
  final bool shared;     // общий (семейный) счёт
  final List<String> members; // uid участников общего счёта

  Account({
    required this.id,
    required this.name,
    required this.type,
    required this.balance,
    required this.ownerId,
    required this.shared,
    required this.members,
  });

  factory Account.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data()!;
    return Account(
      id: doc.id,
      name: d['name'] as String,
      type: AccountType.values.byName(d['type'] as String),
      balance: (d['balance'] as num).toDouble(),
      ownerId: d['ownerId'] as String,
      shared: d['shared'] as bool? ?? false,
      members: List<String>.from(d['members'] ?? []),
    );
  }

  Map<String, dynamic> toMap() => {
        'name': name,
        'type': type.name,
        'balance': balance,
        'ownerId': ownerId,
        'shared': shared,
        'members': members,
      };
}
