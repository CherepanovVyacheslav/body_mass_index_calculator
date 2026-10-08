import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text(
          'Профиль',
          style: TextStyle(color: Color(0xFF4CAF50)),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF4CAF50)),
      ),
      body: const Center(
        child: Text(
          'Здесь будет профиль пользователя',
          style: TextStyle(fontSize: 18, color: Colors.grey),
        ),
      ),
    );
  }
}
