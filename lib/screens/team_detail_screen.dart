import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/team_model.dart';
import '../models/client_model.dart';
import '../services/firestore_service.dart';

class TeamDetailScreen extends StatelessWidget {
  final Team team;

  TeamDetailScreen({super.key, required this.team});

  final FirestoreService _firestoreService = FirestoreService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(team.name),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// TEAM INFO
            Card(
              child: ListTile(
                title: Text(team.name),
                subtitle: Text(
                  'Members: ${team.members}\nWhatsApp: ${team.phone}',
                ),
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              'Assigned Clients',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            Expanded(
              child: StreamBuilder<List<Client>>(
                stream: _firestoreService.getClientsByTeam(team.id),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(
                        child: CircularProgressIndicator());
                  }

                  final clients = snapshot.data!;

                  if (clients.isEmpty) {
                    return const Center(
                        child: Text('No clients assigned'));
                  }

                  return ListView.builder(
                    itemCount: clients.length,
                    itemBuilder: (context, index) {
                      final client = clients[index];
                      return Card(
                        child: ListTile(
                          title: Text(client.name),
                          subtitle: Text(
                            '📅 ${DateFormat('dd MMM yyyy').format(client.nextCleaningDate)}\n📍 ${client.pinLocation ?? 'No location'}',
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),

            const SizedBox(height: 10),

            /// SEND WHATSAPP BUTTON
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.message),
                label: const Text('Send WhatsApp to Team'),
                onPressed: () async {
                  final clients =
                      await _firestoreService.getClientsByTeamOnce(team.id);
                  _sendTeamWhatsApp(team, clients);
                },
              ),
            )
          ],
        ),
      ),
    );
  }

  void _sendTeamWhatsApp(Team team, List<Client> clients) async {
    String message = '''
Hello ${team.name} 👋

Here are your assigned clients for today 🧹👇

''';

    for (int i = 0; i < clients.length; i++) {
      final c = clients[i];
      message += '''
${i + 1}. ${c.name}
📅 ${DateFormat('dd MMM').format(c.nextCleaningDate)}
📍 ${c.pinLocation ?? 'Not provided'}

''';
    }

    message += 'Please confirm once completed ✅';

    final url = Uri.parse(
      'https://wa.me/${team.phone.replaceAll('+', '')}?text=${Uri.encodeComponent(message)}',
    );

    await launchUrl(url, mode: LaunchMode.externalApplication);
  }
}
