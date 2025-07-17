import 'package:flutter/material.dart';
import '../widgets/main_layout.dart';

class StatistikScreen extends StatelessWidget {
  const StatistikScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      title: 'Statistik Hafalan',
      child: const Center(child: Text('Statistik Hafalan Screen')),
    );
  }
}
