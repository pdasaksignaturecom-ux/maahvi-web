import 'package:flutter/material.dart';

class AdminVipManager extends StatefulWidget {
  const AdminVipManager({super.key});

  @override
  State<AdminVipManager> createState() => _AdminVipManagerState();
}

class _AdminVipManagerState extends State<AdminVipManager> {
  // Mock data for VIP users
  final List<Map<String, String>> vipUsers = [
    {
      "id": "USR001",
      "name": "Rahul Khan",
      "status": "Active",
      "expiry": "12h remaining"
    },
    {
      "id": "USR005",
      "name": "Sumit Roy",
      "status": "Active",
      "expiry": "5h remaining"
    },
    {
      "id": "USR012",
      "name": "Anisur Rahman",
      "status": "Expired",
      "expiry": "0h"
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("VIP User Management"),
        backgroundColor: Colors.purple.shade900,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            color: Colors.purple.shade50,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _statItem("Total VIP", "125", Colors.purple),
                _statItem("Active", "84", Colors.green),
                _statItem("Expired", "41", Colors.red),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: vipUsers.length,
              padding: const EdgeInsets.all(10),
              itemBuilder: (context, index) {
                final user = vipUsers[index];
                return Card(
                  child: ListTile(
                    leading: const CircleAvatar(child: Icon(Icons.person)),
                    title: Text(user['name']!,
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(
                        "ID: ${user['id']} • Expires in: ${user['expiry']}"),
                    trailing: _buildStatusChip(user['status']!),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _statItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(value,
            style: TextStyle(
                fontSize: 22, fontWeight: FontWeight.bold, color: color)),
        Text(label,
            style: const TextStyle(fontSize: 12, color: Colors.black54)),
      ],
    );
  }

  Widget _buildStatusChip(String status) {
    Color color = status == "Active" ? Colors.green : Colors.grey;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration:
          BoxDecoration(color: color, borderRadius: BorderRadius.circular(20)),
      child: Text(status,
          style: const TextStyle(
              color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
    );
  }
}
