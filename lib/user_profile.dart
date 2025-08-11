import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class UserProfile extends StatefulWidget {
  const UserProfile({super.key});

  @override
  State<UserProfile> createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Map<String, dynamic>? _userData;
  bool _isLoading = true;

  // Define color scheme
  // final Color _primaryColor = const Color(0xFF2A9D8F);
  final Color _secondaryColor = const Color(0xFF264653);
  final Color _backgroundColor = const Color(0xFFF4F4F4);
  final Color _textColor = const Color(0xFF1D3557);

  @override
  void initState() {
    super.initState();
    _fetchUserDetails();
  }

  Future<void> _fetchUserDetails() async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser != null) {
        final doc = await _firestore.collection('users').doc(currentUser.uid).get();
        if (doc.exists) {
          setState(() {
            _userData = doc.data();
            _isLoading = false;
          });
        } else {
          setState(() {
            _isLoading = false;
          });
          _showError("User data not found.");
        }
      }
    } catch (e) {
      debugPrint('Error fetching user details: $e');
      setState(() => _isLoading = false);
      _showError("Failed to load profile: $e");
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        backgroundColor: Color(0xFF8B49E7),
        title: const Text("User Profile"),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _userData == null
          ? const Center(child: Text("No user data available."))
          : Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            CircleAvatar(
              radius: 50,
              backgroundColor: _secondaryColor,
              child: const Icon(Icons.person, size: 60, color: Colors.white),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView(
                children: [
                  _buildProfileField("Name", _userData!['name']),
                  _buildProfileField("Email", _userData!['email']),
                  _buildProfileField("Phone", _userData!['phone']),
                  _buildProfileField("Date of Birth", _userData!['dob']),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileField(String label, dynamic value) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 3,
      color: Colors.white,
      child: ListTile(
        leading: const Icon(Icons.info_outline_rounded, color: Colors.grey),
        title: Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: _secondaryColor,
          ),
        ),
        subtitle: Text(
          value ?? "Not provided",
          style: TextStyle(
            color: _textColor,
            fontSize: 15,
          ),
        ),
      ),
    );
  }
}
