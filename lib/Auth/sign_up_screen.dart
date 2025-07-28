import 'package:chat_application/Auth/sign_in_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../ChatSystem/chat_room.dart';
import '../main.dart';
import 'auth_service.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _name = TextEditingController();
  final _dob = TextEditingController();

  bool _obscure = true;
  String _error = '';

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: now,
    );
    if (picked != null) {
      _dob.text = DateFormat('yyyy-MM-dd').format(picked);
    }
  }

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      try {
        await AuthService.signUp(
          email: _email.text,
          password: _password.text,
          name: _name.text,
          dob: _dob.text,
        );
       if(mounted){
         ScaffoldMessenger.of(context).showSnackBar(
           const SnackBar(content: Text('Account created successfully!')),
         );
         Navigator.pushReplacement(
           context,
           MaterialPageRoute(builder: (_) => const ChatRoom()),
         );
       }
      } on FirebaseAuthException catch (e) {
        setState(() => _error = e.message ?? "Sign up failed");
      } catch (e) {
        debugPrint("Unexpected error: $e");
        setState(() => _error = "Something went wrong. Try again.");
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF8B49E7),
              Color(0xFF47D5E8),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Column(
              children: [
                Text(
                  "Create Account ✨",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  "Join us to get started",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white.withValues(alpha:0.7),
                  ),
                ),
                const SizedBox(height: 40),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.black.withValues(alpha:0.4)
                        : Colors.white.withValues(alpha:0.9),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha:0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        if (_error.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Text(
                              _error,
                              style: const TextStyle(color: Colors.redAccent),
                            ),
                          ),
                        TextFormField(
                          controller: _name,
                          decoration: _buildInputDecoration(
                            label: "Full Name",
                            icon: Icons.person_outline,
                          ),
                          validator: (val) =>
                          val != null && val.isNotEmpty ? null : "Enter name",
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _dob,
                          readOnly: true,
                          onTap: _pickDate,
                          decoration: _buildInputDecoration(
                            label: "Date of Birth",
                            icon: Icons.calendar_today_outlined,
                          ),
                          validator: (val) =>
                          val != null && val.isNotEmpty ? null : "Select DOB",
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _email,
                          decoration: _buildInputDecoration(
                            label: "Email",
                            icon: Icons.email_outlined,
                          ),
                          validator: (val) => val != null && val.contains('@')
                              ? null
                              : "Enter valid email",
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _password,
                          obscureText: _obscure,
                          decoration: _buildInputDecoration(
                            label: "Password",
                            icon: Icons.lock_outline,
                            suffix: IconButton(
                              icon: Icon(
                                _obscure
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                              ),
                              onPressed: () =>
                                  setState(() => _obscure = !_obscure),
                            ),
                          ),
                          validator: (val) => val != null && val.length >= 6
                              ? null
                              : "Min 6 characters",
                        ),
                        const SizedBox(height: 30),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _submit,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF1D976C),
                              padding:
                              const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 6,
                            ),
                            child: const Text(
                              "Sign Up",
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        TextButton(
                          onPressed: () {
                            Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const SignInScreen()));
                          },
                          child: const Text(
                            "Already have an account? Sign In",
                            style: TextStyle(color: Colors.black),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _buildInputDecoration({
    required String label,
    required IconData icon,
    Widget? suffix,
  }) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      suffixIcon: suffix,
      filled: true,
      fillColor: Colors.grey.shade100,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    );
  }
}
