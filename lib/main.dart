import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'providers/org_provider.dart';
import 'providers/attendance_provider.dart';
import 'firebase_options.dart';
import 'ui/pages/auth_gate.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => OrgProvider()),
        ChangeNotifierProvider(create: (_) => AttendanceProvider()),
      ],
      child: const OrgAttendanceApp(),
    ),
  );
}

class OrgAttendanceApp extends StatelessWidget {
  const OrgAttendanceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Org Attendance QR",
      home: AuthGate(),
    );
  }
}