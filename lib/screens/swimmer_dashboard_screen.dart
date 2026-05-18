import 'package:flutter/material.dart';

class SwimmerDashboardScreen extends StatelessWidget {
  const SwimmerDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Swimming'),
        backgroundColor: const Color(0xFF42A5F5),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.pool, size: 80, color: Color(0xFF42A5F5)),
            SizedBox(height: 20),
            Text(
              'Swimmer Dashboard', 
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text('Track your progress and schedule'),
          ],
        ),
      ),
    );
  }
}