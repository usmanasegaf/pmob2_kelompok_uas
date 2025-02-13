import 'package:flutter/material.dart';
import 'package:pmob2_kelompok_uas/home.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Settings extends StatelessWidget {
  const Settings({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: SettingsScreen(),
      theme: ThemeData(
        brightness: Brightness.dark,
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _vibrateEnabled = true;
  bool _beepEnabled = false;

  @override
  void initState() {
    super.initState();
    _fetchSettings();
  }

  Future<void> _fetchSettings() async {
    final response =
        await http.get(Uri.parse('http://localhost:3000/api/settings'));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        _vibrateEnabled = data['vibrate'] == 1;
        _beepEnabled = data['beep'] == 1;
      });
    }
  }

  Future<void> _updateSettings() async {
    await http.post(
      Uri.parse('http://localhost:3000/api/settings'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'vibrate': _vibrateEnabled ? 1 : 0,
        'beep': _beepEnabled ? 1 : 0,
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF1E1E1E),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Back Button
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: InkWell(
                borderRadius: BorderRadius.circular(8),
                onTap: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const Home()),
                  );
                },
                child: Container(
                  padding: EdgeInsets.all(8),
                  child: Icon(
                    Icons.arrow_back,
                    color: Colors.white,
                  ),
                ),
              ),
            ),

            // Title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'Settings',
                style: TextStyle(
                  color: Colors.orange,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            SizedBox(height: 24),

            // Vibrate Setting
            _buildSettingTile(
              icon: Icons.vibration,
              title: 'Vibrate',
              subtitle: 'Vibration when scan is done.',
              value: _vibrateEnabled,
              onChanged: (bool value) {
                setState(() {
                  _vibrateEnabled = value;
                });
                _updateSettings();
              },
            ),

            // Beep Setting
            _buildSettingTile(
              icon: Icons.notifications,
              title: 'Beep',
              subtitle: 'Beep when scan is done.',
              value: _beepEnabled,
              onChanged: (bool value) {
                setState(() {
                  _beepEnabled = value;
                });
                _updateSettings();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Container(
        decoration: BoxDecoration(
          color: Color(0xFF2C2C2C),
          borderRadius: BorderRadius.circular(12),
        ),
        child: ListTile(
          leading: Icon(
            icon,
            color: Colors.orange,
          ),
          title: Text(
            title,
            style: TextStyle(color: Colors.white),
          ),
          subtitle: Text(
            subtitle,
            style: TextStyle(color: Colors.grey),
          ),
          trailing: Switch(
            value: value,
            onChanged: onChanged,
            activeColor: Colors.orange,
          ),
        ),
      ),
    );
  }
}
