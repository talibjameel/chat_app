import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../Auth/auth_service.dart';
import '../Auth/sign_in_screen.dart';
import '../user_profile.dart';
import 'chat_screen.dart';

class ChatRoom extends StatefulWidget {
  const ChatRoom({super.key});

  @override
  State<ChatRoom> createState() => _ChatRoomState();
}
class _ChatRoomState extends State<ChatRoom> {
  String? currentUserId;
  List<Map<String, dynamic>> usersList = [];
  bool isLoading = true;

  final Color purple = const Color(0xFF8B49E7);
  final Color teal = const Color(0xFF47D5E8);
  final Color yellow = const Color(0xFFFFD700);
  final Color white = Colors.white;

  @override
  void initState() {
    super.initState();
    currentUserId = AuthService.currentUser?.uid;
    fetchAllUsers();
  }

  Future<void> fetchAllUsers() async {
    try {
      QuerySnapshot snapshot =
      await FirebaseFirestore.instance.collection('users').get();

      final users =
      snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();

      setState(() {
        usersList = users;
        isLoading = false;
      });
    } catch (e) {
      debugPrint("Error fetching users: $e");
      setState(() => isLoading = false);
    }
  }

  Widget buildUserCard(Map<String, dynamic> user) {
    final isCurrentUser = user['uid'] == currentUserId;
    final displayName = isCurrentUser ? "You" : user['name'] ?? 'N/A';
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatScreen(
              otherUserId: user['uid'],
              userName: user['name'],
            ),
          ),
        );
      },
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        elevation: 5,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        color: teal.withValues(alpha: 0.3),
        child: ListTile(
          leading: CircleAvatar(
            radius: 28,
            backgroundColor: purple,
            child: const Icon(Icons.person, color: Colors.white, size: 30),
          ),
          title: Text(
            displayName.toUpperCase(),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: purple,
            ),
          ),
          subtitle: Text(
            "${user['email'] ?? 'N/A'}",
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade700,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: white,
      appBar: AppBar(
        backgroundColor: purple,
        title: const Text("Chat Room",
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => UserProfile()));
            },
            icon: Icon(Icons.person, color: yellow),
          ),
          IconButton(
            icon: Icon(Icons.logout, color: yellow),
            onPressed: () {
              AuthService.signOut();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Logged out successfully!')),
              );
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (context) => const SignInScreen()));
            },
          ),
        ],
      ),
      body: isLoading
          ? Center(
        child: CircularProgressIndicator(color: purple),
      )
          : usersList.isEmpty
          ? Center(
        child: Text("No users found.",
            style: TextStyle(
                color: purple, fontWeight: FontWeight.w500)),
      )
          : RefreshIndicator(
        onRefresh: (){
          return fetchAllUsers();
        },
            child: ListView.builder(
                    itemCount: usersList.length,
                    itemBuilder: (context, index) {
            return buildUserCard(usersList[index]);
                    },
                  ),
          ),
    );
  }
}
