import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _isDarkTheme = false;
  bool _notificationsEnabled = true;
  bool _autoSync = false;
  double _fontSize = 16.0;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isDarkTheme = prefs.getBool('isDarkTheme') ?? false;
      _notificationsEnabled = prefs.getBool('notificationsEnabled') ?? true;
      _autoSync = prefs.getBool('autoSync') ?? false;
      _fontSize = prefs.getDouble('fontSize') ?? 16.0;
    });
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkTheme', _isDarkTheme);
    await prefs.setBool('notificationsEnabled', _notificationsEnabled);
    await prefs.setBool('autoSync', _autoSync);
    await prefs.setDouble('fontSize', _fontSize);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Settings saved!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeColor = _isDarkTheme ? Colors.black : Colors.green;
    final bgColor = _isDarkTheme ? Colors.grey[900] : Colors.white;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: themeColor,
        foregroundColor: Colors.white,
        title: Text('Settings'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(
          children: [
            _sectionTitle("Appearance"),
            SwitchListTile(
              title: Text("Dark Theme", style: TextStyle(fontSize: _fontSize)),
              secondary: Icon(Icons.brightness_6, color: themeColor),
              value: _isDarkTheme,
              onChanged: (value) {
                setState(() {
                  _isDarkTheme = value;
                });
                _saveSettings();
              },
            ),
            SizedBox(height: 20),
            Text(
              "Font Size: ${_fontSize.toStringAsFixed(1)}",
              style: TextStyle(fontSize: _fontSize),
            ),
            Slider(
              value: _fontSize,
              min: 12.0,
              max: 24.0,
              divisions: 12,
              label: _fontSize.toStringAsFixed(1),
              activeColor: themeColor,
              onChanged: (value) {
                setState(() {
                  _fontSize = value;
                });
              },
              onChangeEnd: (value) => _saveSettings(),
            ),
            Divider(thickness: 1.2),
            _sectionTitle("Preferences"),
            SwitchListTile(
              title:
              Text("Enable Notifications", style: TextStyle(fontSize: _fontSize)),
              secondary: Icon(Icons.notifications_active, color: themeColor),
              value: _notificationsEnabled,
              onChanged: (value) {
                setState(() {
                  _notificationsEnabled = value;
                });
                _saveSettings();
              },
            ),
            SwitchListTile(
              title: Text("Auto Sync", style: TextStyle(fontSize: _fontSize)),
              secondary: Icon(Icons.sync, color: themeColor),
              value: _autoSync,
              onChanged: (value) {
                setState(() {
                  _autoSync = value;
                });
                _saveSettings();
              },
            ),
            SizedBox(height: 30),
            Center(
              child: ElevatedButton.icon(
                onPressed: _saveSettings,
                icon: Icon(Icons.save),
                label: Text("Save Settings", style: TextStyle(fontSize: _fontSize)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: themeColor,
                  foregroundColor: Colors.white,
                  padding:
                  EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        style: TextStyle(
          color: Colors.green[700],
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
