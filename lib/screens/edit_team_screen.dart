import 'package:flutter/material.dart';
import '../models/team_model.dart';
import '../services/firestore_service.dart';

class EditTeamScreen extends StatefulWidget {
  final Team team;

  const EditTeamScreen({super.key, required this.team});

  @override
  State<EditTeamScreen> createState() => _EditTeamScreenState();
}

class _EditTeamScreenState extends State<EditTeamScreen> {
  final _formKey = GlobalKey<FormState>();
  final FirestoreService _service = FirestoreService();

  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late List<String> _members;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.team.name);
    _phoneController = TextEditingController(text: widget.team.phone);
    _members = List<String>.from(widget.team.members);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  /// ✅ Save Updated Team
  Future<void> _saveTeam() async {
    if (!_formKey.currentState!.validate()) return;

    final updatedTeam = Team(
      id: widget.team.id,
      name: _nameController.text.trim(),
      phone: _phoneController.text.trim(),
      members: _members,
      clientIds: widget.team.clientIds,
    );

    try {
      await _service.updateTeam(updatedTeam);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Team updated successfully ✅')),
      );

      Navigator.pop(context); // back to team list
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating team: $e')),
      );
    }
  }

  /// ✅ Add new member
  void _addMember() {
    setState(() {
      _members.add('');
    });
  }

  /// ✅ Remove member
  void _removeMember(int index) {
    setState(() {
      _members.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Team'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              /// TEAM NAME
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Team Name',
                  icon: Icon(Icons.group),
                ),
                validator: (value) =>
                    value!.isEmpty ? 'Enter team name' : null,
              ),

              const SizedBox(height: 16),

              /// TEAM PHONE
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: 'Team Phone',
                  icon: Icon(Icons.phone),
                ),
                keyboardType: TextInputType.phone,
                validator: (value) =>
                    value!.isEmpty ? 'Enter phone number' : null,
              ),

              const SizedBox(height: 16),

              /// TEAM MEMBERS
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Team Members',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add, color: Colors.green),
                    onPressed: _addMember,
                  ),
                ],
              ),

              const SizedBox(height: 8),

              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _members.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            initialValue: _members[index],
                            decoration: InputDecoration(
                              hintText: 'Member Name',
                              border: const OutlineInputBorder(),
                            ),
                            onChanged: (val) => _members[index] = val,
                            validator: (val) =>
                                val!.isEmpty ? 'Enter member name' : null,
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(Icons.remove_circle,
                              color: Colors.red),
                          onPressed: () => _removeMember(index),
                        ),
                      ],
                    ),
                  );
                },
              ),

              const SizedBox(height: 32),

              /// SAVE BUTTON
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.save),
                  label: const Text('Save Changes'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: _saveTeam,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
