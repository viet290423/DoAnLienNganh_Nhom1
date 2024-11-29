import 'package:flutter/material.dart';

class FullScreenImage extends StatelessWidget {
  final String imageUrl;

  FullScreenImage({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Full Screen Image'),
        backgroundColor: Colors.black,
      ),
      body: Center(
        child: GestureDetector(
          onTap: () {
            // Đóng màn hình FullScreen khi người dùng nhấn vào hình ảnh
            Navigator.pop(context);
          },
          child: InteractiveViewer(
            child: Image.network(
              imageUrl,
              fit: BoxFit.contain,
              width: double.infinity,
              height: double.infinity,
            ),
          ),
        ),
      ),
    );
  }
}
