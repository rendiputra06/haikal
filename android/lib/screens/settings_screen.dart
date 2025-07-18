import 'package:flutter/material.dart';
import '../widgets/main_layout.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool isDarkMode = false;
  bool notifAktif = true;
  String bahasa = 'Indonesia';

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      title: 'Pengaturan',
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SwitchListTile(
              title: const Text('Mode Gelap'),
              value: isDarkMode,
              onChanged: (val) {
                setState(() => isDarkMode = val);
              },
              secondary: const Icon(Icons.dark_mode),
            ),
            SwitchListTile(
              title: const Text('Notifikasi'),
              value: notifAktif,
              onChanged: (val) {
                setState(() => notifAktif = val);
              },
              secondary: const Icon(Icons.notifications_active),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Icon(Icons.language),
                const SizedBox(width: 12),
                const Text('Bahasa:'),
                const SizedBox(width: 12),
                DropdownButton<String>(
                  value: bahasa,
                  items: const [
                    DropdownMenuItem(
                      value: 'Indonesia',
                      child: Text('Indonesia'),
                    ),
                    DropdownMenuItem(value: 'English', child: Text('English')),
                  ],
                  onChanged: (val) {
                    if (val != null) setState(() => bahasa = val);
                  },
                ),
              ],
            ),
            const Spacer(),
            Center(
              child: ElevatedButton.icon(
                onPressed: () {
                  // Dummy action, nanti bisa simpan ke backend/local
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Pengaturan disimpan (dummy)'),
                    ),
                  );
                },
                icon: const Icon(Icons.save),
                label: const Text('Simpan Pengaturan'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
