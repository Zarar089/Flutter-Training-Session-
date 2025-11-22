import 'package:flutter/material.dart';

// Placeholder for Attendance Screen
// TODO: Implement full BLoC architecture for attendance similar to employee feature
class AttendanceScreen extends StatelessWidget {
  const AttendanceScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Attendance'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.access_time, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              'Attendance Feature',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Coming Soon',
              style: TextStyle(color: Colors.grey.shade600),
            ),
            const SizedBox(height: 24),
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'To implement:\n'
                '1. Create AttendanceBloc\n'
                '2. Create Check-in/Check-out events\n'
                '3. Add attendance use cases\n'
                '4. Implement attendance repository',
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}