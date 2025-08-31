import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Settings")),
      body: ListView(
        children: const [
          ListTile(
            leading: Icon(Icons.lock),
            title: Text("Change Password"),
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.notifications),
            title: Text("Notification Settings"),
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.help),
            title: Text("Help & Support"),
          ),
        ],
      ),
    );
  }
}
