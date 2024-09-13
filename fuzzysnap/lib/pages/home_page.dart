import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fuzzysnap/database/firestore.dart';
import 'package:fuzzysnap/widget/my_post.dart';

class HomePage extends StatelessWidget {
  HomePage({super.key});

  // firestore access
  final FirestoreDatabase database = FirestoreDatabase();

  Stream<DocumentSnapshot<Map<String, dynamic>>> getUserStream(
      String userEmail) {
    return FirebaseFirestore.instance
        .collection('User')
        .doc(userEmail)
        .snapshots();
  }

  void signUserOut() {
    FirebaseAuth.instance.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: signUserOut,
            icon: Icon(Icons.logout),
          )
        ],
        forceMaterialTransparency: true,
        centerTitle: false,
        backgroundColor: Colors.white,
        title: const Padding(
          padding: EdgeInsets.only(left: 30),
          child: Text(
            'FUZZYSNAP',
            style: TextStyle(
              color: Colors.black,
              fontSize: 20,
              fontFamily: 'Montserrat',
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: database.getPostsStream(),
        builder: (context, snapshot) {
          // show loading circle
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          // Handle error case
          if (snapshot.hasError) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(25),
                child: Text("An error occurred. Please try again later."),
              ),
            );
          }

          // Handle empty data case
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(25),
                child: Text("No posts.. Post something!"),
              ),
            );
          }

          // get all posts
          final posts = snapshot.data!.docs;

          // return as a list
          return PageView.builder(
            scrollDirection: Axis.vertical,
            itemCount: posts.length,
            itemBuilder: (context, index) {
              // Get each individual post
              final post = posts[index].data() as Map<String, dynamic>;

              // Check and assign values with default if necessary
              String imageUrl = post['ImageUrl'] ?? '';
              String message = post['PostMessage'] ?? 'No message';
              String userEmail = post['UserEmail'] ?? 'Unknown';
              String id = post['PostId'] ?? '';
              Timestamp timestamp = post['TimeStamp'] ?? Timestamp.now();

              // Truy vấn collection User để lấy username
              return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                stream: getUserStream(userEmail),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const SizedBox.shrink();
                  } else if (snapshot.hasError) {
                    return ListTile(
                      title: Text(message),
                      subtitle: Text('Error loading username'),
                    );
                  } else if (snapshot.hasData) {
                    // Check if the document exists and has data
                    if (snapshot.data!.exists) {
                      Map<String, dynamic> userData = snapshot.data!.data()!;
                      String userName = userData['username'] ?? 'Unknown';

                      // Truyền userName và các thông tin khác vao MyPost
                      return MyPost(
                        title: message,
                        userEmail: userEmail,
                        userName: userName,
                        timestamp: timestamp,
                        imageUrl: imageUrl,
                        postId: id,
                      );
                    } else {
                      return ListTile(
                        title: Text(message),
                        subtitle: Text('Username not found'),
                      );
                    }
                  } else {
                    return ListTile(
                      title: Text(message),
                      subtitle: Text('Username not available'),
                    );
                  }
                },
              );
            },
          );
        },
      ),
    );
  }
}
