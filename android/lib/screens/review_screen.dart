import 'package:flutter/material.dart';
import '../widgets/main_layout.dart';

class ReviewScreen extends StatelessWidget {
  const ReviewScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      title: 'Review Koreksi',
      child: const Center(child: Text('Review Koreksi Screen')),
    );
  }
}
