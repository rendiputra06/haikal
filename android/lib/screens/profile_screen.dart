import 'package:flutter/material.dart';
import '../widgets/main_layout.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Data dummy, nanti bisa diganti dengan data dari backend
    final String namaUser = "User Guest";
    final int totalLatihan = 0;
    final double rataRataSkor = 0.0;
    final String terakhirLatihan = "-";

    return MainLayout(
      title: 'Profile User',
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const CircleAvatar(radius: 40, child: Icon(Icons.person, size: 50)),
            const SizedBox(height: 16),
            Text(
              namaUser,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Card(
              margin: const EdgeInsets.symmetric(vertical: 12),
              child: ListTile(
                leading: const Icon(Icons.history),
                title: const Text('Total Latihan'),
                trailing: Text('$totalLatihan'),
              ),
            ),
            Card(
              child: ListTile(
                leading: const Icon(Icons.score),
                title: const Text('Rata-rata Skor'),
                trailing: Text(rataRataSkor.toStringAsFixed(2)),
              ),
            ),
            Card(
              child: ListTile(
                leading: const Icon(Icons.access_time),
                title: const Text('Terakhir Latihan'),
                trailing: Text(terakhirLatihan),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                // Nanti bisa fetch data user dari backend
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Refresh Data'),
            ),
          ],
        ),
      ),
    );
  }
}
