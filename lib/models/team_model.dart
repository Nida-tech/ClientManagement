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
required this.members,
required this.clientIds,
});

factory Team.fromDocument(DocumentSnapshot doc) {
final data = doc.data() as Map<String, dynamic>;
return Team(
id: doc.id,
name: data['name'] ?? '',
phone: data['phone'] ?? '',
members: List<String>.from(data['members'] ?? []),
clientIds: List<String>.from(data['clientIds'] ?? []),
);
}
Map<String, dynamic> toMap() {
    return {
      'name': name,
      'phone': phone,
      'members': members,
      'clientIds': clientIds,
    };
}}

