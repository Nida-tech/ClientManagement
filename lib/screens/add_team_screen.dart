import 'package:flutter/material.dart';
import '../models/team_model.dart';
import '../services/firestore_service.dart';

class AddTeamScreen extends StatefulWidget {
  const AddTeamScreen({super.key});

  @override
  State<AddTeamScreen> createState() => _AddTeamScreenState();
}

class _AddTeamScreenState extends State<AddTeamScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _membersController = TextEditingController();

  final FirestoreService _service = FirestoreService();

  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Team')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Team Name'),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Enter team name' : null,
              ),
             
             
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(labelText: 'Team WhatsApp Number'),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Enter phone number' : null,
              ),
              
              
              TextFormField(
                controller: _membersController,
                decoration: const InputDecoration(
                    labelText: 'Members (comma separated)'),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Enter members' : null,
              ),
              const SizedBox(height: 20),
              _loading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _saveTeam,
                      child: const Text('Save Team'),
                    ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _saveTeam() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    final team = Team(
      id: '',
      name: _nameController.text.trim(),
      phone: _phoneController.text.trim(),
      members: _membersController.text.split(',').map((e) => e.trim()).toList(),
      clientIds: [],
    );

    await _service.addTeam(team);

    if (!mounted) return;
    Navigator.pop(context);
  }
}
