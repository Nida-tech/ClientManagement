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
            snapshot.docs.map((doc) => Client.fromDocument(doc)).toList());
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
    return Client.fromDocument(doc);
  }

  /// ================= TEAMS =================
  Stream<List<Team>> getTeams() {
    return _firestore.collection('teams').snapshots().map(
        (snapshot) => snapshot.docs.map((doc) => Team.fromDocument(doc)).toList());
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

    return query.docs.map((doc) => Client.fromDocument(doc)).toList();
  }
}
