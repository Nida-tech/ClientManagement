import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/client_model.dart';
import '../models/team_model.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// ================= CLIENTS =================
  Stream<List<Client>> getClients() {
    return _firestore
        .collection('clients')
        .orderBy('nextCleaningDate')
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Client.fromFirestore(doc)).toList());
  }

  

  Stream<List<Client>> getConfirmedClients() {
  return _firestore
      .collection('clients')
      .where('status', isEqualTo: 'confirmed')
      .snapshots()
      .map((snapshot) =>
          snapshot.docs.map((doc) => Client.fromFirestore(doc)).toList());
}
Stream<List<Client>> getTeamClients(String teamId) {
  return FirebaseFirestore.instance
      .collection('clients')
      .where('teamId', isEqualTo: teamId)
      .snapshots()
      .map(
        (snapshot) =>
            snapshot.docs.map((doc) => Client.fromFirestore(doc)).toList(),
      );
}

  Future<void> addClient(Client client) async {
    await _firestore.collection('clients').add(client.toMap());
  }

  Future<void> updateClient(Client client) async {
    await _firestore
        .collection('clients')
        .doc(client.id)
        .update(client.toMap());
  }

  Future<void> deleteClient(String clientId) async {
    await _firestore.collection('clients').doc(clientId).delete();
  }

  Future<Client> getClientById(String clientId) async {
    final doc = await _firestore.collection('clients').doc(clientId).get();
    return Client.fromFirestore(doc);
  }

  Future<void> assignClientToTeam(String clientId, String teamId) async {
  await _firestore.collection('clients').doc(clientId).update({
    'assignedTeamId': teamId,
  });
}

Stream<List<Client>> getAssignedClients(String teamId) {
  return FirebaseFirestore.instance
      .collection('clients')
      .where('assignedTeamId', isEqualTo: teamId)
      .snapshots()
      .map(
        (snapshot) =>
            snapshot.docs.map((d) => Client.fromFirestore(d)).toList(),
      );
}



 // job completed function and reschedule funtion
Future<void> markJobCompleted(Client client) async {
  int days = 30;
  if (client.monthlyCleanings == 2) days = 15;
  if (client.monthlyCleanings == 3) days = 10;

  final nextDate =
      client.nextCleaningDate.add(Duration(days: days));

  await FirebaseFirestore.instance
      .collection('clients')
      .doc(client.id)
      .update({
    'nextCleaningDate': Timestamp.fromDate(nextDate),
    'assignedTeamId': null, // 🔥 auto remove
    'status': 'pending',
  });
}

// ======= remove assigned client from team =======
Future<void> removeClientFromTeam(
  String teamId,
  String clientId,
) async {
  final firestore = FirebaseFirestore.instance;

  /// 1️⃣ TEAM document se clientId remove
  await firestore.collection('teams').doc(teamId).update({
    'clientIds': FieldValue.arrayRemove([clientId]),
  });

  /// 2️⃣ CLIENT document se assigned team remove
  await firestore.collection('clients').doc(clientId).update({
    'assignedTeamId': null,
    'status': 'pending', // optional but recommended
  });
}


  /// ================= TEAMS =================
  Stream<List<Team>> getTeams() {
    return _firestore.collection('teams').snapshots().map(
        (snapshot) => snapshot.docs.map((doc) => Team.fromDocument(doc)).toList());
  }

 Future<void> assignClientsToTeam(
  String teamId,
  List<String> clientIds,
) async {
  final batch = FirebaseFirestore.instance.batch();

  for (final id in clientIds) {
    final ref =
        FirebaseFirestore.instance.collection('clients').doc(id);
    batch.update(ref, {
      'assignedTeamId': teamId,
      'status': 'assigned',
    });
  }

  await batch.commit();
}


  Future<void> addTeam(Team team) async {
    await _firestore.collection('teams').add({
      'name': team.name,
      'phone': team.phone,
      'members': team.members,
      'clientIds': team.clientIds,
    });
  }

  Future<void> updateTeam(Team team) async {
    await _firestore.collection('teams').doc(team.id).update({
      'name': team.name,
      'phone': team.phone,
      'members': team.members,
      'clientIds': team.clientIds,
    });
  }

  Future<void> updateClientStatus(String clientId, String status) async {
    await _firestore.collection('clients').doc(clientId).update({
      'status': status,
    });
  }

  Future<void> deleteTeam(String teamId) async {
    await _firestore.collection('teams').doc(teamId).delete();
  }

  Future<Team> getTeamById(String teamId) async {
    final doc = await _firestore.collection('teams').doc(teamId).get();
    return Team.fromDocument(doc);
  }

  /// ================= HELPER =================
  Future<List<Client>> getClientsByIds(List<String> clientIds) async {
    if (clientIds.isEmpty) return [];

    final query = await _firestore
        .collection('clients')
        .where(FieldPath.documentId, whereIn: clientIds)
        .get();

    return query.docs.map((doc) => Client.fromFirestore(doc)).toList();
  }
}
