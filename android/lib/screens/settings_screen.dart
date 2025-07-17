import 'package:flutter/material.dart';
import '../widgets/main_layout.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      title: 'Pengaturan',
      child: const Center(child: Text('Pengaturan Screen')),
    );
  }
}
