import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/client_model.dart';
import '../services/firestore_service.dart';
import 'add_client_screen.dart';
import 'team_list_screen.dart';
import 'client_detail_screen.dart';
import 'package:url_launcher/url_launcher.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final FirestoreService _service = FirestoreService();

  String _searchPhone = '';
  String _selectedTab = 'all';

  DateTime? _fromDate;
  DateTime? _toDate;

  bool _matches(Client c) {
    final phoneMatch =
        _searchPhone.isEmpty || c.phone.contains(_searchPhone);

    final tabMatch =
        _selectedTab == 'all' || c.status == _selectedTab;

    final dateMatch =
        (_fromDate == null && _toDate == null) ||
        (_fromDate != null &&
            _toDate != null &&
            !c.nextCleaningDate.isBefore(_fromDate!) &&
            !c.nextCleaningDate.isAfter(_toDate!));

    return phoneMatch && tabMatch && dateMatch;
  }

  Color _statusColor(String s) {
    switch (s) {
      case 'notified':
        return Colors.orange.shade100;
      case 'confirmed':
        return Colors.green.shade100;
      case 'pending':
        return Colors.grey.shade300;
      default:
        return Colors.white;
    }
  }

  Future<void> _pickDate(bool isFrom) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2023),
      lastDate: DateTime(2030),
    );

    if (picked == null) return;

    setState(() {
      if (isFrom) {
        _fromDate = picked;
      } else {
        _toDate = picked;
      }
    });
  }

  Future<void> _sendWhatsApp(Client client) async {
    final formattedDate =
        DateFormat('dd MMM yyyy').format(client.nextCleaningDate);

    final message = '''
Hello ${client.name} 👋

📅 Next Cleaning: $formattedDate
🔁 Monthly Cleanings: ${client.monthlyCleanings}

Please confirm.
''';

    final url = Uri.parse(
      'https://wa.me/${client.phone.replaceAll('+', '')}?text=${Uri.encodeComponent(message)}',
    );

    await launchUrl(url, mode: LaunchMode.externalApplication);
    await _service.updateClientStatus(client.id, 'notified');
  }

  Widget _summaryCard(String title, int value, Color color, String tab) {
    return GestureDetector(
      onTap: () => setState(() => _selectedTab = tab),
      child: Card(
        color: color,
        child: Container(
          width: 100,
          padding: const EdgeInsets.all(10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('$value',
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(title, textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard')),
      body: SafeArea(
        child: Column(
          children: [

            /// 🔍 SEARCH
            Padding(
              padding: const EdgeInsets.all(12),
              child: TextField(
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  hintText: 'Search by phone',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                onChanged: (v) => setState(() => _searchPhone = v),
              ),
            ),

            /// 📅 DATE FILTER (NEW)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _pickDate(true),
                      child: Text(
                        _fromDate == null
                            ? 'From Date'
                            : DateFormat('dd MMM yyyy')
                                .format(_fromDate!),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _pickDate(false),
                      child: Text(
                        _toDate == null
                            ? 'To Date'
                            : DateFormat('dd MMM yyyy')
                                .format(_toDate!),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      setState(() {
                        _fromDate = null;
                        _toDate = null;
                      });
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            /// 📊 SUMMARY CARDS
            SizedBox(
              height: 90,
              child: StreamBuilder<List<Client>>(
                stream: _service.getClients(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(
                        child: CircularProgressIndicator());
                  }

                  final clients = snapshot.data!;
                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Row(
                      children: [
                        _summaryCard('Total', clients.length,
                            Colors.blue.shade100, 'all'),
                        _summaryCard(
                            'Pending',
                            clients
                                .where((c) => c.status == 'pending')
                                .length,
                            Colors.grey.shade300,
                            'pending'),
                        _summaryCard(
                            'Notified',
                            clients
                                .where((c) => c.status == 'notified')
                                .length,
                            Colors.orange.shade200,
                            'notified'),
                        _summaryCard(
                            'Confirmed',
                            clients
                                .where((c) => c.status == 'confirmed')
                                .length,
                            Colors.green.shade200,
                            'confirmed'),
                      ],
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 8),

            /// 📋 CLIENT LIST
            Expanded(
              child: StreamBuilder<List<Client>>(
                stream: _service.getClients(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(
                        child: CircularProgressIndicator());
                  }

                  final clients =
                      snapshot.data!.where(_matches).toList();

                  if (clients.isEmpty) {
                    return const Center(
                        child: Text('No clients found'));
                  }

                  return ListView.builder(
                    padding:
                        const EdgeInsets.only(bottom: 120),
                    itemCount: clients.length,
                    itemBuilder: (context, i) {
                      final c = clients[i];
                      return Card(
                        color: _statusColor(c.status),
                        child: ListTile(
                          title: Text(c.name),
                          subtitle: Text(
                            '${c.phone}\nNext: ${DateFormat('dd MMM yyyy').format(c.nextCleaningDate)}',
                          ),
                          isThreeLine: true,
                          trailing: IconButton(
                            icon: const Icon(Icons.message,
                                color: Colors.green),
                            onPressed: () => _sendWhatsApp(c),
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    ClientDetailScreen(client: c),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),

      /// ➕ ACTION BUTTONS
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton.extended(
            heroTag: 'addClient',
            icon: const Icon(Icons.person_add),
            label: const Text('Add Client'),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const AddClientScreen()),
              );
            },
          ),
          const SizedBox(height: 10),
          FloatingActionButton.extended(
            heroTag: 'teams',
            icon: const Icon(Icons.groups),
            label: const Text('Teams'),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const TeamListScreen()),
              );
            },
          ),
        ],
      ),
    );
  }
}
