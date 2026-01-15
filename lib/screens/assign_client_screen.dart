import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/client_model.dart';
import '../models/team_model.dart';
import '../services/firestore_service.dart';


class AssignClientScreen extends StatefulWidget {
  const AssignClientScreen({super.key});

  @override
  State<AssignClientScreen> createState() => _AssignClientScreenState();
}

class _AssignClientScreenState extends State<AssignClientScreen> {
  final FirestoreService _firestoreService = FirestoreService();

  Team? selectedTeam;
  final List<Client> selectedClients = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Assign Clients to Team'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// TEAM DROPDOWN
            const Text(
              'Select Team',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            StreamBuilder<List<Team>>(
              stream: _firestoreService.getTeams(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const CircularProgressIndicator();
                }

                final teams = snapshot.data!;

                return DropdownButtonFormField<Team>(
                  initialValue: selectedTeam,
                  hint: const Text('Choose a team'),
                  items: teams.map((team) {
                    return DropdownMenuItem(
                      value: team,
                      child: Text('${team.name} (${team.members} members)'),
                    );
                  }).toList(),
                  onChanged: (team) {
                    setState(() {
                      selectedTeam = team;
                      selectedClients.clear();
                    });
                  },
                );
              },
            ),

            const SizedBox(height: 20),

            /// CLIENT LIST
            const Text(
              'Select Clients (Max 5)',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            Expanded(
              child: StreamBuilder<List<Client>>(
                stream: _firestoreService.getUnassignedClients(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final clients = snapshot.data!;

                  if (clients.isEmpty) {
                    return const Center(
                      child: Text('No unassigned clients'),
                    );
                  }

                  return ListView.builder(
                    itemCount: clients.length,
                    itemBuilder: (context, index) {
                      final client = clients[index];
                      final isSelected =
                          selectedClients.any((c) => c.id == client.id);

                      return Card(
                        child: CheckboxListTile(
                          value: isSelected,
                          title: Text(client.name),
                          subtitle: Text(client.phone),
                          onChanged: (value) {
                            if (value == true) {
                              if (selectedClients.length == 5) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Maximum 5 clients allowed per team',
                                    ),
                                  ),
                                );
                                return;
                              }
                              setState(() {
                                selectedClients.add(client);
                              });
                            } else {
                              setState(() {
                                selectedClients
                                    .removeWhere((c) => c.id == client.id);
                              });
                            }
                          },
                        ),
                      );
                    },
                  );
                },
              ),
            ),

            const SizedBox(height: 10),

            /// ASSIGN BUTTON
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: selectedTeam == null || selectedClients.isEmpty
                    ? null
                    : _assignClients,
                child: const Text('Assign Clients'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _assignClients() async {
    if (selectedTeam == null) return;

    try {
      for (final client in selectedClients) {
        await FirebaseFirestore.instance
            .collection('clients')
            .doc(client.id)
            .update({
          'teamId': selectedTeam!.id,
        });
      }
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Clients assigned successfully')),
      );

      setState(() {
        selectedClients.clear();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }
}
