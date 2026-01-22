import 'package:cloud_firestore/cloud_firestore.dart';

class Client {
  final String id;
  final String name;
  final String phone;
  final DateTime nextCleaningDate;
  final int monthlyCleanings;
  final String? address;
  final String? pinLocation;
  final String? teamId;
  final String status; // NEW: pending, notified, confirmed
  final String? assignedTeamId; // 👈 NEW

  Client({
    required this.id,
    required this.name,
    required this.phone,
    required this.nextCleaningDate,
    required this.monthlyCleanings,
    this.address,
    this.pinLocation,
    this.teamId,
    required this.status,
    this.assignedTeamId,
  });


  


   
  // Factory constructor for Firestore document
  factory Client.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Client(
      id: doc.id,
      name: data['name'] ?? '',
      phone: data['phone'] ?? '',
      nextCleaningDate: (data['nextCleaningDate'] as Timestamp).toDate(),
      monthlyCleanings: data['monthlyCleanings'] ?? 1,
      status: data['status'] ?? 'pending',
      address: data['address'],
      pinLocation: data['pinLocation'],
      teamId: data['teamId'],
      assignedTeamId: data['assignedTeamId'],
    );
    
  }

  

  // 🔥 ADD THIS
  Client copyWith({
    String? name,
    String? phone,
    DateTime? nextCleaningDate,
    int? monthlyCleanings,
    String? status,
    String? assignedTeamId,
    String? pinLocation,
  }) {
    return Client(
      id: id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      nextCleaningDate: nextCleaningDate ?? this.nextCleaningDate,
      monthlyCleanings: monthlyCleanings ?? this.monthlyCleanings,
      status: status ?? this.status,
      assignedTeamId: assignedTeamId ?? this.assignedTeamId,
      pinLocation: pinLocation ?? this.pinLocation,
    );
  }



  // Convert Client object to map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'phone': phone,
      'nextCleaningDate': nextCleaningDate,
      'monthlyCleanings': monthlyCleanings,
      'address': address,
      'pinLocation': pinLocation,
      'teamId': teamId,
      'status': status,
    };
  }

  

  
}
