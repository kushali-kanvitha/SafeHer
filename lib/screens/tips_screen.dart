
import 'package:flutter/material.dart';

class TipsScreen extends StatelessWidget {
  const TipsScreen({super.key});

  final List<Map<String, dynamic>> tips = const [
    {
      'title': 'Stay Aware of Your Surroundings',
      'description':
          'Avoid distractions while walking. Be aware of the people and places around you.',
      'icon': Icons.visibility,
    },
    {
      'title': 'Share Your Travel Details',
      'description':
          'Inform a trusted person about your destination and expected arrival time.',
      'icon': Icons.share_location,
    },
    {
      'title': 'Avoid Isolated Areas',
      'description':
          'Prefer well-lit and populated routes, especially when travelling at night.',
      'icon': Icons.light_mode,
    },
    {
      'title': 'Keep Emergency Contacts Ready',
      'description':
          'Save important phone numbers so you can contact trusted people quickly.',
      'icon': Icons.contact_phone,
    },
    {
      'title': 'Trust Your Instincts',
      'description':
          'If a situation feels uncomfortable or unsafe, move to a safer public place.',
      'icon': Icons.health_and_safety,
    },
    {
      'title': 'Protect Your Digital Privacy',
      'description':
          'Avoid sharing your live location or personal information with unknown people.',
      'icon': Icons.security,
    },
    {
      'title': 'Keep Your Phone Charged',
      'description':
          'Charge your phone before travelling and carry a power bank when possible.',
      'icon': Icons.battery_charging_full,
    },
    {
      'title': 'Know Emergency Services',
      'description':
          'In India, dial 112 for emergency assistance when needed.',
      'icon': Icons.call,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Safety Tips'),
        centerTitle: true,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: tips.length,
        itemBuilder: (context, index) {
          final tip = tips[index];

          return Card(
            margin: const EdgeInsets.only(bottom: 14),
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    tip['icon'] as IconData,
                    size: 32,
                    color: Colors.pink,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          tip['title'] as String,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          tip['description'] as String,
                          style: const TextStyle(
                            fontSize: 14,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
