import 'package:flutter/material.dart';


import '../models/team_model.dart';

import '../services/firestore_service.dart';
import '../models/client_model.dart';
import 'assign_client_screen.dart';
import 'package:intl/intl.dart';

class TeamDetailScreen extends StatelessWidget {
  final Team team;
  final FirestoreService _service = FirestoreService();

  
  
  TeamDetailScreen({super.key, required this.team});



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(team.name)),
      body: FutureBuilder<List<Client>>(
        future: _service.getClientsByIds(team.clientIds),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final clients = snapshot.data ?? [];

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text("Team Members: ${team.members.join(', ')}",
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              ...clients.map((c) => ListTile(
                    title: Text(c.name),
                    subtitle: Text(
                        "Next Cleaning: ${DateFormat('dd MMM yyyy').format(c.nextCleaningDate)}"),
                  )),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => AssignClientScreen(team: team)));
        },
        icon: const Icon(Icons.edit),
        label: const Text('Assign Clients'),
      ),
    );
  }


}
