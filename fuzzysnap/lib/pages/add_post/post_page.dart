import 'dart:io';
import 'package:flutter/material.dart';
import 'package:fuzzysnap/database/firestore.dart';
import 'package:fuzzysnap/widget/my_button.dart';
import 'package:fuzzysnap/widget/my_textfield.dart';

class PostPage extends StatefulWidget {
  final File imageFile;
  final double cameraAspectRatio;

  const PostPage(
      {super.key, required this.imageFile, required this.cameraAspectRatio});

  @override
  State<PostPage> createState() => _PostPageState();
}

class _PostPageState extends State<PostPage> {
  final TextEditingController messageController = TextEditingController();
  bool isLoading = false;

  // Hàm post để lưu ảnh và thông điệp vào Firebase
  Future<void> postToFirebase(BuildContext context) async {
    setState(() {
      isLoading = true;
    });

    // Gọi hàm lưu ảnh và thông điệp vào Firebase
    FirestoreDatabase database = FirestoreDatabase();
    await database.addPost(messageController.text, widget.imageFile);

    // Sau khi post xong thì quay lại HomePage
    if (mounted) {
      Navigator.pushNamedAndRemoveUntil(
          context, '/main_page', (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Post Your Image'),
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : SingleChildScrollView(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(50),
                      child: SizedBox(
                        height: MediaQuery.of(context).size.height / 2,
                        child: AspectRatio(
                          aspectRatio: widget.cameraAspectRatio,
                          child: FittedBox(
                            fit: BoxFit.cover,
                            child: SizedBox(
                              width: MediaQuery.of(context).size.width,
                              height: MediaQuery.of(context).size.height,
                              child: Image.file(widget.imageFile),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25),
                    child: MyTextField(
                      controller: messageController,
                      obscureText: false,
                      hintText: "Enter the message",
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  ElevatedButton(
                      onPressed: () {
                        postToFirebase(context);
                      },
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(
                              vertical: 10, horizontal: 40)),
                      child: const Text(
                        "Post",
                        style: TextStyle(color: Colors.white, fontSize: 20),
                      ))
                ],
              ),
            ),
    );
  }
}
