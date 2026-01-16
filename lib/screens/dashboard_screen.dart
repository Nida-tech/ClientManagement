import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/client_model.dart';
import '../models/team_model.dart';
import '../services/firestore_service.dart';
import 'add_client_screen.dart';
import 'view_clients_screen.dart';
import 'team_detail_screen.dart';
import 'add_team_screen.dart';
import 'package:url_launcher/url_launcher.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final FirestoreService _service = FirestoreService();

  int _selectedTab = 0; // 0: Total, 1: This Month, 2: Upcoming, 3: Pending

  bool _isUpcoming(DateTime date) {
    final now = DateTime.now();
    return date.isAfter(now) && date.isBefore(now.add(const Duration(days: 7)));
  }

  bool _isPending(DateTime date) {
    return date.isBefore(DateTime.now());
  }

  Future<void> sendWhatsAppReminder({
    required String phone,
    required String name,
    required DateTime nextDate,
    required int monthlyTimes,
  }) async {
    final formattedDate = DateFormat('dd MMM yyyy').format(nextDate);

    final message = '''
Hello $name 👋

This is a reminder for your cleaning service 🧹

📅 Next Cleaning Date: $formattedDate
🔁 Monthly Cleanings: $monthlyTimes times

Please reply YES to confirm or NO to reschedule.

Thank you 😊
''';

    final url = Uri.parse(
      'https://wa.me/${phone.replaceAll('+', '')}?text=${Uri.encodeComponent(message)}',
    );

    await launchUrl(
      url,
      mode: LaunchMode.externalApplication,
    );
  }

  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      
      appBar: AppBar(title: const Text('Dashboard'), centerTitle: true),
      body: StreamBuilder<List<Client>>(
        stream: _service.getClients(),
        
        builder: (context, clientSnapshot) {
          if (clientSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final clients = clientSnapshot.data ?? [];
          

          // Client Filtering
          final upcomingClients = clients.where((c) => _isUpcoming(c.nextCleaningDate)).toList();
          final pendingClients = clients.where((c) => _isPending(c.nextCleaningDate)).toList();
          final thisMonthClients = clients.where((c) {
            final now = DateTime.now();
            return c.nextCleaningDate.month == now.month && c.nextCleaningDate.year == now.year;
          }).toList();

          List<Client> displayedClients;
          switch (_selectedTab) {
            case 1:
              displayedClients = thisMonthClients;
              break;
            case 2:
              displayedClients = upcomingClients;
              break;
            case 3:
              displayedClients = pendingClients;
              break;
            default:
              displayedClients = clients;
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // CLIENT SUMMARY CARDS
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _statCard('Total Clients', clients.length.toString(), 0),
                    _statCard('This Month', thisMonthClients.length.toString(), 1),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _statCard('Upcoming', upcomingClients.length.toString(), 2),
                    _statCard('Pending', pendingClients.length.toString(), 3),
                  ],
                ),
                const SizedBox(height: 25),
                
                // TEAMS SUMMARY
                StreamBuilder<List<Team>>(
                  stream: _service.getTeams(),
                  builder: (context, teamSnapshot) {
                    final teams = teamSnapshot.data ?? [];
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Teams', style: Theme.of(context).textTheme.titleLarge),
                        const SizedBox(height: 10),
                        ...teams.map((team) => Card(
                          child: ListTile(
                            title: Text(team.name),
                            subtitle: Text('Members: ${team.members.join(', ')}'),
                            trailing: IconButton(
                              icon: const Icon(Icons.arrow_forward),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => TeamDetailScreen(team: team)),
                                );
                              },
                            ),
                          ),
                        )),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 20),

                // DISPLAY CLIENTS
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Clients',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                const SizedBox(height: 10),
                ...displayedClients.map((client) => Card(
                  child: ListTile(
                    title: Text(client.name),
                    subtitle: Text(DateFormat('dd MMM yyyy').format(client.nextCleaningDate)),
                    trailing: IconButton(
                      icon: const Icon(Icons.message, color: Colors.green),
                      onPressed: () => sendWhatsAppReminder(
                        phone: client.phone,
                        name: client.name,
                        nextDate: client.nextCleaningDate,
                        monthlyTimes: client.monthlyCleanings,
                      ),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => ViewClientsScreen()),
                      );
                    },
                  ),
                )),
              ],
            ),
          );
        },
      ),

      // FLOATING BUTTONS
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        
        children: [
          FloatingActionButton.extended(
            heroTag: 'addClient',
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddClientScreen())),
            icon: const Icon(Icons.add),
            label: const Text('Add Client'),
          ),
          const SizedBox(height: 10),
          
          FloatingActionButton.extended(
            heroTag: 'viewClient',
            
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) =>  ViewClientsScreen())),
            icon: const Icon(Icons.list),
            label: const Text('View Clients'),
          ),
          const SizedBox(height: 10),
          FloatingActionButton.extended(
            heroTag: 'addTeam',
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddTeamScreen())),
            icon: const Icon(Icons.group_add),
            label: const Text('Add Team'),
          ),
        ],
      ),
    );
  }

  Widget _statCard(String title, String value, int tabIndex) {
    final isSelected = _selectedTab == tabIndex;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedTab = tabIndex),
        child: Card(
          color: isSelected ? Colors.blue[100] : null,
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Column(
              children: [
                Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
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
