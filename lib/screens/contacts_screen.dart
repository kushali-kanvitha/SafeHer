
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class ContactsScreen extends StatefulWidget {
  const ContactsScreen({super.key});

  @override
  State<ContactsScreen> createState() => _ContactsScreenState();
}

class _ContactsScreenState extends State<ContactsScreen> {
  List<Map<String, String>> contacts = [];

  @override
  void initState() {
    super.initState();
    loadContacts();
  }

  // Load saved contacts
  Future<void> loadContacts() async {
    final prefs = await SharedPreferences.getInstance();
    final savedContacts = prefs.getString('emergency_contacts');

    if (savedContacts != null) {
      final List decoded = jsonDecode(savedContacts);

      setState(() {
        contacts = decoded.map((item) {
          return Map<String, String>.from(item);
        }).toList();
      });
    }
  }

  // Save contacts locally
  Future<void> saveContacts() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(
      'emergency_contacts',
      jsonEncode(contacts),
    );
  }

  // Add or edit a contact
  void showContactDialog({int? index}) {
    final nameController = TextEditingController(
      text: index != null ? contacts[index]['name'] : '',
    );

    final phoneController = TextEditingController(
      text: index != null ? contacts[index]['phone'] : '',
    );

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            index == null ? 'Add Emergency Contact' : 'Edit Contact',
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Contact Name',
                  prefixIcon: Icon(Icons.person),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Phone Number',
                  prefixIcon: Icon(Icons.phone),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final name = nameController.text.trim();
                final phone = phoneController.text.trim();

                if (name.isEmpty || phone.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please enter both name and phone number'),
                    ),
                  );
                  return;
                }

                setState(() {
                  final contact = {
                    'name': name,
                    'phone': phone,
                  };

                  if (index == null) {
                    contacts.add(contact);
                  } else {
                    contacts[index] = contact;
                  }
                });

                await saveContacts();

                if (!context.mounted) return;
                Navigator.pop(context);

                nameController.dispose();
                phoneController.dispose();
              },
              child: Text(index == null ? 'Add' : 'Save'),
            ),
          ],
        );
      },
    ).then((_) {
      nameController.dispose();
      phoneController.dispose();
    });
  }

  // Delete a contact
  Future<void> deleteContact(int index) async {
    setState(() {
      contacts.removeAt(index);
    });

    await saveContacts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F5FC),
      appBar: AppBar(
        title: const Text(
          'Emergency Contacts',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFFF8F5FC),
      ),
      body: contacts.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.people_outline,
                    size: 75,
                    color: Color(0xFF8B5CF6),
                  ),
                  SizedBox(height: 15),
                  Text(
                    'No emergency contacts yet',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text('Add someone you trust for emergencies.'),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: contacts.length,
              itemBuilder: (context, index) {
                final contact = contacts[index];

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: Color(0xFFEDE4FF),
                      child: Icon(
                        Icons.person,
                        color: Color(0xFF8B5CF6),
                      ),
                    ),
                    title: Text(contact['name'] ?? ''),
                    subtitle: Text(contact['phone'] ?? ''),
                    trailing: PopupMenuButton<String>(
                      onSelected: (value) {
                        if (value == 'edit') {
                          showContactDialog(index: index);
                        } else if (value == 'delete') {
                          deleteContact(index);
                        }
                      },
                      itemBuilder: (context) => const [
                        PopupMenuItem(
                          value: 'edit',
                          child: Text('Edit'),
                        ),
                        PopupMenuItem(
                          value: 'delete',
                          child: Text('Delete'),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showContactDialog(),
        backgroundColor: const Color(0xFF8B5CF6),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Add Contact'),
      ),
    );
  }
}
