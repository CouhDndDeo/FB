import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/account.dart';
import '../services/account_repository.dart';
import '../services/auth_service.dart';
import 'accounts_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = AuthService.instance.currentUser!.uid;
    final fmt = NumberFormat.currency(locale: 'ru_RU', symbol: '₽', decimalDigits: 0);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Бюджет'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: AuthService.instance.signOut,
          ),
        ],
      ),
      body: StreamBuilder<List<Account>>(
        stream: AccountRepository().watchAccounts(uid),
        builder: (context, snap) {
          final accounts = snap.data ?? [];
          final total = accounts.fold<double>(0, (s, a) => s + a.balance);
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Общий баланс',
                          style: TextStyle(color: Theme.of(context).colorScheme.secondary)),
                      const SizedBox(height: 8),
                      Text(fmt.format(total),
                          style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w700)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Счета'),
                subtitle: Text('${accounts.length} шт.'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const AccountsScreen())),
              ),
            ],
          );
        },
      ),
    );
  }
}
