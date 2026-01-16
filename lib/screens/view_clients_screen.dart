import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
//import 'package:flutter_application_1/models/client_model.dart';
import 'client_detail_screen.dart';
//port 'dashboard_screen.dart';

class ViewClientsScreen extends StatefulWidget {
  const ViewClientsScreen({super.key}); 
  
  @override
  State<ViewClientsScreen> createState() => _ViewClientsScreenState();
}

class _ViewClientsScreenState extends State<ViewClientsScreen> {
  final CollectionReference clientsRef =
      FirebaseFirestore.instance.collection('clients');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Clients'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: clientsRef.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No clients found.'));
          }

          final clientsData = snapshot.data!.docs;

          return ListView.builder(
            itemCount: clientsData.length,
            itemBuilder: (context, index) {
              final clientDoc = clientsData[index];
              final client = clientDoc.data() as Map<String, dynamic>;
              final clientName = client['name'] ?? 'No Name';
              final phone = client['phone'] ?? 'No Phone';

              return ListTile(
                title: Text(clientName),
                subtitle: Text(phone),
                leading: const Icon(Icons.person),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  // Pass clientData as Map<String,dynamic> and clientId separately
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ClientDetailScreen(
                        clientData: clientDoc.data() as Map<String, dynamic>,
                        
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
