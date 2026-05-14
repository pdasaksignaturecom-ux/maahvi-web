import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5),
      appBar: AppBar(
        title: const Text('DEAR LOTTERY ADMIN',
            style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1)),
        backgroundColor: Colors.indigo.shade900,
        foregroundColor: Colors.white,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => context.go('/'),
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildStatBanner(),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 15,
                mainAxisSpacing: 15,
                childAspectRatio: 1.1,
                children: [
                  _adminTile(
                      context,
                      "UPLOAD RESULT",
                      Icons.cloud_upload,
                      Colors.blue.shade700,
                      () => context.push('/admin/upload-result')),
                  _adminTile(
                      context,
                      "ADS & PREDICTION",
                      Icons.campaign,
                      Colors.orange.shade800,
                      () => context.push('/admin/manage-ads')),
                  _adminTile(
                      context,
                      "VIP MANAGEMENT",
                      Icons.stars_rounded,
                      Colors.purple.shade700,
                      () => context.push('/admin/vip-manager')),
                  _adminTile(context, "USER ANALYTICS", Icons.people,
                      Colors.teal.shade700, () => {}),
                  _adminTile(
                      context,
                      "NOTIFICATIONS",
                      Icons.notifications_active,
                      Colors.red.shade700,
                      () => {}),
                  _adminTile(
                      context,
                      "SETTINGS",
                      Icons.settings,
                      Colors.blueGrey.shade700,
                      () => context.push('/admin/manage-ads')),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: Colors.indigo.shade900,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: const Column(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: Colors.white24,
            child:
                Icon(Icons.admin_panel_settings, color: Colors.white, size: 50),
          ),
          SizedBox(height: 15),
          Text(
            "Admin Control Room",
            style: TextStyle(
                color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
          ),
          Text(
            "Maahvi Lottery Web & App",
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _adminTile(BuildContext context, String title, IconData icon,
      Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            color: Colors.white,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 45, color: color),
              const SizedBox(height: 10),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: Colors.black87),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
