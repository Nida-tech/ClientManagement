import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/client_model.dart';
import '../services/firestore_service.dart';
import '../screens/client_detail_screen.dart';
import '../screens/add_client_screen.dart';
import '../screens/view_team_screen.dart';

enum DashboardFilter {
  all,
  upcoming,
  pending,
  thisMonth,
}

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final FirestoreService _firestoreService = FirestoreService();

  DashboardFilter selectedFilter = DashboardFilter.upcoming;

  bool _isUpcoming(DateTime date) {
    final now = DateTime.now();
    return date.isAfter(now) &&
        date.isBefore(now.add(const Duration(days: 7)));
  }

  bool _isPending(DateTime date) {
    return date.isBefore(DateTime.now());
  }

  bool _isThisMonth(DateTime date) {
    final now = DateTime.now();
    return date.month == now.month && date.year == now.year;
  }

  List<Client> _applyFilter(List<Client> clients) {
    switch (selectedFilter) {
      case DashboardFilter.all:
        return clients;
      case DashboardFilter.upcoming:
        return clients.where((c) => _isUpcoming(c.nextCleaningDate)).toList();
      case DashboardFilter.pending:
        return clients.where((c) => _isPending(c.nextCleaningDate)).toList();
      case DashboardFilter.thisMonth:
        return clients.where((c) => _isThisMonth(c.nextCleaningDate)).toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.groups),
            tooltip: 'Teams',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ViewTeamsScreen()),
              );
            },
          )
        ],
      ),

      body: StreamBuilder<List<Client>>(
        stream: _firestoreService.getClients(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No clients found'));
          }

          final clients = snapshot.data!;

          final upcoming =
              clients.where((c) => _isUpcoming(c.nextCleaningDate)).length;
          final pending =
              clients.where((c) => _isPending(c.nextCleaningDate)).length;
          final thisMonth =
              clients.where((c) => _isThisMonth(c.nextCleaningDate)).length;

          final filteredClients = _applyFilter(clients);

          return Column(
            children: [
              /// DASHBOARD CARDS
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      children: [
                        _statCard(
                          title: 'Total Clients',
                          value: clients.length.toString(),
                          onTap: () =>
                              setState(() => selectedFilter = DashboardFilter.all),
                        ),
                        _statCard(
                          title: 'This Month',
                          value: thisMonth.toString(),
                          onTap: () => setState(
                              () => selectedFilter = DashboardFilter.thisMonth),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        _statCard(
                          title: 'Upcoming',
                          value: upcoming.toString(),
                          onTap: () => setState(
                              () => selectedFilter = DashboardFilter.upcoming),
                        ),
                        _statCard(
                          title: 'Pending',
                          value: pending.toString(),
                          onTap: () => setState(
                              () => selectedFilter = DashboardFilter.pending),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              /// FILTER TITLE
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    _filterTitle(),
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
              ),

              const SizedBox(height: 10),

              /// CLIENT LIST
              Expanded(
                child: ListView.builder(
                  itemCount: filteredClients.length,
                  itemBuilder: (context, index) {
                    final client = filteredClients[index];
                    return Card(
                      margin:
                          const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      child: ListTile(
                        leading: const Icon(Icons.person),
                        title: Text(client.name),
                        subtitle: Text(
                          DateFormat('dd MMM yyyy')
                              .format(client.nextCleaningDate),
                        ),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  ClientDetailScreen(clientData: {
    'name': client.name,
    'phone': client.phone,
    'nextCleaningDate': client.nextCleaningDate,
     },
)

                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddClientScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  String _filterTitle() {
    switch (selectedFilter) {
      case DashboardFilter.all:
        return 'All Clients';
      case DashboardFilter.upcoming:
        return 'Upcoming Clients';
      case DashboardFilter.pending:
        return 'Pending Clients';
      case DashboardFilter.thisMonth:
        return 'This Month Clients';
    }
  }

  Widget _statCard({
    required String title,
    required String value,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Card(
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Column(
              children: [
                Text(
                  value,
                  style:
                      const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 5),
                Text(title),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
