import 'package:flutter/material.dart';

class FullScreenImageDialog extends StatelessWidget {
  final String imageUrl;

  FullScreenImageDialog({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black.withOpacity(0.9), // Nền đen mờ
      body: Stack(
        children: [
          Center(
            child: InteractiveViewer(
              panEnabled: true, // Cho phép kéo ảnh
              scaleEnabled: true, // Cho phép zoom ảnh
              minScale: 0.5, // Tỉ lệ phóng đại tối thiểu
              maxScale: 4.0, // Tỉ lệ phóng đại tối đa
              child: Hero(
                tag: imageUrl,
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.contain,
                  width: double.infinity,
                  height: double.infinity,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) {
                      return child;
                    } else {
                      return Center(
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                                  (loadingProgress.expectedTotalBytes ?? 1)
                              : null,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      );
                    }
                  },
                ),
              ),
            ),
          ),
          // Dòng chứa các nút
          Positioned(
            top: 40, // Vị trí phía trên màn hình
            left: 0,
            right: 0,
            child: Row(
              children: [
                // Nút Đóng (dấu X) ở góc trái
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context); // Đóng khi nhấn
                  },
                  child: Container(
                    margin:
                        EdgeInsets.only(left: 16), // Thêm khoảng cách bên trái
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ),
                Spacer(), // Đẩy 3 nút còn lại về phía phải
                // Nút Tải xuống
                GestureDetector(
                  onTap: () {
                    print("Download icon tapped");
                  },
                  child: Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.download,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ),
                SizedBox(width: 16), // Khoảng cách giữa các nút
                // Nút Chỉnh sửa
                GestureDetector(
                  onTap: () {
                    print("Edit icon tapped");
                  },
                  child: Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.edit,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ),
                SizedBox(width: 16), // Khoảng cách giữa các nút
                // Nút 3 chấm
                GestureDetector(
                  onTap: () {
                    print("More options icon tapped");
                  },
                  child: Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.more_vert,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ),
                SizedBox(width: 16), // Khoảng cách với lề phải
              ],
            ),
          ),
        ],
      ),
    );
  }
}
