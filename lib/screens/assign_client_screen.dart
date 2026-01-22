import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/team_model.dart';
import '../models/client_model.dart';
import '../services/firestore_service.dart';



class AssignClientsScreen extends StatefulWidget {
  final Team team;

  const AssignClientsScreen({
    super.key,
    required this.team,
  });

  @override
  State<AssignClientsScreen> createState() => _AssignClientsScreenState();
}

class _AssignClientsScreenState extends State<AssignClientsScreen> {
  final FirestoreService _service = FirestoreService();
  final List<String> selectedClientIds = [];

  // ✅ Send WhatsApp message to team
  Future<void> _sendTeamWhatsApp(List<Client> clients) async {
    String message =
        'Hello ${widget.team.name} Team 👋\n\nAssigned Clients:\n';

    for (var client in clients) {
      message += '- ${client.name} | PinLocation: ${client.pinLocation}\n';
    }

    final phone = widget.team.phone.replaceAll('+', '');
    final url = Uri.parse(
      'https://wa.me/$phone?text=${Uri.encodeComponent(message)}',
    );

    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  // ✅ Assign selected clients
  Future<void> _assignClients(List<Client> confirmedClients) async {
    if (selectedClientIds.isEmpty) return;

    await _service.assignClientsToTeam(
      widget.team.id,
      selectedClientIds,
    );

    final assignedClients = confirmedClients
        .where((c) => selectedClientIds.contains(c.id))
        .toList();

    if (!mounted) return;

    await _sendTeamWhatsApp(assignedClients);
    if (!mounted) return;
    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Clients Assigned Successfully ✅')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Assign Clients to ${widget.team.name}'),
      ),
      body: StreamBuilder<List<Client>>(
        stream: _service.getConfirmedClients(), // ✅ ONLY CONFIRMED
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final confirmedClients = snapshot.data!
              .where((c) => c.assignedTeamId == null) // ✅ not assigned
              .toList();

          if (confirmedClients.isEmpty) {
            return const Center(
              child: Text('No confirmed clients available'),
            );
          }

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: confirmedClients.length,
                  itemBuilder: (context, index) {
                    final client = confirmedClients[index];
                    final isSelected =
                        selectedClientIds.contains(client.id);

                    return CheckboxListTile(
                      value: isSelected,
                      title: Text(client.name),
                      subtitle: Text(client.phone),
                      onChanged: (val) {
                        setState(() {
                          if (val == true) {
                            selectedClientIds.add(client.id);
                          } else {
                            selectedClientIds.remove(client.id);
                          }
                        });
                      },
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: ElevatedButton(
                  onPressed: () => _assignClients(confirmedClients),
                  child: const Text('Assign Selected Clients'),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
