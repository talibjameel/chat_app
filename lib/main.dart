import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'Auth/sign_in_screen.dart';
import 'ChatSystem/chat_room.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Chat Application',
      theme: ThemeData(
        textSelectionTheme: const TextSelectionThemeData(
          cursorColor: Colors.deepPurple,
          selectionColor: Colors.deepPurple,
          selectionHandleColor: Colors.deepPurple,
        ),
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: AuthMiddleware(),
    );
  }
}



class AuthMiddleware extends StatelessWidget {
  const AuthMiddleware({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
              body: Center(child: CircularProgressIndicator()));
        } else if (snapshot.hasData) {
          return const ChatRoom();
        } else {
          return const SignInScreen();
        }
      },
    );
  }
}