import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Diffchecker')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.home, size: 64),
            const SizedBox(height: 16),
            Text('Diffchecker', style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 8),
            Text('Diffchecker — Mobile app (flutter)',
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
