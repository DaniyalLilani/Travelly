import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';

class PostDetailPage extends StatefulWidget {
  final String postId;

  PostDetailPage({required this.postId});

  @override
  _PostDetailPageState createState() => _PostDetailPageState();
}

class _PostDetailPageState extends State<PostDetailPage> {
  File? _pickedImage; // Image picked by the user
  TextEditingController _commentController = TextEditingController();
  double _rating = 0; // To store the rating
  String currentUserId = ''; // Store the current user's id
  String currentUserUsername = ''; // Store the current user's username

  // Fetch post data and comments from Firestore
  Future<DocumentSnapshot> _getPostData() async {
    return await FirebaseFirestore.instance.collection('pins').doc(widget.postId).get();
  }

  // Fetch current user's ID and username
  Future<void> _fetchCurrentUserId() async {
    var user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      currentUserId = user.uid;
      // Fetch current user's username
      DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (userDoc.exists) {
        setState(() {
          currentUserUsername = userDoc['username']; // Assuming username field exists
        });
      }
    } else {
      print('No user is logged in.');
      return;
    }
  }

  // Shows a dialog to add a comment
  void showCommentDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Add a comment"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 10),
                TextField(
                  controller: _commentController,
                  decoration: InputDecoration(hintText: "Write your comment here"),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () async {
                    final picker = ImagePicker();
                    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
                    if (pickedFile != null) {
                      setState(() {
                        _pickedImage = File(pickedFile.path);
                      });
                    }
                  },
                  child: Text("Upload an Image"),
                ),
                if (_pickedImage != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 10.0),
                    child: Image.file(_pickedImage!, width: 100, height: 100),
                  ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                if (_commentController.text.isNotEmpty) {
                  FirebaseFirestore.instance.collection('pins').doc(widget.postId).update({
                    'comments': FieldValue.arrayUnion([
                      {
                        'username': currentUserUsername,  // Use fetched username
                        'comment': _commentController.text,
                        'image': _pickedImage != null ? _pickedImage!.path : '',
                      }
                    ]),
                  });
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Comment added!')),
                  );
                }
              },
              child: Text("Submit"),
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _fetchCurrentUserId(); // Fetch current user's ID and username when page is loaded
  }

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text('Post Details'),
        backgroundColor: Colors.purple,
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: _getPostData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator()); // Loading state
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}')); // Error state
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return Center(child: Text('Post not found.'));
          }

          var postData = snapshot.data!.data() as Map<String, dynamic>;
          var postDescription = postData['description'] ?? 'No Description'; // Default value if null
          var username = postData['username'] ?? 'Unknown'; // Default value if null
          var location = postData['location'] ?? 'Unknown Location'; // Default value if null
          var rating = postData['rating'] ?? 0; // Default value if null
          var comments = postData['comments'] ?? []; // Default empty list if null
          var postOwnerId = postData['userID']; // Fetch post owner ID to check if user can rate it

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(postDescription, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)), // Post title
                SizedBox(height: 8),
                Text('Posted by: $username', style: TextStyle(color: isDarkMode ? Colors.white70 : Colors.black54)),
                SizedBox(height: 8),
                Text("Location: $location", style: TextStyle(color: isDarkMode ? Colors.white70 : Colors.black54)),
                SizedBox(height: 8),
                Text("Rating: $rating ⭐", style: TextStyle(color: isDarkMode ? Colors.white70 : Colors.black54)),
                SizedBox(height: 16),
                // Comment Section
                ElevatedButton(
                  onPressed: showCommentDialog,
                  child: Text("Add Comment"),
                ),
                SizedBox(height: 20),
                Text("Comments:"),
                for (var comment in comments)
                  ListTile(
                    title: Row(
                      children: [
                        Text("${comment['username'] ?? 'Anonymous'}:", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
                      ],
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(comment['comment'] ?? 'No Comment', style: TextStyle(color: isDarkMode ? Colors.white : Colors.grey[700])),
                        if (comment['image'] != null && comment['image'].isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: comment['image'].startsWith("http")
                                ? Image.network(comment['image'])
                                : Image.file(File(comment['image'])),
                          ),
                      ],
                    ),
                  ),
                SizedBox(height: 20),
                // Rating Section (enabled only if the current user is not the post owner)
                if (postOwnerId != currentUserId) ...[
                  Text("Rate this Post", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  Row(
                    children: List.generate(5, (index) {
                      return IconButton(
                        icon: Icon(
                          index < _rating ? Icons.star : Icons.star_border,
                          color: index < _rating ? Colors.yellow : Colors.grey,
                        ),
                        onPressed: () {
                          setState(() {
                            _rating = index + 1.0;
                          });
                          FirebaseFirestore.instance.collection('pins').doc(widget.postId).update({
                            'rating': _rating,
                          });
                        },
                      );
                    }),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      FirebaseFirestore.instance.collection('pins').doc(widget.postId).update({
                        'rating': _rating,
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Rating submitted!')),
                      );
                    },
                    child: Text('Submit Rating'),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}
