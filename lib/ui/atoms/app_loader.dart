import 'package:flutter/material.dart';

/// The spinner shown while data is loading (Auth Gate, StreamBuilder screens).
class AppLoader extends StatelessWidget {
  const AppLoader({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }
}
