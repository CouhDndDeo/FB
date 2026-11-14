import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/account.dart';

class AccountRepository {
  final _db = FirebaseFirestore.instance;

  /// Личные и общие счета, доступные пользователю.
  Stream<List<Account>> watchAccounts(String uid) {
    return _db
        .collection('accounts')
        .where('members', arrayContains: uid)
        .snapshots()
        .map((s) => s.docs.map(Account.fromDoc).toList());
  }

  Future<void> addAccount(Account account) =>
      _db.collection('accounts').add(account.toMap());

  /// Пригласить партнёра в общий счёт по uid.
  Future<void> addMember(String accountId, String uid) =>
      _db.collection('accounts').doc(accountId).update({
        'members': FieldValue.arrayUnion([uid]),
      });
}
