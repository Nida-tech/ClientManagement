import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class AddClientScreen extends StatefulWidget {
  const AddClientScreen({super.key});

  @override
  State<AddClientScreen> createState() => _AddClientScreenState();
}

class _AddClientScreenState extends State<AddClientScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController manualAddressController = TextEditingController();
  final TextEditingController pinLocationController = TextEditingController(); // optional

  DateTime? selectedDate;
  int monthlyTimes = 1;

  final _formKey = GlobalKey<FormState>();
  bool isLoading = false;

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(DateTime.now().year + 2),
    );
    if (picked != null) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  Future<void> _saveClient() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      isLoading = true;
    });

    try {
      await FirebaseFirestore.instance.collection('clients').add({
        'name': nameController.text,
        'phone': phoneController.text,
        'manualAddress': manualAddressController.text,
        'pinLocation': pinLocationController.text, // optional
        'nextCleaningDate': selectedDate != null
            ? Timestamp.fromDate(selectedDate!)
            : null,
        'monthlyTimes': monthlyTimes,
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Client added successfully!')),
      );

      // Clear fields
      nameController.clear();
      phoneController.clear();
      manualAddressController.clear();
      pinLocationController.clear();
      setState(() {
        selectedDate = null;
        monthlyTimes = 1;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Client')),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    TextFormField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: 'Name',
                        icon: Icon(Icons.person),
                      ),
                      validator: (value) =>
                          value!.isEmpty ? 'Enter client name' : null,
                    ),
                    TextFormField(
                      controller: phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        labelText: 'Phone',
                        icon: Icon(Icons.phone),
                      ),
                      validator: (value) =>
                          value!.isEmpty ? 'Enter phone number' : null,
                    ),
                    TextFormField(
                      controller: manualAddressController,
                      decoration: const InputDecoration(
                        labelText: 'Manual Address',
                        icon: Icon(Icons.home),
                      ),
                      validator: (value) =>
                          value!.isEmpty ? 'Enter address' : null,
                    ),
                    TextFormField(
                      controller: pinLocationController,
                      decoration: const InputDecoration(
                        labelText: 'Pin Location (Optional)',
                        hintText: 'Google Maps / WhatsApp link',
                        icon: Icon(Icons.location_pin),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        const Icon(Icons.date_range),
                        const SizedBox(width: 16),
                        Text(selectedDate == null
                            ? 'Select Next Cleaning Date'
                            : DateFormat('dd MMM yyyy').format(selectedDate!)),
                        const SizedBox(width: 16),
                        ElevatedButton(
                          onPressed: () => _selectDate(context),
                          child: const Text('Pick Date'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        const Icon(Icons.repeat),
                        const SizedBox(width: 16),
                        const Text('Monthly Cleanings:'),
                        const SizedBox(width: 16),
                        DropdownButton<int>(
                          value: monthlyTimes,
                          items: const [
                            DropdownMenuItem(value: 1, child: Text('1 time')),
                            DropdownMenuItem(value: 2, child: Text('2 times')),
                            DropdownMenuItem(value: 3, child: Text('3 times')),
                          ],
                          onChanged: (value) {
                            if (value != null) {
                              setState(() {
                                monthlyTimes = value;
                              });
                            }
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.save),
                      label: const Text('Add Client'),
                      onPressed: _saveClient,
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
