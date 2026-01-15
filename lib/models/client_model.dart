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

  Client({
    required this.id,
    required this.name,
    required this.phone,
    required this.nextCleaningDate,
    required this.monthlyCleanings,
    this.address,
    this.pinLocation,
    this.teamId
  });

  // Factory constructor for Firestore document
  factory Client.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Client(
      id: doc.id,
      name: data['name'] ?? '',
      phone: data['phone'] ?? '',
      nextCleaningDate: (data['nextCleaningDate'] as Timestamp).toDate(),
      monthlyCleanings: data['monthlyCleanings'] ?? 1,
      address: data['address'],
      pinLocation: data['pinLocation'],
      teamId: data['teamId'],
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
    };
  }
}
