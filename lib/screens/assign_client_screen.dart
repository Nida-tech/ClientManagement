import 'package:flutter/material.dart';


import '../models/client_model.dart';
import '../models/team_model.dart';
import '../services/firestore_service.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class AssignClientScreen extends StatefulWidget {
  final Team team;
  const AssignClientScreen({super.key, required this.team});

  @override
  State<AssignClientScreen> createState() => _AssignClientScreenState();
}

class _AssignClientScreenState extends State<AssignClientScreen> {
  final FirestoreService _service = FirestoreService();
  List<Client> _clients = [];
  List<String> _selectedClientIds = [];

  @override
  void initState() {
    super.initState();
    _loadClients();
    _selectedClientIds = List.from(widget.team.clientIds);
  }

  Future<void> _loadClients() async {
    final clients = await _service.getClients().first;
    setState(() => _clients = clients);
  }

  Future<void> _saveAssignment() async {
    if (_selectedClientIds.length > 5) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Max 5 clients can be assigned')));
      return;
    }

    final updatedTeam = Team(
      id: widget.team.id,
      name: widget.team.name,
      phone: widget.team.phone,
      members: widget.team.members,
      clientIds: _selectedClientIds,
    );

    await _service.updateTeam(updatedTeam);

    await _sendWhatsAppMessage(updatedTeam);

    if (!mounted) return;
    Navigator.pop(context);
  }

  Future<void> _sendWhatsAppMessage(Team team) async {
    final assignedClients =
        await _service.getClientsByIds(team.clientIds);

    final messageBuffer = StringBuffer();
    messageBuffer.writeln("Hello ${team.name} 👋\nAssigned Clients:\n");

    for (var client in assignedClients) {
      messageBuffer.writeln(
          "${client.name} - ${client.pinLocation} - ${DateFormat('dd MMM yyyy').format(client.nextCleaningDate)}");
    }

    final url = Uri.parse(
        'https://wa.me/${team.phone.replaceAll('+', '')}?text=${Uri.encodeComponent(messageBuffer.toString())}');

    await launchUrl(url, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Assign Clients to ${widget.team.name}')),
      body: ListView(
        children: _clients.map((client) {
          final isSelected = _selectedClientIds.contains(client.id);
          return CheckboxListTile(
            title: Text(client.name),
            subtitle: Text(DateFormat('dd MMM yyyy').format(client.nextCleaningDate)),
            value: isSelected,
            onChanged: (val) {
              setState(() {
                if (val == true) {
                  _selectedClientIds.add(client.id);
                } else {
                  _selectedClientIds.remove(client.id);
                }
              });
            },
          );
        }).toList(),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _saveAssignment,
        label: const Text('Assign & Notify'),
        icon: const Icon(Icons.send),
      ),
    );
  }


}
