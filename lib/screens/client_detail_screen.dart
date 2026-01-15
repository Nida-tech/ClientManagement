import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart'; // Date formatting
import 'package:cloud_firestore/cloud_firestore.dart';

class ClientDetailScreen extends StatefulWidget {
  final Map<String, dynamic> clientData;

  const ClientDetailScreen({super.key, required this.clientData});

  @override
  ClientDetailScreenState createState() => ClientDetailScreenState();
}

class ClientDetailScreenState extends State<ClientDetailScreen> {
  late String name;
  late String phone;
  late Timestamp nextCleaningTimestamp;
  late int monthlyCleanings;
  String? pinLocation;

  @override
  void initState() {
    super.initState();
    final data = widget.clientData;
    name = data['name'] ?? '';
    phone = data['phone'] ?? '';
    nextCleaningTimestamp = data['nextCleaning'] ?? Timestamp.now();
    monthlyCleanings = data['monthlyCleanings'] ?? 1;
    pinLocation = data['pinLocation']; // optional
  }

  String get formattedNextCleaning {
    final date = nextCleaningTimestamp.toDate();
    return DateFormat('dd MMM yyyy').format(date);
  }

  Future<void> sendWhatsAppReminder() async {
    final whatsappNumber = phone.replaceAll('+', '');
    final message =
        "Hello $name 👋\n\nThis is a reminder for your cleaning service.\n📅 Next Cleaning Date: $formattedNextCleaning\n🧹 Monthly Cleanings: $monthlyCleanings times\n\nPlease reply YES to confirm or NO to reschedule.\n\nThank you 🙂";

    final url = Uri.parse("https://wa.me/$whatsappNumber?text=${Uri.encodeComponent(message)}");

    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {

      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Could not open WhatsApp for $phone")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(name),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              leading: Icon(Icons.phone, color: Colors.teal),
              title: Text(phone),
            ),
            ListTile(
              leading: Icon(Icons.calendar_today, color: Colors.teal),
              title: Text("Next Cleaning Date: $formattedNextCleaning"),
            ),
            ListTile(
              leading: Icon(Icons.repeat, color: Colors.teal),
              title: Text("Monthly Cleanings: $monthlyCleanings times"),
            ),
            if (pinLocation != null)
              ListTile(
                leading: Icon(Icons.pin_drop, color: Colors.teal),
                title: Text("Pin Location"),
                subtitle: Text(pinLocation!),
              ),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton.icon(
                onPressed: sendWhatsAppReminder,
                icon: Icon(Icons.message),
                label: Text("Send WhatsApp Reminder"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
