import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/account.dart';
import '../services/account_repository.dart';
import '../services/auth_service.dart';

class AccountsScreen extends StatelessWidget {
  const AccountsScreen({super.key});

  static const _typeLabels = {
    AccountType.card: 'Карта',
    AccountType.cash: 'Наличные',
    AccountType.savings: 'Накопления',
    AccountType.other: 'Другое',
  };

  @override
  Widget build(BuildContext context) {
    final uid = AuthService.instance.currentUser!.uid;
    final repo = AccountRepository();
    final fmt = NumberFormat.currency(locale: 'ru_RU', symbol: '₽', decimalDigits: 0);

    return Scaffold(
      appBar: AppBar(title: const Text('Счета')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddDialog(context, repo, uid),
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder<List<Account>>(
        stream: repo.watchAccounts(uid),
        builder: (context, snap) {
          final list = snap.data ?? [];
          if (list.isEmpty) {
            return const Center(child: Text('Добавьте первый счёт'));
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: list.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (_, i) {
              final a = list[i];
              return Card(
                child: ListTile(
                  leading: Icon(a.shared ? Icons.group : Icons.account_balance_wallet_outlined),
                  title: Text(a.name),
                  subtitle: Text('${_typeLabels[a.type]} · ${a.shared ? "Общий" : "Личный"}'),
                  trailing: Text(fmt.format(a.balance),
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _showAddDialog(BuildContext context, AccountRepository repo, String uid) {
    final nameCtrl = TextEditingController();
    final balanceCtrl = TextEditingController(text: '0');
    var type = AccountType.card;
    var shared = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheet) => Padding(
          padding: EdgeInsets.fromLTRB(20, 20, 20,
              MediaQuery.of(ctx).viewInsets.bottom + 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(hintText: 'Название (например, Сбер)'),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<AccountType>(
                value: type,
                dropdownColor: Theme.of(context).colorScheme.surface,
                decoration: const InputDecoration(),
                items: _typeLabels.entries
                    .map((e) => DropdownMenuItem(value: e.key, child: Text(e.value)))
                    .toList(),
                onChanged: (v) => setSheet(() => type = v!),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: balanceCtrl,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(hintText: 'Начальный баланс, ₽'),
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Общий счёт (семья)'),
                value: shared,
                onChanged: (v) => setSheet(() => shared = v),
              ),
              const SizedBox(height: 8),
              FilledButton(
                onPressed: () async {
                  if (nameCtrl.text.trim().isEmpty) return;
                  await repo.addAccount(Account(
                    id: '',
                    name: nameCtrl.text.trim(),
                    type: type,
                    balance: double.tryParse(balanceCtrl.text.replaceAll(',', '.')) ?? 0,
                    ownerId: uid,
                    shared: shared,
                    members: [uid],
                  ));
                  if (ctx.mounted) Navigator.pop(ctx);
                },
                child: const Text('Добавить счёт'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
