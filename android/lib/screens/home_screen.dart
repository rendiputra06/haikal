import 'package:flutter/material.dart';
import '../widgets/main_layout.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      title: 'Home',
      child: Center(
        child: Text(
          'Selamat datang di Quran Whisper!\nPilih menu di samping untuk mulai latihan atau cek riwayat.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
