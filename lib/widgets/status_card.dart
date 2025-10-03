import 'package:flutter/material.dart';

class StatusCard extends StatelessWidget {
  final String location;
  final bool online;
  final VoidCallback onEmergency;
  const StatusCard({super.key, required this.location, required this.online, required this.onEmergency});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(12),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            const Icon(Icons.place, color: Colors.redAccent),
            const SizedBox(width: 8),
            Expanded(child: Text(location, style: const TextStyle(fontWeight: FontWeight.w600))),
          ]),
          const SizedBox(height: 8),
          Row(children: [
            Icon(online ? Icons.wifi : Icons.wifi_off_rounded, color: online ? Colors.green : Colors.orange),
            const SizedBox(width: 8),
            Text(online ? 'Online' : 'Offline'),
            const Spacer(),
            ElevatedButton.icon(onPressed: onEmergency, icon: const Icon(Icons.emergency), label: const Text('NEED HELP?')),
          ])
        ]),
      ),
    );
  }
}


