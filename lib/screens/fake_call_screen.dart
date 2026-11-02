
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:convert';

const Color purple = Color(0xFF6D28D9);
const Color chatGreen = Color(0xFF075E54);

class FakeCallScreen extends StatelessWidget {
  const FakeCallScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final situations = [
      {
        'title': 'Someone is following me',
        'subtitle': 'I feel unsafe while travelling.',
        'icon': Icons.directions_walk,
        'color': const Color(0xFFFCE4EC),
      },
      {
        'title': 'I feel uncomfortable',
        'subtitle': 'I want to leave an uncomfortable situation.',
        'icon': Icons.person_off,
        'color': const Color(0xFFFFF3E0),
      },
      {
        'title': 'I need a pickup',
        'subtitle': 'I need someone to come and get me.',
        'icon': Icons.local_taxi,
        'color': const Color(0xFFE3F2FD),
      },
      {
        'title': 'I need urgent help',
        'subtitle': 'I may be in immediate danger.',
        'icon': Icons.warning_amber_rounded,
        'color': const Color(0xFFEDE7F6),
      },
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF8F5FC),
      appBar: AppBar(
        title: const Text('Smart Safety Call'),
        backgroundColor: const Color(0xFFF8F5FC),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'What is happening?',
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                  color: purple,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Choose your situation to start a personalized safety conversation.',
                style: TextStyle(fontSize: 15, color: Colors.grey),
              ),
              const SizedBox(height: 25),
              Expanded(
                child: ListView.builder(
                  itemCount: situations.length,
                  itemBuilder: (context, index) {
                    final situation = situations[index];

                    return Card(
                      color: Colors.white,
                      margin: const EdgeInsets.only(bottom: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(15),
                        leading: CircleAvatar(
                          radius: 27,
                          backgroundColor: situation['color'] as Color,
                          child: Icon(
                            situation['icon'] as IconData,
                            color: purple,
                            size: 27,
                          ),
                        ),
                        title: Text(
                          situation['title'] as String,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Text(situation['subtitle'] as String),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 17),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => CallerSelectionScreen(
                                situation: situation['title'] as String,
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
              const Text(
                'If you are in immediate danger, move to a safer public place if possible and call 112.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CallerSelectionScreen extends StatefulWidget {
  final String situation;

  const CallerSelectionScreen({super.key, required this.situation});

  @override
  State<CallerSelectionScreen> createState() => _CallerSelectionScreenState();
}

class _CallerSelectionScreenState extends State<CallerSelectionScreen> {
  List<Map<String, String>> contacts = [];
  bool loading = true;

  final List<Map<String, dynamic>> callers = [
    {'name': 'Mom', 'icon': Icons.favorite},
    {'name': 'Dad', 'icon': Icons.person},
    {'name': 'Sister', 'icon': Icons.face_3},
    {'name': 'Best Friend', 'icon': Icons.people},
  ];

  @override
  void initState() {
    super.initState();
    loadContacts();
  }

  Future<void> loadContacts() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString('emergency_contacts');

    if (saved != null) {
      // Read the same contact format used by ContactsScreen.
      final decoded = (saved.isNotEmpty)
          ? _decodeContacts(saved)
          : <Map<String, String>>[];

      if (!mounted) return;
      setState(() {
        contacts = decoded;
        loading = false;
      });
    } else {
      if (!mounted) return;
      setState(() => loading = false);
    }
  }

  List<Map<String, String>> _decodeContacts(String saved) {
    try {
      final List<dynamic> data =
          (saved.startsWith('[')) ? _jsonDecode(saved) : [];

      return data.map((item) {
        return {
          'name': item['name']?.toString() ?? '',
          'phone': item['phone']?.toString() ?? '',
        };
      }).toList();
    } catch (_) {
      return [];
    }
  }

  // These helpers keep the saved contact data in its existing JSON format.
  dynamic _jsonDecode(String value) {
    return _decodeJsonValue(value);
  }

  String _normalise(String value) => value.trim().toLowerCase();

  Map<String, String>? findContact(String name) {
    for (final contact in contacts) {
      if (_normalise(contact['name'] ?? '') == _normalise(name)) {
        return contact;
      }
    }
    return null;
  }

  Future<void> callNumber(String phone) async {
    final number = phone.replaceAll(RegExp(r'[^0-9+]'), '');

    if (number.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('This contact has no valid phone number.')),
      );
      return;
    }

    final uri = Uri(scheme: 'tel', path: number);

    try {
      final opened = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );

      if (!opened && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'No phone dialer is available. Try this feature on an Android phone.',
            ),
          ),
        );
      }
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unable to open phone dialer: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F5FC),
      appBar: AppBar(
        title: const Text('Choose Caller'),
        backgroundColor: const Color(0xFFF8F5FC),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Who would you like to contact?',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: purple,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Situation: ${widget.situation}',
                    style: const TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: ListView(
                      children: callers.map((caller) {
                        final name = caller['name'] as String;
                        final contact = findContact(name);
                        final phone = contact?['phone'] ?? '';

                        return Card(
                          color: Colors.white,
                          margin: const EdgeInsets.only(bottom: 13),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  backgroundColor: const Color(0xFFEDE4FF),
                                  child: Icon(caller['icon'], color: purple),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        name,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                      Text(
                                        phone.isNotEmpty
                                            ? phone
                                            : 'Add "$name" in Emergency Contacts',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  tooltip: 'Call $name',
                                  onPressed: phone.isEmpty
                                      ? null
                                      : () => callNumber(phone),
                                  icon: const Icon(
                                    Icons.call,
                                    color: Colors.green,
                                  ),
                                ),
                                IconButton(
                                  tooltip: 'Start simulated chat',
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            EmergencyConversationScreen(
                                          situation: widget.situation,
                                          caller: name,
                                          phone: phone,
                                        ),
                                      ),
                                    );
                                  },
                                  icon: const Icon(
                                    Icons.chat,
                                    color: purple,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const Text(
                    'Chat is simulated. The call button opens your device phone dialer.',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
    );
  }
}

// JSON decoding helper.
dynamic _decodeJsonValue(String value) {
  return jsonDecode(value);
}

class ChatMessage {
  final String sender;
  final String message;
  final DateTime time;

  ChatMessage({
    required this.sender,
    required this.message,
    DateTime? time,
  }) : time = time ?? DateTime.now();
}

class EmergencyConversationScreen extends StatefulWidget {
  final String situation;
  final String caller;
  final String phone;

  const EmergencyConversationScreen({
    super.key,
    required this.situation,
    required this.caller,
    required this.phone,
  });

  @override
  State<EmergencyConversationScreen> createState() =>
      _EmergencyConversationScreenState();
}

class _EmergencyConversationScreenState
    extends State<EmergencyConversationScreen> {
  final List<ChatMessage> messages = [];
  final TextEditingController messageController = TextEditingController();
  final ScrollController scrollController = ScrollController();

  List<String> suggestions = [];
  bool conversationEnded = false;

  @override
  void initState() {
    super.initState();
    startConversation();
  }

  @override
  void dispose() {
    messageController.dispose();
    scrollController.dispose();
    super.dispose();
  }

  void addMessage(String sender, String message) {
    messages.add(ChatMessage(sender: sender, message: message));
  }

  void startConversation() {
    String firstMessage;

    if (widget.situation == 'Someone is following me') {
      firstMessage = 'Are you okay? Is someone following you?';
      suggestions = [
        'Yes, someone is following me.',
        'I am moving to a public place.',
        'I need immediate help.',
      ];
    } else if (widget.situation == 'I feel uncomfortable') {
      firstMessage = 'You sound uncomfortable. Do you want to leave?';
      suggestions = [
        'Yes, I want to leave.',
        'Someone is making me uncomfortable.',
        'Please stay on the call.',
      ];
    } else if (widget.situation == 'I need a pickup') {
      firstMessage = 'Where are you? Do you need someone to pick you up?';
      suggestions = [
        'Yes, I need a pickup.',
        'I will share my location.',
        'Please arrange help.',
      ];
    } else {
      firstMessage = 'I am here with you. Are you in immediate danger?';
      suggestions = [
        'Yes, I need immediate help.',
        'I am trying to reach a safe place.',
        'I need to contact someone.',
      ];
    }

    addMessage(widget.caller, firstMessage);
  }

  void sendMessage([String? suggestedMessage]) {
    final message = (suggestedMessage ?? messageController.text).trim();
    if (message.isEmpty || conversationEnded) return;

    setState(() {
      addMessage('You', message);
      messageController.clear();
      replyTo(message);
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void replyTo(String message) {
    final text = message.toLowerCase();
    String reply;

    if (text.contains('112') || text.contains('immediate help') ||
        text.contains('urgent')) {
      reply =
          'If you are in immediate danger, call 112 now if you can. Move towards other people if it is safe.';
      suggestions = ['I will call 112.', 'I am moving to a safer place.'];
    } else if (text.contains('following')) {
      reply =
          'Stay calm. Move towards a busy, well-lit place. Can you see a shop or security guard nearby?';
      suggestions = ['Yes, I can see a shop.', 'No, I am somewhere isolated.'];
    } else if (text.contains('shop')) {
      reply =
          'Go inside if it is safe. Stay near staff or other people. Contact someone you trust.';
      suggestions = ['I will contact my family.', 'I need emergency help.'];
    } else if (text.contains('isolated')) {
      reply =
          'Try to move towards a populated, well-lit area if possible. Avoid approaching the person.';
      suggestions = ['I will call 112.', 'I will contact someone I trust.'];
    } else if (text.contains('leave') || text.contains('uncomfortable')) {
      reply =
          'You do not need to explain yourself. Move towards an exit or a place with other people if safe.';
      suggestions = ['I can leave safely.', 'I need someone to help me.'];
    } else if (text.contains('pickup') || text.contains('location')) {
      reply =
          'Share your location with someone you trust and wait in a safe public place.';
      suggestions = ['I will share my location.', 'I will wait somewhere public.'];
    } else if (text.contains('contact') || text.contains('family') ||
        text.contains('trusted')) {
      reply =
          'Please contact someone you trust directly. Share your location if possible.';
      suggestions = ['Okay, I will do that.', 'I need emergency help.'];
    } else if (text.contains('thank')) {
      reply = 'Take care. Stay somewhere safe and contact someone you trust.';
      suggestions = [];
      conversationEnded = true;
    } else {
      reply =
          'I am here for you. Focus on getting somewhere safe. Can you contact someone you trust?';
      suggestions = ['Yes, I will contact them.', 'I need immediate help.'];
    }

    addMessage(widget.caller, reply);
  }

  Future<void> callSelectedContact() async {
    if (widget.phone.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Add ${widget.caller} in Emergency Contacts to call them.',
          ),
        ),
      );
      return;
    }

    final number = widget.phone.replaceAll(RegExp(r'[^0-9+]'), '');
    if (number.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('This contact has no valid phone number.')),
      );
      return;
    }

    final uri = Uri(scheme: 'tel', path: number);

    try {
      final opened = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );

      if (!opened && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'No phone dialer is available. Try this feature on an Android phone.',
            ),
          ),
        );
      }
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unable to open phone dialer: $error')),
      );
    }
  }

  Future<void> call112() async {
    final uri = Uri(scheme: 'tel', path: '112');

    try {
      final opened = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );

      if (!opened && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'No phone dialer is available. Try this feature on an Android phone.',
            ),
          ),
        );
      }
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unable to open emergency dialer: $error')),
      );
    }
  }

  String formatTime(DateTime time) {
    final hour = time.hour % 12 == 0 ? 12 : time.hour % 12;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }

  Widget buildBubble(ChatMessage message) {
    final isMe = message.sender == 'You';

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 310),
        margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
        padding: const EdgeInsets.fromLTRB(13, 9, 10, 7),
        decoration: BoxDecoration(
          color: isMe ? const Color(0xFFD9FDD3) : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(13),
            topRight: const Radius.circular(13),
            bottomLeft: Radius.circular(isMe ? 13 : 3),
            bottomRight: Radius.circular(isMe ? 3 : 13),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 2,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                message.message,
                style: const TextStyle(fontSize: 15, color: Colors.black87),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              formatTime(message.time),
              style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFECE5DD),
      appBar: AppBar(
        backgroundColor: chatGreen,
        foregroundColor: Colors.white,
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.white,
              child: Text(
                widget.caller[0],
                style: const TextStyle(color: chatGreen),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.caller, style: const TextStyle(fontSize: 17)),
                  const Text(
                    'Simulated safety conversation',
                    style: TextStyle(fontSize: 11, color: Colors.white70),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Call contact',
            onPressed: callSelectedContact,
            icon: const Icon(Icons.call),
          ),
          IconButton(
            tooltip: 'Call emergency number 112',
            onPressed: call112,
            icon: const Icon(Icons.emergency),
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 700),
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  color: const Color(0xFFFFF3CD),
                  child: const Text(
                    'This is a simulated chat, not a real call.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12, color: Colors.black87),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    controller: scrollController,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    itemCount: messages.length,
                    itemBuilder: (context, index) =>
                        buildBubble(messages[index]),
                  ),
                ),
                if (!conversationEnded && suggestions.isNotEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(10, 5, 10, 8),
                    color: const Color(0xFFF7F3EF),
                    child: Wrap(
                      spacing: 7,
                      runSpacing: 7,
                      children: suggestions.map((suggestion) {
                        return ActionChip(
                          label: Text(suggestion),
                          labelStyle: const TextStyle(
                            color: chatGreen,
                            fontSize: 12,
                          ),
                          backgroundColor: Colors.white,
                          side: const BorderSide(color: chatGreen),
                          onPressed: () => sendMessage(suggestion),
                        );
                      }).toList(),
                    ),
                  ),
                if (conversationEnded)
                  const Padding(
                    padding: EdgeInsets.all(10),
                    child: Text(
                      'Conversation completed. Stay safe!',
                      style: TextStyle(
                        color: chatGreen,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                Container(
                  color: const Color(0xFFF7F3EF),
                  padding: const EdgeInsets.fromLTRB(8, 7, 8, 7),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: messageController,
                          minLines: 1,
                          maxLines: 4,
                          textInputAction: TextInputAction.send,
                          onSubmitted: (_) => sendMessage(),
                          decoration: InputDecoration(
                            hintText: 'Type a message...',
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 11,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(25),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 7),
                      CircleAvatar(
                        backgroundColor: chatGreen,
                        child: IconButton(
                          onPressed: conversationEnded ? null : sendMessage,
                          icon: const Icon(Icons.send, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
