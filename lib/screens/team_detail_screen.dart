import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/team_model.dart';
import '../models/client_model.dart';
import '../services/firestore_service.dart';
import 'assign_client_screen.dart';

class TeamDetailScreen extends StatelessWidget {
  final Team team;
  final FirestoreService _service = FirestoreService();

  TeamDetailScreen({
    super.key,
    required this.team,
  });

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

            /// 👥 TEAM INFO
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Team Members',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      team.members.isEmpty
                          ? 'No members added'
                          : team.members.join(', '),
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            /// 📋 ASSIGNED CLIENTS TITLE
            const Text(
              'Assigned Clients',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            /// 🔥 ASSIGNED CLIENTS LIST (LIVE)
            Expanded(
              child: StreamBuilder<List<Client>>(
                stream: _service.getAssignedClients(team.id),
                builder: (context, snapshot) {
                  if (snapshot.connectionState ==
                      ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  if (!snapshot.hasData ||
                      snapshot.data!.isEmpty) {
                    return const Center(
                      child: Text(
                        'No clients assigned to this team',
                        style: TextStyle(color: Colors.grey),
                      ),
                    );
                  }

                  final clients = snapshot.data!;

                  return ListView.builder(
                    itemCount: clients.length,
                    itemBuilder: (context, index) {
                      final client = clients[index];

                      return Card(
                        elevation: 3,
                        margin:
                            const EdgeInsets.symmetric(vertical: 6),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [

                              /// CLIENT NAME
                              Text(
                                client.name,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),

                              const SizedBox(height: 4),

                              /// NEXT CLEANING DATE
                              Text(
                                'Next Cleaning: ${DateFormat('dd MMM yyyy').format(client.nextCleaningDate)}',
                                style: const TextStyle(
                                  color: Colors.grey,
                                ),
                              ),

                              const SizedBox(height: 12),

                              /// ✅ JOB COMPLETED BUTTON
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton.icon(
                                  icon: const Icon(Icons.check_circle),
                                  label:
                                      const Text('Job Completed'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green,
                                    padding:
                                        const EdgeInsets.symmetric(
                                      vertical: 12,
                                    ),
                                  ),
                                  onPressed: () async {
                                    /// 🔒 CONFIRMATION
                                    final ok =
                                        await showDialog<bool>(
                                      context: context,
                                      builder: (_) => AlertDialog(
                                        title: const Text(
                                          'Confirm Job Completion',
                                        ),
                                        content: const Text(
                                          'Are you sure this job is completed?\nClient will be rescheduled.',
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.pop(
                                                    context, false),
                                            child:
                                                const Text('Cancel'),
                                          ),
                                          ElevatedButton(
                                            onPressed: () =>
                                                Navigator.pop(
                                                    context, true),
                                            child:
                                                const Text('Yes'),
                                          ),
                                        ],
                                      ),
                                    );

                                    if (ok != true) return;

                                    await _service
                                        .markJobCompleted(client);

                                    if (!context.mounted) return;

                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Job completed & client rescheduled',
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
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

      /// ➕ ASSIGN CLIENT BUTTON
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add),
        label: const Text('Assign Client'),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  AssignClientsScreen(team: team),
            ),
          );
        },
      ),
    );
  }
}
