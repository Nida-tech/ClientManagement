import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../models/client_model.dart';

class EditClientScreen extends StatefulWidget {
  final Client client;

  const EditClientScreen({super.key, required this.client});

  @override
  State<EditClientScreen> createState() => _EditClientScreenState();
}

class _EditClientScreenState extends State<EditClientScreen> {
  late TextEditingController nameController;
  late TextEditingController phoneController;
  late TextEditingController manualAddressController;
  late TextEditingController pinLocationController;

  DateTime? selectedDate;
  int monthlyTimes = 1;

  final _formKey = GlobalKey<FormState>();
  bool isLoading = false;

  @override
  void initState() {
    super.initState();

    // 👇 PRE-FILLED DATA
    nameController = TextEditingController(text: widget.client.name);
    phoneController = TextEditingController(text: widget.client.phone);
    manualAddressController =
        TextEditingController(text: widget.client.address ?? '');
    pinLocationController =
        TextEditingController(text: widget.client.pinLocation ?? '');

    selectedDate = widget.client.nextCleaningDate;
    monthlyTimes = widget.client.monthlyCleanings;
  }

  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(DateTime.now().year + 2),
    );

    if (picked != null) {
      setState(() => selectedDate = picked);
    }
  }

  Future<void> _updateClient() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    try {
      await FirebaseFirestore.instance
          .collection('clients')
          .doc(widget.client.id)
          .update({
        'name': nameController.text,
        'phone': phoneController.text,
        'manualAddress': manualAddressController.text,
        'pinLocation': pinLocationController.text,
        'nextCleaningDate': selectedDate != null
            ? Timestamp.fromDate(selectedDate!)
            : null,
        'monthlyTimes': monthlyTimes,
      });

      if (!mounted) return;
      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Client updated successfully ✅')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Client')),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    TextFormField(
                      controller: nameController,
                      decoration: const InputDecoration(labelText: 'Name'),
                      validator: (v) => v!.isEmpty ? 'Required' : null,
                    ),
                    TextFormField(
                      controller: phoneController,
                      decoration: const InputDecoration(labelText: 'Phone'),
                      validator: (v) => v!.isEmpty ? 'Required' : null,
                    ),
                    TextFormField(
                      controller: manualAddressController,
                      decoration:
                          const InputDecoration(labelText: 'Manual Address'),
                    ),
                    TextFormField(
                      controller: pinLocationController,
                      decoration:
                          const InputDecoration(labelText: 'Pin Location'),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Text(
                          selectedDate == null
                              ? 'Select date'
                              : DateFormat('dd MMM yyyy')
                                  .format(selectedDate!),
                        ),
                        const Spacer(),
                        TextButton(
                          onPressed: () => _selectDate(context),
                          child: const Text('Pick Date'),
                        )
                      ],
                    ),
                    const SizedBox(height: 16),
                    DropdownButton<int>(
                      value: monthlyTimes,
                      items: const [
                        DropdownMenuItem(value: 1, child: Text('1 time')),
                        DropdownMenuItem(value: 2, child: Text('2 times')),
                        DropdownMenuItem(value: 3, child: Text('3 times')),
                      ],
                      onChanged: (v) => setState(() => monthlyTimes = v!),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _updateClient,
                      child: const Text('Update Client'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
