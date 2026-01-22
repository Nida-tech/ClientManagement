import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';
import '../models/client_model.dart';
import '../services/firestore_service.dart';
import 'add_client_screen.dart';
import 'edit_client_screen.dart';

class ClientDetailScreen extends StatefulWidget {
  final Client client;

  const ClientDetailScreen({super.key, required this.client});

  @override
  State<ClientDetailScreen> createState() => _ClientDetailScreenState();
}

class _ClientDetailScreenState extends State<ClientDetailScreen> {
  final FirestoreService _service = FirestoreService();

  late Client client;
  bool _isUpdating = false;

  @override
  void initState() {
    super.initState();
     client = widget.client;
     

  }

  String get formattedNextCleaning {
    return DateFormat('dd MMM yyyy').format(client.nextCleaningDate);
  }

  Color _getStatusColor() {
    switch (client.status) {
      case 'notified':
        return Colors.orange.shade100;
      case 'confirmed':
        return Colors.green.shade100;
      default:
        return Colors.white;
    }
  }

  // ================= WHATSAPP =================
  Future<void> sendWhatsAppReminder() async {
    final number = client.phone.replaceAll('+', '');
    final message =
        "Hello ${client.name} 👋\n\n"
        "This is a reminder for your cleaning service.\n"
        "📅 Next Cleaning Date: $formattedNextCleaning\n"
        "🧹 Monthly Cleanings: ${client.monthlyCleanings} times\n\n"
        "Please reply YES to confirm or NO to reschedule.\n\nThank you 🙂";

    final url =
        Uri.parse("https://wa.me/$number?text=${Uri.encodeComponent(message)}");

    await launchUrl(url, mode: LaunchMode.externalApplication);
    await _service.updateClientStatus(client.id, 'notified');

    if (mounted) {
      setState(() => client = client.copyWith(status: 'notified'));
    }
  }

  // ================= CONFIRM =================
  Future<void> _markAsConfirmed() async {
    setState(() => _isUpdating = true);

    await _service.updateClientStatus(client.id, 'confirmed');

    if (!mounted) return;
    setState(() {
      client = client.copyWith(status: 'confirmed');
      _isUpdating = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Client confirmed ✅')),
    );

    Navigator.pop(context);
  }

  // ================= DELETE =================
  Future<void> _deleteClient() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Client'),
        content: const Text('Are you sure?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel')),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Delete')),
        ],
      ),
    );

    if (confirm == true) {
      await _service.deleteClient(client.id);
      if (!mounted) return;
      Navigator.pop(context);
    }
  }

  // ================= EDIT =================
  void _editClient() {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => EditClientScreen(client: client),
    ),
  );
}


  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(client.name),
        actions: [
          IconButton(icon: const Icon(Icons.edit), onPressed: _editClient),
          IconButton(icon: const Icon(Icons.delete), onPressed: _deleteClient),
        ],
      ),
      body: Container(
        color: _getStatusColor(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Phone: ${client.phone}'),
            const SizedBox(height: 8),
            Text('Next Cleaning: $formattedNextCleaning'),
            const SizedBox(height: 8),
            Text('Monthly Cleanings: ${client.monthlyCleanings}'),
            const SizedBox(height: 8),
            Text('Status: ${client.status.toUpperCase()}'),

            const SizedBox(height: 25),

            ElevatedButton.icon(
              onPressed: sendWhatsAppReminder,
              icon: const Icon(Icons.message),
              label: const Text('Send WhatsApp Reminder'),
            ),

            const SizedBox(height: 15),

            if (client.status == 'notified')
              ElevatedButton(
                onPressed: _isUpdating ? null : _markAsConfirmed,
                child: _isUpdating
                    ? const CircularProgressIndicator()
                    : const Text('Mark as Confirmed'),
              ),
          ],
        ),
      ),
    );
  }
}
