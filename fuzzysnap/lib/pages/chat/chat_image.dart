import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

class ChatImagePicker {
  final ImagePicker _imagePicker = ImagePicker();

  /// Kiểm tra quyền truy cập thư viện ảnh
  Future<bool> _requestGalleryPermission() async {
    final PermissionStatus status = await Permission.photos.request();
    if (status.isGranted) {
      return true;
    } else {
      debugPrint("Quyền truy cập thư viện ảnh bị từ chối.");
      return false;
    }
  }

  /// Kiểm tra quyền truy cập camera
  Future<bool> _requestCameraPermission() async {
    final PermissionStatus status = await Permission.camera.request();
    if (status.isGranted) {
      return true;
    } else {
      debugPrint("Quyền truy cập camera bị từ chối.");
      return false;
    }
  }

  /// Nén ảnh để tối ưu hóa dung lượng
  Future<File?> _compressImage(File file) async {
    try {
      final String tempPath = file.path.replaceFirst('.jpg', '_compressed.jpg');
      final File? compressedImage =
          await FlutterImageCompress.compressAndGetFile(
        file.path,
        tempPath,
        quality: 85, // Chất lượng nén (0-100)
        minWidth: 800,
        minHeight: 800,
      );
      if (compressedImage != null) {
        debugPrint("Ảnh đã được nén thành công.");
      }
      return compressedImage;
    } catch (e) {
      debugPrint("Lỗi khi nén ảnh: $e");
      return null;
    }
  }

  /// Chọn ảnh từ thư viện
  Future<File?> pickImageFromGallery() async {
    // Kiểm tra quyền trước khi mở thư viện
    if (!await _requestGalleryPermission()) {
      return null;
    }
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
      );
      if (pickedFile != null) {
        final File file = File(pickedFile.path);
        debugPrint("Đã chọn ảnh từ thư viện: ${file.path}");
        return await _compressImage(file); // Nén ảnh trước khi trả về
      } else {
        debugPrint("Người dùng đã hủy chọn ảnh từ thư viện.");
      }
    } catch (e) {
      debugPrint("Lỗi khi chọn ảnh từ thư viện: $e");
    }
    return null;
  }

  /// Chụp ảnh từ camera
  Future<File?> pickImageFromCamera() async {
    // Kiểm tra quyền trước khi mở camera
    if (!await _requestCameraPermission()) {
      return null;
    }
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: 800,
        maxHeight: 800,
      );
      if (pickedFile != null) {
        final File file = File(pickedFile.path);
        debugPrint("Đã chụp ảnh từ camera: ${file.path}");
        return await _compressImage(file); // Nén ảnh trước khi trả về
      } else {
        debugPrint("Người dùng đã hủy chụp ảnh.");
      }
    } catch (e) {
      debugPrint("Lỗi khi chụp ảnh: $e");
    }
    return null;
  }

  /// Hàm chung để chọn ảnh từ nguồn bất kỳ (camera hoặc thư viện)
  Future<File?> pickImage({required ImageSource source}) async {
    try {
      final bool permissionGranted = source == ImageSource.camera
          ? await _requestCameraPermission()
          : await _requestGalleryPermission();

      if (!permissionGranted) return null;

      final XFile? pickedFile = await _imagePicker.pickImage(
        source: source,
        maxWidth: 800,
        maxHeight: 800,
      );
      if (pickedFile != null) {
        final File file = File(pickedFile.path);
        debugPrint("Đã chọn ảnh: ${file.path}");
        return await _compressImage(file); // Nén ảnh trước khi trả về
      } else {
        debugPrint("Người dùng đã hủy thao tác.");
      }
    } catch (e) {
      debugPrint("Lỗi khi chọn ảnh: $e");
    }
    return null;
  }
}
