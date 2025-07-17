import 'package:flutter/material.dart';
import '../widgets/main_layout.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      title: 'Profile User',
      child: const Center(child: Text('Profile User Screen')),
    );
  }
}
