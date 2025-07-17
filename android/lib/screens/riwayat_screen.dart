import 'package:flutter/material.dart';
import '../widgets/main_layout.dart';

class RiwayatScreen extends StatelessWidget {
  const RiwayatScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      title: 'Riwayat Latihan',
      child: const Center(child: Text('Riwayat Latihan Screen')),
    );
  }
}
