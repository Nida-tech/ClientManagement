import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/client_model.dart';
import '../models/team_model.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
Stream<List<Team>> getTeams() {
  return _firestore.collection('teams').snapshots().map(
        (snapshot) =>
            snapshot.docs.map((doc) => Team.fromDocument(doc)).toList(),
      );
}

Stream<List<Client>> getUnassignedClients() {
  return _firestore
      .collection('clients')
      .where('teamId', isNull: true)
      .snapshots()
      .map(
        (snapshot) =>
            snapshot.docs.map((doc) => Client.fromDocument(doc)).toList(),
      );
}

Stream<List<Client>> getClientsByTeam(String teamId) {
  return _firestore
      .collection('clients')
      .where('teamId', isEqualTo: teamId)
      .snapshots()
      .map((s) =>
          s.docs.map((d) => Client.fromDocument(d)).toList());
}

Future<List<Client>> getClientsByTeamOnce(String teamId) async {
  final snap = await _firestore
      .collection('clients')
      .where('teamId', isEqualTo: teamId)
      .get();

  return snap.docs.map((d) => Client.fromDocument(d)).toList();
}

  // Get all clients
  Stream<List<Client>> getClients() {
    return _firestore
        .collection('clients')
        .orderBy('nextCleaningDate')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => Client.fromDocument(doc))
              .toList(),
        );
  }

  // Add client
  Future<void> addClient(Client client) async {
    await _firestore.collection('clients').add(client.toMap());
  }

  // Update client
  Future<void> updateClient(String id, Map<String, dynamic> data) async {
    await _firestore.collection('clients').doc(id).update(data);
  }

  // Delete client
  Future<void> deleteClient(String id) async {
    await _firestore.collection('clients').doc(id).delete();
  }

  Future<void> assignClientToTeam({
  required String clientId,
  required String teamId,
}) async {
  final teamRef = _firestore.collection('teams').doc(teamId);
  final clientRef = _firestore.collection('clients').doc(clientId);

  final teamSnap = await teamRef.get();
  final teamData = teamSnap.data() as Map<String, dynamic>;

  final List clients =
      List.from(teamData['clientIds'] ?? []);

  if (clients.length >= 5) {
    throw Exception('This team already has 5 clients');
  }

  await teamRef.update({
    'clientIds': FieldValue.arrayUnion([clientId]),
  });

  await clientRef.update({
    'teamId': teamId,
  });
}



}
