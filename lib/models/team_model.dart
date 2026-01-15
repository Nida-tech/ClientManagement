import 'package:cloud_firestore/cloud_firestore.dart';

class Team {
  final String id;
  final String name;
  final String phone;
  final List<String> members;
  
  final List<String> clientIds;

  Team({
    required this.id,
    required this.name,
    required this.phone,
    required this.clientIds,
    required this.members,
  });

  factory Team.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Team(
      id: doc.id,
      name: data['name'],
      phone: data['phone'],
      clientIds: List<String>.from(data['clientIds'] ?? []),
      members: List<String>.from(data['members'] ?? []),
    );
  }
}
