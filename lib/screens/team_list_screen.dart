import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/team_model.dart';
import 'team_detail_screen.dart';


class TeamListScreen extends StatelessWidget {
const TeamListScreen({super.key});


@override
Widget build(BuildContext context) {
return Scaffold(
appBar: AppBar(title: const Text('Teams')),
body: StreamBuilder<QuerySnapshot>(
stream: FirebaseFirestore.instance.collection('teams').snapshots(),
builder: (context, snapshot) {
if (snapshot.connectionState == ConnectionState.waiting) {
return const Center(child: CircularProgressIndicator());
}


if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
return const Center(child: Text('No teams found'));
}


final teams = snapshot.data!.docs
.map((doc) => Team.fromDocument(doc))
.toList();


return ListView.builder(
itemCount: teams.length,
itemBuilder: (context, index) {
final team = teams[index];
return Card(
child: ListTile(
leading: const Icon(Icons.group),
title: Text(team.name),
subtitle: Text('Clients: ${team.clientIds.length}'),
trailing: const Icon(Icons.arrow_forward_ios),
onTap: () {
Navigator.push(
context,
MaterialPageRoute(
builder: (_) => TeamDetailScreen(team: team),
),
);
},
),
);
},
);
},
),
);
}
}