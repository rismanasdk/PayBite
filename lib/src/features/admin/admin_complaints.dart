import 'package:flutter/material.dart';

class AdminComplaintsPage extends StatelessWidget {
  const AdminComplaintsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.report_problem, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          const Text(
            'Kelola Complaint',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          const Text(
            'Fitur manajemen complaint segera hadir',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
