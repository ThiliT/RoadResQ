import 'package:flutter/material.dart';

class MechanicDashboardScreen extends StatefulWidget {
  const MechanicDashboardScreen({super.key});

  @override
  State<MechanicDashboardScreen> createState() => _MechanicDashboardScreenState();
}

class _MechanicDashboardScreenState extends State<MechanicDashboardScreen> {
  String _availability = 'Available';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mechanic Dashboard')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: ListTile(
              leading: CircleAvatar(backgroundColor: Colors.orange.shade100, child: const Icon(Icons.handyman_rounded)),
              title: const Text('Your Profile'),
              subtitle: const Text('Name • Phone • Service Area'),
              trailing: IconButton(onPressed: () {}, icon: const Icon(Icons.edit_outlined)),
            ),
          ),
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(children: [
                const Text('Availability'),
                const Spacer(),
                DropdownButton<String>(
                  value: _availability,
                  items: const [
                    DropdownMenuItem(value: 'Available', child: Text('Available')),
                    DropdownMenuItem(value: 'Busy', child: Text('Busy')),
                    DropdownMenuItem(value: 'Offline', child: Text('Offline')),
                  ],
                  onChanged: (v) => setState(() => _availability = v ?? 'Available'),
                )
              ]),
            ),
          ),
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(children: const [
                Expanded(child: _StatTile(label: 'Requests today', value: '0')),
                Expanded(child: _StatTile(label: 'Distance', value: '0 km')),
                Expanded(child: _StatTile(label: 'Rating', value: '⭐⭐⭐⭐⭐')),
              ]),
            ),
          ),
          const SizedBox(height: 8),
          const Text('Incoming Requests', style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          ...List.generate(3, (i) => _RequestCard(index: i + 1)),
          const SizedBox(height: 12),
          ElevatedButton.icon(onPressed: () {}, icon: const Icon(Icons.my_location), label: const Text('Update Current Location')),
        ],
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  final String label;
  final String value;
  const _StatTile({required this.label, required this.value});
  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: const TextStyle(color: Colors.black54)),
      const SizedBox(height: 6),
      Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
    ]);
  }
}

class _RequestCard extends StatelessWidget {
  final int index;
  const _RequestCard({required this.index});
  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(child: Text(index.toString())),
        title: Text('Driver #$index'),
        subtitle: const Text('2.5 km away • 10:30 AM'),
        trailing: Wrap(spacing: 8, children: [
          TextButton(onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Declined'))), child: const Text('Decline')),
          ElevatedButton(onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Accepted'))), child: const Text('Accept')),
        ]),
      ),
    );
  }
}



