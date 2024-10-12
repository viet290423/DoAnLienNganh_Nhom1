import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fuzzysnap/database/firestore.dart';
import 'package:fuzzysnap/widget/my_post.dart';
import 'package:fuzzysnap/widget/search_friend_widget.dart';
import 'package:iconsax/iconsax.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: IconButton(
              icon: const Icon(Iconsax.search_normal_1),
              onPressed: () {
                showSearch(
                  context: context,
                  delegate:
                      FriendSearchDelegate(),
                );
              },
            ),
          )
        ],
        forceMaterialTransparency: true,
        centerTitle: false,
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: const Padding(
          padding: EdgeInsets.only(left: 30),
          child: Text(
            'FUZZYSNAP',
            style: TextStyle(
              // color: Theme.of(context).colorScheme.primary,
              fontSize: 20,
              fontFamily: 'Montserrat',
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ),
      body: StreamBuilder<List<DocumentSnapshot>>(
        stream: database.getAllPostsStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(25),
                child: Text("An error occurred. Please try again later."),
              ),
            );
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(25),
                child: Text("No posts.. Post something!"),
              ),
            );
          }

          final posts = snapshot.data!;

          // return as a list
          return PageView.builder(
            scrollDirection: Axis.vertical,
            itemCount: posts.length,
            itemBuilder: (context, index) {
              final post = posts[index].data() as Map<String, dynamic>;

              String imageUrl = post['ImageUrl'] ?? '';
              String message = post['PostMessage'] ?? 'No message';
              String userEmail = post['UserEmail'] ?? 'Unknown';
              String id = post['PostId'] ?? '';
              Timestamp timestamp = post['TimeStamp'] ?? Timestamp.now();

              return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                stream: getUserStream(userEmail),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const SizedBox.shrink();
                  } else if (snapshot.hasError) {
                    return ListTile(
                      title: Text(message),
                      subtitle: const Text('Error loading username'),
                    );
                  } else if (snapshot.hasData) {
                    if (snapshot.data!.exists) {
                      Map<String, dynamic> userData = snapshot.data!.data()!;
                      String userName = userData['username'] ?? 'Unknown';

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
                        subtitle: const Text('Username not found'),
                      );
                    }
                  } else {
                    return ListTile(
                      title: Text(message),
                      subtitle: const Text('Username not available'),
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
