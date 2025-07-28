import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';


class ChatScreen extends StatefulWidget {
  final String otherUserId;
  final String userName;

  const ChatScreen({
    super.key,
    required this.otherUserId,
    required this.userName,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  String? currentUserId;
  Map<String, dynamic>? currentUserData;

  final Color purple = const Color(0xFF8B49E7);
  final Color teal = const Color(0xFF47D5E8);
  final Color yellow = const Color(0xFFFFD700);
  final Color white = Colors.white;

  @override
  void initState() {
    super.initState();
    fetchCurrentUser();
  }

  Future<void> fetchCurrentUser() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      currentUserId = user.uid;

      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (userDoc.exists) {
        currentUserData = userDoc.data() as Map<String, dynamic>;
        setState(() {});
      }
    } catch (e) {
      debugPrint("Error fetching current user: $e");
    }
  }

  String get roomId {
    if (currentUserId == null) return '';
    return currentUserId!.hashCode <= widget.otherUserId.hashCode
        ? '${currentUserId}_${widget.otherUserId}'
        : '${widget.otherUserId}_$currentUserId';
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty || currentUserId == null) return;

    await FirebaseFirestore.instance
        .collection('chats')
        .doc(roomId)
        .collection('messages')
        .add({
      'text': text,
      'senderId': currentUserId,
      'timestamp': FieldValue.serverTimestamp(),
    });

    _messageController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: white,
      appBar: AppBar(
        backgroundColor: purple,
        title: Text(
          widget.userName.toUpperCase(),
          style: const TextStyle(fontWeight: FontWeight.bold,color: Colors.white),
        ),
        centerTitle: true,
        iconTheme: IconThemeData(color: yellow),
      ),
      body: currentUserId == null
          ? Center(child: CircularProgressIndicator(color: purple))
          : SafeArea(
        child: Column(
          children: [
            Expanded(
              child: RefreshIndicator(
                onRefresh: () {
                  return Future.delayed(Duration.zero);
                },
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('chats')
                      .doc(roomId)
                      .collection('messages')
                      .orderBy('timestamp', descending: false)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return Center(
                          child:
                          CircularProgressIndicator(color: purple));
                    }

                    final docs = snapshot.data!.docs;

                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      itemCount: docs.length,
                      itemBuilder: (context, index) {
                        final data =
                        docs[index].data() as Map<String, dynamic>;
                        final isMe = data['senderId'] == currentUserId;

                        // Safe timestamp parsing
                        final timestamp = data['timestamp'];
                        String formattedTime = '';
                        if (timestamp != null && timestamp is Timestamp) {
                          DateTime dt = timestamp.toDate();
                          formattedTime = DateFormat.jm().format(dt); // e.g., 5:30 PM
                        }

                        return Align(
                          alignment: isMe
                              ? Alignment.centerRight
                              : Alignment.centerLeft,
                          child: Container(
                            margin: const EdgeInsets.symmetric(
                                vertical: 4, horizontal: 12),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 10),
                            decoration: BoxDecoration(
                              color: isMe
                                  ? purple.withOpacity(0.9)
                                  : teal.withOpacity(0.9),
                              borderRadius: BorderRadius.only(
                                topLeft: const Radius.circular(16),
                                topRight: const Radius.circular(16),
                                bottomLeft:
                                Radius.circular(isMe ? 16 : 0),
                                bottomRight:
                                Radius.circular(isMe ? 0 : 16),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  data['text'] ?? '',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  formattedTime,
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 10,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ),

            // Message Input Field
            Container(
              padding: const EdgeInsets.symmetric(
                  vertical: 6, horizontal: 12),
              color: Colors.grey.shade100,
              child: Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _messageController,
                      decoration: InputDecoration(
                        hintText: "Type your message...",
                        hintStyle:
                        TextStyle(color: Colors.grey.shade600),
                        filled: true,
                        fillColor: white,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      onFieldSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  CircleAvatar(
                    radius: 22,
                    backgroundColor: yellow,
                    child: IconButton(
                      icon: const Icon(Icons.send, color: Colors.black),
                      onPressed: _sendMessage,
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
